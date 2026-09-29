import 'package:device_preview_plus/device_preview_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'admin/clinica_api.dart';
import 'auth/ui/auth_tabs_screen.dart';
import 'core/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ClinicaApi.sharedClient.loadSavedSession();

  // Activado por defecto en entorno Web (o mediante --dart-define=DEVICE_PREVIEW=true)
  const bool enableDevicePreview = bool.fromEnvironment(
    'DEVICE_PREVIEW',
    defaultValue: kIsWeb,
  );

  runApp(
    DevicePreview(
      enabled: enableDevicePreview,
      builder: (context) => const SmartCaseApp(),
    ),
  );
}

class SmartCaseApp extends StatelessWidget {
  const SmartCaseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SmartCase',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      locale: DevicePreview.locale(context),
      builder: DevicePreview.appBuilder,
      home: const AuthTabsScreen(),
    );
  }
}

// import 'map_test_screen.dart';
// Future<void> main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await ClinicaApi.sharedClient.loadSavedSession();

//   runApp(
//     const MaterialApp(
//       debugShowCheckedModeBanner: false,
//       title: 'Metro GPS',
//       home: MapTestScreen(),
//     ),
//   );
// }
