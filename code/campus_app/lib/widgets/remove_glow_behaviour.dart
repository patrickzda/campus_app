import 'package:flutter/material.dart';

class RemoveGlowBehavior extends StatelessWidget {
  final Widget child;

  const RemoveGlowBehavior({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return NotificationListener<OverscrollIndicatorNotification>(
      onNotification: (OverscrollIndicatorNotification notification){
        notification.disallowIndicator();
        return false;
      },
      child: child,
    );
  }
}