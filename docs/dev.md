# **Outdoors.jl Window Management API Documentation**

This section documents the core window-management API of **Outdoors**, intended to be overloaded by backend implementations (SDL, GLFW, custom engines, etc.).
Every function presented here is meant to be **dispatched on your custom window type** when you implement a new backend.

Most functions require you to emit specific notifications once the window operation succeeds.

---

## **Initialization**

### InitOutdoor(::Type{AbstractStyle})`

Initialize the Outdoors backend for the given window style.

```julia
InitOutdoor(::Type{AbstractStyle})
```

When implementing your own window style, create a method dispatched on your style type.

**Notification to emit:**

* `NOTIF_OUTDOOR_INITED`

---

## **Window Creation**

### CreateWindow(::Type{AbstractStyle}, args...; kwargs...)`

Create a new window with the given style.

```julia
CreateWindow(::Type{AbstractStyle}, args...; kwargs...)
```

Backend styles must overload this method and return the created window instance.

**Notification to emit:**

* `NOTIF_WINDOW_CREATED`

---

## **Window Resizing / Movement**

### ResizeWindow(app::ODWindow, width, height)`

Resize a window.

```julia
ResizeWindow(app::ODWindow, width, height)
```

**Notification to emit:**

* `NOTIF_WINDOW_RESIZED` with `(window, width, height)`

---

### RepositionWindow(app::ODWindow, x, y)`

Move a window to the given coordinates.

```julia
RepositionWindow(app::ODWindow, x, y)
```

**Notification to emit:**

* `NOTIF_WINDOW_REPOSITIONED` with `(window, x, y)`

---

### SetWindowTitle(app::ODWindow, new_title)`

Set a window’s title.

```julia
SetWindowTitle(app::ODWindow, new_title)
```

**Notification to emit:**

* `NOTIF_WINDOW_TITLE_CHANGED` with `(window, new_title)`

---

## **Window State (Maximize / Minimize / Restore)**

### MaximizeWindow(app::ODWindow)`

Maximize the window to the screen.

```julia
MaximizeWindow(app::ODWindow)
```

**Notification to emit:**

* `NOTIF_WINDOW_MAXIMIZED`

---

### MinimizeWindow(app::ODWindow)`

Minimize the window.

```julia
MinimizeWindow(app::ODWindow)
```

**Notification to emit:**

* `NOTIF_WINDOW_MINIMIZED`

---

### RestoreWindow(app::ODWindow)`

Restore a minimized window.

```julia
RestoreWindow(app::ODWindow)
```

**Notification to emit:**

* `NOTIF_WINDOW_RESTORED`

---

## **Visibility Control**

### HideWindow(app::ODWindow)`

Hide the window.

```julia
HideWindow(app::ODWindow)
```

**Notification to emit:**

* `NOTIF_WINDOW_HIDDEN`

---

### ShowWindow(app::ODWindow)`

Show the window.

```julia
ShowWindow(app::ODWindow)
```

**Notification to emit:**

* `NOTIF_WINDOW_SHOWN`

---

## **Z-Order / Fullscreen**

### RaiseWindow(app::ODWindow)`

Bring the window to the front.

```julia
RaiseWindow(app::ODWindow)
```

**Notification to emit:**

* `NOTIF_WINDOW_RAISED`

---

### SetFullscreen(app::ODWindow, active::Bool)`

Enable or disable fullscreen.

```julia
SetFullscreen(app::ODWindow, active::Bool)
```

**Notification to emit:**

* `NOTIF_WINDOW_FULLSCREEN` with `(window, active)`

---

## **Window Updating**

### UpdateWindow(app::ODWindow, args...)`

Redraw or refresh a window.

```julia
UpdateWindow(app::ODWindow, args...)
```

**Notification to emit:**

* `NOTIF_WINDOW_UPDATED`

---

## **Error Handling**

### GetError(app::ODWindow, args...)`

Return the latest window-related error.

```julia
GetError(app::ODWindow, args...)
```

Backends should provide their own error system.

Depending on severity, emit:

* `NOTIF_INFO`
* `NOTIF_WARNING`
* `NOTIF_ERROR`

---

## **Window Identification**

### GetWindowID(app::ODWindow)`

Return the unique numeric ID of the window.

```julia
GetWindowID(app::ODWindow)
```

Backends must set this field when creating windows.

---

## **Window Quit / Shutdown**

### QuitWindow(app::ODWindow)`

Close a window.

```julia
QuitWindow(app::ODWindow)
```

**Notification to emit:**

* `NOTIF_WINDOW_EXITTED`

---

### QuitStyle(T::Type{AbstractStyle})`

Notify that the given window style is shutting down.

```julia
QuitStyle(T::Type{AbstractStyle})
```

Emits:

* `NOTIF_OUTDOOR_STYLE_QUITTED`

---

### QuitOutdoor(app::ODApp)`

Close **all windows**, destroy children, and shut down the Outdoors backend.

```julia
QuitOutdoor(app::ODApp)
```

Steps:

1. Quit all top-level windows.
2. Recursively destroy child windows.
3. Emit shutdown event.

**Notification to emit:**

* `NOTIF_OUTDOOR_QUITTED`

---

## **App & Window Utilities**

### WindowCount()`

Return the number of active windows.

```julia
WindowCount()
```

---

### GetStyle(app::ODWindow)`

Return the backend-specific style data.

```julia
GetStyle(app::ODWindow)
```

---

### GetWindowFromStyleID(app::ODApp, style::Type, id::Integer)`

Retrieve a window instances by its backend style and style-specific ID.

```julia
GetWindowFromStyleID(app::ODApp, style::Type{<:AbstractStyle}, id::Integer)
```

---

### AttribID(...)`

Utility functions to create attribute IDs for window metadata.

```julia
AttribID(id::Integer)
AttribID(id1::Tuple, id2::Integer)
AttribID(app::ODWindow, id::Integer)
```

---

## **Window Tree Management**

### add_to_app(app::ODApp, win::ODWindow; name="")`

Add a newly created window to the application tree.

* Creates a node in the window tree
* Assigns a unique ID
* Registers window in `app.Windows`

```julia
add_to_app(app::ODApp, win::ODWindow; name="")
```

When creating a windows with your own style, you should always call this somewhere after you created your windows.

---
