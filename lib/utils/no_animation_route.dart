import 'package:flutter/material.dart';

PageRoute<T> noAnimationRoute<T>(WidgetBuilder builder) => PageRouteBuilder<T>(
      pageBuilder: (context, _, __) => builder(context),
      transitionDuration: Duration.zero,
      reverseTransitionDuration: Duration.zero,
    );
