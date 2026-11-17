part of 'desktop_player_bar.dart';

// The thorn skin: a tarnished chrome candybar phone under a filigree crest,
// wrapped in thorned vines with chrome roses. The green screen shows the
// track through a visible pixel grid, and the Roman-numeral keypad drives
// playback.

const _thornSilverLight = Color(0xFFE9ECEF);
const _thornSilver = Color(0xFFA9AFB6);
const _thornSilverDark = Color(0xFF4B5057);
const _thornShadow = Color(0xFF16181B);
const _thornLcdDark = Color(0xFF082A1C);
const _thornLcdMid = Color(0xFF155C40);
const _thornLcdInk = Color(0xFF8DFFD0);

/// The phone body: a candybar, slightly waisted, rounded at both ends.
Path _thornBodyPath() => Path()
  ..moveTo(165, 34)
  ..cubicTo(222, 34, 258, 44, 260, 96)
  ..cubicTo(262, 170, 252, 230, 254, 290)
  ..cubicTo(256, 360, 262, 410, 258, 444)
  ..cubicTo(254, 470, 220, 474, 165, 474)
  ..cubicTo(110, 474, 76, 470, 72, 444)
  ..cubicTo(68, 410, 74, 360, 76, 290)
  ..cubicTo(78, 230, 68, 170, 70, 96)
  ..cubicTo(72, 44, 108, 34, 165, 34)
  ..close();

/// The front plate, set in from the edges.
Path _thornPlatePath() => Path()
  ..moveTo(165, 50)
  ..cubicTo(214, 50, 242, 58, 244, 100)
  ..cubicTo(246, 170, 238, 230, 240, 290)
  ..cubicTo(242, 360, 246, 404, 243, 436)
  ..cubicTo(240, 456, 214, 460, 165, 460)
  ..cubicTo(116, 460, 90, 456, 87, 436)
  ..cubicTo(84, 404, 88, 360, 90, 290)
  ..cubicTo(92, 230, 84, 170, 86, 100)
  ..cubicTo(88, 58, 116, 50, 165, 50)
  ..close();

const _thornScreen = Rect.fromLTRB(100, 142, 230, 248);

// Where the roses bloom, and how big.
const _thornRoses = [
  (Offset(268, 232), 30.0, 0.4),
  (Offset(56, 316), 32.0, 2.1),
  (Offset(262, 436), 30.0, 4.0),
];

/// The body and the roses: where the window can be dragged.
Path _thornGrabPath() {
  var path = _thornBodyPath();
  for (final (center, radius, _) in _thornRoses) {
    path = Path.combine(
      PathOperation.union,
      path,
      Path()..addOval(Rect.fromCircle(center: center, radius: radius)),
    );
  }
  return path;
}

class _ThornGrabClipper extends CustomClipper<Path> {
  const _ThornGrabClipper();

  @override
  Path getClip(Size size) => _thornGrabPath();

  @override
  bool shouldReclip(_ThornGrabClipper oldClipper) => false;
}

/// Polished metal across a curved surface: dark at the sides, a bright
/// streak left of center, lit from the upper left.
Shader _thornChrome(Rect bounds) => const LinearGradient(
  begin: Alignment.centerLeft,
  end: Alignment.centerRight,
  colors: [
    _thornShadow,
    _thornSilverDark,
    _thornSilverLight,
    _thornSilver,
    Color(0xFF6E747C),
    _thornSilverLight,
    _thornSilverDark,
    _thornShadow,
  ],
  stops: [0, 0.10, 0.21, 0.25, 0.40, 0.76, 0.83, 1],
).createShader(bounds);

/// Strokes [path] as a polished chrome cord: a dark core, a lit ridge.
void _chromeCord(Canvas canvas, Path path, double width) {
  canvas.drawPath(
    path.shift(const Offset(1.5, 3)),
    Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = width
      ..color = Colors.black.withValues(alpha: 0.5)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.5),
  );
  canvas.drawPath(
    path,
    Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = width
      ..color = _thornSilverDark,
  );
  canvas.drawPath(
    path.shift(const Offset(-0.6, -0.9)),
    Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = width * 0.45
      ..color = _thornSilverLight,
  );
}

