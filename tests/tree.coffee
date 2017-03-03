tape = require 'tape'
Tree = require '../tree'

tape 'Can descend down a tree with .get', (t) ->
    root = new Tree null, 'root'
    test1 = root.addChild 'test1'
    test2 = root.addChild 'test2'
    test3 = test2.addChild 'test3'
    t.ok root.get('test2').get('test3').key == 'test3'
    t.end()
