# Implementing a New Window Style for the `Outdoors` Module

This document provides a comprehensive guide for developers on how to implement a new window style (e.g., using GLFW, DirectX, or a custom API) within the existing **`Outdoors`** abstraction layer. This pattern ensures your application remains decoupled from the underlying windowing API.

## I. Understanding the Core Architecture

The `Outdoors` module uses a **Dispatch/Notification** pattern, centered around the abstract type `AbstractStyle`.

| Component | Purpose | Why It's Necessary |
| :--- | :--- | :--- |
| **`AbstractStyle`** (Generic) | The required supertype for any concrete window style implementation. | It enables **polymorphism**; all generic `Outdoors` functions are overloaded (dispatched) based on the concrete type inheriting this. |
| **`ODWindow{T <: AbstractStyle}`** (Generic) | The generic container holding the style data (`data::T`), input state, and application reference. | Provides a **unified interface** for application logic, regardless of the underlying API (SDL, GLFW, etc.). |
| **Notifications (`NOTIF_...`)** | The **Pub/Sub** system for notifying the application of successful actions or errors. | Ensures **decoupling**. The core `Outdoors` functions do not return the result; they emit a notification, allowing multiple listeners to react. |

-----

## II. Step-by-Step Implementation Guide

To create a new window style, for instance, based on the **`[NewAPI]`** library, you must create a new module (e.g., `NewAPIOutdoors`) that extends and overloads the generic functions defined in `Outdoors`.

### Step 1: Define the Concrete Style Structure

Create a new `mutable struct` inheriting from `Outdoors.AbstractStyle`. This is where all the API-specific data will reside.

```julia
using Outdoors
using [YourNewAPIName] # e.g., using GLFW

mutable struct NewAPIStyle <: Outdoors.AbstractStyle
    # Mandatory: Ptr to the API's window object
    window_handle :: Ptr{Cvoid} 
    
    # Optional: Renderer or context specific to the API
    context :: Union{Nothing, Ptr{Cvoid}}
    
    # Cache fields for local state (width, height, title, etc.)
    title :: String
    width :: Integer
    # ... other state fields ...
end

# Define a convenience alias
const NewAPIWindow = Outdoors.ODWindow{NewAPIStyle}
```

### Step 2: Implement API Lifecycle Functions

You must provide overloads for initialization and shutdown.

#### A. Initialization (`InitOutdoor`)

This function must initialize the underlying API and emit the success notification.

```julia
function Outdoors.InitOutdoor(::Type{NewAPIStyle})
    if NewAPI.init() # Call the new API's initialization function
        Outdoors.NOTIF_OUTDOOR_INITED.emit(NewAPIStyle)
        return true
    else
        # Critical failure: use NOTIF_ERROR
        err = NewAPI.get_error()
        Outdoors.NOTIF_ERROR.emit("NewAPI failed to initialize.", err)
        return false
    end
end
```

#### B. Style and Window Quitting (`QuitStyle`, `QuitWindow`)

```julia
# Quits a specific window
function Outdoors.QuitWindow(app::NewAPIWindow)
    style = Outdoors.GetStyle(app)
    
    # 1. Destroy all child windows associated with this window (handled by Outdoors)
    Outdoors.DestroyChildWindow(app) 
    
    # 2. Call the API's destroy function
    NewAPI.destroy_window(style.window_handle) 
    
    # 3. Notify the application
    Outdoors.NOTIF_WINDOW_EXITTED.emit(app)
end

# Quits the entire style (e.g., cleans up global resources)
function Outdoors.QuitStyle(::Type{NewAPIStyle})
    NewAPI.quit()
    Outdoors.NOTIF_OUTDOOR_STYLE_QUITTED.emit(NewAPIStyle)
end
```

### Step 3: Implement Window Creation (`CreateWindow`)

This is the most complex step as it involves creating the API object, wrapping it in the style, and registering it with the main `ODApp`.

```julia
function Outdoors.CreateWindow(app::Outdoors.ODApp, ::Type{NewAPIStyle}, title::String, w, h, x=0, y=0; kwargs...)
    # 1. Translate abstract parameters into NewAPI flags/arguments
    # ... (e.g., setting fullscreen, resizable flags for NewAPI)

    # 2. Call the underlying API's create function
    handle = NewAPI.create_window(title, w, h, x, y, flags)

    if handle != C_NULL
        # 3. Create the concrete style object
        style = NewAPIStyle(handle, nothing, title, w, h, x, y)
        
        # 4. Create the generic ODWindow container
        win = Outdoors.ODWindow{NewAPIStyle}(style) 
        
        # 5. Register the window with the ODApp (assigns ID and sets WeakRef)
        Outdoors.add_to_app(app, win)
        
        # 6. Notify success (CRUCIAL)
        Outdoors.NOTIF_WINDOW_CREATED.emit(win) 
        return win
    else
        # 7. Notify failure
        err = NewAPI.get_last_error()
        Outdoors.NOTIF_ERROR.emit("NewAPI failed to create window.", err)
        return nothing
    end
end
```

