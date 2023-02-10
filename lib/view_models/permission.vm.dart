import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_background/flutter_background.dart';
import 'package:fuodz/views/pages/home.page.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:permission_handler/permission_handler.dart';
import 'base.view_model.dart';
import 'package:velocity_x/velocity_x.dart';

class PermissionViewModel extends MyBaseViewModel {
  PermissionViewModel(BuildContext context) {
    this.viewContext = context;
  }

  bool locationPermissinGranted = false;
  bool bgLocationPermissinGranted = false;
  bool bgPermissinGranted = false;
  int currentStep = 0;

  void initialise() async {
    bool granted = false;

    //location
    granted = await isLocationPermissionGranted();
    if (!granted) {
      return;
    }
    //bg location
    granted = await isBgLocationPermissionGranted();
    if (!granted) {
      return;
    }

    if (Platform.isAndroid) {
      //bg
      granted = await isBgPermissionGranted();
      if (!granted) {
        return;
      }
    }

    //all granted
    loadHomepage();
  }

  //
  Future<bool> isLocationPermissionGranted() async {
    var status = await Permission.locationWhenInUse.status;
    locationPermissinGranted = status.isGranted;
    notifyListeners();
    return locationPermissinGranted;
  }

  Future<bool> isBgLocationPermissionGranted() async {
    var status = await Permission.locationAlways.status;
    bgLocationPermissinGranted = status.isGranted;
    notifyListeners();
    return bgLocationPermissinGranted;
  }

  Future<bool> isBgPermissionGranted() async {
    bgPermissinGranted = await FlutterBackground.hasPermissions;
    notifyListeners();
    return bgPermissinGranted;
  }

  //
  bool showLocationPermissionView() {
    return currentStep == 0 && !locationPermissinGranted;
  }

  bool showBgLocationPermissionView() {
    return currentStep == 1 && !bgLocationPermissinGranted;
  }

  bool showBgPermissionView() {
    return currentStep == 2 && !bgPermissinGranted;
  }

  showContinueBtn() {
    //
    return !showLocationPermissionView() &
        !showBgLocationPermissionView() &
        !showBgPermissionView();
  }

//PERMISSION HANDLERS
  handleLocationPermission() async {
    PermissionStatus status = await Permission.locationWhenInUse.request();
    if (status.isGranted) {
      locationPermissinGranted = status.isGranted;
      nextStep();
      notifyListeners();
    } else {
      toastError("Permission denied".tr());
    }

    if (status.isPermanentlyDenied) {
      //When the user previously rejected the permission and select never ask again
      //Open the screen of settings
      await openAppSettings();
      status = await Permission.locationWhenInUse.request();
      locationPermissinGranted = status.isGranted;
      nextStep();
      notifyListeners();
    }
  }

  skipLocationPermission() {
    locationPermissinGranted = true;
    nextStep();
    notifyListeners();
  }

  handleBackgroundLocationPermission() async {
    PermissionStatus status = await Permission.locationAlways.request();
    if (status.isGranted) {
      bgLocationPermissinGranted = status.isGranted;
      nextStep();
      notifyListeners();
    } else {
      toastError("Permission denied".tr());
    }

    if (status.isPermanentlyDenied) {
      //When the user previously rejected the permission and select never ask again
      //Open the screen of settings
      await openAppSettings();
      status = await Permission.locationAlways.request();
      if (status.isGranted) {
        bgLocationPermissinGranted = status.isGranted;
        nextStep();
        notifyListeners();
      } else {
        toastError("Permission denied".tr());
      }
    }
  }

  skipBackgroundLocationPermission() {
    bgLocationPermissinGranted = true;
    nextStep();
    notifyListeners();
  }

  handleBackgroundPermission() async {
    if (Platform.isAndroid) {
      //
      final androidConfig = FlutterBackgroundAndroidConfig(
        notificationTitle: "Background service".tr(),
        notificationText: "Background notification to keep app running".tr(),
        notificationImportance: AndroidNotificationImportance.Default,
        notificationIcon: AndroidResource(
          name: 'notification_icon',
          defType: 'drawable',
        ), // Default is ic_launcher from folder mipmap
      );

      //check for permission
      //CALL THE PERMISSION HANDLER
      await FlutterBackground.initialize(androidConfig: androidConfig);
      bool isGranted = await FlutterBackground.hasPermissions;
      if (isGranted == null || !isGranted) {
        bgPermissinGranted =
            await FlutterBackground.enableBackgroundExecution();
      } else {
        bgPermissinGranted = isGranted;
      }
      nextStep();
    }
  }

  skipBackgroundPermission() {
    bgPermissinGranted = true;
    nextStep();
  }

  //
  nextStep() {
    if (currentStep == 0) {
      if (locationPermissinGranted) {
        currentStep = 1;
      }
    } else if (currentStep == 1) {
      if (bgLocationPermissinGranted) {
        currentStep = 2;
        //
        if (!Platform.isAndroid) {
          loadHomepage();
        }
      }
    } else if (currentStep == 2) {
      if (bgPermissinGranted) {
        loadHomepage();
      }
    }
    //
    notifyListeners();
  }

  loadHomepage() {
    viewContext.nextAndRemoveUntilPage(
      HomePage(),
    );
  }
}
