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

The basic idea of Nalgene is to generate sentences based on a *grammar* and a set of *variables*. The grammar defines a recursive tree of *phrases* that can be generated given some variables, and the generator will expand those phrases into a sentence that makes the most use of the variables.

```
> nalgene examples/iot.nlg --device "office light" --state "on"
The office light is now on.

> nalgene examples/iot.nlg --asset "bitcoin" --price "$1155.33"
Bitcoin is at $1155.33.

> nalgene examples/order.nlg --food "a burger" --location "Tokyo"
You're looking for a burger in Tokyo?

> nalgene examples/order.nlg --food "a burger"
You're looking for a burger?

> nalgene examples/order.nlg
You're looking for some food?
```

## Syntax

### Phrases

Phrases represent multiple sets of tokens, where each set of tokens is a different "possibility", and each token is either a regular word or a special token. A phrase may have many possibilities for different ways to say the same sentence with different amounts of context (from variables, below).

```
%
    %sayHi
    %sayBye

%sayHi
    hello there
    hi

%sayBye
    %formalBye
    %informalBye

%formalBye
    farewell

%informalBye
    bye
    cya
```

When generating you supply an "entry phrase" to expand from, which is `%` by default. In this example, expanding from `%` would start a random walk down all the possibilities, expanding each phrase token it encounters, to generate one of "hello there", "hi", "farewell", "bye", or "cya". Generating from the specific node `%informalBye` would return only "bye" or "cya".

### Variables

Variables are user-supplied values that also influence phrase selection.

If a phrase possibility has variables, it will only be used if all of the variables are available in the context. During generation phrases are ranked by the number of variables that match, to generate a sentence that uses the most context.

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
