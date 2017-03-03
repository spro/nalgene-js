module.exports = class Tree
    constructor: (@parent, @key, @level, @children=[]) ->
        @children_by_key = {}

    addChild: (child, level) ->
        child = new Tree @, child, level
        @children.push child
        @children_by_key[child.key] = child
        return child

    addSibling: (sibling, level) ->
        return @parent.addChild(sibling, level)

    toString: (indent=0) ->
        s = '\n'
        for ii in [0...indent*4]
            s += ' '
        s += '( ' + @key
        if @children?.length
            s += ' ( '
            for child in @children
                s += child.toString(indent+1)
            s += ' )'
        s += ' )'
        return s

    get: (key) ->
        # console.log '[Tree.get]', key
        if typeof key == 'number'
            return @children[key]
        else if typeof key == 'string'
            return @children_by_key[key]

