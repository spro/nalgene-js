fs = require 'fs'
minimist = require 'minimist'
{randomChoice, flatten, splitToken, asSentence} = require './helpers'
parse = require './parse'

VERBOSE = true

# Main generation
# ------------------------------------------------------------------------------

# A sentence is generated from a grammar filename, context, and optional entry key

group = (list, group_by=2) ->
    grouped = []
    for a in [0...Math.floor(list.length / group_by)]
        grouped.push list.slice(a * group_by, (a + 1) * group_by)
    return grouped

listKeys = (list) ->
    (l[0] for l in list)

listValues = (list) ->
    (l[1] for l in list)

bestMatch = (child_keys, context) ->
    for child_key in child_keys
        context_keys = listKeys group context
        score = scoreKey child_key, context_keys
        if score == 0
            return [child_key, listValues group context]
    return [null, null]

scoreKey = (child_key, context_keys) ->
    if VERBOSE
        console.log '[scoreKey]', child_key, context_keys
    child_tokens = child_key.split(' ')
    child_phrases = child_tokens.filter (t) -> t[0] in ['%', '$']
    while context_keys.length
        cc = context_keys.shift()
        ci = child_phrases.indexOf cc
        if ci == -1
            return -1
        else
            child_phrases.splice(ci, 1)
    return child_phrases.length # Number of unfulfilled phrases

contextAsString = (l) ->
    if typeof l == 'string'
        l
    else
        group(l).map((g) -> g.map(contextAsString).join(': ')).join(', ')

module.exports = generate = (root, entry_key='%' ,context={}, options={}) ->
    if VERBOSE
        console.log '\n[generate]', 'entry =', entry_key, 'context =', context
    entry = root.get(entry_key)
    if !entry?
        throw new Error 'No such phrase on root: ' + entry_key

    # Find best match of phrase from children of entry
    child_keys = (child.key for child in entry.children)
    [best_match, contexts] = bestMatch(child_keys, context)
    if not best_match?
        throw new Error "No best match for #{entry_key} with context #{contextAsString context}"
        process.exit(0)

    # Expand sub-tokens of best match
    expanded = []
    expandable = best_match.split(' ').filter (t) -> t[0] in ['%', '$']

    for token in best_match.split(' ')
        i = expandable.indexOf(token)

        if i > -1 # Expandable
            expandable[i] = 'EXPANDED' # Replace so it doesn't match later
            sub_context = contexts[i]
            if token[0] == '%' # Expand sub phrase
                expanded.push generate root, token, sub_context, options
            else # Variable 
                expanded.push sub_context
        else
            if token[0] == '~' # Synonym
                if token.match /\?$/
                    if Math.random() < 0.5
                        continue
                    else
                        token = token.slice(0, -1)
                synonym = root.get(token)
                expanded.push synonym.randomLeaf().key
            else # Regular word
                expanded.push token

    return expanded

# Expand other tokens with context

expandTokens = (tokens, root, context) ->
    if VERBOSE
        console.log '[expandTokens]', tokens
    expanded = []
    chosen_synonyms = {}

    for token in tokens

        # Variable (value directly from context)
        if token.match /^\$/
            expanded.push context[token]

        # Synonym (randomly chosen)
        else if token.match /^~/
            if token.match /\?$/
                if Math.random() < 0.5
                    continue
                else
                    token = token.slice(0, -1)
            synonym = root.get(token)
            if !synonym
                throw new Error 'No such synonym on root: ' + token

            pruned_synonym = synonym.prune(chosen_synonyms[token])

            # Reset chosen list if empty
            if pruned_synonym.children.length == 0
                pruned_synonym = synonym
                delete chosen_synonyms[token]

            chosen_synonym = pruned_synonym.randomLeaf().key

            # Add chosen to chosen list
            chosen_synonyms[token] ||= []
            chosen_synonyms[token].push chosen_synonym

            synonym_tokens = chosen_synonym.split(' ')
            expanded = expanded.concat expandTokens synonym_tokens, root, context

        # Hash (keyed value given what's in context)
        else if token.match /^#/
            [token, given...] = token.split('|')

            sub_phrase = root.get(token)
            if !sub_phrase?
                throw new Error 'No such hash on root: ' + token

            if !given.length
                throw new Error 'No values given for hash: ' + token

            for g in given
                if g.match /^\$/
                    sub_phrase = sub_phrase.get(context[g])
                else
                    sub_phrase = sub_phrase.get(g)
                if !sub_phrase?
                    throw new Error 'No such value on hash: ' +
                        token + '|' + given.map((g) -> context[g]).join('|')

            sub_tokens = sub_phrase.randomLeaf().key.split(' ')
            expanded = expanded.concat expandTokens sub_tokens, root, context

        # Regular word token
        else
            expanded.push token

    return expanded

module.exports.fromPlainString = (string, context) ->
    root = parse.fromObject {'%': string}
    generate root, context

# Run as a script
if require.main == module
    argv = minimist(process.argv.slice(2))
    parse = require './parse'

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

