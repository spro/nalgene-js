helpers = require './helpers'
Tree = require './tree'

# Parse an indented string as a Tree

module.exports = parse = (grammar) ->
    lines = grammar.split('\n')
        .map(helpers.countIndentation)
        .filter(helpers.isALine)

    root = new Tree(null, '^', -1)
    tree = root

    current_index = -1

    for [i, s] in lines
        # At the same level - add a sibling
        if i == current_index
            tree = tree.addSibling(s, i)
        # At deeper level - add a child
        else if i > current_index
            tree = tree.addChild(s, i)
        # At a shallower level - climb back to the parent level and add a sibling
        else if i < current_index
            for ii in [0...(i - tree.level)]
                tree = tree.parent
            tree = tree.addSibling(s, i)
        current_index = i

    return root
