# nalgene

Nalgene is a natural language generation language.

## Overview

Nalgene is used to generate text from an object of values. Generation requires two things: a grammar and a phrase tree. The grammar defines how phrases join together.

Here's a very simple grammar that demonstrates the three main features of Nalgene &mdash; `%phrases`, `~synonyms`, and `$values`, as well as `optional?` tokens:

```nlg
%greeting
    ~hello $name

~hello
    hello
    hi
    hey there?
```

Given values `{name: "Fred"}` this grammar might expand to:

* "hello Fred"
* "hey Fred"
* "hey there Fred"

## Repetition

With an array of values to expand, e.g. a `%greeting` with `$names = ["Joe", "Fred", "Sam"]`, with expected output "hello Joe and Fred and Sam", use the `$value:joiner` syntax:

```
%greeting
    hello $names:and
```

If your joiner is more than two words, wrap it in parentheses like so:

```
%greeting
    hello $names:(and also)
```

If you want a different joiner for the last word, as is common in English (commas until an ending "and"), use the secondary joiner syntax. This will output "hello Joe, Fred and Sam".

```
%greeting
    hello $names:,:and
```

To keep the first joiner between the last two values, e.g. to implement an Oxford comma ("hello Joe, Fred, and Sam"), replace the second `:` with `;`.

```
%greeting
    hello $names:,;and
```

An alternative to the above would be `$names:,:(, and)` but that creates an awkward situation if there are only two values: "hello Joe, and Sam".