/// Paints the phone: shadow, side wall, chrome body, the tarnished plate
/// with its filigree corners, the earpiece, the nameplate, the crest above
/// and below, and the screen's sunken bezel.
class _ThornBodyPainter extends CustomPainter {
  const _ThornBodyPainter();

  void _scroll(Canvas canvas, Offset at, double scale, {bool flip = false}) {
    final sx = flip ? -scale : scale;
    final path = Path()
      ..moveTo(at.dx, at.dy)
      ..cubicTo(
        at.dx + 10 * sx,
        at.dy - 2 * scale,
        at.dx + 16 * sx,
        at.dy + 8 * scale,
        at.dx + 8 * sx,
        at.dy + 12 * scale,
      )
      ..cubicTo(
        at.dx + 2 * sx,
        at.dy + 14 * scale,
        at.dx + 1 * sx,
        at.dy + 6 * scale,
        at.dx + 6 * sx,
        at.dy + 6 * scale,
      );
    _chromeCord(canvas, path, 2.2);
  }

  /// A spiked filigree crest centered on [center], mirrored left and right.
  void _crest(Canvas canvas, Offset center, double direction) {
    final d = direction;
    for (final side in [-1.0, 1.0]) {
      final curl = Path()
        ..moveTo(center.dx, center.dy)
        ..cubicTo(
          center.dx + 14 * side,
          center.dy - 16 * d,
          center.dx + 34 * side,
          center.dy - 4 * d,
          center.dx + 46 * side,
          center.dy - 14 * d,
        )
        ..cubicTo(
          center.dx + 56 * side,
          center.dy - 22 * d,
          center.dx + 50 * side,
          center.dy - 32 * d,
          center.dx + 42 * side,
          center.dy - 26 * d,
        );
      _chromeCord(canvas, curl, 5);
      // Spikes along the crest.
      for (final (x, h) in [(16.0, 14.0), (30.0, 11.0), (58.0, 9.0)]) {
        final spike = Path()
          ..moveTo(center.dx + (x - 4) * side, center.dy - 6 * d)
          ..lineTo(center.dx + x * side, center.dy - (6 + h) * d)
          ..lineTo(center.dx + (x + 4) * side, center.dy - 6 * d)
          ..close();
        canvas.drawPath(spike, Paint()..color = _thornSilver);
        canvas.drawPath(
          spike,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 0.8
            ..color = _thornShadow,
        );
      }
    }
    // The center spire.
    final spire = Path()
      ..moveTo(center.dx - 7, center.dy)
      ..lineTo(center.dx, center.dy - 26 * d)
      ..lineTo(center.dx + 7, center.dy)
      ..close();
    canvas.drawPath(spire, Paint()..shader = _thornChrome(spire.getBounds()));
    canvas.drawPath(
      spire,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.8
        ..color = _thornShadow,
    );
  }

