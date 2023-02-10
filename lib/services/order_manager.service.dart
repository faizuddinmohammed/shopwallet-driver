import 'dart:async';
import 'dart:convert';
import 'dart:isolate';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_isolate/flutter_isolate.dart';
import 'package:fuodz/constants/app_strings.dart';
import 'package:fuodz/models/new_order.dart';
import 'package:fuodz/models/new_taxi_order.dart';
import 'package:fuodz/services/auth.service.dart';
import 'package:fuodz/services/background_order.service.dart';
import 'package:fuodz/services/firebase_order_handler.service.dart';
import 'package:fuodz/services/local_storage.service.dart';
import 'package:fuodz/services/taxi_background_order.service.dart';
import 'package:schedulers/schedulers.dart';
import 'package:singleton/singleton.dart';

import 'app.service.dart';
import 'order_assignment.service.dart';

class OrderManagerService {
  //
  /// Factory method that reuse same instance automatically
  factory OrderManagerService() =>
      Singleton.lazy(() => OrderManagerService._());

  /// Private constructor
  OrderManagerService._() {}

  //
  FirebaseFirestore firebaseFireStore = FirebaseFirestore.instance;
  StreamSubscription<DocumentSnapshot> newOrderDocsRefSubscription;
  StreamSubscription<DocumentSnapshot> driverNewOrderDocsRefSubscription;
  StreamSubscription<dynamic> firebaseOrderHandlerServiceSubscription;
  IntervalScheduler driverNewOrderDataScheduler;
  final alertDriverNewOrderAlert = "can_notify_driver";

  //listen to driver new order firebase node
  void startListener() async {
    //
    //for new driver matching system
    if (AppStrings.driverMatchingNewSystem) {
      if (firebaseOrderHandlerServiceSubscription != null) {
        print("prevent multiple calls");
        return;
      }

      final driver = AuthServices.currentUser.toJson() ?? {};
      Map<String, dynamic> jsonObject = {
        "user": driver,
        "vehicle": AuthServices.driverVehicle.toJson() ?? {},
      };
      //
      firebaseOrderHandlerServiceSubscription?.cancel();
      firebaseOrderHandlerServiceSubscription =
          FirebaseOrderHandlerService.port.asBroadcastStream().listen(
        (data) async {
          String docRef = data[0];
          dynamic newOrderAlertData = data[1];
          //
          if (newOrderAlertData == null) {
            return;
          }

          //
          newOrderAlertData = newOrderAlertData as Map<String, dynamic>;
          bool canHandleOrder =
              await OrderAssignmentService.driverCanHandleOrder(
            newOrderAlertData,
            docRef,
          );

          //
          if (canShowAlert() && canHandleOrder) {
            final hasVehicle =
                newOrderAlertData.containsKey("vehicle_type_id") ?? false;
            //if is taxi
            if (hasVehicle) {
              NewTaxiOrder nTOrder = NewTaxiOrder.fromJson(newOrderAlertData);
              nTOrder.docRef = docRef;
              TaxiBackgroundOrderService().processOrderNotification(nTOrder);
            } else {
              NewOrder newOrder = NewOrder.fromJson(newOrderAlertData);
              newOrder.docRef = docRef;
              BackgroundOrderService().processOrderNotification(newOrder);
            }
            toggleCanShowAlert(allow: false);
          }

          //auto allow the
          await Future.delayed(Duration(seconds: AppStrings.alertDuration));
          toggleCanShowAlert(allow: true);
          //schedule a data delete functon/action
          scheduleClearDriverNewOrderListener();
        },
      );
      FlutterIsolate.spawn(
        FirebaseOrderHandlerService.startAutoOrderAssignment,
        [jsonEncode(jsonObject), FirebaseOrderHandlerService.port.sendPort],
      );
    } 
    //old driver matching from firebase notification
    else {
      final driverId = (await AuthServices.getCurrentUser()).id.toString();
      final newOrderDocsRef =
          firebaseFireStore.collection("driver_new_order").doc(driverId);
      //close any previous listener
      newOrderDocsRefSubscription?.cancel();
      //start the data listener
      newOrderDocsRefSubscription = newOrderDocsRef.snapshots().listen(
        (docSnapshot) async {
          //
          final newOrderAlertData = docSnapshot.data();
          if (newOrderAlertData == null) {
            return;
          }

          print("New order metadata ===> ${docSnapshot.metadata}");
          if (!docSnapshot.exists) {
            return;
          }
          //
          if (canShowAlert()) {
            final hasVehicle =
                newOrderAlertData.containsKey("vehicle_type_id") ?? false;
            //if is taxi
            if (hasVehicle) {
              final newTaxiOrder = NewTaxiOrder.fromJson(newOrderAlertData);
              TaxiBackgroundOrderService()
                  .processOrderNotification(newTaxiOrder);
            } else {
              final newOrder = NewOrder.fromJson(newOrderAlertData);
              BackgroundOrderService().processOrderNotification(newOrder);
            }
            toggleCanShowAlert(allow: false);
          }

          //auto allow the
          await Future.delayed(Duration(seconds: AppStrings.alertDuration));
          toggleCanShowAlert(allow: true);
          //schedule a data delete functon/action
          scheduleClearDriverNewOrderListener();
        },
      );
    }
  }

