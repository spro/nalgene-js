// Generated by CoffeeScript 1.12.4
var Tree, helpers, parse;

helpers = require('./helpers');

Tree = require('./tree');

module.exports = parse = function(grammar) {
  var current_index, i, ii, j, len, lines, m, ref, ref1, root, s, tree;
  lines = grammar.split('\n').map(helpers.countIndentation).filter(helpers.isALine);
  root = new Tree(null, '^', -1);
  tree = root;
  current_index = -1;
  for (j = 0, len = lines.length; j < len; j++) {
    ref = lines[j], i = ref[0], s = ref[1];
    if (i === current_index) {
      tree = tree.addSibling(s, i);
    } else if (i > current_index) {
      tree = tree.addChild(s, i);
    } else if (i < current_index) {
      for (ii = m = 0, ref1 = i - tree.level; 0 <= ref1 ? m < ref1 : m > ref1; ii = 0 <= ref1 ? ++m : --m) {
        tree = tree.parent;
      }
      tree = tree.addSibling(s, i);
    }
    current_index = i;
  }
  return root;
};

parse.fromCSV = function(csv, key) {
  var j, len, line, lines, m, p, ref, sub_categories, sub_category, sub_i, tree;
  lines = csv.trim().split('\n').map(function(l) {
    return l.trim().split(',');
  });
  sub_categories = lines.shift().slice(1);
  tree = new Tree(null, key);
  for (j = 0, len = lines.length; j < len; j++) {
    line = lines[j];
    p = tree.addChild(line[0]);
    for (sub_i = m = 0, ref = sub_categories.length; 0 <= ref ? m < ref : m > ref; sub_i = 0 <= ref ? ++m : --m) {
      sub_category = sub_categories[sub_i];
      p.addChild(sub_category).addChild(line[sub_i + 1]);
    }
  }
  return tree;
};

parse.fromObject = function(object, key) {
  var j, k, len, tree, v;
  tree = new Tree(null, key);
  if (Array.isArray(object)) {
    for (j = 0, len = object.length; j < len; j++) {
      v = object[j];
      tree.addChild(v);
    }
  } else if (typeof object === 'object') {
    for (k in object) {
      v = object[k];
      tree.addChild(parse.fromObject(v, k));
    }
  } else {
    tree.addChild(object);
  }
  return tree;
};