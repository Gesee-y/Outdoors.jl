---
Title: ReadMe

Author: Talom Laël
...

# Outdoors 

## Quick start

```julia
Pkg.add("Outdoors.jl")
using Outdoors
```
## Intro

Windows management has always been the base of any GUI software. The windows's hierarchy, storage, etc, mostly depends on our use case. In our ecosystem, there are multiple API(Application Programming Interface), each with his strength and constraints. For larger projects, an API may be better for UI while another one would be better for visualization and rendering. Switching from one API to another may become cumbersome or if the need to change API comes while the project is already tightly coupled to it, it may become a real challenge.

Outdoors is made for that purpose.
It's a module to manage the window of the app. It's mean to be an abstraction for different API like [SDL2]() or [GLFW]() while providing an easy way to add new one. It uses the [Notifyer.jl]() package, allowing reactiveness for each API.

## Installation 

```julia
julia>Pkg.add("Outdoors.jl")
```

or from the GitHub repository 
```julia
julia>Pkg.add(url="https://github.com/Gesee-y/Outdoors.jl.git")
```

## Usage

```julia

using Outdoors

Outdoors.connect(NOTIF_OUTDOOR_INITED) do
        println("Outdoor successfuly inited!")
        println()
end

Outdoors.connect(NOTIF_WINDOW_CREATED) do win
        sl = GetStyle(win)
        println("A new window named '$(sl.title)' have been created.")
end
Outdoors.connect(NOTIF_WINDOW_EXITTED) do win
        sl = GetStyle(win)
        println("The window named '$(sl.title)' have been exitted.")
end
Outdoors.connect(NOTIF_ERROR) do msg,err
        error(msg*err)
end

const Close = Ref(false)

Outdoors.connect(NOTIF_QUIT_EVENT) do
        Close[] = true
end

InitOutdoor(SDLStyle)
app = ODApp()

win = CreateWindow(app,SDLStyle,"Outdoor Test",640,480)

while !Close[]
        GetEvents(win)
        yield()
end

QuitWindow(win)
QuitStyle(SDLStyle)
```

## License 

This package is under the MIT license, for more information see [License]()

## Contribution

## Bug report 
