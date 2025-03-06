---
Title: ReadMe

Author: Talom Laël
...

##### Outdoors ####

## Quick start

```
Pkg.add("Outdoors")
using Outdoors
```
## Intro

Windows management has always been the base of any GUI software. The windows's hierarchy, storage, etc, mostly depends on our use case. In our ecosystem, there are multiple API(Application Programming Interface) that create and manage windows for us, each with it's specificity:
  * [SDL]() that can have OpenGL, and SDL render context but with a more rigid interface
  * [GLFW]() specialized for OpenGL

Windows are our view on the virtual world as in a house where we can see the outside through the windows. Outdoors is made for that purpose.
It's a module to manage the window of the app. It's mean to be an abstraction for different API like [SDL2]() and [GLFW]()