fs = require 'fs'
nalgene = require './src'
argv = require('minimist')(process.argv.slice(2))

filename = process.argv[2]
if !filename?
    console.log "Usage: coffee example.coffee [file.nlg] (--key=value...)"
    process.exit()

# Parse the gramamr file

grammar = nalgene.parse fs.readFileSync filename, 'utf8'

# Build context from arguments

context = {}
for k, v of argv
    context['$' + k] =  v

# Generate

console.log nalgene.generate grammar, context
