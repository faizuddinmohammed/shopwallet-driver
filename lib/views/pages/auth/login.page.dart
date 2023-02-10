import 'package:flutter/material.dart';
import 'package:fuodz/constants/app_images.dart';
import 'package:fuodz/constants/app_strings.dart';
import 'package:fuodz/services/validator.service.dart';
import 'package:fuodz/view_models/login.view_model.dart';
import 'package:fuodz/widgets/base.page.dart';
import 'package:fuodz/widgets/buttons/custom_button.dart';
import 'package:fuodz/widgets/buttons/custom_text_button.dart';
import 'package:fuodz/widgets/custom_text_form_field.dart';
import 'package:localize_and_translate/localize_and_translate.dart';

import 'package:stacked/stacked.dart';
import 'package:velocity_x/velocity_x.dart';

import 'login/scan_login.view.dart';

class LoginPage extends StatefulWidget {
  LoginPage({Key key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<LoginViewModel>.reactive(
      viewModelBuilder: () => LoginViewModel(context),
      onModelReady: (model) => model.initialise(),
      builder: (context, model, child) {
        return BasePage(
          body: SafeArea(
            top: true,
            bottom: false,
            child: VStack(
              [
                Image.asset(
                  AppImages.onboarding1,
                ).hOneForth(context).centered(),
                //
                VStack(
                  [
                    //
                    "Welcome Back".tr().text.xl2.semiBold.make(),
                    "Login to continue".tr().text.light.make(),

                    //form
                    Form(
                      key: model.formKey,
                      child: VStack(
                        [
                          //
                          CustomTextFormField(
                            labelText: "Email".tr(),
                            keyboardType: TextInputType.emailAddress,
                            textEditingController: model.emailTEC,
                            validator: FormValidator.validateEmail,
                          ).py12(),
                          CustomTextFormField(
                            labelText: "Password".tr(),
                            obscureText: true,
                            textEditingController: model.passwordTEC,
                            validator: FormValidator.validatePassword,
                          ).py12(),

                          //
                          "Forgot Password ?"
                              .tr()
                              .text
                              .underline
                              .make()
                              .onInkTap(
                                model.openForgotPassword,
                              ),
                          //
                          CustomButton(
                            title: "Login".tr(),
                            loading: model.isBusy,
                            onPressed: model.processLogin,
                          ).centered().py12(),
                        ],
                        crossAlignment: CrossAxisAlignment.end,
                      ),
                    ).py20(),

                    ScanLoginView(model),

                    //registration link
                    Visibility(
                      visible: AppStrings.partnersCanRegister,
                      child: CustomTextButton(
                        title: "Become a partner".tr(),
                        onPressed: model.openRegistrationlink,
                      ).centered(),
                    ),
                  ],
                )
                    .wFull(context)
                    .p20()
                    .scrollVertical()
                    .box
                    .color(context.cardColor)
                    .make()
                    .expand(),

                //
              ],
            ).pOnly(
              bottom: context.mq.viewInsets.bottom,
            ),
          ),
        );
      },
    );
  }
}
