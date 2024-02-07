import 'package:campus_app/services/unity_communication_service.dart';
import 'package:campus_app/widgets/text_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_scale_tap/flutter_scale_tap.dart';
import 'package:remix_flutter/remix_flutter.dart';
import '../constants/Constants.dart';
import '../constants/Sizes.dart';

class PerspectiveSwitchWidget extends StatefulWidget {
  const PerspectiveSwitchWidget({super.key});

  @override
  State<PerspectiveSwitchWidget> createState() => _PerspectiveSwitchWidgetState();
}

class _PerspectiveSwitchWidgetState extends State<PerspectiveSwitchWidget> {
  bool is3d = true;

  @override
  Widget build(BuildContext context) {
    Sizes().initialize(context);
    return ScaleTap(
      duration: animationDuration,
      scaleCurve: animationCurve,
      scaleMinValue: 0.75,
      onPressed: (){
        setState(() {
          is3d = !is3d;
        });
        UnityCommunicationService.toggle3dView();
      },
      child: Container(
        decoration: BoxDecoration(
          color: white,
          borderRadius: BorderRadius.circular(Sizes.borderRadius)
        ),
        padding: EdgeInsets.all(Sizes.paddingSmall),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Icon(
              RemixIcon.skip_down_line,
              size: Sizes.iconSize,
              color: Colors.transparent,
            ),
            DMSansMediumText(
              size: Sizes.textSizeSmall,
              color: black,
              text: is3d ? "3D" : "2D",
            ),
          ],
        ),
      ),
    );
  }
}
