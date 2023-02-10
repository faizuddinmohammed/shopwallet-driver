import 'package:circular_countdown_timer/circular_countdown_timer.dart';
import 'package:flutter/material.dart';
import 'package:fuodz/constants/app_colors.dart';
import 'package:fuodz/constants/app_strings.dart';
import 'package:fuodz/models/new_taxi_order.dart';
import 'package:fuodz/utils/ui_spacer.dart';
import 'package:fuodz/view_models/taxi/new_taxi_order_alert.vm.dart';
import 'package:fuodz/view_models/taxi/taxi.vm.dart';
import 'package:fuodz/widgets/busy_indicator.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:measure_size/measure_size.dart';
import 'package:stacked/stacked.dart';
import 'package:swipebuttonflutter/swipebuttonflutter.dart';
import 'package:velocity_x/velocity_x.dart';

class IncomingNewOrderAlert extends StatefulWidget {
  const IncomingNewOrderAlert(this.taxiViewModel, this.newTaxiOrder, {Key key})
      : super(key: key);

  final TaxiViewModel taxiViewModel;
  final NewTaxiOrder newTaxiOrder;

  @override
  _IncomingNewOrderAlertState createState() => _IncomingNewOrderAlertState();
}

class _IncomingNewOrderAlertState extends State<IncomingNewOrderAlert> {
  //
  bool started = false;
  NewTaxiOrderAlertViewModel vm;

  //
  @override
  void initState() {
    super.initState();
    vm = NewTaxiOrderAlertViewModel(widget.newTaxiOrder, context);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      started = true;
      vm.initialise();
    });
  }

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<NewTaxiOrderAlertViewModel>.reactive(
      viewModelBuilder: () => vm,
      builder: (context, vm, child) {
        return MeasureSize(
          onChange: (size) {
            widget.taxiViewModel.taxiGoogleMapManagerService
                .updateGoogleMapPadding(size.height);
          },
          child: VStack(
            [
              //
              HStack(
                [
                  //title
                  "New Order Alert"
                      .tr()
                      .text
                      .semiBold
                      .xl2
                      .make()
                      .py12()
                      .expand(),

                  //countdown
                  CircularCountDownTimer(
                    duration: AppStrings.alertDuration,
                    controller: vm.countDownTimerController,
                    initialDuration: vm.newOrder.initialAlertDuration,
                    width: 30,
                    height: 30,
                    ringColor: Colors.grey[300],
                    ringGradient: null,
                    fillColor: AppColor.accentColor,
                    fillGradient: null,
                    backgroundColor: AppColor.primaryColorDark,
                    backgroundGradient: null,
                    strokeWidth: 4.0,
                    strokeCap: StrokeCap.round,
                    textStyle: TextStyle(
                      fontSize: 14,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    textFormat: CountdownTextFormat.S,
                    isReverse: true,
                    isReverseAnimation: false,
                    isTimerTextShown: true,
                    autoStart: false,
                    onStart: () {
                      print('Countdown Started');
                    },
                    onComplete: () {
                      widget.taxiViewModel.taxiGoogleMapManagerService
                          .clearMapData();
                      widget.taxiViewModel.taxiLocationService.zoomToLocation();
                      widget.taxiViewModel.taxiGoogleMapManagerService
                          .updateGoogleMapPadding(20);
                      vm.countDownCompleted(started);
                    },
                  ),
                ],
              ),
              HStack(
                [
                  "Pickup Distance".tr().text.lg.make().expand(),
                  "${vm.newOrder?.pickupDistance?.numCurrency}km"
                      .text
                      .medium
                      .xl2
                      .make(),
                ],
              ),
              HStack(
                [
                  "Trip Distance".tr().text.lg.make().expand(),
                  "${vm.newOrder?.tripDistance?.numCurrency}km"
                      .text
                      .medium
                      .xl2
                      .make(),
                ],
              ),
              //swipe to accept
              VStack(
                [
                  SwipingButton(
                    height: 50,
                    backgroundColor: AppColor.accentColor.withOpacity(0.50),
                    swipeButtonColor: AppColor.primaryColorDark,
                    swipePercentageNeeded: 0.80,
                    text: "Accept".tr(),
                    onSwipeCallback: vm.processOrderAcceptance,
                  ).wFull(context).box.make().h(vm.isBusy ? 0 : 50),
                  vm.isBusy
                      ? BusyIndicator().centered().p20()
                      : UiSpacer.emptySpace(),
                ],
              ).py12(),
              SafeArea(
                child: "Swipe to accept order".tr().text.makeCentered().py4(),
              ),
            ],
          )
              .p20()
              .px20()
              .box
              .color(context.backgroundColor)
              .topRounded()
              .shadow
              .make(),
        );
      },
    );
  }
}
