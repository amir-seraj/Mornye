part of 'desktop_player_bar.dart';

// The machined skin: a square, bolted CD deck. Bead-blasted gray metal with
// crimson anodized plates, a small green LCD, a brass knob, and the disc,
// printed with the album cover, turning behind two glazed cutouts.

const _machinedMetalLight = Color(0xFF9EA3A8);
const _machinedMetal = Color(0xFF6F7479);
const _machinedMetalDark = Color(0xFF3C4044);
const _machinedEdge = Color(0xFF111315);
const _machinedCrimsonLight = Color(0xFFA42A40);
const _machinedCrimson = Color(0xFF6E1528);
const _machinedCrimsonDark = Color(0xFF380913);
const _machinedGreen = Color(0xFF5CFF7E);
const _machinedGreenGlow = Color(0xFF1FD655);

/// The deck's square face.
final _machinedDeck = RRect.fromLTRBR(
  24,
  26,
  410,
  408,
  const Radius.circular(22),
);

/// The crimson tabs that cap the top and bottom edges.
final _machinedTopTab = RRect.fromLTRBR(
  136,
  10,
  304,
  40,
  const Radius.circular(6),
);
final _machinedBottomTab = RRect.fromLTRBR(
  158,
  396,
  282,
  424,
  const Radius.circular(6),
);

/// The crimson control plate holding the LCD.
final _machinedPlate = RRect.fromLTRBR(
  40,
  74,
  262,
  198,
  const Radius.circular(10),
);
const _machinedLcd = Rect.fromLTRB(82, 86, 198, 186);

const _machinedKnobCenter = Offset(232, 238);
const double _machinedKnobRadius = 22;

/// Where the disc turns, under the deck.
const _machinedDiscCenter = Offset(262, 292);
const double _machinedDiscRadius = 168;

/// The chamfered cutout at the upper right.
Path _machinedUpperWindow() => Path()
  ..moveTo(282, 70)
  ..lineTo(392, 70)
  ..lineTo(394, 72)
  ..lineTo(394, 284)
  ..lineTo(352, 284)
  ..lineTo(322, 256)
  ..lineTo(322, 196)
  ..lineTo(282, 164)
  ..close();

/// The half-round cutout across the bottom.
Path _machinedLowerWindow() => Path()
  ..moveTo(60, 300)
  ..lineTo(120, 300)
  ..lineTo(134, 288)
  ..lineTo(302, 288)
  ..lineTo(316, 300)
  ..lineTo(376, 300)
  ..arcTo(const Rect.fromLTRB(60, 202, 376, 394), 0, math.pi, false)
  ..close();

Path _machinedWindows() => Path.combine(
  PathOperation.union,
  _machinedUpperWindow(),
  _machinedLowerWindow(),
);

/// Everything solid: the deck and its tabs, where the window drags.
Path _machinedGrabPath() {
  var path = Path()..addRRect(_machinedDeck);
  for (final tab in [_machinedTopTab, _machinedBottomTab]) {
    path = Path.combine(PathOperation.union, path, Path()..addRRect(tab));
  }
  return path;
}

class _MachinedGrabClipper extends CustomClipper<Path> {
  const _MachinedGrabClipper();

  @override
  Path getClip(Size size) => _machinedGrabPath();

  @override
  bool shouldReclip(_MachinedGrabClipper oldClipper) => false;
}

class _MachinedWindowsClipper extends CustomClipper<Path> {
  const _MachinedWindowsClipper();

  @override
  Path getClip(Size size) => _machinedWindows();

  @override
  bool shouldReclip(_MachinedWindowsClipper oldClipper) => false;
}

/// Fine light and dark specks over [bounds]: a bead-blasted finish.
void _machinedGrain(Canvas canvas, Rect bounds, int seed, double strength) {
  final random = math.Random(seed);
  final light = Path();
  final dark = Path();
  final count = (bounds.width * bounds.height / 22).round();
  for (var i = 0; i < count; i++) {
    final speck = Rect.fromLTWH(
      bounds.left + random.nextDouble() * bounds.width,
      bounds.top + random.nextDouble() * bounds.height,
      1,
      1,
    );
    (random.nextBool() ? light : dark).addRect(speck);
  }
  canvas.drawPath(
    light,
    Paint()..color = Colors.white.withValues(alpha: strength),
  );
  canvas.drawPath(
    dark,
    Paint()..color = Colors.black.withValues(alpha: strength * 1.4),
  );
}

