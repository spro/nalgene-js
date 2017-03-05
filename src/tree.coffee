{randomChoice} = require './helpers'

module.exports = class Tree
    constructor: (@parent, @key, @level, @children=[]) ->
        @children_by_key = {}

    addChild: (child, level) ->
        if !child.key?
            child = new Tree @, child, level
        else
            child.parent = @
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
        return @children_by_key[key]

    randomChild: ->
        randomChoice @children

    randomLeaf: ->
        leaf = @randomChild()
        if leaf.isLeaf()
            return leaf
        else
            return leaf.randomLeaf()

    isLeaf: ->
        @children.length == 0

    allLeaves: ->
        all_leaves = []
        for child in @children
            if child.isLeaf()
                all_leaves.push child
            else
                all_leaves = all_leaves.concat child.allLeaves()
        return all_leaves

