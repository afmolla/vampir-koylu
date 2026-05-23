import 'package:flutter/material.dart';

import 'app.dart';
import 'services/local_notifications_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  LocalNotificationsService.instance.init();
  runApp(const VampirKoyluApp());
}
