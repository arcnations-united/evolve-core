import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../back_end/app_data.dart';
import '../back_end/runner/run_in_terminal.dart';
import '../theme_manager/gtk_to_theme.dart';
import '../theme_manager/gtk_widgets.dart';
import '../theme_manager/tab_manage.dart';

import '../back_end/windowbehave/appwindow.dart';

class AppSettings extends StatefulWidget {
  final Function state;
  const AppSettings({
    super.key,
    required this.state,
  });

  @override
  State<AppSettings> createState() => _AppSettingsState();
}

//the app specific settings page. Needs an UI update to match the rest of the application
class _AppSettingsState extends State<AppSettings> {
  @override
  void initState() {
    // TODO: implement initState
    fetchCacheData();
    super.initState();
  }

  fetchCacheData() async {
    Directory d = Directory("${SystemInfo.home}/.NexData/cache");
    if (d.existsSync()) {
      String s = (await runInBash("du --max-depth=0 ${SystemInfo.home}/.NexData/cache"));
      s = s.substring(0, s.indexOf("\t")).trim();
      try {
        cacheDt = double.parse((double.parse(s) / 1000).toString().substring(
            0, (double.parse(s) / 1000).toString().indexOf(".") + 3));
      } catch (e) {
        cacheDt = (double.parse(s) / 1000);
      }
      setState(() {});
    }
  }

