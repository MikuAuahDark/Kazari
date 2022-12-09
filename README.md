Kazari
=====

Kazari is a touch gesture input library.

Setup
-----

To start, clone the repository. Say you're in your current project directory (directory where `main.lua` reside), run:

```
git clone https://github.com/MikuAuahDark/Kazari libs/kazari
```

You can change `libs/kazari` to `libs/hanachirusato` or anywhere else as long as you remember what name to use in `require` later.

To load the library, use `require`:

```lua
local kazari = require("libs.kazari")
```

Documentation
-----

### `Constraint`

This is pseudo-type that can be used to limit where the touch gesture operates on.

This pseudo-type accept one of these:
* `nil`, which means touch is unbounded.
* Array of numbers in order: `{x position, y position, width, height}`
* Key-value pairs with these structure: `{x = x position, y = y position, w = width, h = height}`
* [NLay's `BaseConstraint` type](https://github.com/MikuAuahDark/NPad93#nlay)

### `boolean kazari.is(any object, Class<? extends BaseGesture> class)`

Check if `object` is an instance of `class` where `class` inherits `BaseGesture`.

Returns: is `object` an instance of `class`?

Example:
```lua
-- Check if object is an instance of BaseGesture
print(kazari.is(object, kazari.BaseGesture))
```

### `kazari.BaseGesture`

The `BaseGesture` class. All gesture object inherit this class.

### `boolean BaseGesture:touchpressed(any id, number x, number y, number pressure)`

Send touch pressed event to the gesture. In LÖVE environment, this function should be called in
[`love.touchpressed`](https://love2d.org/wiki/love.touchpressed) with their arguments passed accordingly.

Class that derive `BaseGesture` may contain `constraint` as their constructor parameter. It's responsible to ensure
that only touches at those areas defined by `constraint` are consumed.

Returns: Is the event consumed?

### `boolean BaseGesture:touchmoved(any id, number x, number y, number dx, number dy, number pressure)`

Send touch moved event to the gesture. In LÖVE environment, this function should be called in
[`love.touchmoved`](https://love2d.org/wiki/love.touchmoved) with their arguments passed accordingly.

### `boolean BaseGesture:touchreleased(any id, number x, number y)`

Send touch released event to the gesture. In LÖVE environment, this function should be called in
[`love.touchreleased`](https://love2d.org/wiki/love.touchreleased) with their arguments passed accordingly.

### `kazari.ZoomGesture(boolean clip = false, Constraint constraint = nil)`

The `ZoomGesture` class. This gesture class is responsible of performing pinch zoom using 2 fingers.
Calling this function creates `ZoomGesture` instance which is derived from `BaseGesture`.

Setting `clip` to `true` restrict each finger movement to the area bounded by `constraint`.

### `void ZoomGesture:onZoom(any context, function func)`

Register function `func` to be called everytime the zoom ratio is updated, additionally passing
`context` as the 1st parameter.

The function signature for `func` must follow this convention:

```
void func(any context, number scale)
```

Where `scale` always starts at 1 first then increase or decrease based on the finger movement.

### `void ZoomGesture:onZoomComplete(any context, function func)`

Same as above but called when pinch zoom gesture is completed (user lifting their finger) and passes
the final value.

### `kazari.RotateGesture(Constraint constraint = nil)`

The `RotateGesture` class. This gesture class is responsible of performing 2-finger rotate gesture.
Calling this function creates `RotateGesture` instance which is derived from `BaseGesture`.

### `void RotateGesture:onRotate(any context, function func)`

Register function `func` to be called everytime the angle is updated, additionally passing
`context` as the 1st parameter.

The function signature for `func` must follow this convention:

```
void func(any context, number angle, number da)
```

Where `angle` always starts at 0 first then increase or decrease based on the finger movement. `angle`
range can go above `2 * math.pi` (1 turn clockwise) or below `-2 * math.pi` (1 turn counter-clockwise).
`da` is angle difference between last angle update. Positive value means clockwise rotation, negative value
means counter-clockwise rotation.

### `void RotateGesture:onRotateComplete(any context, function func)`

Same as above but called when rotate gesture is completed (user lifting their finger) and passes
the final value.
