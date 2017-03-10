# nalgene-js

## Installation

```
npm install nalgene
```

## Running examples

`examples/iot.nlg` defines some post-action responses for a conversational IoT bot:

```
> nalgene examples/iot.nlg --device "office light" --state "on"
The office light is now on.

> nalgene examples/iot.nlg --asset "bitcoin" --price "$1155.33"
Bitcoin is at $1155.33.
```

## Usage

```coffeescript
nalgene = require 'nalgene'

grammar = nalgene.parse '...'
grammar.addChild nalgene.parse.fromCSV '...'
grammar.addChild nalgene.parse.fromObject {...}
nalgene.generate grammar, {...}
```
