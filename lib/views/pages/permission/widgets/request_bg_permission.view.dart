import 'package:flutter/material.dart';
import 'package:fuodz/utils/ui_spacer.dart';
import 'package:fuodz/view_models/permission.vm.dart';
import 'package:fuodz/widgets/buttons/custom_button.dart';
import 'package:fuodz/widgets/buttons/custom_text_button.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';

class RequestBGPermissionView extends StatefulWidget {
  const RequestBGPermissionView(this.vm, {Key key}) : super(key: key);

  final PermissionViewModel vm;

  @override
  State<RequestBGPermissionView> createState() => _RequestBGPermissionViewState();
}

class _RequestBGPermissionViewState extends State<RequestBGPermissionView> {
  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: widget.vm.showBgPermissionView(),
      child: VStack(
        [
          "Background Permission Request".tr().text.bold.xl2.make().py12(),
          "This app requires your background permission to enable app receive new order notification even when app is in background"
              .tr()
              .text
              .make(),
          UiSpacer.vSpace(),
          CustomButton(
            title: "Next".tr(),
            onPressed: widget.vm.handleBackgroundPermission,
          ),
          UiSpacer.vSpace(10),
          CustomTextButton(
            title: "Skip".tr(),
            onPressed: widget.vm.skipBackgroundPermission,
          ).wFull(context),
          UiSpacer.vSpace(10),
        ],
      ).p32(),
    );
  }
}