/// A cross-head screw sunk into the metal.
void _machinedScrew(Canvas canvas, Offset center, {double radius = 6}) {
  canvas.drawCircle(
    center.translate(0, 1),
    radius + 1.5,
    Paint()..color = Colors.black.withValues(alpha: 0.6),
  );
  canvas.drawCircle(
    center,
    radius,
    Paint()
      ..shader = const RadialGradient(
        center: Alignment(-0.4, -0.5),
        colors: [Color(0xFFE6E8EA), Color(0xFF8A8F94), Color(0xFF3A3D41)],
      ).createShader(Rect.fromCircle(center: center, radius: radius)),
  );
  canvas.drawArc(
    Rect.fromCircle(center: center, radius: radius - 0.8),
    math.pi * 1.05,
    math.pi * 0.65,
    false,
    Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.7
      ..color = const Color(0xFFE6ECE9).withValues(alpha: 0.7),
  );
  final slot = Paint()
    ..strokeWidth = 1.6
    ..strokeCap = StrokeCap.round
    ..color = const Color(0xFF26292C);
  final r = radius * 0.55;
  canvas.drawLine(center.translate(-r, -r), center.translate(r, r), slot);
  canvas.drawLine(center.translate(-r, r), center.translate(r, -r), slot);
  canvas.drawCircle(
    center,
    radius,
    Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8
      ..color = _machinedEdge,
  );
}

/// Bevels a flat part: a lit lip inside the top, a shade inside the bottom.
void _machinedBevel(Canvas canvas, Path path, {double depth = 1}) {
  canvas.save();
  canvas.clipPath(path);
  canvas.drawPath(
    path.shift(Offset(0, 2 * depth)),
    Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5 * depth
      ..color = Colors.white.withValues(alpha: 0.32),
  );
  canvas.drawPath(
    path.shift(Offset(0, -4 * depth)),
    Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 7 * depth
      ..color = Colors.black.withValues(alpha: 0.45)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
  );
  canvas.restore();
  canvas.drawPath(
    path,
    Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.3
      ..color = _machinedEdge,
  );
}

/// An anodized crimson part with its bevel and grain.
void _machinedCrimsonPart(Canvas canvas, RRect part, int seed) {
  final path = Path()..addRRect(part);
  canvas.drawRRect(
    part.shift(const Offset(0, 4)),
    Paint()
      ..color = Colors.black.withValues(alpha: 0.6)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
  );
  canvas.drawRRect(
    part,
    Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [_machinedCrimsonLight, _machinedCrimson, _machinedCrimsonDark],
      ).createShader(part.outerRect),
  );
  canvas.save();
  canvas.clipRRect(part);
  _machinedGrain(canvas, part.outerRect, seed, 0.035);
  final brush = Paint()..strokeWidth = 0.45;
  for (var y = part.top + 2; y < part.bottom - 2; y += 1.8) {
    brush.color = const Color(0xFFE8A4AE).withValues(alpha: 0.055);
    canvas.drawLine(Offset(part.left + 2, y), Offset(part.right - 2, y), brush);
  }
  canvas.restore();
  _skinRelief(
    canvas,
    path,
    shade: _machinedCrimsonDark.withValues(alpha: 0.8),
    light: const Color(0xFFEBA6AE).withValues(alpha: 0.6),
    width: 3,
  );
  _machinedBevel(canvas, path);
}

/// Engraved lettering: dark strokes with a light lip under them.
void _machinedEngrave(
  Canvas canvas,
  String text,
  Offset center, {
  double size = 7,
  double spacing = 1.6,
  Color color = const Color(0xFF1A0408),
  double angle = 0,
}) {
  final painter = TextPainter(
    text: TextSpan(
      text: text,
      style: TextStyle(
        fontSize: size,
        fontWeight: FontWeight.w700,
        letterSpacing: spacing,
        color: color,
        shadows: [
          Shadow(
            color: Colors.white.withValues(alpha: 0.28),
            offset: const Offset(0, 0.8),
          ),
        ],
      ),
    ),
    textDirection: TextDirection.ltr,
  )..layout();
  canvas.save();
  canvas.translate(center.dx, center.dy);
  canvas.rotate(angle);
  painter.paint(canvas, Offset(-painter.width / 2, -painter.height / 2));
  canvas.restore();
  painter.dispose();
}

