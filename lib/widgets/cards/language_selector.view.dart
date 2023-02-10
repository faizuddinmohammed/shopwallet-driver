import 'package:flutter/material.dart' hide MenuItem;
import 'package:flag/flag.dart';
import 'package:fuodz/constants/app_languages.dart';
import 'package:fuodz/services/auth.service.dart';
import 'package:fuodz/utils/ui_spacer.dart';
import 'package:fuodz/utils/utils.dart';
import 'package:fuodz/widgets/menu_item.dart';

import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';

class AppLanguageSelector extends StatelessWidget {
  const AppLanguageSelector({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: VStack(
        [
          //
          "Select your preferred language".tr()
              .text
              .xl
              .semiBold
              .make()
              .py20()
              .px12(),
          UiSpacer.divider(),

          //
          VStack(
            [
              ...(AppLanguages.codes.mapIndexed((code, index) {
                return MenuItem(
                  title: AppLanguages.names[index],
                  suffix: Flag.fromString(
                    AppLanguages.flags[index],
                    height: 24,
                    width: 24,
                  ),
                  onPressed: () => _onSelected(context, code),
                );
              }).toList()),
            ],
          ).scrollVertical().expand(),
        ],
      ),
    ).hThreeForth(context);
  }

  void _onSelected(BuildContext context, String code) async {
    
    await AuthServices.setLocale(code);
    await Utils.setJiffyLocale();
    //
    await translator.setNewLanguage(
      context,
      newLanguage: code,
      remember: true,
      restart: true,
    );
    //
    context.pop();
  }
}
