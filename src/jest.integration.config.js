const config = require('./jest.config.js')

config.coverageDirectory = 'coverage-integration'

config.testMatch = [
    // Last I looked, there were a lot of places saying you do 'micromatch' globing and something like:
    // '**/+(*.)+integration-test.?([mc])[jt]s?(x)' but that doesn't seem to work.
    '<rootDir>/**/*.integration-test.{js,jsx,ts,tsx}'
]

module.exports = config