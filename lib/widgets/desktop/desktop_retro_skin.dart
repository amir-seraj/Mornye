part of 'desktop_player_bar.dart';

/// How the floating mini player looks.
enum DesktopMiniPlayerSkin {
  /// The regular panel: artwork, title, transport and progress.
  classic,

  /// A lime plastic chassis in the spirit of early 2000s media player skins:
  /// speaker wings, pill buttons and a dark CRT with ribbon bars. The window turns see-through around it where the runner
  /// supports that (Linux on a compositing desktop).
  retro,

  /// A bulky gunmetal shell: brushed metal, chrome bevels, a big obsidian
  /// play dome and a curved glass screen with a glowing green orb behind
  /// the track. See-through around it, like [retro].
  gunmetal,

  /// A tarnished chrome candybar phone wrapped in thorned vines and chrome
  /// roses, with a pixel-grid green screen and a Roman-numeral keypad.
  thorn,

  /// A square machined CD deck: bolted gray metal, crimson anodized plates,
  /// a small green LCD, a brass knob, and the disc turning behind cutouts.
  machined,

  /// A matte-black disc machine: a large disc turning inside ribbed arc
  /// segments, a tall touchscreen beside it and a lock knob at the hub.
  vault,

  /// A glossy liquid-lime blob with a black screen, a seek slider, bubble
  /// buttons and a lime-slice speaker.
  jelly,

  /// A faceted wandering prophet carrying a linen sandwich-board player.
  prophet,
}

/// The skin after [skin], as the chassis's skin buttons cycle them.
DesktopMiniPlayerSkin _nextSkin(DesktopMiniPlayerSkin skin) =>
    DesktopMiniPlayerSkin.values[(skin.index + 1) %
        DesktopMiniPlayerSkin.values.length];

const _miniPlayerSkinKey = 'desktop_mini_player_skin';

/// The retro chassis, in logical pixels. The window is exactly this size.
const Size _retroSkinSize = Size(720, 520);

/// The gunmetal shell, in logical pixels.
const Size _gunmetalSkinSize = Size(480, 300);

/// The thorn phone with its roses and crest, in logical pixels.
const Size _thornSkinSize = Size(330, 500);

/// The machined deck, the vault and the jelly blob, in logical pixels.
const Size _machinedSkinSize = Size(440, 440);
const Size _vaultSkinSize = Size(500, 420);
const Size _jellySkinSize = Size(480, 250);
const Size _prophetSkinSize = Size(360, 520);

/// The window size a chassis skin needs.
Size _chassisSize(DesktopMiniPlayerSkin skin) => switch (skin) {
  DesktopMiniPlayerSkin.gunmetal => _gunmetalSkinSize,
  DesktopMiniPlayerSkin.thorn => _thornSkinSize,
  DesktopMiniPlayerSkin.machined => _machinedSkinSize,
  DesktopMiniPlayerSkin.vault => _vaultSkinSize,
  DesktopMiniPlayerSkin.jelly => _jellySkinSize,
  DesktopMiniPlayerSkin.prophet => _prophetSkinSize,
  _ => _retroSkinSize,
};

/// The mini player's skin. [setDesktopMiniPlayerSkin] changes and keeps it.
final desktopMiniPlayerSkin = ValueNotifier<DesktopMiniPlayerSkin>(
  DesktopMiniPlayerSkin.classic,
);

/// Whether the window is see-through right now. The desktop shell stops
/// painting its background while it is, so only the chassis shows.
final desktopWindowSeeThrough = ValueNotifier<bool>(false);

/// Restores the skin [setDesktopMiniPlayerSkin] last saved.
void restoreDesktopMiniPlayerSkin(SharedPreferences prefs) {
  final saved = prefs.getString(_miniPlayerSkinKey);
  desktopMiniPlayerSkin.value = DesktopMiniPlayerSkin.values.firstWhere(
    (skin) => skin.name == saved,
    orElse: () => DesktopMiniPlayerSkin.classic,
  );
}

/// Turns window transparency on or off. Going opaque, the shell paints again
/// before the runner clears to black, so nothing behind ever flashes through.
Future<void> _setWindowSeeThrough(bool seeThrough) async {
  if (!seeThrough) {
    if (!desktopWindowSeeThrough.value) return;
    desktopWindowSeeThrough.value = false;
    await setDesktopWindowTransparent(false);
    return;
  }
  if (desktopWindowSeeThrough.value) return;
  final applied = await setDesktopWindowTransparent(true);
  desktopWindowSeeThrough.value =
      applied &&
      desktopMiniPlayerOpen.value &&
      desktopMiniPlayerSkin.value != DesktopMiniPlayerSkin.classic;
  if (applied && !desktopWindowSeeThrough.value) {
    await setDesktopWindowTransparent(false);
  }
}

/// Switches the mini player's skin, resizing the open panel, and keeps the
/// choice for the next time it opens.
Future<void> setDesktopMiniPlayerSkin(DesktopMiniPlayerSkin skin) async {
  if (skin == desktopMiniPlayerSkin.value || _miniPlayerBusy) return;
  _miniPlayerBusy = true;
  try {
    final previous = desktopMiniPlayerSkin.value;
    if (desktopMiniPlayerOpen.value) {
      if (skin == DesktopMiniPlayerSkin.classic) {
        await _setWindowSeeThrough(false);
      }
      desktopMiniPlayerSkin.value = skin;
      final resized = await openDesktopMiniPlayerWindow(desktopMiniPlayerSize);
      if (!resized) {
        desktopMiniPlayerSkin.value = previous;
        return;
      }
      if (skin != DesktopMiniPlayerSkin.classic) {
        await _setWindowSeeThrough(true);
      }
    } else {
      desktopMiniPlayerSkin.value = skin;
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_miniPlayerSkinKey, skin.name);
  } finally {
    _miniPlayerBusy = false;
  }
}

// Palette: lime plastic, its dark rim, and the LCD's blues.
const _limeHighlight = Color(0xFFD6FF63);
const _limeLight = Color(0xFFA8EE2E);
const _limeMid = Color(0xFF79CC12);
const _limeDeep = Color(0xFF4A960A);
const _limeRim = Color(0xFF2A5A05);
const _lcdText = Color(0xFFE3ECFF);
const _lcdGlow = Color(0xFF5A8CFF);
const _lcdCyan = Color(0xFF6FD3FF);

/// The rounded crown, deep screen pod and tapering sculpted chin.
Path _retroBodyPath() => Path()
  ..moveTo(240, 178)
  ..cubicTo(240, 88, 276, 30, 360, 30)
  ..cubicTo(444, 30, 480, 88, 480, 178)
  ..lineTo(480, 290)
  ..cubicTo(480, 368, 436, 487, 360, 487)
  ..cubicTo(284, 487, 240, 368, 240, 290)
  ..close();

Path _retroWingsPath() =>
    Path()
      ..addRRect(RRect.fromLTRBR(12, 135, 708, 333, const Radius.circular(35)));

/// The large sculpted chin, also the user's picture surface.
Path _retroFacePath() => Path.combine(
  PathOperation.intersect,
  _retroBodyPath(),
  Path()..addRect(const Rect.fromLTRB(240, 334, 480, 490)),
);

class _RetroFaceClipper extends CustomClipper<Path> {
  const _RetroFaceClipper();

  @override
  Path getClip(Size size) => _retroFacePath();