  @override
  void paint(Canvas canvas, Size size) {
    final body = _thornBodyPath();
    final plate = _thornPlatePath();
    final bounds = body.getBounds();

    canvas.drawShadow(body.shift(const Offset(4, 10)), Colors.black, 10, false);
    // The side wall.
    const depth = 9.0;
    for (var d = depth; d >= 1; d--) {
      canvas.drawPath(
        body.shift(Offset(d * 0.3, d)),
        Paint()..color = Color.lerp(_thornSilverDark, _thornShadow, d / depth)!,
      );
    }
    canvas.drawPath(body, Paint()..shader = _thornChrome(bounds));

    _skinRelief(
      canvas,
      body,
      shade: _thornShadow.withValues(alpha: 0.85),
      light: const Color(0xFFF0F2EC).withValues(alpha: 0.85),
      width: 8,
    );

    // The plate: duller, tarnished metal set into the body.
    canvas.drawPath(
      plate.shift(const Offset(0, -1.5)),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..color = _thornShadow.withValues(alpha: 0.8)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.5),
    );
    canvas.drawPath(
      plate,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFC9CED4),
            Color(0xFF8C9299),
            Color(0xFF5E636A),
            Color(0xFF8A9097),
            Color(0xFF3E4248),
          ],
          stops: [0, 0.3, 0.55, 0.75, 1],
        ).createShader(plate.getBounds()),
    );
    canvas.save();
    canvas.clipPath(plate);
    _skinGrain(canvas, plate.getBounds(), seed: 71, strength: 0.10, pitch: 3);
    // Tarnish collects at the rolled plate edges, rather than coating the face.
    canvas.drawPath(
      plate,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 16
        ..color = const Color(0xFF382B1E).withValues(alpha: 0.36)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
    );
    // Tarnish: soft dark blooms and fine scratches.
    final random = math.Random(31);
    for (var i = 0; i < 26; i++) {
      final center = Offset(
        86 + random.nextDouble() * 158,
        50 + random.nextDouble() * 410,
      );
      final radius = 8 + random.nextDouble() * 26;
      canvas.drawCircle(
        center,
        radius,
        Paint()
          ..shader = RadialGradient(
            colors: [
              Colors.black.withValues(alpha: 0.05 + random.nextDouble() * 0.1),
              Colors.black.withValues(alpha: 0),
            ],
          ).createShader(Rect.fromCircle(center: center, radius: radius)),
      );
    }
    final scratch = Paint()..strokeWidth = 0.6;
    for (var i = 0; i < 70; i++) {
      final x = 86 + random.nextDouble() * 158;
      final y = 50 + random.nextDouble() * 410;
      final angle = random.nextDouble() * math.pi;
      final length = 4 + random.nextDouble() * 14;
      scratch.color = (random.nextBool() ? Colors.white : Colors.black)
          .withValues(alpha: 0.08 + random.nextDouble() * 0.12);
      canvas.drawLine(
        Offset(x, y),
        Offset(x + math.cos(angle) * length, y + math.sin(angle) * length),
        scratch,
      );
    }
    canvas.restore();
    canvas.drawPath(
      plate,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2
        ..color = _thornShadow,
    );
    canvas.drawPath(
      plate.shift(const Offset(0, 1.2)),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.8
        ..color = Colors.white.withValues(alpha: 0.35),
    );

    // Filigree in the plate's corners.
    _scroll(canvas, const Offset(100, 66), 1.1);
    _scroll(canvas, const Offset(230, 66), 1.1, flip: true);
    _scroll(canvas, const Offset(100, 262), 0.9);
    _scroll(canvas, const Offset(230, 262), 0.9, flip: true);

    // The earpiece: a pointed slot down the middle with three grille dashes.
    final ear = Path()
      ..moveTo(165, 58)
      ..quadraticBezierTo(171, 76, 165, 96)
      ..quadraticBezierTo(159, 76, 165, 58)
      ..close();
    canvas.drawPath(ear, Paint()..color = _thornShadow);
    canvas.drawPath(
      ear.shift(const Offset(0, 1)),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.8
        ..color = Colors.white.withValues(alpha: 0.4),
    );
    for (var i = 0; i < 3; i++) {
      final y = 102.0 + i * 7;
      canvas.drawRRect(
        RRect.fromLTRBR(160, y, 170, y + 3, const Radius.circular(1.5)),
        Paint()..color = _thornShadow,
      );
    }

    // The nameplate.
    final plaque = RRect.fromLTRBR(
      132,
      122,
      198,
      138,
      const Radius.circular(2),
    );
    canvas.drawRRect(plaque, Paint()..shader = _thornChrome(plaque.outerRect));
    canvas.drawRRect(
      plaque,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = _thornShadow,
    );
    final name = TextPainter(
      text: const TextSpan(
        text: 'MORNYE',
        style: TextStyle(
          fontFamily: 'serif',
          fontSize: 10,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.5,
          color: _thornShadow,
          shadows: [Shadow(color: Colors.white70, offset: Offset(0, 0.8))],
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    name.paint(canvas, Offset(165 - name.width / 2, 130 - name.height / 2));
    name.dispose();

    // The screen's sunken bezel.
    final bezel = RRect.fromRectAndRadius(
      _thornScreen.inflate(7),
      const Radius.circular(14),
    );
    canvas.drawRRect(
      bezel,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [_thornShadow, _thornSilverDark, _thornSilverLight],
        ).createShader(bezel.outerRect),
    );
    canvas.drawRRect(
      bezel,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2
        ..color = _thornShadow,
    );

    // The crest above and below.
    _crest(canvas, const Offset(165, 36), 1);
    _crest(canvas, const Offset(165, 464), -1);
  }

  @override
  bool shouldRepaint(_ThornBodyPainter oldDelegate) => false;
}

