import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pc_remote_control/features/audio/audio_page.dart';
import 'package:pc_remote_control/features/audio/models/audio_request.dart';
import 'package:pc_remote_control/features/audio/models/audio_session.dart';
import 'package:pc_remote_control/features/audio/services/audio_service.dart';
import 'package:pc_remote_control/features/audio/state/audio_browser_controller.dart';
import 'package:pc_remote_control/features/audio/theme/theme_context.dart';
import 'package:pc_remote_control/l10n/generated/app_localizations.dart';
import 'package:pc_remote_control/l10n/l10n_context.dart';

class MockAudioService extends Mock implements AudioService {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockAudioService mockAudioService;
  late AudioBrowserController controller;

  setUp(() {
    mockAudioService = MockAudioService();
    controller = AudioBrowserController(service: mockAudioService);
  });

  testWidgets(
    'renders compact layout and loads sessions after device selection',
    (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(390, 844));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      when(
        () => mockAudioService.listDevices(),
      ).thenAnswer(
        (_) async => [
          DeviceSound(id: 'device-1', name: 'Speakers'),
        ],
      );
      when(
        () => mockAudioService.listSessions('device-1'),
      ).thenAnswer(
        (_) async => [
          AudioSession(
            id: 'session-1',
            displayName: 'Spotify',
            volumeLevel: 64,
            state: AudioSessionState.active,
            muted: false,
          ),
        ],
      );

      await tester.pumpWidget(_buildTestApp(controller));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.text('Destino do som'), findsOneWidget);
      expect(find.text('Aplicativos com som'), findsOneWidget);

      await controller.selectDevice('device-1');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.text('Spotify'), findsOneWidget);
      expect(find.text('64%'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('shows sessions error message when session fetch fails', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1280, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    when(
      () => mockAudioService.listDevices(),
    ).thenAnswer(
      (_) async => [
        DeviceSound(id: 'device-1', name: 'Speakers'),
      ],
    );
    when(
      () => mockAudioService.listSessions('device-1'),
    ).thenThrow(Exception('boom'));

    await tester.pumpWidget(_buildTestApp(controller));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    await controller.selectDevice('device-1');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(
      find.text('Nao foi possivel carregar os aplicativos'),
      findsOneWidget,
    );
    expect(find.textContaining('boom'), findsOneWidget);
  });
}

Widget _buildTestApp(AudioBrowserController controller) {
  return MaterialApp(
    locale: const Locale('pt'),
    onGenerateTitle: (context) => context.l10n.appTitle,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    theme: buildAudioAppTheme(),
    home: AudioPage(controller: controller),
  );
}
