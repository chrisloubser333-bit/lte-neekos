import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'providers/chat_provider.dart';
import 'providers/settings_provider.dart';
import 'screens/chat_screen.dart';
import 'services/xai_service.dart';
import 'services/storage_service.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Status bar style for dark futuristic look
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: AppTheme.background,
    systemNavigationBarIconBrightness: Brightness.light,
  ));

  final storage = StorageService();
  await storage.init();

  final xai = XaiService();
  final savedKey = await storage.getApiKey();
  if (savedKey != null && savedKey.isNotEmpty) {
    xai.setApiKey(savedKey);
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SettingsProvider(storage)),
        ChangeNotifierProvider(
          create: (context) => ChatProvider(
            xai,
            context.read<SettingsProvider>(),
            storage,
          ),
        ),
      ],
      child: const LteApp(),
    ),
  );
}

class LteApp extends StatelessWidget {
  const LteApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Force the futuristic dark theme as the primary experience
    return MaterialApp(
      title: 'Listen with Eve',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark,
      darkTheme: AppTheme.darkTheme,
      theme: AppTheme.darkTheme, // also set light to dark for consistency
      home: const ChatScreen(),
    );
  }
}
