import 'dart:async';

import 'package:flutter_fgbg/flutter_fgbg.dart';
import 'package:fuodz/services/local_storage.service.dart';

class ExtendedOrderService {
  StreamSubscription<FGBGType> subscriptionFGBGType;

  void fbListener() {
    //
    LocalStorageService.prefs.setBool("appInBackground", false);
    //
    subscriptionFGBGType = FGBGEvents.stream.listen((event) {
      final appInBackground = (event == FGBGType.background);
      LocalStorageService.prefs.setBool("appInBackground", appInBackground);
    });
  }

  bool appIsInBackground() {
    return LocalStorageService.prefs.getBool("appInBackground") ?? false;
  }

  void dispose() {
    subscriptionFGBGType?.cancel();
  }
}
