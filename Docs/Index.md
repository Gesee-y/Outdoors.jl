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

## Usage

```julia
using Outdoors
using SDLOutdoors

InitOutdoor(SDLStyle)

const Close = Ref(false)

# This event is emitted when all windows are closed
Outdoors.connect(Outdoors.NOTIF_QUIT_EVENT) do
	Close[] = true
end

# This event is emitted when a key on the keyboard is pressed
Outdoors.connect(Outdoors.NOTIF_KEYBOARD_INPUT) do win,key
	obj = key.key

	if key.just_pressed[]
		println("Key '\$obj' just pressed.")
	elseif key.pressed
		println("Key '\$obj' is pressed.")
	elseif key.released
		println("Key '\$obj' have been released.")
	end
end

# This event is emitted when a change on a window happened
Outdoors.connect(Outdoors.NOTIF_WINDOW_EVENT) do win,type,w,h
	if type == Outdoors.WINDOW_RESIZED
		println("Resizing to \$(w)x\$h.")
	elseif type == Outdoors.WINDOW_MOVED
		println("Moving to \$(w),\$h.")
	elseif type == Outdoors.WINDOW_HAVE_FOCUS
		println("The mouse is in the window.")
	elseif type == Outdoors.WINDOW_LOSE_FOCUS
		println("The mouse exit the window.")
	end
end

# This event is emitted when a button of the mouse is pressed.
Outdoors.connect(Outdoors.NOTIF_MOUSE_BUTTON) do _, ev
	if ev.type isa LeftClick{1}
		println("Left click.")
	elseif ev.type isa LeftDoubleClick
		println("Left double click.")
	elseif ev.type isa RightClick{1}
		println("Right click.")
	elseif ev.type isa RightDoubleClick
		println("Right double click.")
	elseif ev.type isa MiddleClick
		println("Wheel click.")
	end
end

win = CreateWindow(SDLStyle,"Outdoor Events",640,480)
while !Close[]
	EventLoop(app,SDLStyle) # It's better to use EventLoop(SDLStyle) for the events
	yield()
end

QuitWindow(win)
QuitOutdoor(SDLStyle)
```