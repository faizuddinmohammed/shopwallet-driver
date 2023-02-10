import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'dart:convert';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:fuodz/constants/app_colors.dart';
import 'package:fuodz/constants/app_strings.dart';
import 'package:fuodz/models/new_taxi_order.dart';
import 'package:fuodz/services/extened_order_service.dart';
import 'package:fuodz/services/notification.service.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:singleton/singleton.dart';

class TaxiBackgroundOrderService extends ExtendedOrderService {
  //
  /// Factory method that reuse same instance automatically
  factory TaxiBackgroundOrderService() =>
      Singleton.lazy(() => TaxiBackgroundOrderService._());

  /// Private constructor
  TaxiBackgroundOrderService._() {
    this.fbListener();
  }

  BehaviorSubject<NewTaxiOrder> showNewOrderStream = BehaviorSubject();
  NewTaxiOrder newOrder;

  processOrderNotification(NewTaxiOrder newOrder) async {
    //not in background
    showNewOrderStream.add(newOrder);
    if (appIsInBackground()) {
      //send notification to phone notification tray
      showNewOrderNotificationAlert(newOrder);
    }
  }

  showNewOrderNotificationAlert(
    NewTaxiOrder newOrder, {
    int notifcationId = 10,
  }) async {
    //
    // await LocalStorageService.getPrefs();
    //show action notification to driver
    AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: notifcationId,
        ticker: "${AppStrings.appName}",
        channelKey:
            NotificationService.newOrderNotificationChannel().channelKey,
        title: "New Order Alert".tr(),
        backgroundColor: AppColor.primaryColorDark ?? null,
        body: ("Pickup Location".tr() +
            ": " +
            "${newOrder.pickup.address} (${newOrder.pickupDistance.toInt().ceil()}km)"),
        notificationLayout: NotificationLayout.BigText,
        //
        payload: {
          "id": newOrder.id.toString(),
          "notifcationId": notifcationId.toString(),
          "newOrder": jsonEncode(newOrder.toJson()),
        },
      ),
      actionButtons: [
        NotificationActionButton(
          key: "accept",
          label: "Accept".tr(),
          color: Colors.green,
        ),
        NotificationActionButton(
          key: "reject",
          label: "Reject".tr(),
          color: Colors.red,
        ),
      ],
    );

    return;
  }
}