  //stop
  bool stopListener() {
    if (newOrderDocsRefSubscription != null) {
      newOrderDocsRefSubscription?.cancel();
    }
    // driverNewOrderDocsRefSubscription?.cancel();
    //
    firebaseOrderHandlerServiceSubscription?.cancel();
    firebaseOrderHandlerServiceSubscription = null;
    FirebaseOrderHandlerService?.port?.close();
    FirebaseOrderHandlerService.port = ReceivePort();
    return true;
  }

  //This is not monitor if the driver node onf ifrestore has the online/free fields
  //so it can be used in connecting order to drivers
  void monitorOnlineStatusListener({AppService appService}) async {
    //
    final driverId = (await AuthServices.getCurrentUser()).id.toString();
    final driverDoc =
        await firebaseFireStore.collection("drivers").doc(driverId).get();

    bool shouldGoOffline = false;
    //if exists
    if (driverDoc.exists) {
      //
      if (!driverDoc.data().containsKey("online") ||
          !driverDoc.data().containsKey("free")) {
        //forcefully update doc value
        await driverDoc.reference.update(
          {
            "online": driverDoc.data().containsKey("online")
                ? driverDoc.get("online")
                : 1,
            "free": driverDoc.data().containsKey("free")
                ? driverDoc.get("free")
                : 1,
          },
        );
      }
    } else {
      shouldGoOffline = true;
      await driverDoc.reference.set(
        {
          "online": AppService().driverIsOnline ? 1 : 0,
          "free": 1,
        },
      );
    }
    //set the status to the backend
    if (shouldGoOffline) {
      await LocalStorageService.prefs.setBool(AppStrings.onlineOnApp, false);
      if (appService != null) {
        appService.driverIsOnline = false;
      } else {
        AppService().driverIsOnline = false;
      }
    }
  }

  //MONITOR IF NEW ALERT SHOULD BE SHOWN TO DRIVER OR NOT
  bool canShowAlert() {
    return LocalStorageService.prefs.getBool(alertDriverNewOrderAlert) ?? true;
  }

  Future<void> toggleCanShowAlert({bool allow}) async {
    bool allowed = !canShowAlert();
    if (allow != null) {
      allowed = allow;
    }
    await LocalStorageService.prefs.setBool(alertDriverNewOrderAlert, allowed);
  }
  //DONE

  //
  void scheduleClearDriverNewOrderListener() {
    if (driverNewOrderDataScheduler != null) {
      driverNewOrderDataScheduler.dispose();
      driverNewOrderDataScheduler = null;
    }

    if (driverNewOrderDataScheduler == null) {
      driverNewOrderDataScheduler = IntervalScheduler(
        delay: Duration(seconds: AppStrings.alertDuration),
      );
    }
    //
    driverNewOrderDataScheduler.run(
      () => clearDriverNewOrderListener(),
    );
  }

  //This is delete exipred driver_new_order data
  void clearDriverNewOrderListener() async {
    //
    final driverId = (await AuthServices.getCurrentUser()).id.toString();
    final driverNewOrderData = await firebaseFireStore
        .collection("driver_new_order")
        .doc(driverId)
        .get();

    //
    if (driverNewOrderData.exists) {
      await firebaseFireStore
          .collection("driver_new_order")
          .doc(driverId)
          .delete();
    }
  }
}
