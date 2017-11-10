fs = require 'fs'
minimist = require 'minimist'
{randomChoice, flatten, splitToken, asSentence} = require './helpers'
parse = require './parse'
generate = require './generate'

argv = minimist(process.argv.slice(2))

filename = process.argv[2]
if !filename?
    console.log "Usage: nalgene [file.nlg] (--key=value...)"
    process.exit()

# Parse the gramamr file
grammar = parse fs.readFileSync filename, 'utf8'

# Build context from arguments
context = {}
for k, v of argv
    context['$' + k] =  v

# Generate
console.log generate grammar, context
