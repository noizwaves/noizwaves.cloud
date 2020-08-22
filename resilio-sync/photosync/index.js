const chokidar = require('chokidar')
const path = require('path')
const ExifReader = require('exifreader');
const {mkdir} = require('fs').promises
const {copyFileSync, readFileSync} = require('fs')

const sourceRootPath = process.env.SOURCE_ROOT_PATH
const destinationRootPath = process.env.DESTINATION_ROOT_PATH

console.log('Starting file sync...')
console.log(`> From source: ${sourceRootPath}`)
console.log(`> To Destination: ${destinationRootPath}`)
console.log('')

// Returns [year, month, day] parts
const extractJpgDate = (sourcePath) => {
    const buffer = readFileSync(sourcePath)
    let tags = ExifReader.load(buffer);
    return tags['DateTime'].value[0].substr(0, 10).split(':')
}

// Returns [year, month, day] parts
const extractPngDate = (sourcePath) => {
    const buffer = readFileSync(sourcePath)
    let tags = ExifReader.load(buffer);
    return tags['DateCreated'].value.substr(0, 10).split('-')
}

chokidar
    .watch(sourceRootPath, { ignoreInitial: true, usePolling: false, interval: 5000 })
    .on('add', async (sourcePath) => {
        console.log(`Detected new file...`)
        console.log(`> Source file ${sourcePath}`)

        let date = null
        switch (path.extname(sourcePath).toLowerCase()) {
            case '.jpg':
            case '.jpeg':
                date = extractJpgDate(sourcePath)
                break;
            case '.png':
                date = extractPngDate(sourcePath)
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
    });