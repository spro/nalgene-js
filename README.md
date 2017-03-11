# nalgene-js

## Installation

As a local Node module:

```
npm install nalgene
```

Or to use the `nalgene` command line tool:

```
npm install -g nalgene
```

## What is this?

The basic idea of Nalgene is to define a language as a tree of templates, and then given some variables, expand that tree into a sentence. Nalgene will always try to expand to the sentence that satisfies the most variables.

For example, with this simple grammar:

```
%confirmFoodSearch
    You're looking for $food in $location ?
    You're looking for some food in $location ?
    You're looking for $food ?
    You're looking for some food ?
```

Nalgene will generate the output that satisfies the most variables from the context:

```
%confirmFoodSearch $food="a burger" $location="Tokyo"
> You're looking for a burger in Tokyo?

%confirmFoodSearch $food="a burger"
> You're looking for a burger?

%confirmFoodSearch
> You're looking for some food?
```

## Examples

`examples/iot.nlg` defines some responses for a conversational IoT bot:

```
> nalgene examples/iot.nlg --device "office light" --state "on"
The office light is now on.

> nalgene examples/iot.nlg --asset "bitcoin" --price "$1155.33"
Bitcoin is at $1155.33.
```

## Usage

*TODO*: Expand

```coffeescript
nalgene = require 'nalgene'

grammar = nalgene.parse '...'
grammar.addChild nalgene.parse.fromCSV '...'
grammar.addChild nalgene.parse.fromObject {...}
nalgene.generate grammar, {...}
```
