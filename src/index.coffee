nearley = require 'nearley'
fs = require 'fs'
parser_grammar = require './grammar'
{inspect, sortBy, flatten, randomChoice, fixPunctuation} = require './helpers'

# Parse and index blocks (phrase and synonym sections)
# ------------------------------------------------------------------------------

exports.parse = parse = (grammar_string) ->
    if grammar_string.endsWith '.nlg'
        grammar_string = fs.readFileSync(grammar_string, 'utf8')
    grammar_string = grammar_string.trim()

    parser = new (nearley.Parser)(parser_grammar.ParserRules, parser_grammar.ParserStart)
    parser.feed grammar_string
    parsed = parser.results[0]
    # inspect 'parsed', parsed

    grammar =
        phrases: {}
        synonyms: {}

    parsed.forEach (block) ->
        # inspect 'block', block
        if block.phrase
            grammar.phrases[block.phrase] = block
        else if block.phrase == ''
            grammar.phrases.root = block
        else if block.synonym
            grammar.synonyms[block.synonym] = block

    for phrase_key, phrases of grammar.phrases
        phrases.lines.forEach (phrase, pi) ->
            phrase.dependencies = getPhraseDependencies phrase, grammar

    return grammar

# Attach chain of dependencies to phrases
# ------------------------------------------------------------------------------
# In order to efficiently support phrase selection (see next) each phrase needs
# a "chain of dependencies" which specifies which values are required to expand
# this phrase.

getPhraseDependencies = (phrase, grammar) ->
    phrase_values = phrase
        .filter (token) -> token.value?
        .map (token) -> token.value
    phrase_phrases = phrase
        .filter (token) -> token.phrase?
        .map (token) -> token.phrase
    sub_dependencies = flatten flatten phrase_phrases.map (phrase_key) ->
        grammar.phrases[phrase_key].lines.map (phrase, pi) ->
            getPhraseDependencies phrase, grammar

    return phrase_values.concat sub_dependencies

# Choosing a phrase given known values
# ------------------------------------------------------------------------------
# Phrases are chosen based on how many values are satisfied by the values object
# - ideally there is a one to one correlation. A phrase with values that are not
# in the values object will not be chosen, but it is acceptable to have values in
# the values object that are not used in the phrase (with the consideration that
# they are likely used in another phrase). The best phrase is considered the
# one with the most matching values, or a random selection if there are
# several good options.
#
# In the case that a phrase expands into further sub-phrases, those phrases have
# to be checked to verify the parent's validity. This might be done by pre-
# attaching a chain of dependencies right after parsing.

bestChoice = (phrases, values) ->
    available_values = Object.keys values

    # Filter out unusable phrases (those with values not provided by object)
    filtered_phrases = phrases.filter (phrase) ->
        for dependency in phrase.dependencies
            if dependency not in available_values
                return false
        return true

    # Select best phrases (those with highest number of available values)
    countDependencies = (phrase) ->
        return phrase.dependencies.length
    value_counts = filtered_phrases.map countDependencies
    best_phrases = sortBy filtered_phrases, countDependencies
    best_count = countDependencies best_phrases[0]
    best_phrases = best_phrases.filter (phrase) ->
        countDependencies(phrase) == best_count

    # Choose one of best phrases
    randomChoice best_phrases

# Expanding phrases into strings
# ------------------------------------------------------------------------------

expandToken = (token, grammar, context) ->
    # inspect 'expandToken', token
    expanded = []

    # Expand a word (nothing else to do here)
    if word_token = token.word
        expanded.push word_token

    # Expand a group (an array of tokens)
    else if group_token = token.group
        group_expanded = token.group.map (token) ->
            expandToken token, grammar, context
        expanded.push group_expanded.join ' '

    # Expand a phrase
    else if phrase_token = token.phrase
        phrase = grammar.phrases[phrase_token]
        phrase_expanded = expandPhrase phrase, grammar, context
        expanded.push phrase_expanded

    # Expand a synonym (usually simple random choice)
    else if synonym_token = token.synonym
        synonym = grammar.synonyms[synonym_token]
        expanded.push expandSynonym synonym, grammar, context

    # Expand a value, possibly an array with joiners, possibly formatted
    else if value_token = token.value
        value = context.values[value_token]

        if expander = token.expander
            tokenExpander = (item) ->
                # inspect 'item', item
                item_context = Object.assign {}, context, {values: item}
                expandToken {phrase: expander}, grammar, item_context
            if Array.isArray value
                value = value.map tokenExpander
            else
                value = tokenExpander value

        if Array.isArray(value) and joiner = token.joiner

            if value.length == 1
                expanded.push value[0]
                return expanded

            # Up to second to last item with regular joiner
            for item in value.slice(0, -2)
                expanded.push item
                expanded.push expandToken joiner, grammar, context

            # Second to last item, last joiner
            if secondary = token.secondary
                expanded.push value.slice(-2)[0]
                if token.oxford
                    expanded.push expandToken joiner, grammar, context
                expanded.push expandToken secondary, grammar, context

            else
                expanded.push value.slice(-2)[0]
                expanded.push expandToken joiner, grammar, context

            # Last item
            expanded.push value.slice(-1)[0]

        else if formatter = token.formatter
            formatted = context.formatters[formatter](value)
            expanded.push formatted

        else
            expanded.push value

    return expanded

expandPhrase = (phrase, grammar, context) ->
    expanded = []
    line = bestChoice phrase.lines, context.values
    for token in line
        expanded = expanded.concat expandToken token, grammar, context
    return expanded.join ' '

# TODO: Should it be required that synonyms do not contain values?
expandSynonym = (synonym, grammar, context) ->
    expanded = []
    line = randomChoice synonym.lines
    for token in line
        expanded = expanded.concat expandToken token, grammar, context
    return expanded.join ' '

exports.generate = generate = (grammar, context, root_node='root') ->
    fixPunctuation expandPhrase grammar.phrases[root_node], grammar, context

exports.generate.fromPlainString = (grammar_string, context) ->
    grammar_string = '%\n\t' + grammar_string
    grammar = parse grammar_string
    generate grammar, context

