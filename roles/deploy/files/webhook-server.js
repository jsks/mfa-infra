/*
 * Simple HTTP webhook server that downloads the latest release build
 * from GitHub and stores it locally on the production server.
 */

const crypto = require('crypto'),
      fs = require('fs'),
      http = require('http'),
      https = require('https'),
      process = require('process')

const config_file = process.argv.slice(2)[0]
if (!isFile(config_file))
    usage()

const config = JSON.parse(fs.readFileSync(config_file))

function usage() {
    console.error("Usage: ./webhook-server.js <config-file>")
    process.exit(1)
}

function base64(str) {
    return Buffer.from(str).toString('base64')
}

function isFile(file) {
    try {
        return fs.lstatSync(file).isFile()
    } catch (e) {
        return false
    }
}

function sha256_sig(str, secret) {
    return 'sha256=' + crypto.createHmac('sha256', secret).update(str).digest('hex')
}

function get(options) {
    return new Promise((resolve, reject) => {
        const request = https.get(options, response => {
            switch (response.statusCode) {
                case 302:
                    resolve(get(response.headers.location))
                case 200:
                    resolve(response)
                default:
                    reject(`GET ${options.host}/${options.path} failed with ${response.statusCode}`)
            }
        })

        request.on('error', err => reject(err.message))
    })
}

async function get_release(id, file_path) {
    const authkey = base64(`jsks:${config.access_token}`),
          options = {
              hostname: 'api.github.com',
              port: 443,
              path: `/repos/jsks/mfa-twitter/releases/assets/${id}`,
              headers: {
                  'accept': 'application/octet-stream',
                  'authorization': `Basic ${authkey}`,
                  'user-agent': 'build-server/v1.0'
              }
          }

    const response = await get(options),
          stream = fs.createWriteStream(file_path)

    response.pipe(stream)
}


const server = http.createServer((request, response) => {
    if (request.method != "POST" || request.headers['x-github-event'] != "release")
        return

    let body = ""
    request.on('data', chunk => body += chunk)

    request.on('end', () => {
        if (sha256_sig(body, config.webhook_secret) != request.headers['x-hub-signature-256']) {
            console.error('Token mismatch, rejecting request!')
            return
        }

        response.setHeader('Connection', 'close')
        response.writeHead(202)
        response.end()

        try {
            const { action, release: { assets } } = JSON.parse(body)
            if (action == 'published') {
                if (assets) {
                    get_release(assets[0].id, `${config.output_dir}/${assets[0].name}`)
                    console.log(`Fetched ${assets[0].name} from GitHub`)
                } else {
                    console.error('Release published, but missing build asset')
                }
            }
        } catch (err) {
            console.error(err)
        }
    })
})

server.listen(8080)
console.log("Server listening on 8080")
