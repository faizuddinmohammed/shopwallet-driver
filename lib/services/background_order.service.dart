import 'dart:async';
import 'dart:convert';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:fuodz/constants/app_colors.dart';
import 'package:fuodz/constants/app_strings.dart';
import 'package:fuodz/models/new_order.dart';
import 'package:fuodz/services/notification.service.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:singleton/singleton.dart';
import 'package:velocity_x/src/extensions/num_ext.dart';

import 'extened_order_service.dart';

class BackgroundOrderService extends ExtendedOrderService {
  //
  /// Factory method that reuse same instance automatically
  factory BackgroundOrderService() =>
      Singleton.lazy(() => BackgroundOrderService._());

  /// Private constructor
  BackgroundOrderService._() {
    this.fbListener();
  }
  StreamController<NewOrder> showNewOrderStream = StreamController.broadcast();
  NewOrder newOrder;

  //
  processOrderNotification(NewOrder newOrder) async {
    //
    showNewOrderStream.add(newOrder);
    if (appIsInBackground()) {
      showNewOrderNotificationAlert(newOrder);
    }
  }

  //
  //show notification
  showNewOrderNotificationAlert(
    NewOrder newOrder, {
    int notifcationId = 10,
  }) async {
    //
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
            "${newOrder.pickup.address} (${newOrder.pickup.distance.numCurrency}km)"),
        notificationLayout: NotificationLayout.BigText,
        //
        payload: {
          "id": newOrder.id.toString(),
          "notifcationId": notifcationId.toString(),
          "newOrder": jsonEncode(newOrder.toJson()),
        },
        criticalAlert: true,
      ),
      actionButtons: [
        NotificationActionButton(
          key: "open",
          label: "Open".tr(),
          color:AppColor.primaryColor,
        ),
      ],
    );

    return;
  }
}
