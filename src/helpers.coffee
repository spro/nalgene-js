util = require 'util'

# Helpers for lists

exports.flatten = (ls) ->
    flat = []
    for l in ls
        for i in l
            flat.push i
    return flat

exports.randomChoice = (l) -> l[Math.floor Math.random() * l.length]

# Helpers for strings

exports.capitalize = (s) ->
    if s.length
        s[0].toUpperCase() + s.slice(1)
    else
        ''

exports.countIndentation = (s) ->
    i = 0
    for c in s.split('')
        if c == ' '
            i += 1
        else
            break
    s = s.slice(i)
    return [i / 4, s] # We assume a four space indent

exports.isALine = ([i, s]) -> s.length > 0

exports.splitToken = (token) ->
    token.split('|')

exports.fixCapitalization = (s) ->
    s = s.split(/([.!?] )/).map(exports.capitalize).join('')

exports.fixPunctuation = (s) ->
    s = s.replace /\s+/g, ' '
    s = s.replace /\ ([,.!?])/g, '$1'
    s

exports.asSentence = (tokens) -> exports.fixCapitalization exports.fixPunctuation tokens.join(' ')

# Helpers for printing

exports.inspect = (o) ->
    util.inspect o, {colors: true, depth: null}

print = (o...) ->
    if o.length > 1
        if typeof o[0] == 'string'
            console.log "[#{o[0]}]"
            o.shift()
        o_string = o.map(exports.inspect).join('\n    ')
    else
        o_string = exports.inspect o[0]
    console.log '    ' + o_string