/// The vines and roses wrapped over the phone. Drawn above the keys, so
/// they never take a click.
class _ThornVinePainter extends CustomPainter {
  const _ThornVinePainter();

  static final List<Path> _vines = [
    Path()
      ..moveTo(28, 150)
      ..cubicTo(90, 120, 160, 150, 214, 112)
      ..cubicTo(250, 86, 290, 100, 300, 70),
    Path()
      ..moveTo(196, 70)
      ..cubicTo(230, 130, 240, 190, 268, 232),
    Path()
      ..moveTo(56, 316)
      ..cubicTo(110, 290, 200, 320, 250, 270)
      ..cubicTo(270, 250, 290, 262, 306, 250),
    Path()
      ..moveTo(40, 290)
      ..cubicTo(90, 360, 170, 330, 230, 400)
      ..cubicTo(248, 420, 256, 430, 262, 436),
    Path()
      ..moveTo(70, 470)
      ..cubicTo(110, 420, 190, 470, 262, 436),
  ];

  void _thorns(Canvas canvas, Path path) {
    final fill = Paint()..color = _thornSilver;
    final edge = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.7
      ..color = _thornShadow;
    for (final metric in path.computeMetrics()) {
      var side = 1.0;
      for (var d = 10.0; d < metric.length - 6; d += 13) {
        final tangent = metric.getTangentForOffset(d);
        if (tangent == null) continue;
        final along = tangent.vector / tangent.vector.distance;
        final normal = Offset(-along.dy, along.dx) * side;
        final base = tangent.position;
        final thorn = Path()
          ..moveTo(base.dx - along.dx * 4, base.dy - along.dy * 4)
          ..lineTo(
            base.dx + normal.dx * 11 + along.dx * 3,
            base.dy + normal.dy * 11 + along.dy * 3,
          )
          ..lineTo(base.dx + along.dx * 4, base.dy + along.dy * 4)
          ..close();
        fill.shader = _thornChrome(thorn.getBounds());
        canvas.drawPath(
          thorn.shift(const Offset(1, 2)),
          Paint()..color = _thornShadow.withValues(alpha: 0.6),
        );
        canvas.drawPath(thorn, fill);
        final facet = Path()
          ..moveTo(base.dx, base.dy)
          ..lineTo(
            base.dx + normal.dx * 11 + along.dx * 3,
            base.dy + normal.dy * 11 + along.dy * 3,
          )
          ..lineTo(base.dx + along.dx * 4, base.dy + along.dy * 4)
          ..close();
        canvas.drawPath(
          facet,
          Paint()..color = _thornShadow.withValues(alpha: 0.45),
        );
        canvas.drawPath(thorn, edge);
        side = -side;
      }
    }
  }

  void _leaf(Canvas canvas, Offset at, double angle) {
    canvas.save();
    canvas.translate(at.dx, at.dy);
    canvas.rotate(angle);
    final leaf = Path()
      ..moveTo(0, 0)
      ..quadraticBezierTo(12, -9, 26, 0)
      ..quadraticBezierTo(12, 9, 0, 0)
      ..close();
    canvas.drawPath(
      leaf,
      Paint()..shader = _thornChrome(const Rect.fromLTRB(0, -9, 26, 9)),
    );
    canvas.drawPath(
      leaf,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.9
        ..color = _thornShadow,
    );
    canvas.drawLine(
      Offset.zero,
      const Offset(22, 0),
      Paint()
        ..strokeWidth = 0.7
        ..color = _thornShadow,
    );
    canvas.restore();
  }