/// Paints the deck: shadow, side wall, blasted face, seams and channels,
/// window frames, crimson plates, screws and the brass knob's collar.
class _MachinedDeckPainter extends CustomPainter {
  const _MachinedDeckPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final deck = Path()..addRRect(_machinedDeck);
    final windows = _machinedWindows();

    // The shadow and side wall only show outside the face, so the windows
    // stay clear down to the disc.
    canvas.save();
    canvas.clipPath(
      Path.combine(
        PathOperation.difference,
        Path()..addRect(Offset.zero & size),
        deck,
      ),
    );
    canvas.drawShadow(
      _machinedGrabPath().shift(const Offset(0, 10)),
      Colors.black,
      12,
      false,
    );
    // The side wall.
    const depth = 10.0;
    for (var d = depth; d >= 1; d--) {
      canvas.drawRRect(
        _machinedDeck.shift(Offset(0, d)),
        Paint()
          ..color = Color.lerp(_machinedMetalDark, _machinedEdge, d / depth)!,
      );
    }
    canvas.restore();

    // The face, with the windows cut out of it.
    final face = Path.combine(PathOperation.difference, deck, windows);
    canvas.drawPath(
      face,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _machinedMetalLight,
            _machinedMetal,
            Color(0xFF575B60),
            _machinedMetalDark,
          ],
          stops: [0, 0.35, 0.7, 1],
        ).createShader(_machinedDeck.outerRect),
    );
    canvas.save();
    canvas.clipPath(face);
    _machinedGrain(canvas, _machinedDeck.outerRect, 11, 0.05);
    // Panel seams and recessed channels milled into the face.
    final seam = Paint()
      ..strokeWidth = 1.2
      ..color = Colors.black.withValues(alpha: 0.55);
    final seamLip = Paint()
      ..strokeWidth = 1
      ..color = Colors.white.withValues(alpha: 0.22);
    for (final (a, b) in [
      (const Offset(24, 60), const Offset(410, 60)),
      (const Offset(270, 60), const Offset(270, 212)),
      (const Offset(24, 214), const Offset(176, 214)),
      (const Offset(24, 284), const Offset(60, 284)),
      (const Offset(376, 300), const Offset(410, 300)),
    ]) {
      canvas.drawLine(a, b, seam);
      canvas.drawLine(a.translate(0, 1.2), b.translate(0, 1.2), seamLip);
    }
    for (final channel in [
      RRect.fromLTRBR(28, 220, 36, 278, const Radius.circular(4)),
      RRect.fromLTRBR(398, 310, 406, 380, const Radius.circular(4)),
      RRect.fromLTRBR(28, 310, 36, 380, const Radius.circular(4)),
    ]) {
      canvas.drawRRect(channel, Paint()..color = const Color(0xFF1C1E21));
      canvas.drawRRect(
        channel.shift(const Offset(0, 1)),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.8
          ..color = Colors.white.withValues(alpha: 0.25),
      );
    }
    canvas.restore();
    _machinedBevel(canvas, deck, depth: 1.4);
    _skinRelief(
      canvas,
      deck,
      shade: _machinedEdge.withValues(alpha: 0.7),
      light: const Color(0xFFE0E5E3).withValues(alpha: 0.7),
      width: 8,
    );
    // A milled step just inside the edge: a dark cut, then a lit ledge.
    final step = _machinedDeck.deflate(9);
    canvas.drawRRect(
      step,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = Colors.black.withValues(alpha: 0.5),
    );
    canvas.drawRRect(
      step.deflate(1.6),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = Colors.white.withValues(alpha: 0.28),
    );

    // Shadow at the top of the cutout reveals the thickness of the deck.
    canvas.save();
    canvas.clipPath(windows);
    canvas.drawPath(
      windows.shift(const Offset(2, 5)),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 10
        ..color = _machinedEdge.withValues(alpha: 0.85)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2),
    );
    canvas.restore();
    // The window frames: a dark recessed lip with a lit outer edge.
    canvas.drawPath(
      windows,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 9
        ..strokeJoin = StrokeJoin.round
        ..color = const Color(0xFF2A2D31),
    );
    canvas.drawPath(
      windows.shift(const Offset(0, 1.5)),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2
        ..strokeJoin = StrokeJoin.round
        ..color = Colors.white.withValues(alpha: 0.35),
    );
    canvas.drawPath(
      windows,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4
        ..strokeJoin = StrokeJoin.round
        ..color = _machinedEdge,
    );

    _machinedCrimsonPart(canvas, _machinedTopTab, 3);
    _machinedCrimsonPart(canvas, _machinedBottomTab, 4);
    _machinedCrimsonPart(canvas, _machinedPlate, 5);
    _machinedEngrave(canvas, 'MORNYE · DISC DECK', const Offset(196, 25));
    _machinedEngrave(canvas, 'MR-440 · 2026', const Offset(220, 410));
    _machinedEngrave(
      canvas,
      'MORNYE AUDIO',
      const Offset(48, 136),
      size: 5.5,
      angle: -math.pi / 2,
      color: const Color(0xFFE6B3BD),
    );

    // The LCD's black frame.
    final lcd = RRect.fromRectAndRadius(
      _machinedLcd.inflate(4),
      const Radius.circular(5),
    );
    canvas.drawRRect(lcd, Paint()..color = const Color(0xFF07080A));
    canvas.drawRRect(
      lcd.shift(const Offset(0, 1.2)),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = Colors.white.withValues(alpha: 0.2),
    );

    // The speaker grille beside it.
    final grille = RRect.fromLTRBR(208, 90, 232, 170, const Radius.circular(4));
    canvas.drawRRect(grille, Paint()..color = const Color(0xFF1A0408));
    final hole = Paint()..color = const Color(0xFF050101);
    for (var y = 94.0; y < 166; y += 5) {
      for (var x = 212.0; x < 230; x += 5) {
        canvas.drawCircle(Offset(x, y), 1.3, hole);
      }
    }
    canvas.drawRRect(
      grille,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = Colors.white.withValues(alpha: 0.18),
    );

    // The knob's collar, milled into the face.
    canvas.drawCircle(
      _machinedKnobCenter,
      _machinedKnobRadius + 8,
      Paint()..color = const Color(0xFF26292C),
    );
    canvas.drawCircle(
      _machinedKnobCenter,
      _machinedKnobRadius + 8,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2
        ..color = Colors.white.withValues(alpha: 0.3),
    );

    for (final screw in const [
      Offset(42, 44),
      Offset(392, 44),
      Offset(42, 392),
      Offset(392, 392),
      Offset(150, 25),
      Offset(290, 25),
      Offset(172, 410),
      Offset(268, 410),
      Offset(54, 86),
      Offset(250, 86),
      Offset(54, 186),
      Offset(250, 186),
      Offset(408, 180),
      Offset(306, 300),
    ]) {
      _machinedScrew(
        canvas,
        screw,
        radius: screw.dy < 30 || screw.dy > 405 || screw.dx > 400 ? 4 : 5,
      );
    }
  }

  @override
  bool shouldRepaint(_MachinedDeckPainter oldDelegate) => false;
}

