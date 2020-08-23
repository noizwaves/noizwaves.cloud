const chokidar = require('chokidar')
const path = require('path')
const exif = require('exiftool');
const {mkdir} = require('fs').promises
const {copyFileSync} = require('fs')

const sourceRootPath = process.env.SOURCE_ROOT_PATH
const destinationRootPath = process.env.DESTINATION_ROOT_PATH

console.log('Starting file sync...')
console.log(`> From source: ${sourceRootPath}`)
console.log(`> To Destination: ${destinationRootPath}`)
console.log('')

const extractExitDateFunc = (fieldName) => {
    return (sourcePath) => {
        return new Promise(((resolve, reject) => {
            exif.metadata(sourcePath, (err, metadata) => {
                if (err) {
                    reject(err)
                } else {
                    const rawDate = metadata[fieldName]
                    resolve(rawDate.substr(0, 10).split(':'))
                }
            });
        }))
    }
}


const extractJpgDate = extractExitDateFunc('createDate')
const extractPngDate = extractExitDateFunc('dateCreated')
const extractMovDate = extractExitDateFunc('createDate')

chokidar
    .watch(sourceRootPath, { ignoreInitial: true, usePolling: false, interval: 5000 })
    .on('add', async (sourcePath) => {
        console.log(`Detected new file...`)
        console.log(`> Source file ${sourcePath}`)

        let date = null
        switch (path.extname(sourcePath).toLowerCase()) {
            case '.jpg':
            case '.jpeg':
                date = await extractJpgDate(sourcePath)
                break;
            case '.png':
                date = await extractPngDate(sourcePath)
                break;
            case '.mov':
                date = await extractMovDate(sourcePath)
                break;
        }

        if (date === null) {
            console.log('! Unknown file type, skipping')
        }

        const filename = path.basename(sourcePath)
        const [year, month, day] = date

        const destinationPath = path.join(destinationRootPath, year, month, day, filename)
        await mkdir(path.dirname(destinationPath), { recursive: true})

        copyFileSync(sourcePath, destinationPath)

        console.log(`> Copied to ${destinationPath}`)
    })
