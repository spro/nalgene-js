{randomChoice, flatten, splitToken, asSentence} = require './helpers'

# Helpers

# Main generation
# ------------------------------------------------------------------------------

# A sentence is generated from a grammar filename, context, and optional entry key

module.exports = generate = (root, context={}, entry_key='%') ->
    phrases = expandPhrases root.get(entry_key), root

    # Filter expanded phrases to those that can be resolved with the given context
    notInContext = (token) ->
        token.match(/^\$/) and !context[token]?

    numNotInContext = (tokens) ->
        flatten(tokens.map(splitToken))
            .filter(notInContext).length

    inContext = (token) ->
        token.match(/^\$/) and context[token]?

    numInContext = (tokens) ->
        flatten(tokens.map(splitToken))
            .filter(inContext).length

    good_phrases = phrases.filter (tokens) ->
        numNotInContext(tokens) == 0

    # Choose a phrase that uses the most of the context
    good_phrases.sort (a, b) -> numInContext(b) - numInContext(a)
    num_in_best = numInContext(good_phrases[0])
    best_phrases = []
    for phrase in good_phrases
        if numInContext(phrase) == num_in_best
            best_phrases.push phrase
        else
            break
    phrase = randomChoice best_phrases

    return asSentence expandTokens(phrase, root, context)

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
            synonym_tokens = synonyms.randomLeaf().key.split(' ')
            expanded = expanded.concat expandTokens synonym_tokens, root, context

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

