---
Title: ReadMe

Author: Talom Laël
...

# Outdoors.jl

[![License](https://img.shields.io/badge/License-Apache_2.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)
[![julia 1.6+](https://img.shields.io/badge/Julia-1.6%2B-purple.svg)](https://julialang.org)

## Quick start

```julia
using Pkg
Pkg.add("Outdoors")
using Outdoors
```
## Intro

In modern GUI application, The facility to switch between multiple  windowing APIs(Application Programming Interface) while reducing dependencies to a specific one is a plus.

Outdoors is made for that purpose.
It's a module that manage window of an app. It's meant to be an abstraction for different API like [SDL2](https://www.libsdl.org) or [GLFW](https://www.glfw.org) while providing an easy way to add new style (API using the Outdoor interface) and then decouple the program from the API. It uses the [Notifyers.jl](https://github.com/Gesee-y/Notifyers.jl) package, allowing reactiveness for each API.

## Installation 

```julia
julia> ] add Outdoors
```
or for development 

```julia
julia> Pkg.add(url="https://github.com/Gesee-y/Outdoors.jl.git")
```

## Features

   * Abstraction for SDL2/GLFW/...
   * Provide an easy-to-use interface to implement new window style
   * Events driven management
   * A generalized window hierarchy ( a window can be the sub window of another one, even if they don't use the same API)

## Usage

```julia

using Outdoors

# will call the function if Outdoors encountered an error
Outdoors.connect(NOTIF_ERROR) do msg,err
        error(msg*err)
end

# to know when to exit the event loop
const Close = Ref(false)

# will call this function when all windows will be closed
Outdoors.connect(NOTIF_QUIT_EVENT) do
        Close[] = true
end

# we initialize our Outdoors style 
InitOutdoor(SDLStyle)

# And create our application context
app = ODApp()

win = CreateWindow(app, SDLStyle, "Outdoor Test", 640, 480)

# Event loop 
while !Close[]
    GetEvents(win)

    # allow asynchronous call
    yield()
end

# Clean up resources
QuitWindow(win)
QuitStyle(SDLStyle)
```

## License 

This package is under the Apache 2.0 license, for more information see [License](https://github.com/Gesee-y/Outdoors.jl/blob/main/LICENSE)

## Contribution

This package is made for that, I would greatly appreciate your contribution to the package.
To do so, just :
   1. Fork the repository
   2. Create a feature branch (`git checkout -b feat/new-style`)
   3. Submit a Pull Request

Contribution can be *performance improvement*, *new window style*, or *bug fix*

## Bug report 

If you encountered any problem or counter intuitive behavior, you can create an issue at [my GitHub](https://github.com/Gesee-y/Outdoors.jl)