/// The dark cavity behind the windows, painted under the disc.
class _MachinedCavityPainter extends CustomPainter {
  const _MachinedCavityPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = RadialGradient(
          center: Alignment(
            _machinedDiscCenter.dx / size.width * 2 - 1,
            _machinedDiscCenter.dy / size.height * 2 - 1,
          ),
          radius: 0.8,
          colors: const [Color(0xFF15301C), Color(0xFF050807)],
        ).createShader(rect),
    );
  }

  @override
  bool shouldRepaint(_MachinedCavityPainter oldDelegate) => false;
}

/// The disc's surface over the album cover: grooves, a rainbow sheen, the
/// clear center ring and the metal hub.
class _MachinedDiscPainter extends CustomPainter {
  const _MachinedDiscPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.shortestSide / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..shader = SweepGradient(
          colors: [
            Colors.white.withValues(alpha: 0),
            const Color(0xFF8CF4FF).withValues(alpha: 0.28),
            Colors.white.withValues(alpha: 0),
            const Color(0xFFFF9CE6).withValues(alpha: 0.24),
            Colors.white.withValues(alpha: 0),
            const Color(0xFFC6FF8A).withValues(alpha: 0.26),
            Colors.white.withValues(alpha: 0),
          ],
        ).createShader(rect),
    );
    final groove = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.6;
    for (var r = radius * 0.34; r < radius; r += 3.2) {
      groove.color = Colors.black.withValues(alpha: 0.08);
      canvas.drawCircle(center, r, groove);
    }
    // The clear plastic center and the spindle hub.
    canvas.drawCircle(
      center,
      radius * 0.3,
      Paint()..color = const Color(0xFFDDE3E6).withValues(alpha: 0.55),
    );
    canvas.drawCircle(
      center,
      radius * 0.3,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2
        ..color = Colors.black.withValues(alpha: 0.4),
    );
    canvas.drawCircle(
      center,
      radius * 0.14,
      Paint()
        ..shader = const RadialGradient(
          center: Alignment(-0.3, -0.4),
          colors: [Color(0xFFECEEF0), Color(0xFF7D8288), Color(0xFF2B2E31)],
        ).createShader(Rect.fromCircle(center: center, radius: radius * 0.14)),
    );
    canvas.drawCircle(
      center,
      radius * 0.05,
      Paint()..color = const Color(0xFF0B0C0D),
    );
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = Colors.black.withValues(alpha: 0.5),
    );
  }

  @override
  bool shouldRepaint(_MachinedDiscPainter oldDelegate) => false;
}

