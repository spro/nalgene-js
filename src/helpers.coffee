util = require 'util'

exports.inspect = (tag, o) ->
    console.log "[#{tag}]", util.inspect o, {colors: true, depth: null}

exports.sortBy = (l, fn) ->
    l.sort (a, b) ->
        fn(b) - fn(a)

exports.flatten = (ls) ->
    flat = []
    for l in ls
        for i in l
            flat.push i
    return flat

exports.randomChoice = (l) ->
    l[Math.floor Math.random() * l.length]

exports.fixPunctuation = (s) ->
    s = s.trim().replace /\s+/g, ' '
    s = s.replace /\ ([,.!?])/g, '$1'
    s = s.trim()
    if s.slice(-1)[0] not in '.!?'
        s += '.'
    s

