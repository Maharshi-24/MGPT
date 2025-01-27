import 'package:flutter/material.dart';

class PushPageRoute extends PageRouteBuilder {
  final Widget page;

  PushPageRoute({required this.page})
      : super(
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      var begin = Offset(1.0, 0.0);
      var end = Offset.zero;
      var curve = Curves.easeInOut;

      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
      var offsetAnimation = animation.drive(tween);

      var slidingChild = SlideTransition(
        position: offsetAnimation,
        child: child,
      );

      var pushTween = Tween<Offset>(
        begin: Offset.zero,
        end: Offset(-0.25, 0.0),
      ).chain(CurveTween(curve: curve));

      var pushAnimation = animation.drive(pushTween);

      return Stack(
        children: [
          SlideTransition(
            position: pushAnimation,
            child: Container(
              color: Colors.black,
              child: AbsorbPointer(
                absorbing: true,
                child: Opacity(
                  opacity: 1 - animation.value,
                  child: Container(
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ),
          slidingChild,
        ],
      );
    },
    transitionDuration: Duration(milliseconds: 300),
    reverseTransitionDuration: Duration(milliseconds: 300),
  );
}

