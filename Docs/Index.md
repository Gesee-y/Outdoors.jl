# Outdoors Documentations

Outdoors is an abstraction layer for windows management and inputs handling.
It's purpose it to provide a simple entry point for developers to use and create their own windowing backend.

Let's start with the doc

## Installation

**Stable release**:  
```julia  
julia> ]add Outdoors  
```  

**Development version**:  
```julia  
julia> ]add https://github.com/Gesee-y/Outdoors.jl.git  
```

## Set up Outdoors

To use Outdoors in your script all you have to do is:

```
using Outdoors
```

But this himself isn't enough to get a window or inputs, for that you need to add a **window style** to Outdoors.
A **window style** is a windowing backend that will execute the command through the Outdoors's interface. So when you will do `CreateWindow`, the given window style will execute it and open a window.

Windows style are available as standalone packages to keep Outdoors lightweight, there are already [SDLOutdoors](https://github.com/Gesee-y/SDLOutdoors.jl) and [GLFWOutdoors](https://github.com/Gesee-y/GLFWOutdoors.jl).

## Windowing functions

TODO