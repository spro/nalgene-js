@preprocessor coffee

@{%
    empty = -> []
    single = (d) -> d[0]
    joined = (d) ->
        d[0].concat d[2]
    concat = (d) -> d[0].concat [d[2]]
%}

blocks ->
    block
    | blocks newline:+ block {% joined %}

block ->
    starter newline lines {% (d) -> Object.assign d[0], {lines: d[2]} %}
    | comment {% (d) -> {comment: d[0]} %}

comment ->
    "#" space:? string {% (d) -> d[2] %}

starter ->
    phrase_token {% single %}
    | synonym_token {% single %}
    | value_token {% single %}

# Tokens

@{%
    labeled = (label, extras={}) -> (d) ->
        value = d[1]
        o = {}
        o[label] = value
        Object.assign o, extras
        return o
%}

phrase_token ->
    "%" word {% labeled 'phrase' %}

synonym_token ->
    "~" word "?" {% labeled 'synonym', {optional: true} %}
    | "~" word {% labeled 'synonym' %}

value_token ->
    "$" word "*%" word ":" joiners {% (d) -> Object.assign {value: d[1], expander: d[3]}, d[5] %}
    | "$" word ":" joiners {% (d) -> Object.assign {value: d[1]}, d[3] %}
    | "$" word "|" word {% (d) -> Object.assign {value: d[1]}, {formatter: d[3]} %}
    | "$" word "*%" word {% (d) -> Object.assign {value: d[1]}, {expander: d[3]} %}
    | "$" word {% labeled 'value' %}

joiners ->
    token {% (d) -> {joiner: d[0]} %}
    | token ":" token {% (d) -> {joiner: d[0], secondary: d[2]} %}
    | token ";" token {% (d) -> {joiner: d[0], secondary: d[2], oxford: true} %}

token ->
    group {% single %}
    | phrase_token {% single %}
    | synonym_token {% single %}
    | value_token {% single %}
    | word_token {% single %}
    | optional_token {% single %}

optional_token ->
    token "?" {% (d) -> Object.assign d[0], {optional: true} %}

word_token -> word {% (d) -> {word: d[0]} %}

tokens ->
    token
    | token space tokens {% (d) -> [d[0]].concat d[2] %}

group ->
    "(" tokens ")" {% (d) -> {group: d[1]} %}

# Lines of tokens

lines ->
    lines newline line {% concat %}
    | line

line ->
    indent tokens {% (d) -> d[1] %}

# General strings

newline -> "\r" "\n" | "\r" | "\n" {% empty %}

space -> " "

indent -> "    " | "\t"

string ->
    [^\n]:* {% (d) -> d[0].join('') %}

word ->
    word_char:* {% (d) -> d[0].join('') %}

word_char ->
    [^\s:;$%*~?()|]
    | esc_word_char

esc_word_char ->
    "\\$" {% -> "$" %}
    | "\\~" {% -> "~" %}
    | "\\%" {% -> "%" %}
    | "\\*" {% -> "*" %}
    | "\\|" {% -> "|" %}
    | "\\:" {% -> ":" %}
    | "\\;" {% -> ";" %}
    | "\\?" {% -> "?" %}
    | "\\(" {% -> "(" %}
    | "\\)" {% -> ")" %}

