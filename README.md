## Items
```
    ['pickaxe'] = {
        label = 'Pickaxe',
        weight = 1000,
        stack = false,
        decay = true,
    },
    ['ore_iron'] = {
        label = 'Iron Ore',
        weight = 100,
    },
    ['ore_copper'] = {
        label = 'Copper Ore',
        weight = 100,
    },
    ['ore_silver'] = {
        label = 'Silver Ore',
        weight = 100,
    },
    ['ore_gold'] = {
        label = 'Gold Ore',
        weight = 100,
    },
    ['ore_platinum'] = {
        label = 'Platinum Ore',
        weight = 100,
    },
    ['ore_diamond'] = {
        label = 'Diamond Ore',
        weight = 100,
    },
```

## Shop Items
**Important: every shop system should set metadata durability to 100 to force durability initialization**
```
    { name = 'pickaxe', price = 100, metadata = { durability = 100 } },
```