  double cacheDt = 0.0;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        WidsManager().gtkColumn(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              WidsManager()
                  .getText("App Settings", fontWeight: ThemeDt.boldText),
              WidsManager().getText(
                "App specific settings. These do not affect the system.",
                color: "altfg",
              ),
              const SizedBox(
                height: 13,
              )
            ],
          ),
          width: TabManager.isSuperLarge
              ? 900.0
              : MediaQuery.sizeOf(context).width -
                  ((TabManager.isLargeScreen) ? 170 : 0),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                WidsManager().getText("Improve Contrast"),
                GetToggleButton(
                  value: AppData.DataFile["HCONTRAST"] ?? false,
                  onTap: () {
                    AppData.DataFile["HCONTRAST"] ??= false;
                    AppData.DataFile["HCONTRAST"] =
                        !AppData.DataFile["HCONTRAST"];
                    AppData().writeDataFile();
                    AppSettingsToggle().toggleContrast();
                    widget.state();
                  },
                )
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                WidsManager().getText("Scale up"),
                GetToggleButton(
                  value: AppData.DataFile["MAXSIZE"] ?? false,
                  onTap: () {
                    AppData.DataFile["MAXSIZE"] ??= false;
                    AppData.DataFile["MAXSIZE"] = !AppData.DataFile["MAXSIZE"];
                    AppData().writeDataFile();
                    AppSettingsToggle().toggleMaxSize();
                    widget.state();
                  },
                ),
              ],
            ),
           /* Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                WidsManager().getText("Toggle animations"),
                GetToggleButton(
                  value: (AppData.DataFile["ANIMATE"] ?? true),
                  onTap: () async {
                    AppData.DataFile["ANIMATE"] ??= true;
                    AppData.DataFile["ANIMATE"] = !AppData.DataFile["ANIMATE"];
                    AppData().writeDataFile();
                    AppSettingsToggle().updateAnimation();
                    widget.state();
                  },
                ),
              ],
            ),*/
            GestureDetector(
              onTap: () {
                if (cacheDt > 0.0) {
                  Directory d = Directory("${SystemInfo.home}/.NexData/cache");
                  if (d.existsSync()) {
                    d.deleteSync(recursive: true);
                  }
                  setState(() {
                    cacheDt = 0.0;
                  });
                }
              },
              child: Container(
                color: ThemeDt.themeColors["altbg"],
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    WidsManager().getText("Clear cache ($cacheDt MB)"),
                    Icon(
                      Icons.chevron_right,
                      color: ThemeDt.themeColors["fg"],
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(
          height: 25,
        ),
        WidsManager().gtkColumn(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              WidsManager()
                  .getText("Theme Settings", fontWeight: ThemeDt.boldText),
              WidsManager().getText(
                "System level changes. These affect the system",
                color: "altfg",
              ),
              const SizedBox(
                height: 13,
              )
            ],
          ),
          width: TabManager.isSuperLarge
              ? 900.0
              : MediaQuery.sizeOf(context).width -
                  ((TabManager.isLargeScreen) ? 170 : 0),
          children: [
            GestureDetector(
              onTap: () {
                AppSettingsToggle().makeShellEditable(context);
              },
              child: Container(
                color: Colors.white.withOpacity(0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    WidsManager().getText("Make Default Shell Editable"),
                    Icon(
                      Icons.chevron_right,
                      color: ThemeDt.themeColors["fg"],
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(
          height: 24,
        ),
        AnimatedAlign(
          alignment: TabManager.isSuperLarge
              ? Alignment.bottomCenter
              : Alignment.bottomRight,
          duration: ThemeDt.d,
          curve: ThemeDt.c,
          child: GetButtons(
            pillShaped: true,
            onTap: () async {
              AppData().deleteData();
              WidsManager().showMessage(
                  title: "Info",
                  message: "All related settings reset. Evolve Core will close now.",
                  context: context,
                  child: Container());
              await Future.delayed(3.seconds);
              appWindow.close();
            },
            text: "Reset Settings",
            light: true,
          ),
        ),
      ],
    );
  }
}

class AppSettingsToggle {
  //toggles settings accordingly
  toggleContrast() {
    if (AppData.DataFile["HCONTRAST"] == null) {
      AppData.DataFile["HCONTRAST"] = false;
    }
    if (AppData.DataFile["HCONTRAST"] == "TRUE") {
      AppData.DataFile["HCONTRAST"] = true;
    } else if (AppData.DataFile["HCONTRAST"] == "FALSE") {
      AppData.DataFile["HCONTRAST"] = false;
    }
    if (AppData.DataFile["HCONTRAST"] == true) {
      ThemeDt.boldText = FontWeight.w500;
    } else {
      ThemeDt.boldText = FontWeight.w300;
    }
  }

  toggleMaxSize() {
    if (AppData.DataFile["MAXSIZE"] == null) {
      AppData.DataFile["MAXSIZE"] = false;
    }
    if (AppData.DataFile["MAXSIZE"] == "TRUE") {
      AppData.DataFile["MAXSIZE"] = true;
    } else if (AppData.DataFile["MAXSIZE"] == "FALSE") {
      AppData.DataFile["MAXSIZE"] = false;
    }
    if (AppData.DataFile["MAXSIZE"] ?? false) {
      ThemeDt.boldText = FontWeight.w400;
    } else {
      ThemeDt.boldText = FontWeight.w300;
    }
  }

  updateGnomeUI() async {
    if (AppData.DataFile["GNOMEUI"] == null) {
      AppData.DataFile["GNOMEUI"] = false;
    }
    if (AppData.DataFile["GNOMEUI"] == true) {
      await WidsManager().loadFontAndApply();
    }
  }

  updateAllParams() async {
    toggleContrast();
    toggleMaxSize();
    await updateGnomeUI();
    updateAnimation();
  }

  void updateAnimation() {
    if (AppData.DataFile["ANIMATE"] == false) {
      ThemeDt.d = Duration.zero;
    } else {
      ThemeDt.d = const Duration(milliseconds: 300);
    }
  }

  void makeShellEditable(BuildContext context) {
    WidsManager().showMessage(
      title: "Info",
      message: "Copy the original GNOME Shell theme to make it editable.",
      context: context,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          GetButtons(
            onTap: () {
              Navigator.pop(context);
            },
            text: "Exit",
          ),
          const SizedBox(
            width: 10,
          ),
          GetButtons(
            onTap: () {
              Navigator.pop(context);
              WidsManager().showMessage(
                title: "Set-up Theme",
                message: "Enter a name for the copy. (eg : Adwaita-Copy)",
                context: context,
                child: GetTextBox(
                  onDone: (tx) async {
                    Directory dir =
                        Directory("${SystemInfo.home}/.themes/$tx/gnome-shell");
                    if (await dir.exists()) {
                      WidsManager().showMessage(
                        title: "Error",
                        message:
                            "A theme with the same name already exists. Try a different name.",
                        context: context,
                      );
                    } else {
                      String out = (await runInBash("""
                        which gresource
                        """));
                      if (out.contains("no gresource")) {
                        WidsManager().showMessage(
                          title: "Error",
                          message: "PLease install gresource to continue",
                          context: context,
                        );
                      } else {
                        await dir.create(recursive: true);
                        await runInBash(
                            """cp /usr/share/gnome-shell/gnome-shell-theme.gresource ${dir.path}
                           """);
                        List m = await ThemeDt().listResFile(
                            "${dir.path}/gnome-shell-theme.gresource");
                        for (String name in m) {
                          if (name.contains("gnome-shell-dark")) {
                            await runInBash(
                                """gresource extract ${dir.path}/gnome-shell-theme.gresource $name > ${dir.path}/gnome-shell.css""");
                            break;
                          }
                        }
                        Navigator.pop(context);
                      }
                    }
                  },
                ),
              );
            },
            text: "Continue",
          ),
        ],
      ),
    );
  }
}
