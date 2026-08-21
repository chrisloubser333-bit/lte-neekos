import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'providers/chat_provider.dart';
import 'providers/settings_provider.dart';
import 'screens/chat_screen.dart';
import 'services/xai_service.dart';
import 'services/storage_service.dart';
import 'services/memory_manager.dart';
import 'services/memory_intelligence_service.dart';
import 'services/embedding_service.dart';
import 'services/ai_provider.dart';
import 'services/ai_http_providers.dart';
import 'models/ai_model_option.dart';
import 'providers/memory_provider.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: AppTheme.background,
    systemNavigationBarIconBrightness: Brightness.light,
  ));

  final storage = StorageService();
  await storage.init();
  final keys = <AiProviderId, String?>{};
  for (final provider in AiProviderId.values) {
    keys[provider] = await storage.getProviderApiKey(provider.name);
  }

  final xai = XaiService();
  if ((keys[AiProviderId.xai] ?? '').isNotEmpty) xai.setApiKey(keys[AiProviderId.xai]!);
  final registry = AiProviderRegistry([
    XaiChatProvider(xai),
    OpenAiProvider(keys[AiProviderId.openai]),
    AnthropicProvider(keys[AiProviderId.anthropic]),
    GoogleGeminiProvider(keys[AiProviderId.google]),
  ]);
  final embedding = EmbeddingService(keys[AiProviderId.openai]);
  final memory = MemoryManager(storage, embedding);
  final memoryIntelligence = MemoryIntelligenceService(registry);

  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => SettingsProvider(storage)),
      ChangeNotifierProvider.value(value: memory),
      ChangeNotifierProvider(create: (_) => MemoryProvider(memory)),
      ChangeNotifierProvider(create: (context) => ChatProvider(
        xai, registry, context.read<SettingsProvider>(), storage, memory, memoryIntelligence,
      )),
    ],
    child: const LteApp(),
  ));
}

/// Adapter that preserves the existing xAI service for the provider gateway.
class XaiChatProvider implements AiProvider {
  @override
  void setApiKey(String key) {}
  final XaiService service;
  XaiChatProvider(this.service);
  @override AiProviderId get id => AiProviderId.xai;
  @override bool get isConfigured => service.hasApiKey;
  @override Future<String> chat(AiChatRequest request) => service.chatCompletion(
    messages: request.messages, model: request.model, systemPrompt: request.systemPrompt,
  );
}

class LteApp extends StatelessWidget {
  const LteApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Listen with Eve',
    debugShowCheckedModeBanner: false,
    themeMode: ThemeMode.dark,
    darkTheme: AppTheme.darkTheme,
    theme: AppTheme.darkTheme,
    home: const ChatScreen(),
  );
}

// Fix missing AiProvider method
extension AiProviderApiKeyFix on AiProvider {
  void setApiKey(String key) {}
}
