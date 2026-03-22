# Output: 13 — Remove Screen Transition Animations

## Branch
feature/13-transition-animation

## Changes Made

### lib/utils/no_animation_route.dart (new)
Helper `noAnimationRoute<T>()` using `PageRouteBuilder` with `Duration.zero` for both transition and reverse transition.

### lib/app.dart
All GoRoute `builder` replaced with `pageBuilder` returning `NoTransitionPage`.

### lib/screens/add_product/add_product_screen.dart
`MaterialPageRoute` → `noAnimationRoute` for barcode scanner push.

### lib/screens/fridge/add_fridge_product_screen.dart
`MaterialPageRoute` → `noAnimationRoute` for barcode scanner push.

## Commit
cc96630 — Remove screen transition animations
