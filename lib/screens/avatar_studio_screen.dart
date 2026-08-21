import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/talking_avatar.dart';

class AvatarStudioScreen extends StatefulWidget {
  const AvatarStudioScreen({super.key});

  @override
  State<AvatarStudioScreen> createState() => _AvatarStudioScreenState();
}

class _AvatarStudioScreenState extends State<AvatarStudioScreen> {
  final ImagePicker _picker = ImagePicker();

  Future<void> _pick(ImageSource source) async {
    final file = await _picker.pickImage(
      source: source,
      imageQuality: 88,
      maxWidth: 1200,
    );
    if (file == null || !mounted) return;
    await context.read<SettingsProvider>().setAvatarPath(file.path);
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final isAf = settings.language == 'af';

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(isAf ? 'Eve-avatar' : 'Eve Avatar Studio'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Center(
            child: TalkingAvatar(
              imagePath: settings.avatarPath,
              isSpeaking: false,
              size: 220,
            ),
          ),
          const SizedBox(height: 28),
          Text(
            isAf ? 'Kies Eve se voorkoms' : 'Choose Eve’s appearance',
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            isAf
                ? 'Gebruik ’n foto om ’n persoonlike avatar-identiteit te skep.'
                : 'Use a photo as the visual identity for your personalized avatar.',
            style: const TextStyle(color: AppTheme.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: () => _pick(ImageSource.camera),
                  icon: const Icon(Icons.camera_alt_rounded),
                  label: Text(isAf ? 'Neem foto' : 'Take photo'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _pick(ImageSource.gallery),
                  icon: const Icon(Icons.photo_library_rounded),
                  label: Text(isAf ? 'Galery' : 'Gallery'),
                ),
              ),
            ],
          ),
          if (settings.avatarPath != null) ...[
            const SizedBox(height: 12),
            TextButton.icon(
              onPressed: () => settings.setAvatarPath(null),
              icon: const Icon(Icons.restore_rounded),
              label: Text(isAf ? 'Gebruik standaard Eve' : 'Use default Eve'),
            ),
          ],
          const SizedBox(height: 28),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.surface.withOpacity(.7),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.border),
            ),
            child: const Text(
              'Face calibration runs on-device when you choose a photo. Eve detects the eyes and lips once, then uses that geometry for the live lip-sync animation. Your photo remains the visual identity.',
              style: TextStyle(color: AppTheme.textSecondary, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}
