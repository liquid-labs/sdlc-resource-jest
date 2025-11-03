const config = require('./jest.config.js')

config.coverageDirectory = 'coverage'

config.testMatch = [
    // see note in jest.integration.config.js on test matching
    '<rootDir>/**/*.test.{js,jsx,ts,tsx}'
]

module.exports = config