  @override
  bool shouldReclip(_RetroFaceClipper oldClipper) => false;
}

/// Everything the chassis covers: where the window can be dragged.
Path _retroChassisPath() =>
    Path.combine(PathOperation.union, _retroBodyPath(), _retroWingsPath());

class _RetroChassisClipper extends CustomClipper<Path> {
  const _RetroChassisClipper();

  @override
  Path getClip(Size size) => _retroChassisPath();

  @override
  bool shouldReclip(_RetroChassisClipper oldClipper) => false;
}

/// Deterministic microtexture for stationary material layers. Two batched
/// paths keep the finish cheap to record inside the chassis repaint boundary.
void _skinGrain(
  Canvas canvas,
  Rect bounds, {
  required int seed,
  double strength = 0.025,
  double pitch = 4,
}) {
  final random = math.Random(seed);
  final light = Path();
  final dark = Path();
  for (var y = bounds.top; y < bounds.bottom; y += pitch) {
    for (var x = bounds.left; x < bounds.right; x += pitch) {
      final dot = Rect.fromLTWH(
        x + random.nextDouble() * pitch,
        y + random.nextDouble() * pitch,
        0.65,
        0.65,
      );
      (random.nextBool() ? light : dark).addOval(dot);
    }
  }
  canvas.drawPath(
    light,
    Paint()..color = const Color(0xFFEAF0DB).withValues(alpha: strength),
  );
  canvas.drawPath(
    dark,
    Paint()..color = const Color(0xFF101810).withValues(alpha: strength * 1.5),
  );
}

/// Grazing light on a rounded edge, with the light fixed above and left.
/// Clipping makes the lower-right stroke an inset shade, not an outer halo.
void _skinRelief(
  Canvas canvas,
  Path shape, {
  required Color shade,
  required Color light,
  double width = 6,
}) {
  canvas.save();
  canvas.clipPath(shape);
  canvas.drawPath(
    shape.shift(const Offset(2, 3)),
    Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = width
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [light, light.withValues(alpha: 0)],
      ).createShader(shape.getBounds()),
  );
  canvas.drawPath(
    shape.shift(const Offset(-2, -3)),
    Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = width * 1.6
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [shade.withValues(alpha: 0), shade],
      ).createShader(shape.getBounds()),
  );
  canvas.restore();
}

/// Paints the plastic: wings, body, gloss, rims and, without a face
/// picture, the jaw's grille.
class _RetroChassisPainter extends CustomPainter {
  const _RetroChassisPainter({this.face = false});

  /// A face picture covers the jaw, so the grille is left off.
  final bool face;

