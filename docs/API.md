# Outdoors Module API Documentation

The `Outdoors` module provides an extensible, notification-driven abstraction layer for managing windows, user input, and application state, independent of the underlying windowing API (referred to as the **Style**).

## I. Core Types and Structures

These are the primary types that define the structure and extensibility of the module.

| Export | Type / Structure | Description |
| :--- | :--- | :--- |
| `AbstractStyle` | `abstract type` | The **abstract supertype** for all concrete window style implementations (e.g., `SDLStyle`, `GLFWStyle`). Developers must inherit from this to create a new window backend. |
| `ODWindow` | `mutable struct` | The generic container wrapping the `AbstractStyle` data. This is the primary object used to interact with a window instance in the application code. |
| `ODApp` | `struct` | The application state container. It manages the collection of active `ODWindow` instances (`Windows`) and their hierarchical structure (`WindowTree`). |
| `WindowEvents` | `@enum` | An enumeration used to classify various window-related events (e.g., `WINDOW_RESIZED`, `WINDOW_CLOSE`, `WINDOW_HAVE_FOCUS`). |
| `Event` | `abstract type` | The base type for all input and system events. |
| `ClickEvent` | `abstract type` | The base type for all mouse click events. |
| `LeftClick`, `RightClick`, `MiddleClick` | `struct` | Types representing a click, typically parameterized by the number of clicks (e.g., `LeftClick{1}`, `LeftClick{2}`/`LeftDoubleClick`). |
| `LeftDoubleClick`, `RightDoubleClick` | `const alias` | Aliases for double-click events (`LeftClick{2}` and `RightClick{2}`). |
| `AxisEvent` | `abstract type` | The base type for input events related to continuous axes (motion, wheel). |
| `KeyboardEvent` | `struct` | Stores the state of a single keyboard key (e.g., `just_pressed`, `pressed`, `just_released`). |
| `MouseClickEvent` | `struct` | Stores the state of a mouse button (e.g., `just_pressed`, `pressed`). |
| `MouseMotionEvent` | `struct` | Stores mouse movement data (`x`, `y`, `xrel`, `yrel`). |
| `MouseWheelEvent` | `struct` | Stores mouse wheel scroll data (`xwheel`, `ywheel`). |

---

## II. Window Management Functions (Dispatch Points)

These functions are the primary interface for manipulating windows. **All these functions require a concrete overload for each `AbstractStyle` implementation.**

| Export | Signature | Description |
| :--- | :--- | :--- |
| `InitOutdoor` | `InitOutdoor(::Type{AbstractStyle})` | Initializes the selected windowing API (Style). **Must emit `NOTIF_OUTDOOR_INITED`.** |
| `CreateWindow` | `CreateWindow(::Type{AbstractStyle}, args...)` | Creates a new window instance using the specified Style. **Must emit `NOTIF_WINDOW_CREATED`.** |
| `ResizeWindow` | `ResizeWindow(app::ODWindow, width, height)` | Sets the window's new dimensions. **Must emit `NOTIF_WINDOW_RESIZED`.** |
| `RepositionWindow` | `RepositionWindow(app::ODWindow, x, y)` | Sets the window's new screen position. **Must emit `NOTIF_WINDOW_REPOSITIONED`.** |
| `SetWindowTitle` | `SetWindowTitle(app::ODWindow, new_title)` | Changes the window's title string. **Must emit `NOTIF_WINDOW_TITLE_CHANGED`.** |
| `SetFullscreen` | `SetFullscreen(app::ODWindow, active::Bool)` | Toggles fullscreen mode for the window. **Must emit `NOTIF_WINDOW_FULLSCREEN`.** |
| `MaximizeWindow` | `MaximizeWindow(app::ODWindow)` | Maximizes the window. **Must emit `NOTIF_WINDOW_MAXIMIZED`.** |
| `MinimizeWindow` | `MinimizeWindow(app::ODWindow)` | Minimizes the window. **Must emit `NOTIF_WINDOW_MINIMIZED`.** |
| `RestoreWindow` | `RestoreWindow(app::ODWindow)` | Restores the window from minimized or maximized state. **Must emit `NOTIF_WINDOW_RESTORED`.** |
| `HideWindow` | `HideWindow(app::ODWindow)` | Hides the window. **Must emit `NOTIF_WINDOW_HIDDEN`.** |
| `ShowWindow` | `ShowWindow(app::ODWindow)` | Shows a previously hidden window. **Must emit `NOTIF_WINDOW_SHOWN`.** |
| `RaiseWindow` | `RaiseWindow(app::ODWindow)` | Brings the window to the front/top of the desktop stack. **Must emit `NOTIF_WINDOW_RAISED`.** |
| `UpdateWindow` | `UpdateWindow(app::ODWindow, args...)` | Forces a redraw/update of the window. **Must emit `NOTIF_WINDOW_UPDATED`.** |
| `QuitWindow` | `QuitWindow(app::ODWindow)` | Closes the window. **Must emit `NOTIF_WINDOW_EXITTED`.** |
| `QuitStyle` | `QuitStyle(T::Type{AbstractStyle})` | Shuts down the windowing API (Style) globally. **Must emit `NOTIF_OUTDOOR_STYLE_QUITTED`.** |
| `QuitOutdoor` | `QuitOutdoor(app::ODApp)` | Quits all active windows in the application. **Must emit `NOTIF_OUTDOOR_QUITTED`.** |
| `GetError` | `GetError(app::ODWindow, args...)` | Returns the last error from the windowing API. **Should be followed by `NOTIF_INFO`, `NOTIF_WARNING`, or `NOTIF_ERROR`.** |
| `GetWindowID` | `GetWindowID(app::ODWindow)` | Returns the unique `Outdoors` ID of the window. |
| `GetStyleWindowID`| `GetStyleWindowID(win::ODWindow)` | Returns the raw ID used by the underlying windowing API. |
| `GetStyle` | `GetStyle(app::ODWindow)` | Returns the concrete `AbstractStyle` data contained in the `ODWindow`. |
| `WindowCount` | `WindowCount()` | Returns the number of currently active windows. |

