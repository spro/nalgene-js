# Generated automatically by nearley
# http://github.com/Hardmath123/nearley
do ->
  id = (d)->d[0]

  empty = -> []
  single = (d) -> d[0]
  joined = (d) ->
      d[0].concat d[2]
  concat = (d) -> d[0].concat [d[2]]
  
  
  labeled = (label, extras={}) -> (d) ->
      value = d[1]
      o = {}
      o[label] = value
      Object.assign o, extras
      return o
  
  grammar = {
    ParserRules: [
          {"name": "blocks", "symbols": ["block"]},
          {"name": "blocks$ebnf$1", "symbols": ["newline"]},
          {"name": "blocks$ebnf$1", "symbols": ["newline", "blocks$ebnf$1"], "postprocess": (d) -> [d[0]].concat(d[1])},
          {"name": "blocks", "symbols": ["blocks", "blocks$ebnf$1", "block"], "postprocess": joined},
          {"name": "block", "symbols": ["starter", "newline", "lines"], "postprocess": (d) -> Object.assign d[0], {lines: d[2]}},
          {"name": "block", "symbols": ["comment"], "postprocess": (d) -> {comment: d[0]}},
          {"name": "comment$ebnf$1", "symbols": ["space"], "postprocess": id},
          {"name": "comment$ebnf$1", "symbols": [], "postprocess": () -> null},
          {"name": "comment", "symbols": [{"literal":"#"}, "comment$ebnf$1", "string"], "postprocess": (d) -> d[2]},
          {"name": "starter", "symbols": ["phrase_token"], "postprocess": single},
          {"name": "starter", "symbols": ["synonym_token"], "postprocess": single},
          {"name": "starter", "symbols": ["value_token"], "postprocess": single},
          {"name": "phrase_token", "symbols": [{"literal":"%"}, "word"], "postprocess": labeled 'phrase'},
          {"name": "synonym_token", "symbols": [{"literal":"~"}, "word", {"literal":"?"}], "postprocess": labeled 'synonym', {optional: true}},
          {"name": "synonym_token", "symbols": [{"literal":"~"}, "word"], "postprocess": labeled 'synonym'},
          {"name": "value_token", "symbols": [{"literal":"$"}, "word", {"literal":":"}, "joiners"], "postprocess": (d) -> Object.assign {value: d[1]}, d[3]},
          {"name": "value_token", "symbols": [{"literal":"$"}, "word", {"literal":"|"}, "word"], "postprocess": (d) -> Object.assign {value: d[1]}, {formatter: d[3]}},
          {"name": "value_token", "symbols": [{"literal":"$"}, "word"], "postprocess": labeled 'value'},
          {"name": "joiners", "symbols": ["token"], "postprocess": (d) -> {joiner: d[0]}},
          {"name": "joiners", "symbols": ["token", {"literal":":"}, "token"], "postprocess": (d) -> {joiner: d[0], secondary: d[2]}},
          {"name": "joiners", "symbols": ["token", {"literal":";"}, "token"], "postprocess": (d) -> {joiner: d[0], secondary: d[2], oxford: true}},
          {"name": "token", "symbols": ["group"], "postprocess": single},
          {"name": "token", "symbols": ["phrase_token"], "postprocess": single},
          {"name": "token", "symbols": ["synonym_token"], "postprocess": single},
          {"name": "token", "symbols": ["value_token"], "postprocess": single},
          {"name": "token", "symbols": ["word_token"], "postprocess": single},
          {"name": "token", "symbols": ["optional_token"], "postprocess": single},
          {"name": "optional_token", "symbols": ["token", {"literal":"?"}], "postprocess": (d) -> Object.assign d[0], {optional: true}},
          {"name": "word_token", "symbols": ["word"], "postprocess": (d) -> {word: d[0]}},
          {"name": "tokens", "symbols": ["token"]},
          {"name": "tokens", "symbols": ["token", "space", "tokens"], "postprocess": (d) -> [d[0]].concat d[2]},
          {"name": "group", "symbols": [{"literal":"("}, "tokens", {"literal":")"}], "postprocess": (d) -> {group: d[1]}},
          {"name": "lines", "symbols": ["lines", "newline", "line"], "postprocess": concat},
          {"name": "lines", "symbols": ["line"]},
          {"name": "line", "symbols": ["indent", "tokens"], "postprocess": (d) -> d[1]},
          {"name": "newline", "symbols": [{"literal":"\r"}, {"literal":"\n"}]},
          {"name": "newline", "symbols": [{"literal":"\r"}]},
          {"name": "newline", "symbols": [{"literal":"\n"}], "postprocess": empty},
          {"name": "space", "symbols": [{"literal":" "}]},
          {"name": "indent$string$1", "symbols": [{"literal":" "}, {"literal":" "}, {"literal":" "}, {"literal":" "}], "postprocess": (d) -> d.join('')},
          {"name": "indent", "symbols": ["indent$string$1"]},
          {"name": "indent", "symbols": [{"literal":"\t"}]},
          {"name": "string$ebnf$1", "symbols": []},
          {"name": "string$ebnf$1", "symbols": [/[^\n]/, "string$ebnf$1"], "postprocess": (d) -> [d[0]].concat(d[1])},
          {"name": "string", "symbols": ["string$ebnf$1"], "postprocess": (d) -> d[0].join('')},
          {"name": "word$ebnf$1", "symbols": []},
          {"name": "word$ebnf$1", "symbols": ["word_char", "word$ebnf$1"], "postprocess": (d) -> [d[0]].concat(d[1])},
          {"name": "word", "symbols": ["word$ebnf$1"], "postprocess": (d) -> d[0].join('')},
          {"name": "word_char", "symbols": [/[^\s:;$%~?()|]/]},
          {"name": "word_char", "symbols": ["esc_word_char"]},
          {"name": "esc_word_char$string$1", "symbols": [{"literal":"\\"}, {"literal":"$"}], "postprocess": (d) -> d.join('')},
          {"name": "esc_word_char", "symbols": ["esc_word_char$string$1"], "postprocess": -> "$"},
          {"name": "esc_word_char$string$2", "symbols": [{"literal":"\\"}, {"literal":"~"}], "postprocess": (d) -> d.join('')},
          {"name": "esc_word_char", "symbols": ["esc_word_char$string$2"], "postprocess": -> "~"},
          {"name": "esc_word_char$string$3", "symbols": [{"literal":"\\"}, {"literal":"%"}], "postprocess": (d) -> d.join('')},
          {"name": "esc_word_char", "symbols": ["esc_word_char$string$3"], "postprocess": -> "%"},
          {"name": "esc_word_char$string$4", "symbols": [{"literal":"\\"}, {"literal":"|"}], "postprocess": (d) -> d.join('')},
          {"name": "esc_word_char", "symbols": ["esc_word_char$string$4"], "postprocess": -> "|"},
          {"name": "esc_word_char$string$5", "symbols": [{"literal":"\\"}, {"literal":":"}], "postprocess": (d) -> d.join('')},
          {"name": "esc_word_char", "symbols": ["esc_word_char$string$5"], "postprocess": -> ":"},
          {"name": "esc_word_char$string$6", "symbols": [{"literal":"\\"}, {"literal":";"}], "postprocess": (d) -> d.join('')},
          {"name": "esc_word_char", "symbols": ["esc_word_char$string$6"], "postprocess": -> ";"},
          {"name": "esc_word_char$string$7", "symbols": [{"literal":"\\"}, {"literal":"?"}], "postprocess": (d) -> d.join('')},
          {"name": "esc_word_char", "symbols": ["esc_word_char$string$7"], "postprocess": -> "?"},
          {"name": "esc_word_char$string$8", "symbols": [{"literal":"\\"}, {"literal":"("}], "postprocess": (d) -> d.join('')},
          {"name": "esc_word_char", "symbols": ["esc_word_char$string$8"], "postprocess": -> "("},
          {"name": "esc_word_char$string$9", "symbols": [{"literal":"\\"}, {"literal":")"}], "postprocess": (d) -> d.join('')},
          {"name": "esc_word_char", "symbols": ["esc_word_char$string$9"], "postprocess": -> ")"}
      ],
    ParserStart: "blocks"
  }
  if typeof module != 'undefined' && typeof module.exports != 'undefined'
    module.exports = grammar;
  else
    window.grammar = grammar;
