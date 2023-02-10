import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart' hide MenuItem;
import 'package:flutter_icons/flutter_icons.dart';
import 'package:fuodz/constants/app_images.dart';
import 'package:fuodz/constants/app_strings.dart';
import 'package:fuodz/utils/ui_spacer.dart';
import 'package:fuodz/view_models/profile.vm.dart';
import 'package:fuodz/widgets/busy_indicator.dart';
import 'package:fuodz/widgets/menu_item.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';

class ProfileCard extends StatelessWidget {
  const ProfileCard(this.model, {Key key}) : super(key: key);

  final ProfileViewModel model;
  @override
  Widget build(BuildContext context) {
    return VStack(
      [
        //profile card
        (model.isBusy || model.currentUser == null)
            ? BusyIndicator().centered().p20()
            : HStack(
                [
                  //
                  CachedNetworkImage(
                    imageUrl: model.currentUser.photo,
                    progressIndicatorBuilder: (context, imageUrl, progress) {
                      return BusyIndicator();
                    },
                    errorWidget: (context, imageUrl, progress) {
                      return Image.asset(
                        AppImages.user,
                      );
                    },
                  )
                      .wh(Vx.dp64, Vx.dp64)
                      .box
                      .roundedFull
                      .clip(Clip.antiAlias)
                      .make(),

                  //
                  VStack(
                    [
                      //name
                      model.currentUser.name.text.xl.semiBold.make(),
                      //email
                      model.currentUser.email.text.light.make(),
                    ],
                  ).px20().expand(),

                  //
                ],
              ).p12(),

        //
        MenuItem(
          title: "Edit Profile".tr(),
          onPressed: model.openEditProfile,
          topDivider: true,
        ),
        //change password
        MenuItem(
          title: "Change Password".tr(),
          onPressed: model.openChangePassword,
          topDivider: true,
        ),
        //Earning
        MenuItem(
          title: "Earning".tr(),
          onPressed: model.showEarning,
          divider: true,
        ),
        //
        AppStrings.enableDriverWallet
            ? MenuItem(
                title: "Wallet".tr(),
                onPressed: model.openWallet,
              )
            : UiSpacer.emptySpace(),
        //
        //
        MenuItem(
          title: "Payment Accounts".tr(),
          onPressed: model.openPaymentAccounts,
        ),
        //
        MenuItem(
          child: "Logout".tr().text.red500.make(),
          onPressed: model.logoutPressed,
          divider: false,
          suffix: Icon(
            FlutterIcons.logout_ant,
            size: 16,
          ),
        ),

        UiSpacer.vSpace(15),
        HStack(
          [
            UiSpacer.expandedSpace(),
            HStack(
              [
                Icon(
                  FlutterIcons.delete_ant,
                  size: 16,
                  color: Vx.red400,
                ),
                UiSpacer.hSpace(10),
                "Delete Account".tr().text.sm.make(),
              ],
            ).onInkTap(model.deleteAccount),
            UiSpacer.expandedSpace(),
          ],
          crossAlignment: CrossAxisAlignment.center,
          alignment: MainAxisAlignment.center,
        ).wFull(context),
        UiSpacer.vSpace(15),
      ],
    )
        .wFull(context)
        .box
        .border(color: Theme.of(context).cardColor)
        .color(Theme.of(context).cardColor)
        .shadow
        .roundedSM
        .make();
  }
}
