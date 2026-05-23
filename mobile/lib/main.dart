import 'package:flutter/material.dart';

import 'app.dart';
import 'core/server_config.dart';
import 'services/local_notifications_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ServerConfig.load();
  LocalNotificationsService.instance.init();
  runApp(const VampirKoyluApp());
}
