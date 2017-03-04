parse = require './parse'
{randomChoice, flatten, splitToken, asSentence} = require './helpers'

# Helpers

# Main generation
# ------------------------------------------------------------------------------

# A sentence is generated from a grammar filename, context, and optional entry key

module.exports = generate = (filename, context={}, entry_key='%') ->
    root = parse(filename)
    phrases = expandPhrases root.get(entry_key), root
    good_phrases = filterPhrases phrases, context
    return asSentence expandTokens(good_phrases[0], root, context)

expandPhrases = (phrase, root) ->
    # console.log '[expandPhrases]', phrase.key
    flatten phrase.allLeaves().map (leaf) -> expandPhrase leaf.key, root

# Expand phrase takes a root node and descends into every possible phrasing by
# expanding only phrase (%) nodes. It returns a list of flat phrases (token lists)

expandPhrase = (key, root) ->
    # console.log '[expandPhrase]', key
    expansions = [[]]
    tokens = key.split(' ')

    for token in tokens

        # For sub-phrases we duplicate existing expansions with every possible sub-expansion
        if token.match /^%/
            new_expansions = []
            token = token.split('|')[0]
            for e in expandPhrases root.get(token), root
                for expansion in expansions
                    new_expansions.push expansion.concat e
            expansions = new_expansions

        # Non-phrase tokens are added directly to the end of expansions
        else
            for expansion in expansions
                expansion.push token

    return expansions

# Filter expanded phrases to those that can be resolved with the given context

filterPhrases = (phrases, context) ->
    notInContext = (token) ->
        if token.match /^\$/
            !context[token]?
        else
            false

    phrases.filter (tokens) ->
        f = flatten(tokens.map(splitToken))
        f.filter(notInContext).length == 0

# Expand other tokens with context

expandTokens = (tokens, root, context) ->
    expanded = []
    for token in tokens

        # Variable (value directly from context)
        if token.match /^\$/
            expanded.push context[token]

        # Synonym (randomly chosen)
        else if token.match /^~/
            synonyms = root.get(token)
            expanded.push synonyms.randomLeaf().key

        # Hash (keyed value given what's in context)
        else if token.match /^#/
            [token, given...] = token.split('|')

            sub_phrase = root.get(token)

            if given.length
                for g in given
                    if g.match /^\$/
                        sub_phrase = sub_phrase.get(context[g])
                    else
                        sub_phrase = sub_phrase.get(g)
            sub_tokens = sub_phrase.randomLeaf().key.split(' ')
            expanded = expanded.concat expandTokens sub_tokens, root, context

        # Regular word token
        else
            expanded.push token

    return expanded