/// The glazing over the windows: a faint green tint, a reflection band and
/// shade along the frames.
class _MachinedGlassPainter extends CustomPainter {
  const _MachinedGlassPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final windows = _machinedWindows();
    canvas.save();
    canvas.clipPath(windows);
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = _machinedGreenGlow.withValues(alpha: 0.08),
    );
    final band = Path()
      ..moveTo(300, 60)
      ..lineTo(350, 60)
      ..lineTo(180, 420)
      ..lineTo(130, 420)
      ..close();
    canvas.drawPath(
      band,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.1)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
    );
    canvas.drawPath(
      windows,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 16
        ..color = Colors.black.withValues(alpha: 0.65)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(_MachinedGlassPainter oldDelegate) => false;
}

/// The brass knob: knurled rim, domed cap, a tick showing play state.
class _MachinedKnob extends StatefulWidget {
  const _MachinedKnob({
    required this.playing,
    required this.tooltip,
    required this.onPressed,
  });

  final bool playing;
  final String tooltip;
  final VoidCallback? onPressed;

  @override
  State<_MachinedKnob> createState() => _MachinedKnobState();
}

class _MachinedKnobState extends State<_MachinedKnob> {
  bool _hover = false;
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onPressed != null;
    return Tooltip(
      message: widget.tooltip,
      waitDuration: const Duration(milliseconds: 600),
      child: MouseRegion(
        cursor: enabled ? SystemMouseCursors.click : MouseCursor.defer,
        onEnter: (_) => setState(() => _hover = true),
        onExit: (_) => setState(() => _hover = _down = false),
        child: GestureDetector(
          key: const ValueKey('machined-play-pause'),
          behavior: HitTestBehavior.opaque,
          onTapDown: enabled ? (_) => setState(() => _down = true) : null,
          onTapUp: enabled ? (_) => setState(() => _down = false) : null,
          onTapCancel: () => setState(() => _down = false),
          onTap: widget.onPressed,
          child: CustomPaint(
            size: const Size.square(_machinedKnobRadius * 2),
            painter: _MachinedKnobPainter(
              playing: widget.playing,
              hover: _hover && enabled,
              down: _down,
            ),
          ),
        ),
      ),
    );
  }
}

class _MachinedKnobPainter extends CustomPainter {
  const _MachinedKnobPainter({
    required this.playing,
    required this.hover,
    required this.down,
  });

