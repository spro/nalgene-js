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

# Turn a CSV with lines [category, sub_category, sub_category, ...] into a tree
# 
# For example, with this CSV:
#
#     category,high,low
#     curious,you are curious,you are not curious
#     brave,you are brave,you are not brave
#
# Create this tree:
#
#     curious
#         high
#             you are curious
#         low
#             you are not curious
#     brave
#         high
#             you are brave
#         low
#             you are not brave

parse.fromCSV = (csv, key) ->
    lines = csv.trim().split('\n').map((l) -> l.trim().split(','))
    sub_categories = lines.shift().slice(1)
    tree = new Tree null, key
    for line in lines
        p = tree.addChild line[0]
        for sub_i in [0...sub_categories.length]
            sub_category = sub_categories[sub_i]
            p.addChild(sub_category).addChild line[sub_i+1]
    return tree

parse.fromObject = (key, object) ->
    tree = new Tree null, key
    if Array.isArray object
        for v in object
            tree.addChild v
    else if typeof object == 'object'
        for k, v of object
            tree.addChild Tree.fromObject tree, k, v
    else
        tree.addChild object
    return tree
