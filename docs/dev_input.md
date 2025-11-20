# **Outdoors.jl – Input Handling Guide**

This document explains how to implement **input handling** for a custom backend in **Outdoors.jl**.
This uses the implementation of **[SDLOutdoors](https://github.com/Gesee-y/SDLOutdoors.jl)** as an example, but the pattern applies to any system (GLFW, Windows API, custom renderer, etc.).

All input events are emitted via notifications, which the application can subscribe to.

---

## **Event Loop**

### `GetEvents(::Type{Style}, app::ODApp)`

Fetch all events from the backend and dispatch them as notifications.

```julia
GetEvents(::Type{SDLStyle}, app::ODApp)
```

**Responsibilities of the backend:**

1. Poll events from the OS / backend (e.g., `SDL_PollEvent`).
2. Dispatch window events (`Resize`, `Move`, `Focus`, `Close`).
3. Dispatch keyboard input (`KeyDown`, `KeyUp`, `TextInput`).
4. Dispatch mouse input (`MouseButton`, `MouseMotion`, `MouseWheel`).
5. Detect quit events (`SDL_QUIT`) and emit `NOTIF_QUIT_EVENT`.

---

## **Window Events**

### `HandleWindowEvent(app::ODApp, event::Ref{Event}, ev_type)`

Handles all window-level events.

**Common events:**

| Event Type | Action                    | Notification                               |
| ---------- | ------------------------- | ------------------------------------------ |
| Resize     | Resize window             | `NOTIF_WINDOW_EVENT` with `WINDOW_RESIZED` |
| Move       | Reposition window         | `WINDOW_MOVED`                             |
| Minimize   | Minimize window           | `WINDOW_MINIMIZED`                         |
| Restore    | Restore window            | `WINDOW_RESTORED`                          |
| Show       | Show window               | `WINDOW_SHOWN`                             |
| Hide       | Hide window               | `WINDOW_HIDDEN`                            |
| Enter      | Mouse enters window       | `WINDOW_HAVE_FOCUS`                        |
| Leave      | Mouse leaves window       | `WINDOW_LOSE_FOCUS`                        |
| Close      | Window requested to close | `WINDOW_CLOSE`                             |

**Example usage:**

```julia
win = GetWindowFromStyleID(app, SDLStyle, id)
ResizeWindow(win, width, height)
NOTIF_WINDOW_EVENT.emit = (win, WINDOW_RESIZED, width, height)
```

---

## **Keyboard Events**

### ### `HandleKeyboardInputs(app::ODApp, event::Ref{Event}, ev_type)`

Dispatch keyboard key presses and releases.

**Event types:**

* `KeyDown` → `_KeyboardKeyDown(win, event)`
* `KeyUp` → `_KeyboardKeyUp(win, event)`

**KeyboardEvent Fields:**

* `id` – backend key code
* `key` – string representation of key
* `just_pressed` – true if key just pressed
* `pressed` – true if key is currently pressed
* `just_released` – true if key just released
* `released` – true if key is currently released
* `Pkey` – physical key (scan code)

**Notification:**

* `NOTIF_KEYBOARD_INPUT.emit = (win, KeyboardEvent(...))`

---

### `HandleKeyboardTextInputs(app::ODApp, event::Ref{Event}, ev_type)`

Handles text input events (`TEXTINPUT`, `TEXTEDITING`) for character input.

**Backend responsibilities:**

* Extract the character(s) from the event.
* Convert to `Char`.
* Dispatch to your window/input system as needed.

---

## **Mouse Events**

### `HandleMouseEvents(app::ODApp, event::Ref{Event}, ev_type)`

Handles mouse button presses and releases.

**MouseEvent Fields:**

* `type` – `LeftClick`, `RightClick`, `MiddleClick` (with click count)
* `just_pressed`, `pressed`, `just_released`, `released` – state flags

**Notifications:**

* `NOTIF_MOUSE_BUTTON.emit = (win, MouseClickEvent(...))`

---

### `HandleMouseMotionEvents(app::ODApp, event::Ref{Event}, ev_type)`

Handles mouse motion events.

**MouseMotionEvent Fields:**

* `x`, `y` – current mouse position
* `xrel`, `yrel` – relative movement

**Notification:**

* `NOTIF_MOUSE_MOTION.emit = (win, MouseMotionEvent(...))`

---

### `HandleMouseWheelEvents(app::ODApp, event::Ref{Event}, ev_type)`

Handles scroll wheel events.

**MouseWheelEvent Fields:**

* `x`, `y` – scroll deltas

**Notification:**

* `NOTIF_MOUSE_WHEEL.emit = (win, MouseWheelEvent(...))`

---

## **Utility Functions**

### `ConvertKey(::Type{Style}, key; physical=false)`

Convert a backend key code to a string representation.

```julia
ConvertKey(::Type{SDLStyle}, key; physical=false)
```

* `physical=true` → use scan code instead of virtual key.
* Returns uppercase string representation.

---

## **Event Handling Flow**

1. Poll backend events.
2. Call `HandleWindowEvent` for window events.
3. Call `HandleKeyboardInputs` for key events.
4. Call `HandleKeyboardTextInputs` for text input.
5. Call `HandleMouseEvents` for button events.
6. Call `HandleMouseMotionEvents` for motion.
7. Call `HandleMouseWheelEvents` for scroll.
8. Check for quit events with `IsQuitEvent`.

**Example main loop:**

```julia
while !Close[]
    GetEvents(SDLStyle, app)
    yield() # allow coroutine / update loop
end
```

---

## **Notifications Overview**

| Notification           | Description                                           |
| ---------------------- | ----------------------------------------------------- |
| `NOTIF_QUIT_EVENT`     | Emitted when the application should close             |
| `NOTIF_KEYBOARD_INPUT` | Keyboard press/release events                         |
| `NOTIF_MOUSE_BUTTON`   | Mouse button events                                   |
| `NOTIF_MOUSE_MOTION`   | Mouse motion events                                   |
| `NOTIF_MOUSE_WHEEL`    | Mouse wheel events                                    |
| `NOTIF_WINDOW_EVENT`   | Window events (resize, move, show, hide, focus, etc.) |

---

## **Developer Guidelines**

1. **Backend-specific dispatch:**
   All functions are meant to be overloaded for the custom style type.
2. **Emit notifications:**
   Always emit the proper notification after handling the event.
3. **Use internal state registers:**
   Keep keyboard and mouse states in memory to avoid querying backend each frame.
4. **Support text input:**
   Capture character events separately from keycodes.
5. **Respect window IDs:**
   Match events to the correct window using unique backend IDs.

---