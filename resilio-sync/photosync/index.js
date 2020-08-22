const chokidar = require('chokidar')
const { ExifImage } = require('exif')
const path = require('path')
const {mkdir} = require('fs').promises
const {copyFileSync} = require('fs')

const sourceRootPath = process.env.SOURCE_ROOT_PATH
const destinationRootPath = process.env.DESTINATION_ROOT_PATH

console.log('Starting file sync...')
console.log(`> From source: ${sourceRootPath}`)
console.log(`> To Destination: ${destinationRootPath}`)
console.log('')

chokidar
    .watch(sourceRootPath, { ignoreInitial: true, usePolling: false, interval: 5000 })
    .on('add', async (sourcePath) => {
        console.log(`Detected new file...`)
        console.log(`> Source file ${sourcePath}`)

        new ExifImage({ image: sourcePath}, async (err, data) => {
            if (err) {
                throw err
            } else {

                const rawDate = data.exif["CreateDate"] || data.exif["DateTimeOriginal"]

                const filename = path.basename(sourcePath)
                const [year, month, day] = rawDate.substr(0, 10).split(':')

                const destinationPath = path.join(destinationRootPath, year, month, day, filename)
                await mkdir(path.dirname(destinationPath), { recursive: true})

                copyFileSync(sourcePath, destinationPath)

                console.log(`> Copied to ${destinationPath}`)
            }
        })
    });