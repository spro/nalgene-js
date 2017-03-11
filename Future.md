# Future

### Context as tree

From some transformation of a parse tree

```
> pls turn on the office light and also what time is it?

parsed =
    %sequence
        %setState $device="office light" $state="on"
        %getTime

response =
    %sequence
        %didSetState $device="office light" $state="on"
        %didGetTime $time="8:53pm"

generate(grammar, response)

> I turned the office light on. The time is currently 8:53pm.
```

### Ranges

Or more generally, hash keys that run some function.

```
#reports
    Goodness
        > 90
            You are great.
        > 66
            You are good.
        >= 33
            You are ok.
        > 0
            You are terrible.
        == 0
            You are literally the worst.

#reports|$scale|$score
```

### Descending with arrays

```
$scale=['Goodness', 57]
#reports|$scale
```

### Loops & joining

```
$scales=[['Goodness', 57], ['Smartness', 5]]

(#reports|$scale for $scale in $scales).join(~also)

$scales:#reports|$,~also

[$scales, $scale: #reports|$scale](~also)
[$scales: #reports|$](~also)

> You are ok. Furthermore, you are very dumb.
```

### Comparing variables

```
%kill_statements $highest_ratio="Zerg" $highest_total="Zerg"
> Zerg had the highest kill ratio, and the most kills overall.

%kill_statements $highest_ratio="Zerg" $highest_total="Protoss"
> Zerg had the highest kill ratio. However, Protoss had the most kills overall.
```

```
%kill_statements
    $highest_ratio == $highest_total
        $highest_ratio had the highest kill ratio, and the most kills overall. 
    default
        $highest_ratio had the highest kill ratio. ~however $highest_total had the most kills overall. 
```

