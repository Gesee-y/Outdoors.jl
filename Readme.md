---
Title: ReadMe

Author: Talom Laël
...

# Outdoors.jl

[![julia 1.6+](https://img.shields.io/badge/Julia-1.6%2B-purple.svg)](https://julialang.org)

## Quick start

```julia
using Pkg
Pkg.add("Outdoors")
using Outdoors
```
## Intro

For modern GUI application, switching between multiple API(Application Programming Interface) while reducing dependencies is a plus.

Outdoors is made for that purpose.
It's a module to manage the window of the app. It's meant to be an abstraction for different API like [SDL2](https://www.libsdl.org) or [GLFW](https://www.glfw.org) while providing an easy way to add new style (API using the Outdoor interface) and then decouples the program from the API. It uses the [Notifyers.jl](https://github.com/Gesee-y/Notifyers.jl) package, allowing reactiveness for each API.

## Installation 

```julia
julia> ] add Outdoors
```
or for development 

```julia
julia> Pkg.add(url="https://github.com/Gesee-y/Outdoors.jl.git")
```

## Features

   * Abstraction for SDL/...
   * Provide an easy interface to the implement new windows style
   * Events management 
   * A generalized window hierarchy ( a window can be the sub window of another one, evyif they don't use the same API)

## Usage

```julia

using Outdoors

# will call the function if Outdoors encountered an error
Outdoors.connect(NOTIF_ERROR) do msg,err
        error(msg*err)
end

# to know went to exit the event loop
const Close = Ref(false)

# will call this function when all windows will be closed
Outdoors.connect(NOTIF_QUIT_EVENT) do
        Close[] = true
end

# we initialize our Outdoors style 
InitOutdoor(SDLStyle)

# And create our application context
app = ODApp()

win = CreateWindow(app,SDLStyle,"Outdoor Test",640,480)

#the event loop 
while !Close[]
    GetEvents(win)

    # allow asynchronous call
    yield()
end

# we free the resources
QuitWindow(win)
QuitStyle(SDLStyle)
```

## License 

This package is under the MIT license, for more information see [License](https://github.com/Gesee-y/Outdoors.jl/blob/main/LICENSE)

## Contribution

This package is made for that, I would greatly appreciate your contribution to the package.
To do so, just :
   1. Fork the repository
   2. Create a feature branch (`git checkout -b feat/new-style`)
   3. Submit a Pull Request

Contribution can be *performance improvement*, *new windows style*, or *bug fix*

## Bug report 

If you encountered any problem or counter intuitive behavior, you can create an issue at [my GitHub](https://github.com/Gesee-y/Outdoors.jl)
