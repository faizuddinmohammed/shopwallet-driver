import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fuodz/constants/app_colors.dart';
import 'package:fuodz/utils/ui_spacer.dart';
import 'package:fuodz/utils/utils.dart';
import 'package:fuodz/view_models/permission.vm.dart';
import 'package:fuodz/views/pages/permission/widgets/request_bg_permission.view.dart';
import 'package:fuodz/views/pages/permission/widgets/request_location_permission.view.dart';
import 'package:fuodz/widgets/base.page.dart';
import 'package:fuodz/widgets/buttons/custom_button.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:stacked/stacked.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import 'widgets/request_bg_location_permission.view.dart';

class PermissionPage extends StatelessWidget {
  const PermissionPage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<PermissionViewModel>.reactive(
      viewModelBuilder: () => PermissionViewModel(context),
      onModelReady: (vm) => vm.initialise(),
      builder: (context, vm, child) {
        return BasePage(
          extendBodyBehindAppBar: true,
          body: VStack(
            [
              VStack(
                [
                  UiSpacer.vSpace(kToolbarHeight * 1.1),
                  "Permission Management"
                      .tr()
                      .text
                      .color(Utils.textColorByTheme())
                      .bold
                      .xl3
                      .make(),
                  "App requires some permissions before it can work"
                      .tr()
                      .text
                      .base
                      .color(Utils.textColorByTheme())
                      .light
                      .make(),
                  UiSpacer.vSpace(12),
                  //
                  AnimatedSmoothIndicator(
                    activeIndex: vm.currentStep,
                    count: Platform.isAndroid ? 3 : 2,
                    effect: ExpandingDotsEffect(
                      activeDotColor: context.backgroundColor,
                      dotColor: context.backgroundColor,
                      strokeWidth: 1,
                      paintStyle: PaintingStyle.stroke,
                    ),
                  ),
                  UiSpacer.vSpace(10),
                ],
              ).p20().box.color(AppColor.primaryColor).make().wFull(context),

              //location permission
              RequestLocationPermissionView(vm),
              //background location permission
              RequestBGLocationPermissionView(vm),
              //background permission
              RequestBGPermissionView(vm),

              Visibility(
                visible: vm.showContinueBtn(),
                child: CustomButton(
                  title: "Continue".tr(),
                  onPressed: vm.loadHomepage,
                ).p20(),
              ),
            ],
          ).scrollVertical(),
        );
      },
    );
  }
}
