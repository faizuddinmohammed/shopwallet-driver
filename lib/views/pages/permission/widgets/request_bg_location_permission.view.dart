import 'package:flutter/material.dart';
import 'package:fuodz/utils/ui_spacer.dart';
import 'package:fuodz/view_models/permission.vm.dart';
import 'package:fuodz/widgets/buttons/custom_button.dart';
import 'package:fuodz/widgets/buttons/custom_text_button.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';

class RequestBGLocationPermissionView extends StatefulWidget {
  const RequestBGLocationPermissionView(this.vm, {Key key}) : super(key: key);

  final PermissionViewModel vm;

  @override
  State<RequestBGLocationPermissionView> createState() => _RequestBGLocationPermissionViewState();
}

class _RequestBGLocationPermissionViewState extends State<RequestBGLocationPermissionView> {
  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: widget.vm.showBgLocationPermissionView(),
      child: VStack(
        [
          "Background Location Permission".tr().text.bold.xl2.make().py12(),
          "This app collects location data to enable system search for assignable order within your location and also allow customer track your location when delivering their order even when the app is closed or not in use."
              .tr()
              .text
              .make(),
          UiSpacer.vSpace(),
          CustomButton(
            title: "Next".tr(),
            onPressed: widget.vm.handleBackgroundLocationPermission,
          ),
          UiSpacer.vSpace(10),
          CustomTextButton(
            title: "Skip".tr(),
            onPressed: widget.vm.skipBackgroundLocationPermission,
          ).wFull(context),
          UiSpacer.vSpace(10),
        ],
      ).p32(),
    );
  }
}