### Step 4: Implement Basic Window Actions

For every action, the implementation follows this pattern: **Get Style Data** → **Call API Function** → **Update Local State** → **Emit Notification**.

| Generic Function | NewAPI Implementation Steps | Required Notification |
| :--- | :--- | :--- |
| `ResizeWindow` | 1. `NewAPI.set_size(handle, w, h)` 2. Update `style.width`, `style.height` | `NOTIF_WINDOW_RESIZED(win, w, h)` |
| `SetWindowTitle` | 1. `NewAPI.set_title(handle, title)` 2. Update `style.title` | `NOTIF_WINDOW_TITLE_CHANGED(win, title)` |
| `MaximizeWindow` | 1. `NewAPI.maximize(handle)` | `NOTIF_WINDOW_MAXIMIZED(win)` |
| `HideWindow` | 1. `NewAPI.hide(handle)` 2. Update `style.shown = false` | `NOTIF_WINDOW_HIDDEN(win)` |
| `GetWindowStyleID` | **Direct access:** `return style.id` (if API ID is stored there). | None (direct return) |

Check [API documentation](https://github.com/Gesee-y/Outdoors.jl/blob/main/docs/API.md) for deeper informations

-----

## III. Implementing Event and Input Management

Event handling is the bridge between the API's raw input events and the normalized `InputState` of `Outdoors`.

### Step 5: Implement `GetEvents`

This is the main event loop function that reads events from the underlying API and dispatches them to specialized handlers.

```julia
function Outdoors.GetEvents(::Type{NewAPIStyle}, app::Outdoors.ODApp)
    # 1. Reset 'just_pressed' and 'just_released' flags for all windows
    for win in values(app.Windows)
        Outdoors.reset(Outdoors.get_inputs_state(win))
    end

    # 2. Poll/Process all events from the NewAPI
    while NewAPI.poll_event(event_ref) 
        
        # 3. Find the ODWindow associated with the event's window ID
        api_id = NewAPI.get_event_window_id(event_ref)
        win = Outdoors.GetWindowFromStyleID(app, NewAPIStyle, api_id)

        # 4. Dispatch the raw event to handlers
        if NewAPI.is_keyboard_event(event_ref)
            HandleKeyboardInputs(win, event_ref)
        elseif NewAPI.is_mouse_button_event(event_ref)
            HandleMouseEvents(win, event_ref)
        # ... and so on for mouse motion, window resizing, quit event, etc.
        end
    end
end
```

### Step 6: Implement Input Conversion (`ConvertKey`)

This function is mandatory for abstracting keyboard inputs.

```julia
"""
ConvertKey(::Type{NewAPIStyle}, key_code)

Transforms the NewAPI's raw key code (physical or virtual) into an
uniform string (e.g., 'A', 'SPACE', 'LSHIFT').
"""
function Outdoors.ConvertKey(::Type{NewAPIStyle}, key_code; physical=false)
    # Use a lookup table or a conversion function based on the API's constants
    if physical
        # Translate key_code to standard string (e.g., KEY_CODE_A -> "A")
    else
        # Translate virtual key to standard string
    end
    return uppercase(standard_key_string)
end
```

### Step 7: Implement Event Handlers (Example: Key Down)

Handlers translate raw API data into the normalized `Outdoors.KeyboardEvent` struct and update the window's `InputState`.

```julia
function HandleKeyboardInputs(win::NewAPIWindow, event)
    # Check if the event is a key down
    if NewAPI.is_key_down(event)
        
        # 1. Update counter to track activity for the current frame
        Outdoors._update_keyboard_count(win) 

        # 2. Get normalized key name
        key_code = NewAPI.get_key_code(event)
        key_name = Outdoors.ConvertKey(NewAPIStyle, key_code)
        
        data = Outdoors.get_inputs_data(win)
        Inputs = Outdoors.get_keyboard_data(data)

        # 3. Determine if this is a 'just pressed' event
        just_pressed = haskey(Inputs, key_name) ? !(Inputs[key_name].pressed) : true
        
        # 4. Create the normalized event object
        key_ev = Outdoors.KeyboardEvent(key_code, key_name, just_pressed, true, false, false)
        
        # 5. Store the current state
        Inputs[key_name] = key_ev

        # 6. Notify the application
        Outdoors.NOTIF_KEYBOARD_INPUT.emit(win, key_ev)
    end
end
```

By following these steps, your `NewAPIOutdoors` module successfully implements the abstract interface, allowing the application to use its features simply by choosing the **`NewAPIStyle`** during initialization and creation.