  /// A chrome rose: rings of cupped petals closing toward a spiral bud.
  void _rose(Canvas canvas, Offset center, double radius, double turn) {
    canvas.drawCircle(
      center.translate(2, 5),
      radius,
      Paint()
        ..color = Colors.black.withValues(alpha: 0.55)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
    );
    canvas.drawCircle(center, radius * 0.95, Paint()..color = _thornShadow);
    for (final (ring, count, scale) in [
      (0, 7, 1.0),
      (1, 6, 0.8),
      (2, 5, 0.6),
      (3, 4, 0.42),
    ]) {
      final r = radius * scale;
      for (var i = 0; i < count; i++) {
        final angle = turn + ring * 0.55 + i * math.pi * 2 / count;
        final petalCenter =
            center + Offset(math.cos(angle), math.sin(angle)) * r * 0.45;
        canvas.save();
        canvas.translate(petalCenter.dx, petalCenter.dy);
        canvas.rotate(angle);
        final petal = Rect.fromCenter(
          center: Offset.zero,
          width: r * 1.0,
          height: r * 0.92,
        );
        // Dark where the petal tucks in, bright along its curled rim.
        canvas.drawOval(
          petal,
          Paint()
            ..shader = LinearGradient(
              begin: Alignment(
                -math.cos(angle) - math.sin(angle),
                math.sin(angle) - math.cos(angle),
              ),
              end: Alignment(
                math.cos(angle) + math.sin(angle),
                math.cos(angle) - math.sin(angle),
              ),
              colors: const [
                _thornSilverLight,
                _thornSilver,
                Color(0xFF353A3F),
                Color(0xFF111614),
                _thornSilverDark,
              ],
              stops: const [0, 0.16, 0.34, 0.7, 1],
            ).createShader(petal),
        );
        // The curl: a crescent shadow just inside the rim.
        canvas.drawArc(
          petal.deflate(r * 0.12),
          -1.1,
          2.2,
          false,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = r * 0.08
            ..color = Colors.black.withValues(alpha: 0.55),
        );
        canvas.drawOval(
          petal,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 0.85
            ..color = const Color(0xFF0B0C0E),
        );
        canvas.restore();
      }
    }
    // The bud: a tight spiral.
    final spiral = Path()..moveTo(center.dx, center.dy);
    for (var t = 0.0; t < math.pi * 4; t += 0.2) {
      final r = radius * 0.04 * t;
      spiral.lineTo(
        center.dx + math.cos(t + turn) * r,
        center.dy + math.sin(t + turn) * r,
      );
    }
    canvas.drawPath(
      spiral,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6
        ..color = _thornShadow,
    );
    canvas.drawPath(
      spiral.shift(const Offset(-0.6, -0.6)),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.7
        ..color = _thornSilverLight,
    );
  }

  @override
  void paint(Canvas canvas, Size size) {
    for (final vine in _vines) {
      _chromeCord(canvas, vine, 6.5);
      _thorns(canvas, vine);
    }
    _leaf(canvas, const Offset(250, 252), 0.9);
    _leaf(canvas, const Offset(80, 330), 2.6);
    _leaf(canvas, const Offset(240, 448), 2.9);
    _leaf(canvas, const Offset(290, 212), -0.8);
    for (final (center, radius, turn) in _thornRoses) {
      _rose(canvas, center, radius, turn);
    }
  }

  @override
  bool shouldRepaint(_ThornVinePainter oldDelegate) => false;
}

/// The green screen: a dithered glow, then a pixel grid laid over whatever
/// it shows so even smooth text reads as an old LCD.
class _ThornLcdPainter extends CustomPainter {
  const _ThornLcdPainter({required this.grid});