  final bool playing;
  final bool hover;
  final bool down;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.shortestSide / 2;
    canvas.drawCircle(
      center.translate(0, down ? 1 : 3),
      radius,
      Paint()
        ..color = Colors.black.withValues(alpha: 0.6)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
    );
    // The knurled rim.
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..shader = const SweepGradient(
          colors: [
            Color(0xFFE9C77A),
            Color(0xFF7A5A1E),
            Color(0xFFD9B260),
            Color(0xFF6B4C16),
            Color(0xFFE9C77A),
          ],
        ).createShader(Rect.fromCircle(center: center, radius: radius)),
    );
    final knurl = Paint()
      ..strokeWidth = 1
      ..color = const Color(0xFF3F2C0A).withValues(alpha: 0.6);
    for (var i = 0; i < 36; i++) {
      final angle = i * math.pi * 2 / 36;
      final direction = Offset(math.cos(angle), math.sin(angle));
      canvas.drawLine(
        center + direction * radius * 0.78,
        center + direction * radius,
        knurl,
      );
    }
    // The domed cap.
    var cap = const [Color(0xFFFFF0C0), Color(0xFFD6A84E), Color(0xFF6E4E14)];
    if (down) cap = cap.reversed.toList();
    if (hover && !down) {
      cap = [for (final c in cap) Color.lerp(c, Colors.white, 0.15)!];
    }
    canvas.drawCircle(
      center,
      radius * 0.74,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.35, -0.45),
          colors: cap,
        ).createShader(Rect.fromCircle(center: center, radius: radius * 0.74)),
    );
    canvas.drawCircle(
      center,
      radius * 0.74,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = const Color(0xFF3F2C0A),
    );
    // A pause or play glyph engraved in the cap.
    final glyph = Paint()..color = const Color(0xFF4A3410);
    final g = radius * 0.26;
    if (playing) {
      canvas.drawRect(
        Rect.fromCenter(
          center: center.translate(-g * 0.45, 0),
          width: g * 0.5,
          height: g * 1.6,
        ),
        glyph,
      );
      canvas.drawRect(
        Rect.fromCenter(
          center: center.translate(g * 0.45, 0),
          width: g * 0.5,
          height: g * 1.6,
        ),
        glyph,
      );
    } else {
      canvas.drawPath(
        Path()
          ..moveTo(center.dx - g * 0.6, center.dy - g * 0.85)
          ..lineTo(center.dx + g * 0.9, center.dy)
          ..lineTo(center.dx - g * 0.6, center.dy + g * 0.85)
          ..close(),
        glyph,
      );
    }
  }

  @override
  bool shouldRepaint(_MachinedKnobPainter oldDelegate) =>
      oldDelegate.playing != playing ||
      oldDelegate.hover != hover ||
      oldDelegate.down != down;
}

class _MachinedLedPainter extends CustomPainter {
  _MachinedLedPainter(this.pulse, {required this.playing})
    : super(repaint: pulse);

  final _RetroPulse pulse;
  final bool playing;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final lit = playing ? 0.55 + pulse.energy * 0.45 : 0.1;
    canvas.drawCircle(
      center,
      size.width,
      Paint()
        ..color = _machinedGreen.withValues(alpha: lit * 0.55)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );
    canvas.drawCircle(
      center,
      size.width / 2,
      Paint()
        ..color = Color.lerp(const Color(0xFF0E2A14), _machinedGreen, lit)!,
    );
    canvas.drawCircle(
      center.translate(-0.8, -1),
      size.width / 6,
      Paint()..color = Colors.white.withValues(alpha: 0.7),
    );
  }

  @override
  bool shouldRepaint(_MachinedLedPainter oldDelegate) =>
      oldDelegate.pulse != pulse || oldDelegate.playing != playing;
}

/// A recessed groove with a green-lit trail and a crimson playhead.
class _MachinedSeekGroove extends ConsumerWidget {
  const _MachinedSeekGroove({required this.mediaItem});

  final MediaItem? mediaItem;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final item = mediaItem;
    final duration = item?.duration ?? Duration.zero;
    final position = item == null
        ? Duration.zero
        : ref.watch(playbackPositionProvider);
    final playing =
        ref.watch(playbackPlayingProvider) &&
        !ref.watch(playbackLoadingProvider);
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(9),
        color: const Color(0xFF16181A),
        border: Border.all(color: Colors.white.withValues(alpha: 0.22)),
        boxShadow: const [
          BoxShadow(
            color: Colors.black54,
            blurRadius: 3,
            offset: Offset(0, -1),
          ),
        ],
      ),
      child: SliderTheme(
        data: SliderTheme.of(context).copyWith(
          trackHeight: 3,
          activeTrackColor: _machinedGreen,
          inactiveTrackColor: const Color(0xFF2B2E31),
          thumbColor: _machinedCrimsonLight,
          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
          overlayShape: const RoundSliderOverlayShape(overlayRadius: 9),
          overlayColor: _machinedGreen.withValues(alpha: 0.2),
        ),
        child: PlaybackSeekSlider(
          key: ValueKey(item?.id),
          position: position,
          duration: duration,
          playing: playing,
          onSeek: ref.read(musicPlayerControllerProvider).seek,
        ),
      ),
    );
  }
}

/// Elapsed and total time on the LCD.
class _MachinedTime extends ConsumerWidget {
  const _MachinedTime({required this.mediaItem});

  final MediaItem? mediaItem;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final duration = mediaItem?.duration ?? Duration.zero;
    final position = mediaItem == null
        ? Duration.zero
        : ref.watch(playbackPositionProvider);
    final elapsed = position.inSeconds.clamp(0, duration.inSeconds);
    return Text(
      '${formatClock(elapsed)} / ${formatClock(duration.inSeconds)}',
      style: const TextStyle(
        fontSize: 8.5,
        fontFeatures: [FontFeature.tabularFigures()],
      ),
    );
  }
}

