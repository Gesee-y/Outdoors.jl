---
Title: ReadMe

Author: Talom Laël
...

##### Outdoors ####

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