import 'dart:convert';
import 'dart:io';

import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background/flutter_background.dart';
import 'package:fuodz/constants/app_colors.dart';
import 'package:fuodz/constants/app_routes.dart';
import 'package:fuodz/constants/app_strings.dart';
import 'package:fuodz/constants/app_theme.dart';
import 'package:fuodz/requests/settings.request.dart';
import 'package:fuodz/services/auth.service.dart';
import 'package:fuodz/services/firebase.service.dart';
import 'package:fuodz/utils/utils.dart';
import 'package:fuodz/views/pages/permission/permission.page.dart';
import 'package:fuodz/widgets/cards/language_selector.view.dart';
import 'package:permission_handler/permission_handler.dart';
import 'base.view_model.dart';
import 'package:velocity_x/velocity_x.dart';

class SplashViewModel extends MyBaseViewModel {
  SplashViewModel(BuildContext context) {
    this.viewContext = context;
  }

  //
  SettingsRequest settingsRequest = SettingsRequest();

  //
  initialise() async {
    super.initialise();
    await loadAppSettings();
  }

  //

  //
  loadAppSettings() async {
    setBusy(true);
    try {
      final appSettingsObject = await settingsRequest.appSettings();
      //app settings
      await updateAppVariables(appSettingsObject.body["strings"]);
      //colors
      await updateAppTheme(appSettingsObject.body["colors"]);
      loadNextPage();
    } catch (error) {
      setError(error);
      print("Error loading app settings ==> $error");
    }
    setBusy(false);
  }

  //
  void updateAppVariables(dynamic json) async {
    //
    await AppStrings.saveAppSettingsToLocalStorage(jsonEncode(json));
  }

  //theme change
  updateAppTheme(dynamic colorJson) async {
    //
    await AppColor.saveColorsToLocalStorage(jsonEncode(colorJson));
    //change theme
    // await AdaptiveTheme.of(viewContext).reset();
    await AdaptiveTheme.of(viewContext).setTheme(
      light: AppTheme().lightTheme(),
      dark: AppTheme().darkTheme(),
      notify: true,
    );
    await AdaptiveTheme.of(viewContext).persist();
  }

  //
  loadNextPage() async {
    //
    await Utils.setJiffyLocale();
    //
    if (AuthServices.firstTimeOnApp()) {
      //choose language
      await showModalBottomSheet(
        context: viewContext,
        builder: (context) {
          return AppLanguageSelector();
        },
      );
    }

    //
    if (AuthServices.firstTimeOnApp()) {
      viewContext.navigator
          .pushNamedAndRemoveUntil(AppRoutes.welcomeRoute, (route) => false);
    } else if (!AuthServices.authenticated()) {
      viewContext.navigator
          .pushNamedAndRemoveUntil(AppRoutes.loginRoute, (route) => false);
    } else {
      var inUseStatus = await Permission.locationWhenInUse.status;
      var alwaysUseStatus = await Permission.locationAlways.status;
      final bgPermissinGranted =
          Platform.isIOS ? true : await FlutterBackground.hasPermissions;

      if (bgPermissinGranted &&
          inUseStatus.isGranted &&
          alwaysUseStatus.isGranted) {
        viewContext.navigator.pushNamedAndRemoveUntil(
          AppRoutes.homeRoute,
          (route) => false,
        );
      } else {
        viewContext.nextAndRemoveUntilPage(PermissionPage());
      }
    }

    //
    RemoteMessage initialMessage =
        await FirebaseService().firebaseMessaging.getInitialMessage();
    if (initialMessage != null) {
      //
      FirebaseService().saveNewNotification(initialMessage);
      FirebaseService().notificationPayloadData = initialMessage.data;
      FirebaseService().selectNotification("");
    }
  }
}
