import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:fuodz/utils/ui_spacer.dart';
import 'package:localize_and_translate/localize_and_translate.dart';

import 'package:velocity_x/velocity_x.dart';

class BasePage extends StatefulWidget {
  final bool showAppBar;
  final bool showLeadingAction;
  final bool showCart;
  final Function onBackPressed;
  final String title;
  final Widget body;
  final Widget bottomSheet;
  final Widget fab;
  final bool isLoading;
  final bool extendBodyBehindAppBar;
  final double elevation;
  final Color appBarItemColor;
  final Color backgroundColor;

  BasePage({
    this.showAppBar = false,
    this.showLeadingAction = false,
    this.showCart = false,
    this.onBackPressed,
    this.title = "",
    this.body,
    this.bottomSheet,
    this.fab,
    this.isLoading = false,
    this.elevation,
    this.extendBodyBehindAppBar = false,
    this.appBarItemColor,
    this.backgroundColor,
    Key key,
  }) : super(key: key);

  @override
  _BasePageState createState() => _BasePageState();
}

class _BasePageState extends State<BasePage> {
  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: translator.activeLocale.languageCode == "ar"
          ? TextDirection.rtl
          : TextDirection.ltr,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor:
            widget.backgroundColor ?? Theme.of(context).backgroundColor,
        extendBodyBehindAppBar: widget.extendBodyBehindAppBar,
        appBar: widget.showAppBar
            ? AppBar(
                automaticallyImplyLeading: widget.showLeadingAction,
                elevation: widget.elevation,
                leading: widget.showLeadingAction
                    ? IconButton(
                        icon: Icon(
                          FlutterIcons.arrow_left_fea,
                        ),
                        onPressed: widget.onBackPressed ??
                            () => Navigator.pop(context),
                      )
                    : null,
                title: Text(
                  widget.title,
                ),
              )
            : null,
        body: VStack(
          [
            //
            widget.isLoading
                ? LinearProgressIndicator()
                : UiSpacer.emptySpace(),

            //
            widget.body.expand(),
          ],
        ),
        bottomSheet: widget.bottomSheet,
        floatingActionButton: widget.fab,
        // floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      ),
    );
  }
}
