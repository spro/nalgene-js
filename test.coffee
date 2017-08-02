nalgene = require './lib'

grammar_filename = process.argv[2]
if !grammar_filename
    console.error "Usage: test.coffee [grammar filename]"
    process.exit(1)

values = {
    name: 'Test Jones'
    high_scale_phrases: ['very dog like', 'likely to have the attributes of a fish']
    middle_scale_phrases: ['somewhat cat like']
    price: 55
}

formatters =
    dollars: (v) -> '$' + v.toFixed(2)

grammar = nalgene.parse grammar_filename
console.log nalgene.generate grammar, {values, formatters}


console.log nalgene.generate.fromPlainString 'Just testing this hi there $name', {values: {name: 'Jones'}}