extension _MachinedLayout on _RetroMiniPlayerState {
  Widget _machinedLayout(
    BuildContext context, {
    required MediaItem? mediaItem,
    required bool playing,
    required bool loading,
  }) {
    final l10n = context.l10n;
    final controller = ref.read(musicPlayerControllerProvider);
    final enabled = mediaItem != null;
    const glow = [Shadow(color: _machinedGreenGlow, blurRadius: 2.5)];
    const discSize = _machinedDiscRadius * 2;

    Widget pill(
      String key,
      IconData icon,
      String tooltip,
      VoidCallback? onPressed, {
      Size size = const Size(32, 20),
      double iconSize = 13,
      _RetroPillKind kind = _RetroPillKind.chrome,
    }) => _RetroPill(
      key: ValueKey('machined-$key'),
      icon: icon,
      tooltip: tooltip,
      kind: kind,
      size: size,
      iconSize: iconSize,
      onPressed: onPressed,
    );

    return Material(
      type: MaterialType.transparency,
      child: DesktopVolumeScroll(
        child: OverflowBox(
          alignment: Alignment.topLeft,
          minWidth: _machinedSkinSize.width,
          maxWidth: _machinedSkinSize.width,
          minHeight: _machinedSkinSize.height,
          maxHeight: _machinedSkinSize.height,
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // The disc and its cavity, seen only through the windows.
                Positioned.fill(
                  child: IgnorePointer(
                    child: ClipPath(
                      clipper: const _MachinedWindowsClipper(),
                      child: Stack(
                        children: [
                          const Positioned.fill(
                            child: RepaintBoundary(
                              child: CustomPaint(
                                painter: _MachinedCavityPainter(),
                              ),
                            ),
                          ),
                          Positioned(
                            left: _machinedDiscCenter.dx - _machinedDiscRadius,
                            top: _machinedDiscCenter.dy - _machinedDiscRadius,
                            width: discSize,
                            height: discSize,
                            child: ListenableBuilder(
                              listenable: _pulse,
                              builder: (context, disc) => Transform.rotate(
                                angle: _pulse.time * 2.2,
                                child: disc,
                              ),
                              child: RepaintBoundary(
                                child: ClipOval(
                                  child: Stack(
                                    fit: StackFit.expand,
                                    children: [
                                      _Artwork(
                                        mediaItem: mediaItem,
                                        size: discSize,
                                        radius: _machinedDiscRadius,
                                      ),
                                      const CustomPaint(
                                        painter: _MachinedDiscPainter(),
                                      ),
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
                const Positioned.fill(
                  child: IgnorePointer(
                    child: RepaintBoundary(
                      child: CustomPaint(painter: _MachinedGlassPainter()),
                    ),
                  ),
                ),
                const Positioned.fill(
                  child: RepaintBoundary(
                    child: CustomPaint(painter: _MachinedDeckPainter()),
                  ),
                ),
                const Positioned.fill(
                  child: ClipPath(
                    clipper: _MachinedGrabClipper(),
                    child: DesktopWindowDragArea(frameless: true),
                  ),
                ),
                // The LCD.
                Positioned.fromRect(
                  rect: _machinedLcd,
                  child: IgnorePointer(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(3),
                      child: DecoratedBox(
                        decoration: const BoxDecoration(
                          gradient: RadialGradient(
                            radius: 1.1,
                            colors: [Color(0xFF0D2412), Color(0xFF020604)],
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(7, 6, 7, 5),
                          child: DefaultTextStyle(
                            style: const TextStyle(
                              fontSize: 9,
                              height: 1.25,
                              color: _machinedGreen,
                              shadows: glow,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        mediaItem == null
                                            ? 'IDLE'
                                            : playing
                                            ? 'PLAY'
                                            : 'PAUSE',
                                        style: const TextStyle(
                                          fontSize: 7.5,
                                          letterSpacing: 1.2,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.clip,
                                      ),
                                    ),
                                    const _RetroClock(
                                      style: TextStyle(
                                        fontSize: 13,
                                        height: 1,
                                        fontWeight: FontWeight.w800,
                                        color: _machinedGreen,
                                        shadows: glow,
                                        fontFeatures: [
                                          FontFeature.tabularFigures(),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  mediaItem?.title ?? l10n.desktopPlayerIdle,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFFB8FFC8),
                                  ),
                                ),
                                Text(
                                  mediaItem?.artist ?? '',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 3),
                                Expanded(
                                  child: RepaintBoundary(
                                    child: ValueListenableBuilder<_RetroScope>(
                                      valueListenable: _retroScope,
                                      builder: (context, style, _) =>
                                          CustomPaint(
                                            painter: _RetroScopePainter(
                                              _pulse,
                                              style,
                                              core: const Color(0xFFC8FFD4),
                                              glowColor: _machinedGreenGlow,
                                            ),
                                            size: Size.infinite,
                                          ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                _MachinedTime(mediaItem: mediaItem),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                // Track keys set into the plate's edge.
                Positioned(
                  left: 60,
                  top: 92,
                  child: pill(
                    'previous',
                    Icons.skip_previous,
                    l10n.nowPlayingPreviousTrack,
                    enabled ? controller.previous : null,
                    size: const Size(16, 40),
                    iconSize: 12,
                    kind: _RetroPillKind.obsidian,
                  ),
                ),
                Positioned(
                  left: 60,
                  top: 140,
                  child: pill(
                    'next',
                    Icons.skip_next,
                    l10n.nowPlayingNextTrack,
                    enabled ? controller.next : null,
                    size: const Size(16, 40),
                    iconSize: 12,
                    kind: _RetroPillKind.obsidian,
                  ),
                ),
                Positioned(
                  left: 238,
                  top: 172,
                  width: 9,
                  height: 9,
                  child: IgnorePointer(
                    child: RepaintBoundary(
                      child: CustomPaint(
                        painter: _MachinedLedPainter(_pulse, playing: playing),
                      ),
                    ),
                  ),
                ),
                // Function keys under the plate.
                Positioned(
                  left: 44,
                  top: 222,
                  child: Row(
                    children: [
                      pill(
                        'stop',
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
                        'volume-down',
                        Icons.volume_down,
                        l10n.desktopMiniPlayerVolumeDown,
                        () => _nudgeVolume(-0.05),
                      ),
                      const SizedBox(width: 5),
                      pill(
                        'volume-up',
                        Icons.volume_up,
                        l10n.desktopMiniPlayerVolumeUp,
                        () => _nudgeVolume(0.05),
                      ),
                      const SizedBox(width: 5),
                      pill(
                        'visualizer',
                        Icons.equalizer,
                        l10n.desktopMiniPlayerVisualizer,
                        () => _retroScope.value =
                            _RetroScope.values[(_retroScope.value.index + 1) %
                                _RetroScope.values.length],
                      ),
                    ],
                  ),
                ),
                Positioned(
                  left: 46,
                  top: 254,
                  width: 150,
                  height: 18,
                  child: _MachinedSeekGroove(mediaItem: mediaItem),
                ),
                Positioned(
                  left: _machinedKnobCenter.dx - _machinedKnobRadius,
                  top: _machinedKnobCenter.dy - _machinedKnobRadius,
                  child: _MachinedKnob(
                    playing: playing,
                    tooltip: playing ? l10n.actionPause : l10n.tooltipPlay,
                    onPressed: enabled && !loading
                        ? () => controller.togglePlayPause(playing)
                        : null,
                  ),
                ),
                // Window keys on the top tab.
                Positioned(
                  left: 252,
                  top: 16,
                  child: Row(
                    children: [
                      pill(
                        'minimize',
                        Icons.remove,
                        l10n.desktopMiniPlayerMinimize,
                        () => unawaited(minimizeDesktopWindow()),
                        size: const Size(20, 16),
                        iconSize: 11,
                      ),
                      const SizedBox(width: 4),
                      pill(
                        'expand',
                        Icons.close,
                        l10n.desktopMiniPlayerExpand,
                        () => unawaited(setDesktopMiniPlayer(open: false)),
                        size: const Size(20, 16),
                        iconSize: 11,
                      ),
                    ],
                  ),
                ),
                // Skin key on the bottom tab.
                Positioned(
                  left: 252,
                  top: 402,
                  child: pill(
                    'next-skin',
                    Icons.palette,
                    l10n.desktopMiniPlayerNextSkin,
                    () => unawaited(
                      setDesktopMiniPlayerSkin(_nextSkin(widget.skin)),
                    ),
                    size: const Size(24, 16),
                    iconSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