  /// Draw the grid (over the content) instead of the backdrop (under it).
  final bool grid;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    if (!grid) {
      canvas.drawRect(
        rect,
        Paint()
          ..shader = const RadialGradient(
            center: Alignment(0, -0.2),
            radius: 0.9,
            colors: [_thornLcdMid, _thornLcdDark],
          ).createShader(rect),
      );
      // An ordered dither toward the bottom, like a pixel-art gradient.
      final dot = Paint()..color = _thornLcdInk.withValues(alpha: 0.18);
      for (var y = size.height * 0.62; y < size.height; y += 2) {
        final fill = (y - size.height * 0.62) / (size.height * 0.38);
        for (var x = 0.0; x < size.width; x += 2) {
          final threshold = ((x ~/ 2 + y ~/ 2 * 2) % 4) / 4;
          if (fill > threshold) canvas.drawRect(Rect.fromLTWH(x, y, 1, 1), dot);
        }
      }
      return;
    }
    final line = Paint()..color = _thornShadow.withValues(alpha: 0.17);
    for (var x = 0.0; x < size.width; x += 2) {
      canvas.drawRect(Rect.fromLTWH(x, 0, 0.6, size.height), line);
    }
    for (var y = 0.0; y < size.height; y += 2) {
      canvas.drawRect(Rect.fromLTWH(0, y, size.width, 0.6), line);
    }
    // The glass: a sheen across the top and dark corners.
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height * 0.35),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.white.withValues(alpha: 0.12),
            Colors.white.withValues(alpha: 0),
          ],
        ).createShader(rect),
    );
    canvas.drawRect(
      rect,
      Paint()
        ..shader = RadialGradient(
          radius: 0.85,
          colors: [
            Colors.black.withValues(alpha: 0),
            Colors.black.withValues(alpha: 0.28),
          ],
        ).createShader(rect),
    );
  }

  @override
  bool shouldRepaint(_ThornLcdPainter oldDelegate) => oldDelegate.grid != grid;
}

/// An oval keypad key in polished metal, with its numeral engraved.
class _ThornKey extends StatefulWidget {
  const _ThornKey({
    super.key,
    required this.label,
    required this.tooltip,
    required this.onPressed,
    this.size = const Size(44, 22),
    this.icon,
  });

  final String label;
  final String tooltip;
  final VoidCallback? onPressed;
  final Size size;

  /// Shown instead of [label], for the navigation key.
  final IconData? icon;

  @override
  State<_ThornKey> createState() => _ThornKeyState();
}

class _ThornKeyState extends State<_ThornKey> {
  bool _hover = false;
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onPressed != null;
    final engraved = const TextStyle(
      fontFamily: 'serif',
      fontSize: 11,
      fontWeight: FontWeight.w800,
      color: _thornShadow,
      shadows: [Shadow(color: Colors.white70, offset: Offset(0, 0.8))],
    );
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
            opacity: enabled ? 1 : 0.6,
            child: CustomPaint(
              size: widget.size,
              painter: _ThornKeyPainter(hover: _hover && enabled, down: _down),
              child: SizedBox.fromSize(
                size: widget.size,
                child: Center(
                  child: Transform.translate(
                    offset: Offset(0, _down ? 1 : 0),
                    child: widget.icon != null
                        ? Icon(
                            widget.icon,
                            size: 14,
                            color: _thornShadow,
                            shadows: const [
                              Shadow(
                                color: Colors.white70,
                                offset: Offset(0, 0.8),
                              ),
                            ],
                          )
                        : Text(widget.label, style: engraved),
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

class _ThornKeyPainter extends CustomPainter {
  const _ThornKeyPainter({required this.hover, required this.down});

  final bool hover;
  final bool down;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = (Offset(0, down ? 1 : 0) & size).deflate(0.5);
    canvas.drawOval(
      rect.shift(const Offset(1, 2.5)),
      Paint()
        ..color = Colors.black.withValues(alpha: down ? 0.2 : 0.55)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2),
    );
    var colors = const [
      _thornSilverLight,
      _thornSilver,
      _thornSilverDark,
      Color(0xFF2A2D31),
    ];
    if (down) {
      colors = [for (final c in colors) Color.lerp(c, _thornShadow, 0.24)!];
    }
    if (hover && !down) {
      colors = [for (final c in colors) Color.lerp(c, Colors.white, 0.2)!];
    }
    canvas.drawOval(
      rect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: colors,
        ).createShader(rect),
    );
    if (!down) {
      final gloss = Rect.fromLTRB(
        size.width * 0.18,
        size.height * 0.1,
        size.width * 0.82,
        size.height * 0.48,
      );
      canvas.drawOval(
        gloss,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.white.withValues(alpha: 0.7),
              Colors.white.withValues(alpha: 0),
            ],
          ).createShader(gloss),
      );
    }
    canvas.drawOval(
      rect,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.1
        ..color = _thornShadow,
    );
  }