---

## III. Event and Input Management

These functions are used to process and query user input.

### A. Input Polling (Dispatch Points)

| Export | Signature | Description |
| :--- | :--- | :--- |
| `GetEvents` | `GetEvents(::Type{AbstractStyle})` | Reads all pending events from the underlying API and translates them into `Outdoors` notifications. **Must emit `NOTIF_EVENT_RECEIVED`.** |
| `HandleWindowEvent` | `HandleWindowEvent(::Type{AbstractStyle}, event)` | Processes raw API events related to the window lifecycle (move, resize, focus). |
| `HandleKeyboardInputs` | `HandleKeyboardInputs(window::AbstractStyle)` | Processes keyboard events. **Must emit `NOTIF_KEYBOARD_INPUT`.** |
| `HandleMouseEvents` | `HandleMouseEvents(window::AbstractStyle)` | Processes mouse button and wheel events. **Must emit `NOTIF_MOUSE_BUTTON` and/or `NOTIF_MOUSE_WHEEL`.** |
| `ConvertKey` | `ConvertKey(::Type{AbstractStyle}, key)` | **Critical for extensibility.** Converts a raw API key code into a standardized `String` (e.g., `SDLK_a` becomes `"A"`). |
| `EventLoop` | `EventLoop(app::ODApp, S)` | The convenience function used inside the main loop. It resets input states, calls `GetEvents(S)`, and updates the input state. |
| `GetMousePosition`| `GetMousePosition(::Type{AbstractStyle})` | Returns the absolute (x, y) coordinates of the mouse cursor. |

### B. Input Query Functions (Application Interface)

These functions are used by the application logic to check the current state of inputs.

| Export | Signature | Description |
| :--- | :--- | :--- |
| `IsKeyJustPressed` | `IsKeyJustPressed(win::ODWindow, key::String)` | Returns `true` if the key was pressed *only* in the current frame. |
| `IsKeyPressed` | `IsKeyPressed(win::ODWindow, key::String)` | Returns `true` if the key is currently held down. |
| `IsKeyJustReleased` | `IsKeyJustReleased(win::ODWindow, key::String)` | Returns `true` if the key was released *only* in the current frame. |
| `IsKeyReleased` | `IsKeyReleased(win::ODWindow, key::String)` | Returns `true` if the key is currently not pressed. |
| `IsMouseButtonJustPressed` | `IsMouseButtonJustPressed(win::ODWindow, key::String)` | Returns `true` if the mouse button (`"LeftClick"`, `"RightClick"`) was pressed *only* in the current frame. |
| `IsMouseButtonPressed` | `IsMouseButtonPressed(win::ODWindow, key::String)` | Returns `true` if the mouse button is currently held down. |
| `IsMouseButtonJustReleased` | `IsMouseButtonJustReleased(win::ODWindow, key::String)` | Returns `true` if the mouse button was released *only* in the current frame. |
| `IsMouseButtonReleased` | `IsMouseButtonReleased(win::ODWindow, key::String)` | Returns `true` if the mouse button is currently not pressed. |
| `GetAxis` | `GetAxis(win::ODWindow, name::String)` | Returns the value of a continuous axis (`"MMotion"`, `"Wheel"`). |

