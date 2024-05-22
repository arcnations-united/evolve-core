import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gtkthememanager/front_end/main_page.dart';
import 'package:gtkthememanager/front_end/preview_app_page.dart';
import 'package:gtkthememanager/theme_manager/gtk_to_theme.dart';
import 'package:gtkthememanager/theme_manager/gtk_widgets.dart';
import 'package:page_transition/page_transition.dart';

import '../back_end/app_data.dart';
import 'app_specific_settings.dart';


class CheckValidity extends StatefulWidget {
  final Function() state;
  const CheckValidity({super.key, required this.state});

  @override
  State<CheckValidity> createState() => _CheckValidityState();
}

class _CheckValidityState extends State<CheckValidity> {
  @override
  void initState() {
    // TODO: implement initState

    fetchCode();
    super.initState();
  }
  bool isLoading =true;
  fetchCode()async{
    await AppData().fetchDataFile();

    await AppSettingsToggle().updateAllParams();
          Navigator.push(
              context,
              PageTransition(
                  type: PageTransitionType.fade,
                  child: AppData.dt_not_present?PreviewPage(state: widget.state):const WidgetGTK())
          );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:ThemeDt.themeColors["bg"],
      body: Padding(
        padding: const EdgeInsets.only(left: 38.0,right: 38),
        child:Center(
          child:  Stack(
            children: [
              Center(
                child: ImageFiltered(
                    imageFilter: ImageFilter.blur(
                        sigmaY: 35,
                        sigmaX: 35
                    ),
                    child: Image.asset("assets/iconfile.png", height: 250, width: 250, opacity: const AlwaysStoppedAnimation(.5),)),
              ),
              Center(child: Image.asset("assets/iconfile.png", height: 150, width: 150,)),
            ],
          ).animate(
              effects: [
                FadeEffect(
                    duration: 200.milliseconds
                )
              ]
          )
        ),
      ),
    );

  }
}
class FailPage extends StatelessWidget {
  const FailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeDt.themeColors["bg"],
      body: Center(child: WidsManager().getText("Failed", size: 40)),
    );
  }
}


