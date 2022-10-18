# qb-spawn
Spawn Selector for QR-Core Framework

## Dependencies
- [qr-core](https://github.com/QRCore-RedM-Re/qr-core)
- [qr-appearance](https://github.com/QRCore-RedM-Re/qr-appearance) 
- [qr-clothes](https://github.com/QRCore-RedM-Re/qr-clothes)

## Screenshots
![Spawn selector](https://i.imgur.com/NUyuI5y.jpeg)

## Features
- Ability to select spawn after selecting the character

## Installation
### Manual
- Download the script and put it in the `[qr]` directory.
- Add the following code to your server.cfg/resouces.cfg
```
ensure qr-core
ensure qr-spawn
ensure qr-appearance
ensure qr-clothes
```

## Configuration
An example to add spawn option
```
QR.Spawns = {
    ["spawn1"] = { -- Needs to be unique
        coords = vector4(1.1, -1.1, 1.1, 180.0), -- Coords player will be spawned
        location = "spawn1", -- Needs to be unique
        label = "Spawn 1 Name", -- This is the label which will show up in selection menu.
    },
    ["spawn2"] = { -- Needs to be unique
        coords = vector4(1.1, -1.1, 1.1, 180.0), -- Coords player will be spawned
        location = "spawn2", -- Needs to be unique
        label = "Spawn 2 Name", -- This is the label which will show up in selection menu.
    },
}
```