---

## IV. Notifications (EventNotifiers)

These are the signals the `Outdoors` module emits to notify listeners of state changes or errors.

| Export | Signature | Description |
| :--- | :--- | :--- |
| `NOTIF_OUTDOOR_INITED` | `(style)` | Emitted when a Style (API) has been successfully initialized. |
| `NOTIF_OUTDOOR_QUITTED` | `()` | Emitted when the entire `ODApp` has quit (all windows closed). |
| `NOTIF_OUTDOOR_STYLE_QUITTED` | `(style)` | Emitted when a specific Style (API) has been globally shut down. |
| `NOTIF_CONTEXT_CREATED` | `(win)` | Emitted when a rendering context (e.g., OpenGL) is successfully created in a window. |
| `NOTIF_WINDOW_CREATED` | `(win)` | Emitted when a window is successfully created. |
| `NOTIF_WINDOW_UPDATED` | `(win)` | Emitted when a window has been updated (redrawn). |
| `NOTIF_WINDOW_EXITTED` | `(win)` | Emitted when a window is closed/quit. |
| `NOTIF_WINDOW_MINIMIZED` | `(win)` | Emitted when a window has been minimized. |
| `NOTIF_WINDOW_MAXIMIZED` | `(win)` | Emitted when a window has been maximized. |
| `NOTIF_WINDOW_RESTORED` | `(win)` | Emitted when a window has been restored. |
| `NOTIF_WINDOW_HIDDEN` | `(win)` | Emitted when a window has been hidden. |
| `NOTIF_WINDOW_SHOWN` | `(win)` | Emitted when a window has been shown. |
| `NOTIF_WINDOW_RAISED` | `(win)` | Emitted when a window has been brought to the front. |
| `NOTIF_WINDOW_TITLE_CHANGED` | `(win, new_title::String)` | Emitted when the window title is changed. |
| `NOTIF_WINDOW_REPOSITIONED` | `(win, x::Integer, y::Integer)` | Emitted when the window position changes. |
| `NOTIF_WINDOW_RESIZED` | `(win, width::Integer, height::Integer)` | Emitted when the window size changes. |
| `NOTIF_WINDOW_FULLSCREEN` | `(win, active::Bool, desktop_resolution=false)`| Emitted when fullscreen mode is toggled. |
| `NOTIF_WINDOW_DELAYING` | `(t)` | Emitted when a delay/sleep function is called (internal utility). |
| `NOTIF_EVENT_RECEIVED` | `(event, type)` | Emitted when any raw event is processed (useful for debug/logging). |
| `NOTIF_WINDOW_EVENT` | `(win, ev::WindowEvents, d1=0, d2=0)` | Emitted for high-level window state changes (move, focus, resize). |
| `NOTIF_KEYBOARD_INPUT` | `(win, keys::KeyboardEvent)` | Emitted when a keyboard event is registered. |
| `NOTIF_MOUSE_MOTION` | `(win, ev::MouseMotionEvent)` | Emitted when the mouse moves. |
| `NOTIF_MOUSE_WHEEL` | `(win, ev::MouseWheelEvent)` | Emitted when the mouse wheel is scrolled. |
| `NOTIF_MOUSE_BUTTON` | `(win, ev::MouseClickEvent)` | Emitted when a mouse button state changes. |
| `NOTIF_JOYPAD_INPUT` | `(win, keys::Tuple)` | Emitted for joystick/gamepad input (currently stubbed). |
| `NOTIF_QUIT_EVENT` | `()` | Emitted when the user requests the application to quit (e.g., pressing the 'X' button on the main window). |
| `NOTIF_ERROR` | `(mes::String, error::String)` | Emitted for **severe, non-recoverable** errors. |
| `NOTIF_WARNING` | `(mes::String, warning::String, code=0)` | Emitted for **minor, recoverable** issues. |
| `NOTIF_INFO` | `(mes::String, info::String, code=0)` | Emitted for informational messages (e.g., driver details). |