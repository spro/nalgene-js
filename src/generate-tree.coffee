module.exports = generate = (grammar, context, entry_key='%') ->
    console.log 'generate with', context, 'from', entry_key
    
    console.log grammar.get(entry_key).toString()

    return ''