  void _plastic(Canvas canvas, Path path, Rect bounds, List<Color> colors) {
    canvas.drawPath(
      path,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors,
        ).createShader(bounds),
    );
    // A rounded bevel: a bright lip inside the top edge and a deep shade
    // inside the bottom, both soft, so the plastic reads as thick and domed.
    canvas.save();
    canvas.clipPath(path);
    canvas.drawPath(
      path.shift(const Offset(0, 5)),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 7
        ..color = Colors.white.withValues(alpha: 0.32)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
    );
    canvas.drawPath(
      path.shift(const Offset(0, 2)),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..color = Colors.white.withValues(alpha: 0.55),
    );
    canvas.drawPath(
      path.shift(const Offset(0, -6)),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 10
        ..color = _limeRim.withValues(alpha: 0.4)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );
    _skinGrain(canvas, bounds, seed: 19, strength: 0.035, pitch: 3.5);
    canvas.restore();
    _skinRelief(
      canvas,
      path,
      shade: _limeRim.withValues(alpha: 0.6),
      light: _limeHighlight.withValues(alpha: 0.85),
      width: 7,
    );
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6
        ..color = _limeRim,
    );
  }

  /// The molding's side wall: the outline stacked downward [depth] pixels,
  /// darkening toward the bottom, so the part stands off the desktop.
  void _extrude(Canvas canvas, Path path, double depth) {
    for (var d = depth; d >= 1; d--) {
      canvas.drawPath(
        path.shift(Offset(0, d)),
        Paint()
          ..color = Color.lerp(_limeDeep, const Color(0xFF173202), d / depth)!,
      );
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    final wings = _retroWingsPath();
    final body = _retroBodyPath();
    canvas.drawShadow(_retroChassisPath(), const Color(0xFF142007), 8, false);
    _extrude(canvas, wings, 12);
    _plastic(canvas, wings, wings.getBounds(), const [
      _limeHighlight,
      _limeMid,
      _limeDeep,
    ]);
    // Deep inset instrument wells, with a milled lip around each arm.
    for (final rect in const [
      Rect.fromLTRB(76, 148, 251, 320),
      Rect.fromLTRB(469, 148, 644, 320),
    ]) {
      final well = Path()
        ..addRRect(RRect.fromRectAndRadius(rect, const Radius.circular(8)));
      canvas.drawPath(
        well,
        Paint()
          ..shader = const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF244909), Color(0xFF426F16), Color(0xFF355D0C)],
          ).createShader(rect),
      );
      _skinRelief(
        canvas,
        well,
        shade: const Color(0xFF102C04),
        light: _limeHighlight,
        width: 5,
      );
      canvas.drawPath(
        well,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..color = _limeDeep,
      );
    }
    // Separate bulbous speaker moldings, attached over the arm ends.
    for (final x in [16.0, 650.0]) {
      final cap = Path()
        ..addRRect(
          RRect.fromLTRBR(x, 141, x + 54, 329, const Radius.circular(27)),
        );
      _plastic(canvas, cap, cap.getBounds(), const [
        _limeHighlight,
        _limeMid,
        _limeDeep,
      ]);
    }
    _extrude(canvas, body, 12);
    canvas.drawPath(
      body.shift(const Offset(4, 3)),
      Paint()
        ..color = _limeRim.withValues(alpha: 0.6)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );
    _plastic(canvas, body, body.getBounds(), const [
      _limeHighlight,
      _limeLight,
      _limeMid,
      _limeDeep,
    ]);
    canvas.save();
    canvas.clipPath(_retroChassisPath());
    _skinGrain(
      canvas,
      const Rect.fromLTWH(0, 20, 720, 480),
      seed: 714,
      strength: 0.08,
      pitch: 2,
    );
    canvas.restore();
    canvas.save();
    canvas.clipPath(body);
    canvas.drawOval(
      const Rect.fromLTRB(275, 36, 440, 105),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFFEFFFBD).withValues(alpha: 0.5),
            _limeHighlight.withValues(alpha: 0),
          ],
        ).createShader(const Rect.fromLTRB(275, 36, 440, 105)),
    );
    if (!face) {
      // Original fluted chin: overlapping molded lobes and a recessed grille.
      // No facial features; its mass comes from the swept ribs and central keel.
      for (final side in [-1.0, 1.0]) {
        canvas.save();
        canvas.translate(360, 326);
        canvas.scale(side, 1);
        for (var i = 0; i < 5; i++) {
          final y = 12.0 + i * 23;
          final rib = Path()
            ..moveTo(5, y + 17)
            ..cubicTo(35, y + 20, 70 - i * 6, y + 5, 108 - i * 10, y - 6)
            ..cubicTo(90 - i * 9, y + 26, 40, y + 46, 5, y + 31)
            ..close();
          _plastic(canvas, rib, const Rect.fromLTWH(0, 0, 112, 155), const [
            _limeLight,
            _limeDeep,
            _limeRim,
          ]);
        }
        canvas.restore();
      }
      final keel = Path()
        ..moveTo(350, 335)
        ..quadraticBezierTo(332, 405, 347, 464)
        ..quadraticBezierTo(360, 482, 373, 464)
        ..quadraticBezierTo(388, 405, 370, 335)
        ..close();
      _plastic(canvas, keel, keel.getBounds(), const [
        _limeRim,
        _limeLight,
        _limeMid,
        _limeDeep,
      ]);
      for (var i = 0; i < 6; i++) {
        final y = 359.0 + i * 15;
        canvas.drawRRect(
          RRect.fromLTRBR(354, y, 366, y + 3, const Radius.circular(2)),
          Paint()..color = _limeRim,
        );
        canvas.drawLine(
          Offset(354, y + 4),
          Offset(366, y + 4),
          Paint()..color = _limeHighlight.withValues(alpha: 0.6),
        );
      }
    }
    canvas.restore();
    final name = TextPainter(
      text: const TextSpan(
        text: 'MORNYE',
        style: TextStyle(
          fontFamily: 'Google Sans Flex',
          fontSize: 10,
          fontWeight: FontWeight.w900,
          letterSpacing: 4,
          color: _limeRim,
          shadows: [Shadow(color: _limeHighlight, offset: Offset(0, 1))],
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    name.paint(canvas, Offset(362 - name.width / 2, 317));
    name.dispose();
  }

  @override
  bool shouldRepaint(_RetroChassisPainter oldDelegate) =>
      oldDelegate.face != face;
}

/// The face picture, kept as a file in the app's data folder rather than in
/// the app: null without one. [_RetroMiniPlayerState] loads it.
final _retroFace = ValueNotifier<File?>(null);
bool _retroFaceLoaded = false;

Future<File> _retroFaceFile() async =>
    File('${(await getApplicationSupportDirectory()).path}/retro_face.img');

Future<void> _loadRetroFace() async {
  if (_retroFaceLoaded) return;
  _retroFaceLoaded = true;
  try {
    final file = await _retroFaceFile();
    if (await file.exists()) _retroFace.value = file;
  } catch (error) {
    // No data folder (or no access to it): the jaw keeps its grille.
    AppLogger('RetroSkin').w('Could not load the face picture: $error');
  }
}

/// Copies a picture the user chooses into the app's data folder.
Future<void> _chooseRetroFace() async {
  final picked = await FilePicker.pickFiles(type: FileType.image);
  final path = picked.isEmpty ? null : picked.first.path;
  if (path == null) return;
  final file = await _retroFaceFile();
  await file.parent.create(recursive: true);
  await File(path).copy(file.path);
  await FileImage(file).evict();
  _retroFace.value = null;
  _retroFace.value = file;
}

Future<void> _removeRetroFace() async {
  final file = await _retroFaceFile();
  await FileImage(file).evict();
  if (await file.exists()) await file.delete();
  _retroFace.value = null;
}

/// A color matrix that maps brightness from [dark] to [light], with
/// [contrast] around the middle: the picture becomes the same plastic.
ColorFilter _duotone(Color dark, Color light, {double contrast = 1.35}) {
  final rows = <double>[];
  for (final (d, l) in [
    (dark.r, light.r),
    (dark.g, light.g),
    (dark.b, light.b),
  ]) {
    final range = (l - d) * 255;
    final k = range * contrast / 255;
    rows.addAll([
      k * 0.299,
      k * 0.587,
      k * 0.114,
      0,
      d * 255 + range * (0.5 - 0.5 * contrast),
    ]);
  }
  rows.addAll([0, 0, 0, 1, 0]);
  return ColorFilter.matrix(rows);
}

/// The face picture in the jaw, tinted to the plastic, fading into it at the
/// top and shaded like the rest of the molding. Right-clicking the jaw
/// chooses or removes the picture.
class _RetroFace extends StatelessWidget {
  const _RetroFace({required this.file});

  final File? file;

  Future<void> _menu(BuildContext context, Offset position) async {
    final l10n = context.l10n;
    final choice = await showMenu<bool>(
      context: context,
      position: RelativeRect.fromLTRB(
        position.dx,
        position.dy,
        position.dx,
        position.dy,
      ),
      items: [
        PopupMenuItem(
          value: true,
          child: Text(l10n.desktopMiniPlayerChooseFace),
        ),
        if (file != null)
          PopupMenuItem(
            value: false,
            child: Text(l10n.desktopMiniPlayerRemoveFace),
          ),
      ],
    );
    if (choice == true) await _chooseRetroFace();
    if (choice == false) await _removeRetroFace();
  }

  @override
  Widget build(BuildContext context) {
    final face = file;
    return ClipPath(
      clipper: const _RetroFaceClipper(),
      child: GestureDetector(
        key: const ValueKey('retro-face'),
        // The plastic underneath still drags the window.
        behavior: HitTestBehavior.translucent,
        onSecondaryTapUp: (details) =>
            unawaited(_menu(context, details.globalPosition)),
        child: face == null
            ? const SizedBox.expand()
            : Stack(
                children: [
                  Positioned.fromRect(
                    rect: const Rect.fromLTRB(250, 334, 470, 490),
                    child: ShaderMask(
                      blendMode: BlendMode.dstIn,
                      shaderCallback: (bounds) => const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color(0x00E8FFCB),
                          Color(0xFFE8FFCB),
                          Color(0xFFE8FFCB),
                          Color(0x00E8FFCB),
                        ],
                        stops: [0, 0.25, 0.85, 1],
                      ).createShader(bounds),
                      child: ShaderMask(
                        blendMode: BlendMode.dstIn,
                        shaderCallback: (bounds) => const LinearGradient(
                          colors: [
                            Color(0x00E8FFCB),
                            Color(0xFFE8FFCB),
                            Color(0xFFE8FFCB),
                            Color(0x00E8FFCB),
                          ],
                          stops: [0, 0.12, 0.88, 1],
                        ).createShader(bounds),
                        child: ColorFiltered(
                          colorFilter: _duotone(_limeRim, _limeHighlight),
                          child: Image.file(
                            face,
                            fit: BoxFit.cover,
                            alignment: const Alignment(0, 0.1),
                            filterQuality: FilterQuality.medium,
                            gaplessPlayback: true,
                            errorBuilder: (context, error, stack) =>
                                const SizedBox.shrink(),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const Positioned.fill(
                    child: IgnorePointer(
                      child: CustomPaint(painter: _RetroFaceRimPainter()),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

/// The jaw's rim and lip, drawn again over the picture.
class _RetroFaceRimPainter extends CustomPainter {
  const _RetroFaceRimPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final body = _retroBodyPath();
    canvas.drawPath(
      body.shift(const Offset(0, -3)),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5
        ..color = _limeRim.withValues(alpha: 0.5)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2),
    );
    canvas.drawPath(
      body,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6
        ..color = _limeRim,
    );
  }

  @override
  bool shouldRepaint(_RetroFaceRimPainter oldDelegate) => false;
}

/// Drives the visualizer and the speaker cones. Without an audio tap the
/// levels are synthesized: a steady beat, a few drifting partials and some
/// noise, seeded per track so each one moves a little differently. They
/// fall quiet when playback pauses.
class _RetroPulse extends ChangeNotifier {
  static const int barCount = 56;

  final List<double> bars = List<double>.filled(barCount, 0.04);
  double energy = 0;
  int seed = 0;
  bool playing = false;

  double _time = 0;

  /// Seconds of playback the pulse has run for: a clock for spinning discs.
  double get time => _time;
  Duration _last = Duration.zero;

  double _noise(int bar, int frame) {
    var h =
        (bar * 374761393 + frame * 668265263 + seed * 2246822519) & 0xFFFFFFFF;
    h = ((h ^ (h >> 13)) * 1274126177) & 0xFFFFFFFF;
    return (h & 0xFFFF) / 0xFFFF;
  }

  double _target(int bar) {
    final t = _time;
    final x = bar / (barCount - 1);
    final phase = (seed % 997) / 997 * math.pi * 2;
    final beat = math.pow(0.5 + 0.5 * math.cos(t * math.pi * 4 + phase), 6);
    final bass = (1 - x) * (0.3 + 0.7 * beat);
    final drift =
        0.5 +
        0.5 *
            math.sin(t * (3.1 + bar * 0.37) + bar * 1.7 + phase) *
            math.sin(t * (1.3 + bar * 0.11) + bar);
    final noise = _noise(bar, (t * 14).floor());
    // Taper both ends so the trace sits like a waveform on the screen.
    final edge = math.sin(math.pi * (0.08 + 0.84 * x));
    return ((0.28 * bass + 0.5 * drift * (0.55 + 0.45 * beat) + 0.22 * noise) *
            edge)
        .clamp(0.04, 1.0);
  }

  /// Advances to [elapsed] on the ticker's clock. Returns true once the bars
  /// have settled at rest, so a paused player can stop ticking.
  bool step(Duration elapsed) {
    if (elapsed < _last) _last = Duration.zero;
    final dt = (elapsed - _last).inMicroseconds / 1e6;
    _last = elapsed;
    _time += dt.clamp(0, 0.1);
    var settled = true;
    var low = 0.0;
    for (var i = 0; i < barCount; i++) {
      final target = playing ? _target(i) : 0.04;
      final rate = target > bars[i] ? 0.55 : 0.16;
      bars[i] += (target - bars[i]) * rate;
      if ((bars[i] - target).abs() > 0.005) settled = false;
      if (i < 10) low += bars[i];
    }
    energy = playing ? (low / 10).clamp(0.0, 1.0) : energy * 0.85;
    if (energy > 0.01) settled = false;
    notifyListeners();
    return settled && !playing;
  }

  /// Restarts the clock after the ticker stopped.
  void resume() => _last = Duration.zero;
}

/// Visualizer looks, cycled by the chassis's EQ button.
enum _RetroScope { mirror, bars, wave }

final _retroScope = ValueNotifier<_RetroScope>(_RetroScope.mirror);

class _RetroScopePainter extends CustomPainter {
  _RetroScopePainter(
    this.pulse,
    this.style, {
    this.core = _lcdCyan,
    this.glowColor = _lcdGlow,
  }) : super(repaint: pulse);

  final _RetroPulse pulse;
  final _RetroScope style;

  /// The trace's bright color and the halo around it.
  final Color core;
  final Color glowColor;

  @override
  void paint(Canvas canvas, Size size) {
    final bars = pulse.bars;
    final step = size.width / bars.length;
    final mid = size.height / 2;
    final shader = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [core, glowColor, core],
    ).createShader(Offset.zero & size);
    final glow = Paint()
      ..color = glowColor.withValues(alpha: 0.35)
      ..strokeCap = StrokeCap.round
      ..strokeWidth = step * 0.9
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
    final line = Paint()
      ..shader = shader
      ..strokeCap = StrokeCap.round
      ..strokeWidth = math.max(1, step * 0.45);
    switch (style) {
      case _RetroScope.mirror:
        for (var i = 0; i < bars.length; i++) {
          final x = step * (i + 0.5);
          final h = bars[i] * (mid - 1);
          canvas.drawLine(Offset(x, mid - h), Offset(x, mid + h), glow);
          canvas.drawLine(Offset(x, mid - h), Offset(x, mid + h), line);
        }
      case _RetroScope.bars:
        final cell = Paint()..shader = shader;
        for (var i = 0; i < bars.length; i += 2) {
          final x = step * i;
          final lit = (bars[i] * 8).round();
          for (var c = 0; c < lit; c++) {
            final y = size.height - (c + 1) * (size.height / 8);
            canvas.drawRect(
              Rect.fromLTWH(x, y + 1, step * 1.6, size.height / 8 - 1.5),
              cell,
            );
          }
        }
      case _RetroScope.wave:
        final path = Path();
        for (var i = 0; i < bars.length; i++) {
          final x = step * (i + 0.5);
          final sign = i.isEven ? -1 : 1;
          final y = mid + sign * bars[i] * (mid - 2);
          if (i == 0) {
            path.moveTo(x, y);
          } else {
            path.lineTo(x, y);
          }
        }
        canvas.drawPath(
          path,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 3
            ..color = glowColor.withValues(alpha: 0.4)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2),
        );
        canvas.drawPath(
          path,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.4
            ..strokeJoin = StrokeJoin.round
            ..color = core,
        );
    }
  }

  @override
  bool shouldRepaint(_RetroScopePainter oldDelegate) =>
      oldDelegate.style != style ||
      oldDelegate.pulse != pulse ||
      oldDelegate.core != core ||
      oldDelegate.glowColor != glowColor;
}

/// A chrome speaker whose cone pushes out with the low bars.
class _RetroSpeakerPainter extends CustomPainter {
  _RetroSpeakerPainter(this.pulse) : super(repaint: pulse);

  final _RetroPulse pulse;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final r = size.shortestSide / 2;
    // The mounting ring.
    canvas.drawCircle(
      center,
      r,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFF4F6F8), Color(0xFF8A9099), Color(0xFF3B4048)],
        ).createShader(Rect.fromCircle(center: center, radius: r)),
    );
    canvas.drawCircle(
      center,
      r,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4
        ..color = const Color(0xFF2A2E35),
    );
    // A dark rubber roll behind the bright conical diaphragm.
    final push = 1 + pulse.energy * 0.07;
    final cone = r * 0.78 * push;
    canvas.drawCircle(
      center,
      cone,
      Paint()
        ..shader = const RadialGradient(
          colors: [
            Color(0xFFBCC6C4),
            Color(0xFFBAC4C2),
            Color(0xFF192322),
            Color(0xFF65716E),
            Color(0xFF131D1D),
          ],
          stops: [0, 0.6, 0.7, 0.87, 1],
        ).createShader(Rect.fromCircle(center: center, radius: cone)),
    );
    final diaphragm = cone * 0.68;
    canvas.drawCircle(
      center,
      diaphragm,
      Paint()
        ..shader = const SweepGradient(
          colors: [
            Color(0xFF727D7B),
            Color(0xFFDAE4DF),
            Color(0xFF76827F),
            Color(0xFF3E4948),
            Color(0xFF727D7B),
          ],
          transform: GradientRotation(-math.pi / 3),
        ).createShader(Rect.fromCircle(center: center, radius: diaphragm)),
    );
    canvas.drawCircle(
      center,
      cone * 0.92,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.9
        ..color = const Color(0xFFB9C8BD).withValues(alpha: 0.5),
    );
    // The dust cap.
    final cap = r * 0.26 * push;
    canvas.drawCircle(
      center,
      cap,
      Paint()
        ..shader = const RadialGradient(
          center: Alignment(-0.4, -0.4),
          colors: [Color(0xFFFFFFFF), Color(0xFF9AA0A8), Color(0xFF444950)],
        ).createShader(Rect.fromCircle(center: center, radius: cap)),
    );
  }

  @override
  bool shouldRepaint(_RetroSpeakerPainter oldDelegate) =>
      oldDelegate.pulse != pulse;
}

/// What a chassis button is made of.
enum _RetroPillKind { lime, grape, sun, chrome, obsidian }

/// A glossy plastic button. It lightens on hover and sinks when pressed.
class _RetroPill extends StatefulWidget {
  const _RetroPill({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.kind = _RetroPillKind.lime,
    this.size = const Size(34, 28),
    this.iconSize = 16,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;
  final _RetroPillKind kind;
  final Size size;
  final double iconSize;

  @override
  State<_RetroPill> createState() => _RetroPillState();
}

class _RetroPillState extends State<_RetroPill> {
  bool _hover = false;
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onPressed != null;
    final iconColor = switch (widget.kind) {
      _RetroPillKind.grape => Colors.white,
      _RetroPillKind.sun => const Color(0xFF6B3A00),
      _RetroPillKind.lime => const Color(0xFF1F4704),
      _RetroPillKind.chrome => const Color(0xFF1A1D21),
      _RetroPillKind.obsidian => const Color(0xFFC8FF5A),
    };
    final iconShadow = switch (widget.kind) {
      _RetroPillKind.grape => const Shadow(color: Colors.transparent),
      _RetroPillKind.obsidian => const Shadow(
        color: Color(0xFF7CFF1E),
        blurRadius: 10,
      ),
      _ => Shadow(
        color: Colors.white.withValues(alpha: 0.5),
        offset: const Offset(0, 1),
      ),
    };
    return Tooltip(
      message: widget.tooltip,
      waitDuration: const Duration(milliseconds: 600),
      child: MouseRegion(
        cursor: enabled ? SystemMouseCursors.click : MouseCursor.defer,
        onEnter: (_) => setState(() => _hover = true),
        onExit: (_) => setState(() => _hover = _down = false),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: enabled ? (_) => setState(() => _down = true) : null,
          onTapUp: enabled ? (_) => setState(() => _down = false) : null,
          onTapCancel: () => setState(() => _down = false),
          onTap: widget.onPressed,
          child: Opacity(
            opacity: enabled ? 1 : 0.55,
            child: CustomPaint(
              size: widget.size,
              painter: _RetroPillPainter(
                kind: widget.kind,
                hover: _hover && enabled,
                down: _down,
              ),
              child: SizedBox.fromSize(
                size: widget.size,
                child: Transform.translate(
                  offset: Offset(0, _down ? 1 : 0),
                  child: Icon(
                    widget.icon,
                    size: widget.iconSize,
                    color: iconColor,
                    shadows: [iconShadow],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RetroPillPainter extends CustomPainter {
  const _RetroPillPainter({
    required this.kind,
    required this.hover,
    required this.down,
  });

  final _RetroPillKind kind;
  final bool hover;
  final bool down;

  @override
  void paint(Canvas canvas, Size size) {
    final socket = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(size.shortestSide / 2),
    );
    canvas.drawRRect(
      socket.shift(const Offset(0, 1.5)),
      Paint()..color = const Color(0xFF11190E).withValues(alpha: 0.75),
    );
    final rect = (Offset(0, down ? 1 : 0) & size).deflate(0.6);
    final shape = RRect.fromRectAndRadius(
      rect,
      Radius.circular(size.shortestSide / 2),
    );
    var colors = switch (kind) {
      _RetroPillKind.lime => const [
        Color(0xFFEFFFB8),
        Color(0xFFA6EC34),
        Color(0xFF5BA80F),
      ],
      _RetroPillKind.grape => const [
        Color(0xFFF0B8FF),
        Color(0xFFA43EE2),
        Color(0xFF55107F),
      ],
      _RetroPillKind.sun => const [
        Color(0xFFFFF7B0),
        Color(0xFFFFC21A),
        Color(0xFFD27F00),
      ],
      _RetroPillKind.chrome => const [
        Color(0xFFF7F9FB),
        Color(0xFFB4BAC2),
        Color(0xFF5E656E),
      ],
      _RetroPillKind.obsidian => const [
        Color(0xFF50565F),
        Color(0xFF17191C),
        Color(0xFF040505),
      ],
    };
    if (down) {
      colors = [
        for (final c in colors) Color.lerp(c, const Color(0xFF182014), 0.22)!,
      ];
    }
    if (hover && !down) {
      colors = [
        for (final c in colors) Color.lerp(c, const Color(0xFFF2F5E9), 0.10)!,
      ];
    }
    canvas.drawRRect(
      shape.shift(const Offset(0, 1.5)),
      Paint()..color = Colors.black.withValues(alpha: down ? 0.1 : 0.28),
    );
    canvas.drawRRect(
      shape,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: colors,
        ).createShader(rect),
    );
    if (!down) {
      final gloss = Rect.fromLTRB(
        size.width * 0.16,
        size.height * 0.08,
        size.width * 0.84,
        size.height * 0.5,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(gloss, Radius.circular(gloss.height / 2)),
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.white.withValues(alpha: 0.75),
              Colors.white.withValues(alpha: 0.05),
            ],
          ).createShader(gloss),
      );
    }
    canvas.drawRRect(
      shape,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.3
        ..color = switch (kind) {
          _RetroPillKind.lime => _limeRim,
          _RetroPillKind.grape => const Color(0xFF3A0B5A),
          _RetroPillKind.sun => const Color(0xFF7A4500),
          _RetroPillKind.chrome => const Color(0xFF2B2F35),
          _RetroPillKind.obsidian => Colors.black,
        },
    );
  }

  @override
  bool shouldRepaint(_RetroPillPainter oldDelegate) =>
      oldDelegate.kind != kind ||
      oldDelegate.hover != hover ||
      oldDelegate.down != down;
}

/// The retro mini player: the chassis, its controls and the LCD. Scrolling
/// anywhere on it changes the volume, and dragging the plastic moves the
/// window.
class _RetroMiniPlayer extends ConsumerStatefulWidget {
  const _RetroMiniPlayer({required this.skin});

  /// [DesktopMiniPlayerSkin.retro] or [DesktopMiniPlayerSkin.gunmetal].
  final DesktopMiniPlayerSkin skin;

  @override
  ConsumerState<_RetroMiniPlayer> createState() => _RetroMiniPlayerState();
}

class _RetroMiniPlayerState extends ConsumerState<_RetroMiniPlayer>
    with SingleTickerProviderStateMixin {
  final _pulse = _RetroPulse();
  late final Ticker _ticker = createTicker(_tick);

  void _tick(Duration elapsed) {
    if (_pulse.step(elapsed)) _ticker.stop();
  }

  void _wake() {
    if (_ticker.isActive) return;
    _pulse.resume();
    _ticker.start();
  }

  @override
  void initState() {
    super.initState();
    _retroFace.addListener(_onFace);
    unawaited(_loadRetroFace());
    ref.listenManual<bool>(playbackPlayingProvider, (_, playing) {
      _pulse.playing = playing;
      _wake();
    }, fireImmediately: true);
    ref.listenManual<AsyncValue<MediaItem?>>(currentMediaItemProvider, (
      _,
      next,
    ) {
      _pulse.seed = next.value?.id.hashCode ?? 0;
    }, fireImmediately: true);
  }

  void _onFace() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _retroFace.removeListener(_onFace);
    _ticker.dispose();
    _pulse.dispose();
    super.dispose();
  }

  void _nudgeVolume(double delta) {
    final next = (playbackOutputVolume.value + delta).clamp(0.0, 1.0);
    unawaited(ref.read(systemVolumeWriterProvider)(next));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final mediaItem = ref.watch(currentMediaItemProvider).value;
    final controller = ref.read(musicPlayerControllerProvider);
    final playing = ref.watch(playbackPlayingProvider);
    final loading = ref.watch(playbackLoadingProvider);
    final enabled = mediaItem != null;
    final face = _retroFace.value;
    switch (widget.skin) {
      case DesktopMiniPlayerSkin.prophet:
        return _prophetLayout(
          context,
          mediaItem: mediaItem,
          playing: playing,
          loading: loading,
        );
      case DesktopMiniPlayerSkin.machined:
        return _machinedLayout(
          context,
          mediaItem: mediaItem,
          playing: playing,
          loading: loading,
        );
      case DesktopMiniPlayerSkin.vault:
        return _vaultLayout(
          context,
          mediaItem: mediaItem,
          playing: playing,
          loading: loading,
        );
      case DesktopMiniPlayerSkin.jelly:
        return _jellyLayout(
          context,
          mediaItem: mediaItem,
          playing: playing,
          loading: loading,
        );
      default:
        break;
    }
    if (widget.skin == DesktopMiniPlayerSkin.thorn) {
      return _thornLayout(
        context,
        mediaItem: mediaItem,
        playing: playing,
        loading: loading,
      );
    }
    if (widget.skin == DesktopMiniPlayerSkin.gunmetal) {
      return _gunmetalLayout(
        context,
        mediaItem: mediaItem,
        playing: playing,
        loading: loading,
      );
    }

    Widget pill(
      String key,
      IconData icon,
      String tooltip,
      VoidCallback? action, {
      Size size = const Size(28, 25),
      _RetroPillKind kind = _RetroPillKind.grape,
    }) => _RetroPill(
      key: ValueKey(key),
      icon: icon,
      tooltip: tooltip,
      onPressed: action,
      size: size,
      kind: kind,
      iconSize: 15,
    );
    Widget speaker(double x, double y) => Positioned(
      left: x - 23,
      top: y - 23,
      width: 46,
      height: 46,
      child: IgnorePointer(
        child: RepaintBoundary(
          child: CustomPaint(painter: _RetroSpeakerPainter(_pulse)),
        ),
      ),
    );
    return Material(
      type: MaterialType.transparency,
      child: DesktopVolumeScroll(
        child: OverflowBox(
          alignment: Alignment.topLeft,
          minWidth: _retroSkinSize.width,
          maxWidth: _retroSkinSize.width,
          minHeight: _retroSkinSize.height,
          maxHeight: _retroSkinSize.height,
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned.fill(
                  child: RepaintBoundary(
                    child: CustomPaint(
                      painter: _RetroChassisPainter(face: face != null),
                    ),
                  ),
                ),
                const Positioned.fill(
                  child: ClipPath(
                    clipper: _RetroChassisClipper(),
                    child: DesktopWindowDragArea(frameless: true),
                  ),
                ),
                Positioned.fill(child: _RetroFace(file: face)),
                for (final y in [175.0, 234.0, 293.0]) ...[
                  speaker(43, y),
                  speaker(677, y),
                ],
                Positioned(
                  left: 5,
                  top: 221,
                  child: pill(
                    'retro-volume-down',
                    Icons.chevron_left,
                    l10n.desktopMiniPlayerVolumeDown,
                    () => _nudgeVolume(-0.05),
                    size: const Size(14, 29),
                    kind: _RetroPillKind.lime,
                  ),
                ),
                Positioned(
                  right: 5,
                  top: 221,
                  child: pill(
                    'retro-volume-up',
                    Icons.chevron_right,
                    l10n.desktopMiniPlayerVolumeUp,
                    () => _nudgeVolume(0.05),
                    size: const Size(14, 29),
                    kind: _RetroPillKind.lime,
                  ),
                ),
                Positioned(
                  left: 339,
                  top: 40,
                  child: Row(
                    children: [
                      pill(
                        'retro-minimize',
                        Icons.remove,
                        l10n.desktopMiniPlayerMinimize,
                        () => unawaited(minimizeDesktopWindow()),
                        size: const Size(18, 15),
                        kind: _RetroPillKind.lime,
                      ),
                      const SizedBox(width: 4),
                      pill(
                        'retro-expand',
                        Icons.close,
                        l10n.desktopMiniPlayerExpand,
                        () => unawaited(setDesktopMiniPlayer(open: false)),
                        size: const Size(18, 15),
                        kind: _RetroPillKind.lime,
                      ),
                    ],
                  ),
                ),
                Positioned(
                  left: 282,
                  top: 77,
                  child: Row(
                    children: [
                      pill(
                        'retro-previous',
                        Icons.skip_previous,
                        l10n.nowPlayingPreviousTrack,
                        enabled ? controller.previous : null,
                      ),
                      const SizedBox(width: 5),
                      pill(
                        'retro-play-pause',
                        playing ? Icons.pause : Icons.play_arrow,
                        playing ? l10n.actionPause : l10n.tooltipPlay,
                        enabled && !loading
                            ? () => controller.togglePlayPause(playing)
                            : null,
                      ),
                      const SizedBox(width: 5),
                      pill(
                        'retro-stop',
                        Icons.stop,
                        l10n.desktopMiniPlayerStop,
                        enabled
                            ? () async {
                                if (playing) {
                                  await controller.togglePlayPause(true);
                                }
                                await controller.seek(Duration.zero);
                              }
                            : null,
                      ),
                      const SizedBox(width: 5),
                      pill(
                        'retro-next',
                        Icons.skip_next,
                        l10n.nowPlayingNextTrack,
                        enabled ? controller.next : null,
                      ),
                      const SizedBox(width: 12),
                      pill(
                        'retro-next-skin',
                        Icons.settings,
                        l10n.desktopMiniPlayerNextSkin,
                        () => unawaited(
                          setDesktopMiniPlayerSkin(_nextSkin(widget.skin)),
                        ),
                        size: const Size(25, 25),
                        kind: _RetroPillKind.sun,
                      ),
                    ],
                  ),
                ),
                Positioned(
                  left: 261,
                  top: 113,
                  width: 198,
                  height: 24,
                  child: Container(
                    decoration: BoxDecoration(
                      color: _limeDeep,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: _limeRim),
                    ),
                    child: Row(
                      children: [
                        pill(
                          'retro-lcd-previous',
                          Icons.chevron_left,
                          l10n.nowPlayingPreviousTrack,
                          enabled ? controller.previous : null,
                          size: const Size(23, 20),
                          kind: _RetroPillKind.sun,
                        ),
                        Expanded(
                          child: Text(
                            mediaItem?.title ?? l10n.desktopPlayerIdle,
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: _limeHighlight,
                            ),
                          ),
                        ),
                        pill(
                          'retro-lcd-next',
                          Icons.chevron_right,
                          l10n.nowPlayingNextTrack,
                          enabled ? controller.next : null,
                          size: const Size(23, 20),
                          kind: _RetroPillKind.sun,
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  left: 257,
                  top: 142,
                  width: 206,
                  height: 145,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(25),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(25),
                        border: Border.all(color: _limeRim, width: 4),
                        gradient: const RadialGradient(
                          center: Alignment(0, -0.7),
                          radius: 1.4,
                          colors: [Color(0xFF17291E), Color(0xFF060E0B)],
                        ),
                      ),
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(
                                10,
                                12,
                                10,
                                17,
                              ),
                              child: RepaintBoundary(
                                child: CustomPaint(
                                  painter: _RetroRibbonPainter(_pulse),
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            left: 13,
                            right: 13,
                            bottom: 6,
                            child: Text(
                              mediaItem?.album ?? '',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 9,
                                color: Color(0xFFA8BD8D),
                              ),
                            ),
                          ),
                          Positioned(
                            left: 8,
                            right: 8,
                            top: 5,
                            height: 24,
                            child: IgnorePointer(
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      const Color(
                                        0xFFCBE6CD,
                                      ).withValues(alpha: 0.12),
                                      const Color(
                                        0xFFCBE6CD,
                                      ).withValues(alpha: 0),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 270,
                  top: 295,
                  width: 180,
                  height: 17,
                  child: _RetroSeekGroove(mediaItem: mediaItem),
                ),
                Positioned(
                  left: 85,
                  top: 158,
                  width: 150,
                  height: 151,
                  child: _RetroEqualizer(onVolume: _nudgeVolume),
                ),
                const Positioned(
                  left: 485,
                  top: 158,
                  width: 148,
                  height: 151,
                  child: _RetroQueue(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// The recessed track the playhead slides along.
class _RetroSeekGroove extends ConsumerStatefulWidget {
  const _RetroSeekGroove({required this.mediaItem});
  final MediaItem? mediaItem;

  @override
  ConsumerState<_RetroSeekGroove> createState() => _RetroSeekGrooveState();
}

class _RetroSeekGrooveState extends ConsumerState<_RetroSeekGroove> {
  double? _preview;

  @override
  void didUpdateWidget(_RetroSeekGroove oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.mediaItem?.id != widget.mediaItem?.id) _preview = null;
  }

  @override
  Widget build(BuildContext context) {
    final duration = widget.mediaItem?.duration?.inMilliseconds.toDouble() ?? 0;
    final position = widget.mediaItem == null
        ? 0.0
        : ref.watch(playbackPositionProvider).inMilliseconds.toDouble();
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(11),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [_limeRim, _limeDeep, _limeMid],
        ),
        border: Border.all(color: _limeRim),
      ),
      child: SliderTheme(
        data: SliderTheme.of(context).copyWith(
          trackHeight: 3,
          trackShape: const RoundedRectSliderTrackShape(),
          activeTrackColor: const Color(0xFFAA75CB),
          inactiveTrackColor: const Color(0xFF1F4704),
          thumbColor: const Color(0xFFCF98EF),
          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 5),
          overlayShape: SliderComponentShape.noOverlay,
          padding: const EdgeInsets.symmetric(horizontal: 7),
        ),
        child: Slider(
          value: (_preview ?? position).clamp(0, duration > 0 ? duration : 1),
          max: duration > 0 ? duration : 1,
          onChanged: duration > 0
              ? (value) => setState(() => _preview = value)
              : null,
          onChangeEnd: duration > 0
              ? (value) async {
                  try {
                    await ref
                        .read(musicPlayerControllerProvider)
                        .seek(Duration(milliseconds: value.round()));
                  } finally {
                    if (mounted) setState(() => _preview = null);
                  }
                }
              : null,
        ),
      ),
    );
  }
}

/// The time of day, as the old players showed in their screen's corner.
class _RetroClock extends StatefulWidget {
  const _RetroClock({this.style});

  /// Replaces the blue LCD style.
  final TextStyle? style;

  @override
  State<_RetroClock> createState() => _RetroClockState();
}

class _RetroClockState extends State<_RetroClock> {
  Timer? _timer;
  DateTime _now = DateTime.now();

  void _schedule() {
    final now = DateTime.now();
    _timer = Timer(
      Duration(seconds: 60 - now.second, milliseconds: -now.millisecond),
      () {
        if (!mounted) return;
        setState(() => _now = DateTime.now());
        _schedule();
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _schedule();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final use24 = MediaQuery.alwaysUse24HourFormatOf(context);
    final hour = use24
        ? _now.hour
        : (_now.hour % 12 == 0 ? 12 : _now.hour % 12);
    return Text(
      '$hour:${_now.minute.toString().padLeft(2, '0')}',
      style:
          widget.style ??
          const TextStyle(
            fontSize: 17,
            height: 1,
            fontWeight: FontWeight.w800,
            color: _lcdText,
            shadows: [Shadow(color: _lcdGlow, blurRadius: 2.5)],
            fontFeatures: [FontFeature.tabularFigures()],
          ),
    );
  }
}

/// A perspective ribbon bank, synthesized from the same settling pulse as
/// the other skins. The dark side facets give each bar physical depth.
class _RetroRibbonPainter extends CustomPainter {
  _RetroRibbonPainter(this.pulse) : super(repaint: pulse);
  final _RetroPulse pulse;

  @override
  void paint(Canvas canvas, Size size) {
    for (var row = 3; row >= 0; row--) {
      for (var i = 0; i < 22; i++) {
        final t = i / 21;
        final level = pulse.bars[(i * 2 + row * 3) % _RetroPulse.barCount];
        final x = 13 + t * (size.width - 35) + row * 3;
        final y = size.height - 19 - row * 7 + math.sin(t * math.pi) * 12;
        final h = 6 + level * (size.height - 25) * (0.7 + row * 0.1);
        final lean = (t - 0.5) * 22;
        final color = Color.lerp(
          const Color(0xFF43E8D9),
          const Color(0xFFFF994A),
          t,
        )!;
        final front = Path()
          ..moveTo(x, y)
          ..lineTo(x + lean, y - h)
          ..lineTo(x + lean + 2.5, y - h + 1)
          ..lineTo(x + 3, y + 1)
          ..close();
        canvas.drawPath(
          front,
          Paint()
            ..shader = LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                color.withValues(alpha: 0.85),
                Color.lerp(color, const Color(0xFF144B5D), 0.55)!,
              ],
            ).createShader(front.getBounds()),
        );
        canvas.drawPath(
          Path()
            ..moveTo(x + 3, y + 1)
            ..lineTo(x + lean + 2.5, y - h + 1)
            ..lineTo(x + lean + 5, y - h - 2)
            ..lineTo(x + 5, y - 2)
            ..close(),
          Paint()..color = color.withValues(alpha: 0.28),
        );
        canvas.drawLine(
          Offset(x + lean, y - h),
          Offset(x + lean + 3, y - h - 2),
          Paint()
            ..color = Color.lerp(color, const Color(0xFFE5FFDB), 0.55)!
            ..strokeWidth = 1,
        );
      }
    }
    // Faint phosphor scan lines sit on the glass, not on the chassis.
    for (var y = 1.0; y < size.height; y += 3) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        Paint()
          ..color = const Color(0xFF06140B).withValues(alpha: 0.18)
          ..strokeWidth = 0.6,
      );
    }
  }

  @override
  bool shouldRepaint(_RetroRibbonPainter oldDelegate) =>
      oldDelegate.pulse != pulse;
}

class _RetroEqualizer extends StatefulWidget {
  const _RetroEqualizer({required this.onVolume});
  final ValueChanged<double> onVolume;

  @override
  State<_RetroEqualizer> createState() => _RetroEqualizerState();
}

class _RetroEqualizerState extends State<_RetroEqualizer> {
  double _balance = 0.5;
  final _levels = List<double>.generate(
    10,
    (i) => 0.48 + math.sin(i * 0.8) * 0.12,
  );

  @override
  Widget build(BuildContext context) {
    const text = TextStyle(
      fontSize: 9,
      height: 1,
      color: Color(0xFFD4EBAA),
      fontWeight: FontWeight.w600,
    );
    final l10n = context.l10n;
    Widget horizontal(
      String label,
      double value,
      ValueChanged<double> change,
    ) => Expanded(
      child: Column(
        children: [
          SizedBox(
            height: 18,
            child: SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: 3,
                activeTrackColor: _limeRim,
                inactiveTrackColor: _limeRim,
                thumbColor: const Color(0xFFCCD6AB),
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 4),
                overlayShape: SliderComponentShape.noOverlay,
              ),
              child: Semantics(
                label: label,
                child: Slider(value: value, onChanged: change),
              ),
            ),
          ),
          Text(label, style: text),
        ],
      ),
    );
    return Column(
      children: [
        Row(
          children: [
            horizontal(
              l10n.desktopRetroBalance,
              _balance,
              (v) => setState(() => _balance = v),
            ),
            const SizedBox(width: 9),
            ValueListenableBuilder<double>(
              valueListenable: playbackOutputVolume,
              builder: (context, volume, _) => horizontal(
                l10n.desktopRetroVolume,
                volume.clamp(0, 1),
                (v) => widget.onVolume(v - volume),
              ),
            ),
          ],
        ),
        const SizedBox(height: 13),
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var i = 0; i < 10; i++)
                Expanded(
                  child: Column(
                    children: [
                      Expanded(
                        child: LayoutBuilder(
                          builder: (context, constraints) => Semantics(
                            label:
                                '${const ['32', '64', '125', '250', '500', '1K', '2K', '4K', '8K', '16K'][i]} Hz',
                            child: GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onPanUpdate: (details) => setState(
                                () => _levels[i] =
                                    (_levels[i] -
                                            details.delta.dy /
                                                constraints.maxHeight)
                                        .clamp(0, 1),
                              ),
                              child: CustomPaint(
                                size: Size.infinite,
                                painter: _RetroFaderPainter(_levels[i]),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        const [
                          '32',
                          '64',
                          '125',
                          '250',
                          '500',
                          '1K',
                          '2K',
                          '4K',
                          '8K',
                          '16K',
                        ][i],
                        style: text.copyWith(fontSize: 7),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 7),
        Align(
          alignment: Alignment.centerRight,
          child: InkWell(
            onTap: () => setState(() {
              _balance = 0.5;
              _levels.fillRange(0, 10, 0.5);
            }),
            child: Padding(
              padding: const EdgeInsets.all(2),
              child: Text(
                l10n.desktopRetroReset,
                style: text.copyWith(decoration: TextDecoration.underline),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _RetroFaderPainter extends CustomPainter {
  const _RetroFaderPainter(this.level);
  final double level;

  @override
  void paint(Canvas canvas, Size size) {
    final x = size.width / 2;
    final y = 4 + (1 - level) * (size.height - 8);
    canvas.drawLine(
      Offset(x, 2),
      Offset(x, size.height - 2),
      Paint()
        ..color = const Color(0xFF1C3D07)
        ..strokeWidth = 3,
    );
    canvas.drawLine(
      Offset(x + 2, 2),
      Offset(x + 2, size.height - 2),
      Paint()..color = _limeLight.withValues(alpha: 0.4),
    );
    for (var j = 0; j < 5; j++) {
      final tick = 3 + j * (size.height - 6) / 4;
      canvas.drawLine(
        Offset(x - 5, tick),
        Offset(x - 3, tick),
        Paint()..color = _limeLight.withValues(alpha: 0.4),
      );
    }
    final knob = Rect.fromCenter(center: Offset(x, y), width: 9, height: 5);
    canvas.drawShadow(
      Path()..addRRect(RRect.fromRectAndRadius(knob, const Radius.circular(2))),
      _limeRim,
      2,
      false,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(knob, const Radius.circular(2)),
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFF0F5D9), Color(0xFF929E75), Color(0xFF465337)],
        ).createShader(knob),
    );
  }

  @override
  bool shouldRepaint(_RetroFaderPainter oldDelegate) =>
      oldDelegate.level != level;
}

class _RetroQueue extends ConsumerStatefulWidget {
  const _RetroQueue();

  @override
  ConsumerState<_RetroQueue> createState() => _RetroQueueState();
}

class _RetroQueueState extends ConsumerState<_RetroQueue> {
  final _scroll = ScrollController();

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _move(double delta) {
    if (!_scroll.hasClients) return;
    _scroll.jumpTo(
      (_scroll.offset + delta).clamp(0, _scroll.position.maxScrollExtent),
    );
  }

  @override
  Widget build(BuildContext context) {
    final queue = ref.watch(playQueueProvider).value ?? const <MediaItem>[];
    final current = ref.watch(currentQueueIndexProvider);
    const style = TextStyle(
      fontSize: 10,
      height: 1.1,
      color: Color(0xFFD4EBAA),
    );
    return Column(
      children: [
        SizedBox(
          height: 14,
          child: Row(
            children: [
              Expanded(
                child: Text(
                  context.l10n.desktopRetroQueue,
                  style: style.copyWith(
                    fontSize: 8,
                    letterSpacing: 1.4,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => _move(-36),
                child: const Icon(
                  Icons.arrow_drop_up,
                  size: 17,
                  color: _limeHighlight,
                ),
              ),
              GestureDetector(
                onTap: () => _move(36),
                child: const Icon(
                  Icons.arrow_drop_down,
                  size: 17,
                  color: _limeHighlight,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 5),
        Expanded(
          child: queue.isEmpty
              ? Center(
                  child: Text(context.l10n.desktopPlayerIdle, style: style),
                )
              : ListView.builder(
                  controller: _scroll,
                  padding: EdgeInsets.zero,
                  itemExtent: 18,
                  itemCount: queue.length,
                  itemBuilder: (context, index) {
                    final track = queue[index];
                    final selected = index == current;
                    return Semantics(
                      selected: selected,
                      button: true,
                      child: InkWell(
                        onTap: () => unawaited(
                          ref.read(musicPlayerControllerProvider).jumpTo(index),
                        ),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 2),
                          color: selected ? const Color(0xFF719B33) : null,
                          child: Row(
                            children: [
                              Icon(
                                selected
                                    ? Icons.check_box
                                    : Icons.check_box_outline_blank,
                                size: 11,
                                color: const Color(0xFFD4EBAA),
                              ),
                              const SizedBox(width: 3),
                              Expanded(
                                child: Text(
                                  track.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: style.copyWith(
                                    fontWeight: selected
                                        ? FontWeight.w700
                                        : FontWeight.w400,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                formatClock(track.duration?.inSeconds ?? 0),
                                style: style.copyWith(
                                  fontSize: 9,
                                  fontFeatures: const [
                                    FontFeature.tabularFigures(),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
