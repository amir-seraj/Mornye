import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mornye/l10n/app_localizations.dart';
import 'package:mornye/providers/music_player_provider.dart';
import 'package:mornye/services/playback_deck.dart' show playbackOutputVolume;
import 'package:mornye/theme/app_theme.dart';
import 'package:mornye/utils/desktop_platform.dart';
import 'package:mornye/widgets/desktop/desktop_player_bar.dart';

const _channel = MethodChannel('com.zarz.mornye/window');

const _track = MediaItem(
  id: 'track',
  title: 'Stateside',
  artist: 'An artist',
  album: 'Fancy Some More?',
  duration: Duration(minutes: 3, seconds: 12),
);

class _RetroTestController extends MusicPlayerController {
  int? jumpedTo;
  Duration? soughtTo;
  final toggles = <bool>[];
  int previousCalls = 0;
  int nextCalls = 0;

  @override
  Future<void> togglePlayPause(bool isPlaying) async => toggles.add(isPlaying);

  @override
  Future<void> previous() async => previousCalls++;

  @override
  Future<void> next() async => nextCalls++;

  @override
  Future<void> jumpTo(int index) async => jumpedTo = index;

  @override
  Future<void> seek(Duration position) async => soughtTo = position;
}

void main() {
  late List<MethodCall> calls;
  late bool transparencySupported;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    debugDesktopPlatformOverride = true;
    calls = [];
    transparencySupported = true;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_channel, (call) async {
          calls.add(call);
          return switch (call.method) {
            'openMiniPlayer' => true,
            'setTransparent' => transparencySupported,
            _ => null,
          };
        });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_channel, null);
    debugDesktopPlatformOverride = null;
    desktopMiniPlayerOpen.value = false;
    desktopMiniPlayerSkin.value = DesktopMiniPlayerSkin.classic;
    desktopWindowSeeThrough.value = false;
  });

  test('switching skins resizes the panel and toggles transparency', () async {
    await setDesktopMiniPlayer(open: true);
    calls.clear();

    await setDesktopMiniPlayerSkin(DesktopMiniPlayerSkin.retro);
    expect(calls.map((call) => call.method), [
      'openMiniPlayer',
      'setTransparent',
    ]);
    expect(calls.first.arguments, {'width': 720.0, 'height': 520.0});
    expect(calls.last.arguments, {'transparent': true});
    expect(desktopWindowSeeThrough.value, isTrue);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('desktop_mini_player_skin'), 'retro');

    calls.clear();
    await setDesktopMiniPlayerSkin(DesktopMiniPlayerSkin.classic);
    // Opaque again before the panel shrinks back.
    expect(calls.map((call) => call.method), [
      'setTransparent',
      'openMiniPlayer',
    ]);
    expect(calls.first.arguments, {'transparent': false});
    expect(calls.last.arguments, {'width': 360.0, 'height': 140.0});
    expect(desktopWindowSeeThrough.value, isFalse);
  });

  test('the retro panel opens see-through and closes opaque', () async {
    desktopMiniPlayerSkin.value = DesktopMiniPlayerSkin.retro;
    await setDesktopMiniPlayer(open: true);
    expect(calls.map((call) => call.method), [
      'openMiniPlayer',
      'setTransparent',
    ]);
    expect(desktopWindowSeeThrough.value, isTrue);

    calls.clear();
    await setDesktopMiniPlayer(open: false);
    expect(calls.map((call) => call.method), [
      'setTransparent',
      'closeMiniPlayer',
    ]);
    expect(desktopWindowSeeThrough.value, isFalse);
  });

  test('stays opaque where the runner cannot be transparent', () async {
    transparencySupported = false;
    desktopMiniPlayerSkin.value = DesktopMiniPlayerSkin.retro;
    await setDesktopMiniPlayer(open: true);
    expect(desktopMiniPlayerOpen.value, isTrue);
    expect(desktopWindowSeeThrough.value, isFalse);
  });

  test('the skin buttons cycle through every skin', () async {
    await setDesktopMiniPlayer(open: true);
    await setDesktopMiniPlayerSkin(DesktopMiniPlayerSkin.retro);
    calls.clear();
    await setDesktopMiniPlayerSkin(DesktopMiniPlayerSkin.gunmetal);
    expect(calls.first.arguments, {'width': 480.0, 'height': 300.0});
    // Still see-through: both chassis skins are shaped.
    expect(calls.where((call) => call.method == 'setTransparent'), isEmpty);
    expect(desktopWindowSeeThrough.value, isTrue);
  });

  test('restores the saved skin', () async {
    SharedPreferences.setMockInitialValues({
      'desktop_mini_player_skin': 'retro',
    });
    restoreDesktopMiniPlayerSkin(await SharedPreferences.getInstance());
    expect(desktopMiniPlayerSkin.value, DesktopMiniPlayerSkin.retro);
  });

  testWidgets('draws the retro chassis and drives playback', (tester) async {
    tester.view.physicalSize = const Size(720, 520);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    desktopMiniPlayerSkin.value = DesktopMiniPlayerSkin.retro;
    final playback = StreamController<PlaybackState>.broadcast();
    addTearDown(playback.close);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          currentMediaItemProvider.overrideWithBuild(
            (ref, notifier) => Stream.value(_track),
          ),
          playbackStateProvider.overrideWith((ref) => playback.stream),
        ],
        child: MaterialApp(
          theme: AppTheme.dark(),
          debugShowCheckedModeBanner: false,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const Scaffold(
            backgroundColor: Color(0xFF2B4C9E),
            body: DesktopMiniPlayer(),
          ),
        ),
      ),
    );
    playback.add(
      PlaybackState(
        playing: true,
        processingState: AudioProcessingState.ready,
        updatePosition: const Duration(seconds: 42),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('Stateside'), findsOneWidget);
    expect(find.text('Fancy Some More?'), findsOneWidget);
    expect(find.byKey(const ValueKey('retro-play-pause')), findsOneWidget);

    // Pausing lets the visualizer settle and stop ticking.
    playback.add(PlaybackState(processingState: AudioProcessingState.ready));
    await tester.pump();
    for (var i = 0; i < 150; i++) {
      await tester.pump(const Duration(milliseconds: 16));
    }
    expect(tester.binding.hasScheduledFrame, isFalse);
  });

  testWidgets('retro queue, volume and seeking use the playback APIs', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(720, 520);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    desktopMiniPlayerSkin.value = DesktopMiniPlayerSkin.retro;
    final controller = _RetroTestController();
    final oldVolume = playbackOutputVolume.value;
    playbackOutputVolume.value = 0.3;
    addTearDown(() => playbackOutputVolume.value = oldVolume);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          currentMediaItemProvider.overrideWithBuild(
            (ref, notifier) => Stream.value(_track),
          ),
          playbackStateProvider.overrideWith(
            (ref) => Stream.value(
              PlaybackState(processingState: AudioProcessingState.ready),
            ),
          ),
          playQueueProvider.overrideWith(
            (ref) => Stream.value([
              _track,
              const MediaItem(
                id: 'next',
                title: 'Another track',
                duration: Duration(minutes: 4, seconds: 5),
              ),
            ]),
          ),
          musicPlayerControllerProvider.overrideWithValue(controller),
        ],
        child: MaterialApp(
          theme: AppTheme.dark(),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const Scaffold(body: DesktopMiniPlayer()),
        ),
      ),
    );
    await tester.pump();
    expect(find.text('Another track'), findsOneWidget);
    expect(find.text('4:05'), findsOneWidget);
    await tester.tap(find.text('Another track'));
    expect(controller.jumpedTo, 1);
    // The right-hand horizontal fader changes the desktop output gain.
    await tester.tapAt(const Offset(222, 167));
    await tester.pump();
    expect(playbackOutputVolume.value, greaterThan(0.3));
    // Dragging the seek groove commits a duration through the controller.
    await tester.dragFrom(const Offset(300, 303), const Offset(85, 0));
    await tester.pump();
    expect(controller.soughtTo, isNotNull);
    expect(controller.soughtTo!.inSeconds, greaterThan(60));
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('prophet transport, seeking, volume and skin cycle work', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 520);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    desktopMiniPlayerSkin.value = DesktopMiniPlayerSkin.prophet;
    final controller = _RetroTestController();
    final playback = StreamController<PlaybackState>.broadcast();
    addTearDown(playback.close);
    final oldVolume = playbackOutputVolume.value;
    playbackOutputVolume.value = .3;
    addTearDown(() => playbackOutputVolume.value = oldVolume);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          currentMediaItemProvider.overrideWithBuild(
            (ref, notifier) => Stream.value(_track),
          ),
          playbackStateProvider.overrideWith((ref) => playback.stream),
          musicPlayerControllerProvider.overrideWithValue(controller),
        ],
        child: MaterialApp(
          theme: AppTheme.dark(),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const Scaffold(body: DesktopMiniPlayer()),
        ),
      ),
    );
    await tester.pump();
    expect(find.text('Stateside'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('prophet-play-pause')));
    expect(controller.toggles, [false]);
    playback.add(
      PlaybackState(playing: true, processingState: AudioProcessingState.ready),
    );
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('prophet-pause')));
    expect(controller.toggles, [false, true]);
    await tester.tap(find.byKey(const ValueKey('prophet-previous')));
    await tester.tap(find.byKey(const ValueKey('prophet-next')));
    expect(controller.previousCalls, 1);
    expect(controller.nextCalls, 1);
    await tester.dragFrom(const Offset(150, 404), const Offset(90, 0));
    await tester.pump();
    expect(controller.soughtTo!.inSeconds, greaterThan(60));
    await tester.tapAt(const Offset(240, 30));
    await tester.pump();
    expect(playbackOutputVolume.value, greaterThan(.3));
    final beforeScroll = playbackOutputVolume.value;
    await tester.sendEventToBinding(
      const PointerScrollEvent(
        position: Offset(240, 30),
        scrollDelta: Offset(0, -20),
      ),
    );
    await tester.pump();
    expect(playbackOutputVolume.value, greaterThan(beforeScroll));
    await tester.tap(find.byTooltip('Next Skin').first);
    await tester.pump();
    expect(desktopMiniPlayerSkin.value, DesktopMiniPlayerSkin.classic);
    await tester.pumpWidget(const SizedBox());
  });

  for (final skin in DesktopMiniPlayerSkin.values) {
    if (skin == DesktopMiniPlayerSkin.classic) continue;
    testWidgets('the ${skin.name} skin lays out and settles', (tester) async {
      final size = switch (skin) {
        DesktopMiniPlayerSkin.gunmetal => const Size(480, 300),
        DesktopMiniPlayerSkin.thorn => const Size(330, 500),
        DesktopMiniPlayerSkin.machined => const Size(440, 440),
        DesktopMiniPlayerSkin.vault => const Size(500, 420),
        DesktopMiniPlayerSkin.jelly => const Size(480, 250),
        DesktopMiniPlayerSkin.prophet => const Size(360, 520),
        _ => const Size(720, 520),
      };
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      desktopMiniPlayerSkin.value = skin;
      final playback = StreamController<PlaybackState>.broadcast();
      addTearDown(playback.close);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            currentMediaItemProvider.overrideWithBuild(
              (ref, notifier) => Stream.value(_track),
            ),
            playbackStateProvider.overrideWith((ref) => playback.stream),
          ],
          child: MaterialApp(
            theme: AppTheme.dark(),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const Scaffold(body: DesktopMiniPlayer()),
          ),
        ),
      );
      playback.add(
        PlaybackState(
          playing: true,
          processingState: AudioProcessingState.ready,
          updatePosition: const Duration(seconds: 30),
        ),
      );
      for (var i = 0; i < 30; i++) {
        await tester.pump(const Duration(milliseconds: 16));
      }
      expect(tester.takeException(), isNull);
      playback.add(PlaybackState(processingState: AudioProcessingState.ready));
      for (var i = 0; i < 200; i++) {
        await tester.pump(const Duration(milliseconds: 16));
      }
      expect(tester.binding.hasScheduledFrame, isFalse);
    });
  }
}