  @override
  bool shouldRepaint(_ThornKeyPainter oldDelegate) =>
      oldDelegate.hover != hover || oldDelegate.down != down;
}

extension _ThornLayout on _RetroMiniPlayerState {
  Widget _thornLayout(
    BuildContext context, {
    required MediaItem? mediaItem,
    required bool playing,
    required bool loading,
  }) {
    final l10n = context.l10n;
    final controller = ref.read(musicPlayerControllerProvider);
    final enabled = mediaItem != null;
    const ink = [Shadow(color: _thornLcdInk, blurRadius: 2)];

    void skipBy(Duration delta) {
      final duration = mediaItem?.duration ?? Duration.zero;
      final target = ref.read(playbackPositionProvider) + delta;
      unawaited(
        controller.seek(
          target < Duration.zero
              ? Duration.zero
              : duration > Duration.zero && target > duration
              ? duration
              : target,
        ),
      );
    }

    VoidCallback? whenEnabled(VoidCallback action) => enabled ? action : null;
    final playPause = enabled && !loading
        ? () => controller.togglePlayPause(playing)
        : null;
    final keys = [
      ('I', l10n.nowPlayingPreviousTrack, whenEnabled(controller.previous)),
      ('II', playing ? l10n.actionPause : l10n.tooltipPlay, playPause),
      ('III', l10n.nowPlayingNextTrack, whenEnabled(controller.next)),
      ('IV', l10n.desktopMiniPlayerVolumeDown, () => _nudgeVolume(-0.05)),
      (
        'V',
        l10n.desktopMiniPlayerStop,
        whenEnabled(() async {
          if (playing) await controller.togglePlayPause(true);
          await controller.seek(Duration.zero);
        }),
      ),
      ('VI', l10n.desktopMiniPlayerVolumeUp, () => _nudgeVolume(0.05)),
      (
        'VII',
        l10n.desktopMiniPlayerVisualizer,
        () => _retroScope.value = _RetroScope
            .values[(_retroScope.value.index + 1) % _RetroScope.values.length],
      ),
      (
        'VIII',
        l10n.desktopMiniPlayerSkipBack,
        whenEnabled(() => skipBy(const Duration(seconds: -10))),
      ),
      (
        'IX',
        l10n.desktopMiniPlayerSkipForward,
        whenEnabled(() => skipBy(const Duration(seconds: 10))),
      ),
      (
        '✱',
        l10n.desktopMiniPlayerMinimize,
        () => unawaited(minimizeDesktopWindow()),
      ),
      (
        'X',
        l10n.desktopMiniPlayerNextSkin,
        () => unawaited(setDesktopMiniPlayerSkin(_nextSkin(widget.skin))),
      ),
      (
        '#',
        l10n.desktopMiniPlayerExpand,
        () => unawaited(setDesktopMiniPlayer(open: false)),
      ),
    ];

    return Material(
      type: MaterialType.transparency,
      child: DesktopVolumeScroll(
        child: OverflowBox(
          alignment: Alignment.topLeft,
          minWidth: _thornSkinSize.width,
          maxWidth: _thornSkinSize.width,
          minHeight: _thornSkinSize.height,
          maxHeight: _thornSkinSize.height,
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                const Positioned.fill(
                  child: RepaintBoundary(
                    child: CustomPaint(painter: _ThornBodyPainter()),
                  ),
                ),
                const Positioned.fill(
                  child: ClipPath(
                    clipper: _ThornGrabClipper(),
                    child: DesktopWindowDragArea(frameless: true),
                  ),
                ),
                // The screen.
                Positioned.fromRect(
                  rect: _thornScreen,
                  child: IgnorePointer(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Stack(
                        children: [
                          const Positioned.fill(
                            child: CustomPaint(
                              painter: _ThornLcdPainter(grid: false),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(8, 6, 8, 6),
                            child: DefaultTextStyle(
                              style: const TextStyle(
                                fontFamily: 'monospace',
                                fontSize: 10,
                                height: 1.25,
                                color: _thornLcdInk,
                                shadows: ink,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Row(
                                    children: [
                                      Text(playing ? '▶' : 'Ⅱ'),
                                      const Spacer(),
                                      const _RetroClock(
                                        style: TextStyle(
                                          fontFamily: 'monospace',
                                          fontSize: 12,
                                          height: 1,
                                          fontWeight: FontWeight.w800,
                                          color: _thornLcdInk,
                                          shadows: ink,
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
                                      child: CustomPaint(
                                        painter: _RetroScopePainter(
                                          _pulse,
                                          _RetroScope.bars,
                                          core: _thornLcdInk,
                                          glowColor: const Color(0xFF3BD99A),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  _ThornProgress(mediaItem: mediaItem),
                                ],
                              ),
                            ),
                          ),
                          const Positioned.fill(
                            child: CustomPaint(
                              painter: _ThornLcdPainter(grid: true),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                // The navigation key: play and pause.
                Positioned(
                  left: 130,
                  top: 262,
                  child: _ThornKey(
                    key: const ValueKey('thorn-play-pause'),
                    label: '',
                    icon: playing ? Icons.pause : Icons.play_arrow,
                    tooltip: playing ? l10n.actionPause : l10n.tooltipPlay,
                    size: const Size(70, 24),
                    onPressed: playPause,
                  ),
                ),
                for (var i = 0; i < keys.length; i++)
                  Positioned(
                    left: 117 + (i % 3) * 48 - 22,
                    top: 302 + (i ~/ 3) * 36,
                    child: _ThornKey(
                      key: ValueKey('thorn-key-${keys[i].$1}'),
                      label: keys[i].$1,
                      tooltip: keys[i].$2,
                      onPressed: keys[i].$3,
                    ),
                  ),
                const Positioned.fill(
                  child: IgnorePointer(
                    child: RepaintBoundary(
                      child: CustomPaint(painter: _ThornVinePainter()),
                    ),
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

/// The track's progress as a row of pixel blocks, with the time beside it.
class _ThornProgress extends ConsumerWidget {
  const _ThornProgress({required this.mediaItem});

  final MediaItem? mediaItem;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final duration = mediaItem?.duration ?? Duration.zero;
    final position = mediaItem == null
        ? Duration.zero
        : ref.watch(playbackPositionProvider);
    final elapsed = position.inSeconds.clamp(0, duration.inSeconds);
    final fraction = duration.inSeconds == 0
        ? 0.0
        : elapsed / duration.inSeconds;
    return Row(
      children: [
        Text(formatClock(elapsed), style: const TextStyle(fontSize: 9)),
        const SizedBox(width: 5),
        Expanded(
          child: SizedBox(
            height: 6,
            child: CustomPaint(painter: _ThornBlocksPainter(fraction)),
          ),
        ),
      ],
    );
  }
}

class _ThornBlocksPainter extends CustomPainter {
  const _ThornBlocksPainter(this.fraction);

  final double fraction;

  @override
  void paint(Canvas canvas, Size size) {
    const block = 4.0;
    final count = (size.width / block).floor();
    final lit = (count * fraction).round();
    for (var i = 0; i < count; i++) {
      canvas.drawRect(
        Rect.fromLTWH(i * block, 0, block - 1, size.height),
        Paint()
          ..color = i < lit
              ? _thornLcdInk
              : _thornLcdInk.withValues(alpha: 0.15),
      );
    }
  }

  @override
  bool shouldRepaint(_ThornBlocksPainter oldDelegate) =>
      oldDelegate.fraction != fraction;
}
