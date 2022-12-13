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

***********

These functions are available in Kazari 1.0.0.

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
void func(any context, number scale, number midX, number midY)
```

Where `scale` always starts at 1 first then increase or decrease based on the finger movement. `midX` and `midY`
are middle point of the touch position.

### `void ZoomGesture:onZoomComplete(any context, function func)`

Same as above but called when pinch zoom gesture is completed (user lifting their finger).

The function signature for `func` must follow this convention:

```
void func(any context, number scale)
```

Where `scale` is the final scale ratio relative to the first time this gesture is performed.

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
the final value (with the `da` parameter being `nil`).

### `kazari.PanGesture(number minfingers, number maxfingers = minfingers boolean clip = false, Constraint constraint = nil)`

The `PanGesture` class. This gesture class is responsible of reporting x and y movement from `minfingers`
finger(s) (1 included) to `mzxfingers` finger(s) (1 included). Calling this function creates `PanGesture`
instance which is derived from `BaseGesture`.

Notes:

* `minfingers` must be at least 1.
* `maxfingers` must be at least `minfingers` (default).
* `clip` clips the position of each finger instead of the average.

### `void PanGesture:onMove(any context, function func)`

Register function `func` to be called everytime the average position is updated, additionally passing
`context` as the 1st parameter.

The function signature for `func` must follow this convention:

```
void func(any context, number x, number y, number dx, number dy, number pressure)
```

Where `x`, `y` are the relative position of the movement and `pressure` are the average pressure across fingers.
Note that on pressure-insensitive touchscreens, `pressure` will be always 1. `dx` and `dy` are position differences
from previous call of this function.

### `void PanGesture:onMoveComplete(any context, function func)`

Register function `func` to be called when user lifting their finger and the amount of fingers registered are less
than `minfingers`.

The function signature for `func` must follow this convention:

```
void func(any context, number x, number y, number pressure)
```

Where `x`, `y` are the final relative position of the movement and `pressure` are the average pressure across fingers.
Note that on pressure-insensitive touchscreens, `pressure` will be always 1.

### `void PanGesture:getTouchCount()`

Returns amount of fingers currently the user has in their screen (depends on the `:touch*` method calls). Returns
value from 0 inclusive to `maxfingers` inclusive.

### `kazari.TapGesture(number nfingers, number moveThreshold = 32, number altDuration = 0, Constraint constraint = nil)`

The `TapGesture` class. This gesture class is responsible of sending "tap" event with at least `nfingers`
finger(s) (1 included), additionally with option to have "alternative" tap (usually mapped to "right click") when
user holds their finger(s) for at least `altDuration` _time units_. `altDuration` of 0 means the "alternative" tap
is disabled. `moveThreshold` is the maximum _distance unit_ the user finger can move before the tap is cancelled.
Calling this function creates `TapGesture` instance which is derived from `BaseGesture`.

The definition of _time unit_ depends entirely on the units of delta time passed in `:update` function. If user
treat the delta time as milliseconds, then the _time unit_ is in milliseconds.

The definition of _distance unit_ depends entirely on the user. _Distance units_ may be in virtual resolution
or in pixels, as long as it is a unit that define distance on screen.

### `void TapGesture:update(number dt)`

Update the tap gesture for alternate tap. In LÖVE environment, this function should be called in
[`love.update`](https://love2d.org/wiki/love.update) with their arguments passed accordingly.

Note that it's okay not to call this function if `altDuration` is set to 0 (where alternate tap events is disabled).

### `void TapGesture:onStart(any context, function func)`

Register function `func` to be called when a tap is initiated, additionally passing `context` as the 1st parameter.

"Tap" is initiated when at least `nfingers` finger(s) are in the bound defined by `constraint`, not moving at all.

The function signature for `func` must follow this convention:

```
void func(any context)
```

### `void TapGesture:onCancel(any context, function func)`

Register function `func` to be called when a tap is cancelled, additionally passing `context` as the 1st parameter.

"Tap" is cancelled when the average position of the fingers moves more than `moveThreshold` _distance units_.

The function signature for `func` must follow this convention:

```
void func(any context, number duration)
```

Where `duration` is how long user fingers was on the screen before it was cancelled, in _time units_.

### `void TapGesture:onTap(any context, function func)`

Register function `func` to be called when a tap is successfully initiated, additionally passing `context` as the
1st parameter.

"Tap" is considered success when the average position of the finger moves less than `moveThreshold` _distance units_
and then user release one or more of their finger(s).

The function signature for `func` must follow this convention:

```
void func(any context, boolean alternate, number duration)
```

Where `alternate` is `true` if `duration` is longer than or equal to `altDuration` (except where `altDuration` is
0, `alternate` will always be `false`) and `duration` is how long user fingers was on the screen before the user
releases one or more of their finger(s) on the screen, in _time units_.
