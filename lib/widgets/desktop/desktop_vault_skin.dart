part of 'desktop_player_bar.dart';

// The vault skin: a heavy matte-black disc machine. The album turns as a
// disc inside ribbed arc guards, a hub knob locks it to a bracket from the
// left housing, and the housing holds a tall touchscreen with the track.

const _vaultBlack = Color(0xFF0B0C0E);
const _vaultGraphite = Color(0xFF1E2024);
const _vaultSteel = Color(0xFF3A3E45);
const _vaultEdge = Color(0xFF6B717A);
const _vaultHighlight = Color(0xFFB9BFC7);
const _vaultInk = Color(0xFFE8ECF1);

const _vaultDiscCenter = Offset(312, 210);
const double _vaultDiscRadius = 140;
const double _vaultGuardInner = 146;
const double _vaultGuardOuter = 170;
const double _vaultRingRadius = 178;

final _vaultHousing = RRect.fromLTRBR(
  16,
  36,
  214,
  384,
  const Radius.circular(28),
);
final _vaultModule = RRect.fromLTRBR(
  34,
  92,
  196,
  328,
  const Radius.circular(20),
);
final _vaultScreen = RRect.fromLTRBR(
  44,
  102,
  186,
  318,
  const Radius.circular(13),
);
final _vaultBracket = RRect.fromLTRBR(
  196,
  178,
  296,
  242,
  const Radius.circular(12),
);

/// Everything solid: the housing and the disc's outer ring.
Path _vaultBodyPath() => Path.combine(
  PathOperation.union,
  Path()..addRRect(_vaultHousing),
  Path()..addOval(
    Rect.fromCircle(center: _vaultDiscCenter, radius: _vaultRingRadius + 4),
  ),
);

class _VaultBodyClipper extends CustomClipper<Path> {
  const _VaultBodyClipper();

  @override
  Path getClip(Size size) => _vaultBodyPath();

  @override
  bool shouldReclip(_VaultBodyClipper oldClipper) => false;
}

/// Matte molded plastic, lit faintly from the top.
Shader _vaultMatte(Rect bounds) => const LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [Color(0xFF353B3E), _vaultGraphite, Color(0xFF121618)],
).createShader(bounds);

void _vaultBevel(Canvas canvas, RRect shape) {
  canvas.save();
  canvas.clipRRect(shape);
  canvas.drawRRect(
    shape.shift(const Offset(0, 2)),
    Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = Colors.white.withValues(alpha: 0.16),
  );
  canvas.drawRRect(
    shape.shift(const Offset(0, -5)),
    Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 9
      ..color = Colors.black.withValues(alpha: 0.6)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
  );
  canvas.restore();
  canvas.drawRRect(
    shape,
    Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..color = Colors.black,
  );
}

void _vaultScrew(Canvas canvas, Offset at) {
  canvas.drawCircle(
    at,
    4,
    Paint()
      ..shader = const RadialGradient(
        center: Alignment(-0.4, -0.4),
        colors: [_vaultHighlight, _vaultSteel, _vaultBlack],
      ).createShader(Rect.fromCircle(center: at, radius: 4)),
  );
  canvas.drawLine(
    at.translate(-2.5, 1.5),
    at.translate(2.5, -1.5),
    Paint()
      ..strokeWidth = 1
      ..color = _vaultBlack,
  );
}

void _vaultMicroText(
  Canvas canvas,
  String text,
  Offset center, {
  double angle = 0,
  double size = 6.5,
}) {
  final painter = TextPainter(
    text: TextSpan(
      text: text,
      style: TextStyle(
        fontSize: size,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.6,
        color: Colors.white.withValues(alpha: 0.32),
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

/// Engraving follows the guard's outer land, clear of the cooling ribs.
void _vaultArcLabel(Canvas canvas, String label, double centerAngle) {
  const radius = _vaultGuardOuter - 4;
  const advance = 4.8;
  for (var i = 0; i < label.length; i++) {
    final angle = centerAngle + (i - (label.length - 1) / 2) * advance / radius;
    final painter = TextPainter(
      text: TextSpan(
        text: label[i],
        style: TextStyle(
          fontSize: 5.5,
          fontWeight: FontWeight.w700,
          color: _vaultHighlight.withValues(alpha: 0.55),
          shadows: const [Shadow(color: _vaultBlack, offset: Offset(0, -0.5))],
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    canvas.save();
    final position = _vaultDiscCenter + Offset.fromDirection(angle, radius);
    canvas.translate(position.dx, position.dy);
    canvas.rotate(angle + math.pi / 2);
    painter.paint(canvas, Offset(-painter.width / 2, -painter.height / 2));
    canvas.restore();
    painter.dispose();
  }
}

/// Behind the disc: the machine's shadow, the outer ring's side wall and
/// its face, and the dark well the disc turns in.
class _VaultBasePainter extends CustomPainter {
  const _VaultBasePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final ring = Path()
      ..addOval(
        Rect.fromCircle(center: _vaultDiscCenter, radius: _vaultRingRadius + 4),
      );
    canvas.drawShadow(
      _vaultBodyPath().shift(const Offset(0, 10)),
      Colors.black,
      12,
      false,
    );
    for (var d = 10.0; d >= 1; d--) {
      canvas.drawPath(
        ring.shift(Offset(0, d)),
        Paint()..color = Color.lerp(_vaultGraphite, Colors.black, d / 10)!,
      );
    }
    canvas.drawPath(ring, Paint()..shader = _vaultMatte(ring.getBounds()));
    // The well.
    canvas.drawCircle(
      _vaultDiscCenter,
      _vaultGuardInner + 2,
      Paint()
        ..shader =
            const RadialGradient(
              colors: [Color(0xFF050506), Color(0xFF0E0F11), Color(0xFF020203)],
              stops: [0, 0.85, 1],
            ).createShader(
              Rect.fromCircle(
                center: _vaultDiscCenter,
                radius: _vaultGuardInner,
              ),
            ),
    );
    // The outer ring's two lips.
    for (final (radius, color, width) in [
      (_vaultRingRadius + 3.0, Colors.black, 1.5),
      (_vaultRingRadius, _vaultEdge.withValues(alpha: 0.55), 1.0),
      (_vaultGuardInner + 2.0, Colors.black, 2.0),
    ]) {
      canvas.drawCircle(
        _vaultDiscCenter,
        radius,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = width
          ..color = color,
      );
    }
  }

  @override
  bool shouldRepaint(_VaultBasePainter oldDelegate) => false;
}

/// Over the disc: its grooves and the fixed sweep of light (painted on top
/// of the turning cover, so the shine stays put while the disc spins).
class _VaultDiscGlassPainter extends CustomPainter {
  const _VaultDiscGlassPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.shortestSide / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);
    canvas.save();
    canvas.clipPath(Path()..addOval(rect));
    // Darken toward the rim, like a pressed disc.
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..shader = RadialGradient(
          colors: [
            Colors.black.withValues(alpha: 0.05),
            Colors.black.withValues(alpha: 0.25),
            Colors.black.withValues(alpha: 0.6),
          ],
          stops: const [0, 0.7, 1],
        ).createShader(rect),
    );
    final groove = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.6;
    for (var r = radius * 0.3; r < radius; r += 3) {
      groove.color = Colors.black.withValues(
        alpha: 0.12 + 0.1 * math.sin(r * 0.7).abs(),
      );
      canvas.drawCircle(center, r, groove);
    }
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..shader = SweepGradient(
          colors: [
            Colors.white.withValues(alpha: 0),
            Colors.white.withValues(alpha: 0.26),
            Colors.white.withValues(alpha: 0),
            Colors.white.withValues(alpha: 0),
            Colors.white.withValues(alpha: 0.16),
            Colors.white.withValues(alpha: 0),
          ],
          stops: const [0.02, 0.1, 0.2, 0.52, 0.62, 0.72],
        ).createShader(rect),
    );
    canvas.restore();
    canvas.drawCircle(
      center,
      radius - 0.5,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..color = Colors.black.withValues(alpha: 0.8),
    );
  }

  @override
  bool shouldRepaint(_VaultDiscGlassPainter oldDelegate) => false;
}

/// Above the disc: the ribbed arc guards, the bracket to the hub, and the
/// housing with its fins, rails, screws and the screen module's bezel.
class _VaultFramePainter extends CustomPainter {
  const _VaultFramePainter();

  void _guard(Canvas canvas, double start, double sweep) {
    final outer = Rect.fromCircle(
      center: _vaultDiscCenter,
      radius: _vaultGuardOuter,
    );
    final inner = Rect.fromCircle(
      center: _vaultDiscCenter,
      radius: _vaultGuardInner,
    );
    Path band(double grow) => Path()
      ..arcTo(outer.inflate(grow), start, sweep, true)
      ..arcTo(inner.deflate(grow), start + sweep, -sweep, false)
      ..close();
    final shape = band(0);
    canvas.drawPath(
      shape.shift(const Offset(0, 7)),
      Paint()
        ..color = Colors.black.withValues(alpha: 0.7)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );
    for (var d = 7.0; d >= 1; d--) {
      canvas.drawPath(
        shape.shift(Offset(0, d)),
        Paint()..color = Color.lerp(_vaultSteel, Colors.black, d / 7)!,
      );
    }
    canvas.drawPath(shape, Paint()..shader = _vaultMatte(outer));
    _skinRelief(
      canvas,
      shape,
      shade: _vaultBlack.withValues(alpha: 0.8),
      light: _vaultHighlight.withValues(alpha: 0.32),
      width: 5,
    );
    canvas.save();
    canvas.clipPath(shape);
    _skinGrain(canvas, shape.getBounds(), seed: 29, strength: 0.065, pitch: 3);
    // Knurled ribs, radial across the band.
    final rib = Paint()..strokeWidth = 1.6;
    for (var a = start + 0.05; a < start + sweep - 0.05; a += 0.035) {
      final dir = Offset(math.cos(a), math.sin(a));
      final from = _vaultDiscCenter + dir * (_vaultGuardInner + 5);
      final to = _vaultDiscCenter + dir * (_vaultGuardOuter - 10);
      rib.color = Colors.black.withValues(alpha: 0.85);
      canvas.drawLine(from, to, rib);
      rib.color = _vaultEdge.withValues(alpha: 0.7);
      canvas.drawLine(
        from.translate(-0.8, -0.8),
        to.translate(-0.8, -0.8),
        rib,
      );
    }
    canvas.drawPath(
      shape.shift(const Offset(0, 2)),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = Colors.white.withValues(alpha: 0.2),
    );
    canvas.restore();
    canvas.drawPath(
      shape,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4
        ..color = Colors.black,
    );
  }

  @override
  void paint(Canvas canvas, Size size) {
    _guard(canvas, -1.55, 1.35);
    _guard(canvas, 0.2, 1.35);
    _vaultArcLabel(canvas, 'MORNYE DISC UNIT', -0.9);
    _vaultArcLabel(canvas, 'ROTATION SYSTEM', 0.9);

    // The bracket from the housing to the hub.
    canvas.drawRRect(
      _vaultBracket.shift(const Offset(0, 6)),
      Paint()
        ..color = Colors.black.withValues(alpha: 0.7)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );
    canvas.drawRRect(
      _vaultBracket,
      Paint()..shader = _vaultMatte(_vaultBracket.outerRect),
    );
    _vaultBevel(canvas, _vaultBracket);
    _vaultMicroText(
      canvas,
      'LOCK',
      const Offset(226, 210),
      angle: -math.pi / 2,
    );

    // The housing: side wall, face, bevel.
    final housing = Path()..addRRect(_vaultHousing);
    canvas.drawPath(
      housing.shift(const Offset(4, 10)),
      Paint()
        ..color = Colors.black.withValues(alpha: 0.75)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
    );
    for (var d = 10.0; d >= 1; d--) {
      canvas.drawRRect(
        _vaultHousing.shift(Offset(0, d)),
        Paint()..color = Color.lerp(_vaultSteel, Colors.black, d / 10)!,
      );
    }
    canvas.drawRRect(
      _vaultHousing,
      Paint()..shader = _vaultMatte(_vaultHousing.outerRect),
    );
    canvas.save();
    canvas.clipRRect(_vaultHousing);
    _skinGrain(
      canvas,
      _vaultHousing.outerRect,
      seed: 89,
      strength: 0.085,
      pitch: 2.8,
    );
    canvas.restore();
    _vaultBevel(canvas, _vaultHousing);
    _skinRelief(
      canvas,
      housing,
      shade: _vaultBlack.withValues(alpha: 0.8),
      light: _vaultHighlight.withValues(alpha: 0.3),
      width: 7,
    );

    // Vertical fins above and below the module.
    for (final (top, bottom) in [(46.0, 86.0), (334.0, 374.0)]) {
      final bay = RRect.fromLTRBR(
        62,
        top,
        168,
        bottom,
        const Radius.circular(6),
      );
      canvas.drawRRect(bay, Paint()..color = Colors.black);
      for (var x = 66.0; x < 166; x += 6) {
        final fin = RRect.fromLTRBR(
          x,
          top + 3,
          x + 3.4,
          bottom - 3,
          const Radius.circular(1.5),
        );
        canvas.drawRRect(
          fin,
          Paint()
            ..shader = const LinearGradient(
              colors: [_vaultEdge, _vaultSteel, _vaultBlack],
            ).createShader(fin.outerRect),
        );
      }
    }
    // Side rails with their slots.
    for (final x in [22.0, 200.0]) {
      final rail = RRect.fromLTRBR(x, 70, x + 8, 350, const Radius.circular(4));
      canvas.drawRRect(rail, Paint()..color = Colors.black);
      canvas.drawRRect(
        rail.shift(const Offset(0, 1)),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.8
          ..color = _vaultEdge.withValues(alpha: 0.35),
      );
      for (final y in [120.0, 210.0, 300.0]) {
        canvas.drawRRect(
          RRect.fromLTRBR(x + 2, y, x + 6, y + 22, const Radius.circular(2)),
          Paint()..color = _vaultSteel,
        );
      }
    }
    for (final at in const [
      Offset(36, 54),
      Offset(194, 54),
      Offset(36, 366),
      Offset(194, 366),
      Offset(206, 190),
      Offset(206, 230),
    ]) {
      _vaultScrew(canvas, at);
    }
    _vaultMicroText(
      canvas,
      'MORNYE',
      const Offset(28, 210),
      angle: -math.pi / 2,
      size: 7,
    );

    // The module: a raised slab with a bezel around the glass.
    canvas.drawRRect(
      _vaultModule.shift(const Offset(0, 4)),
      Paint()
        ..color = Colors.black.withValues(alpha: 0.8)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );
    canvas.drawRRect(
      _vaultModule,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF34373D), Color(0xFF16171A), Color(0xFF0C0D0F)],
        ).createShader(_vaultModule.outerRect),
    );
    _vaultBevel(canvas, _vaultModule);
    canvas.drawRRect(_vaultScreen.inflate(2), Paint()..color = Colors.black);
  }

  @override
  bool shouldRepaint(_VaultFramePainter oldDelegate) => false;
}

/// The screen's glass: a cool dark gradient, and a reflection over it.
class _VaultScreenPainter extends CustomPainter {
  const _VaultScreenPainter({required this.glare});

  /// The reflection, painted over the content.
  final bool glare;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    if (!glare) {
      canvas.drawRect(
        rect,
        Paint()
          ..shader = const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF14171C), Color(0xFF07080A)],
          ).createShader(rect),
      );
      return;
    }
    final sheen = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width * 0.75, 0)
      ..lineTo(0, size.height * 0.45)
      ..close();
    canvas.drawPath(
      sheen,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: 0.1),
            Colors.white.withValues(alpha: 0),
          ],
        ).createShader(rect),
    );
  }

  @override
  bool shouldRepaint(_VaultScreenPainter oldDelegate) =>
      oldDelegate.glare != glare;
}

/// The hub knob: a raised knurled cap with a slot across it. Clicking it
/// plays or pauses.
class _VaultKnob extends StatefulWidget {
  const _VaultKnob({super.key, required this.tooltip, required this.onPressed});

  final String tooltip;
  final VoidCallback? onPressed;

  @override
  State<_VaultKnob> createState() => _VaultKnobState();
}

class _VaultKnobState extends State<_VaultKnob> {
  bool _hover = false;
  bool _down = false;

  @override
  Widget build(BuildContext context) => Tooltip(
    message: widget.tooltip,
    waitDuration: const Duration(milliseconds: 600),
    child: MouseRegion(
      cursor: widget.onPressed == null
          ? MouseCursor.defer
          : SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = _down = false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => setState(() => _down = true),
        onTapUp: (_) => setState(() => _down = false),
        onTapCancel: () => setState(() => _down = false),
        onTap: widget.onPressed,
        child: CustomPaint(
          size: const Size.square(64),
          painter: _VaultKnobPainter(hover: _hover, down: _down),
        ),
      ),
    ),
  );
}

class _VaultKnobPainter extends CustomPainter {
  const _VaultKnobPainter({required this.hover, required this.down});

  final bool hover;
  final bool down;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = size.shortestSide / 2;
    canvas.drawCircle(
      c.translate(0, down ? 2 : 5),
      r,
      Paint()
        ..color = Colors.black.withValues(alpha: 0.8)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
    );
    // The knurled skirt.
    canvas.drawCircle(c, r, Paint()..color = _vaultBlack);
    final tick = Paint()..strokeWidth = 1.4;
    for (var a = 0.0; a < math.pi * 2; a += math.pi / 30) {
      final dir = Offset(math.cos(a), math.sin(a));
      tick.color = (math.sin(a - 2.3) > 0 ? _vaultEdge : _vaultSteel)
          .withValues(alpha: 0.9);
      canvas.drawLine(c + dir * (r - 7), c + dir * (r - 1), tick);
    }
    // The cap.
    final cap = r - 9;
    final lit = hover && !down ? 0.12 : 0.0;
    canvas.drawCircle(
      c,
      cap,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.35, -0.45),
          colors: [
            Color.lerp(const Color(0xFF5A5F67), Colors.white, lit)!,
            Color.lerp(_vaultGraphite, Colors.white, lit)!,
            _vaultBlack,
          ],
          stops: const [0, 0.55, 1],
        ).createShader(Rect.fromCircle(center: c, radius: cap)),
    );
    canvas.drawCircle(
      c,
      cap,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2
        ..color = Colors.black,
    );
    canvas.drawCircle(
      c,
      cap - 1.5,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.8
        ..color = Colors.white.withValues(alpha: 0.18),
    );
    // The slot.
    final slot = Offset.fromDirection(-0.8, cap * 0.62);
    canvas.drawLine(
      c - slot,
      c + slot,
      Paint()
        ..strokeCap = StrokeCap.round
        ..strokeWidth = 7
        ..color = Colors.black,
    );
    canvas.drawLine(
      (c - slot).translate(0, 1.5),
      (c + slot).translate(0, 1.5),
      Paint()
        ..strokeCap = StrokeCap.round
        ..strokeWidth = 1
        ..color = Colors.white.withValues(alpha: 0.25),
    );
  }

  @override
  bool shouldRepaint(_VaultKnobPainter oldDelegate) =>
      oldDelegate.hover != hover || oldDelegate.down != down;
}

/// A flat icon on the touchscreen, brighter under the pointer.
class _VaultScreenButton extends StatefulWidget {
  const _VaultScreenButton({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;

  @override
  State<_VaultScreenButton> createState() => _VaultScreenButtonState();
}

class _VaultScreenButtonState extends State<_VaultScreenButton> {
  bool _hover = false;
  bool _down = false;

  @override
  Widget build(BuildContext context) => Tooltip(
    message: widget.tooltip,
    waitDuration: const Duration(milliseconds: 600),
    child: MouseRegion(
      cursor: widget.onPressed == null
          ? MouseCursor.defer
          : SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = _down = false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: widget.onPressed == null
            ? null
            : (_) => setState(() => _down = true),
        onTapUp: widget.onPressed == null
            ? null
            : (_) => setState(() => _down = false),
        onTapCancel: () => setState(() => _down = false),
        onTap: widget.onPressed,
        child: Padding(
          padding: const EdgeInsets.all(3),
          child: Icon(
            widget.icon,
            size: 14,
            color: widget.onPressed == null
                ? _vaultInk.withValues(alpha: 0.3)
                : _down
                ? _vaultInk.withValues(alpha: 0.5)
                : _hover
                ? Colors.white
                : _vaultInk.withValues(alpha: 0.75),
          ),
        ),
      ),
    ),
  );
}

/// Elapsed and total time over a thin seek bar, on the touchscreen.
class _VaultSeek extends ConsumerWidget {
  const _VaultSeek({required this.mediaItem});

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
    final elapsed = position.inSeconds.clamp(0, duration.inSeconds);
    final style = TextStyle(
      fontSize: 9,
      color: _vaultInk.withValues(alpha: 0.6),
      fontFeatures: const [FontFeature.tabularFigures()],
    );
    return Column(
      children: [
        Row(
          children: [
            Text(formatClock(elapsed), style: style),
            const Spacer(),
            Text('-${formatClock(duration.inSeconds - elapsed)}', style: style),
          ],
        ),
        SizedBox(
          height: 16,
          child: SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 2,
              activeTrackColor: _vaultInk,
              inactiveTrackColor: Colors.white.withValues(alpha: 0.14),
              thumbColor: Colors.white,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 4),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 8),
              overlayColor: Colors.white.withValues(alpha: 0.12),
            ),
            child: PlaybackSeekSlider(
              key: ValueKey(item?.id),
              position: position,
              duration: duration,
              playing: playing,
              hairline: true,
              onSeek: ref.read(musicPlayerControllerProvider).seek,
            ),
          ),
        ),
      ],
    );
  }
}

extension _VaultLayout on _RetroMiniPlayerState {
  Widget _vaultLayout(
    BuildContext context, {
    required MediaItem? mediaItem,
    required bool playing,
    required bool loading,
  }) {
    final l10n = context.l10n;
    final controller = ref.read(musicPlayerControllerProvider);
    final enabled = mediaItem != null;
    final playPause = enabled && !loading
        ? () => controller.togglePlayPause(playing)
        : null;
    final screen = _vaultScreen.outerRect;
    const discSize = _vaultDiscRadius * 2;

    return Material(
      type: MaterialType.transparency,
      child: DesktopVolumeScroll(
        child: OverflowBox(
          alignment: Alignment.topLeft,
          minWidth: _vaultSkinSize.width,
          maxWidth: _vaultSkinSize.width,
          minHeight: _vaultSkinSize.height,
          maxHeight: _vaultSkinSize.height,
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                const Positioned.fill(
                  child: RepaintBoundary(
                    child: CustomPaint(painter: _VaultBasePainter()),
                  ),
                ),
                const Positioned.fill(
                  child: ClipPath(
                    clipper: _VaultBodyClipper(),
                    child: DesktopWindowDragArea(frameless: true),
                  ),
                ),
                // The disc: the album cover, turning while it plays.
                Positioned(
                  left: _vaultDiscCenter.dx - _vaultDiscRadius,
                  top: _vaultDiscCenter.dy - _vaultDiscRadius,
                  width: discSize,
                  height: discSize,
                  child: IgnorePointer(
                    child: RepaintBoundary(
                      child: Stack(
                        children: [
                          ListenableBuilder(
                            listenable: _pulse,
                            child: RepaintBoundary(
                              child: ClipOval(
                                child: _Artwork(
                                  mediaItem: mediaItem,
                                  size: discSize,
                                  radius: _vaultDiscRadius,
                                ),
                              ),
                            ),
                            builder: (context, disc) => Transform.rotate(
                              angle: _pulse.time * 1.6,
                              child: disc,
                            ),
                          ),
                          const Positioned.fill(
                            child: RepaintBoundary(
                              child: CustomPaint(
                                painter: _VaultDiscGlassPainter(),
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
                      child: CustomPaint(painter: _VaultFramePainter()),
                    ),
                  ),
                ),
                // The hub knob.
                Positioned(
                  left: _vaultDiscCenter.dx - 32,
                  top: _vaultDiscCenter.dy - 32,
                  child: _VaultKnob(
                    key: const ValueKey('vault-knob'),
                    tooltip: playing ? l10n.actionPause : l10n.tooltipPlay,
                    onPressed: playPause,
                  ),
                ),
                // The touchscreen.
                Positioned.fromRect(
                  rect: screen,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(13),
                    child: Stack(
                      children: [
                        const Positioned.fill(
                          child: CustomPaint(
                            painter: _VaultScreenPainter(glare: false),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(9, 7, 9, 6),
                          child: DefaultTextStyle(
                            style: const TextStyle(
                              fontSize: 10,
                              height: 1.25,
                              color: _vaultInk,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Row(
                                  children: [
                                    _RetroClock(
                                      style: TextStyle(
                                        fontSize: 10,
                                        height: 1,
                                        fontWeight: FontWeight.w700,
                                        color: _vaultInk.withValues(
                                          alpha: 0.85,
                                        ),
                                        fontFeatures: const [
                                          FontFeature.tabularFigures(),
                                        ],
                                      ),
                                    ),
                                    const Spacer(),
                                    Icon(
                                      playing
                                          ? Icons.graphic_eq
                                          : Icons.pause_circle_outline,
                                      size: 11,
                                      color: _vaultInk.withValues(alpha: 0.7),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 7),
                                Row(
                                  children: [
                                    _Artwork(
                                      mediaItem: mediaItem,
                                      size: 42,
                                      radius: 5,
                                    ),
                                    const SizedBox(width: 7),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            mediaItem?.title ??
                                                l10n.desktopPlayerIdle,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w700,
                                              color: Colors.white,
                                            ),
                                          ),
                                          Text(
                                            mediaItem?.artist ?? '',
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontSize: 9.5,
                                              color: _vaultInk.withValues(
                                                alpha: 0.6,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                SizedBox(
                                  height: 26,
                                  child: IgnorePointer(
                                    child: RepaintBoundary(
                                      child:
                                          ValueListenableBuilder<_RetroScope>(
                                            valueListenable: _retroScope,
                                            builder: (context, style, _) =>
                                                CustomPaint(
                                                  painter: _RetroScopePainter(
                                                    _pulse,
                                                    style,
                                                    core: _vaultInk,
                                                    glowColor: _vaultEdge,
                                                  ),
                                                ),
                                          ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                _VaultSeek(mediaItem: mediaItem),
                                const SizedBox(height: 4),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    _RetroPill(
                                      key: const ValueKey('vault-previous'),
                                      icon: Icons.skip_previous,
                                      tooltip: l10n.nowPlayingPreviousTrack,
                                      kind: _RetroPillKind.chrome,
                                      size: const Size(32, 22),
                                      iconSize: 14,
                                      onPressed: enabled
                                          ? controller.previous
                                          : null,
                                    ),
                                    _RetroPill(
                                      key: const ValueKey('vault-play-pause'),
                                      icon: playing
                                          ? Icons.pause
                                          : Icons.play_arrow,
                                      tooltip: playing
                                          ? l10n.actionPause
                                          : l10n.tooltipPlay,
                                      kind: _RetroPillKind.chrome,
                                      size: const Size(36, 24),
                                      iconSize: 16,
                                      onPressed: playPause,
                                    ),
                                    _RetroPill(
                                      key: const ValueKey('vault-next'),
                                      icon: Icons.skip_next,
                                      tooltip: l10n.nowPlayingNextTrack,
                                      kind: _RetroPillKind.chrome,
                                      size: const Size(32, 22),
                                      iconSize: 14,
                                      onPressed: enabled
                                          ? controller.next
                                          : null,
                                    ),
                                  ],
                                ),
                                const Spacer(),
                                Container(
                                  padding: const EdgeInsets.only(top: 3),
                                  decoration: BoxDecoration(
                                    border: Border(
                                      top: BorderSide(
                                        color: Colors.white.withValues(
                                          alpha: 0.1,
                                        ),
                                      ),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      _VaultScreenButton(
                                        key: const ValueKey('vault-visualizer'),
                                        icon: Icons.equalizer,
                                        tooltip:
                                            l10n.desktopMiniPlayerVisualizer,
                                        onPressed: () => _retroScope.value =
                                            _RetroScope.values[(_retroScope
                                                        .value
                                                        .index +
                                                    1) %
                                                _RetroScope.values.length],
                                      ),
                                      _VaultScreenButton(
                                        key: const ValueKey('vault-next-skin'),
                                        icon: Icons.palette_outlined,
                                        tooltip: l10n.desktopMiniPlayerNextSkin,
                                        onPressed: () => unawaited(
                                          setDesktopMiniPlayerSkin(
                                            _nextSkin(widget.skin),
                                          ),
                                        ),
                                      ),
                                      _VaultScreenButton(
                                        key: const ValueKey('vault-minimize'),
                                        icon: Icons.remove,
                                        tooltip: l10n.desktopMiniPlayerMinimize,
                                        onPressed: () =>
                                            unawaited(minimizeDesktopWindow()),
                                      ),
                                      _VaultScreenButton(
                                        key: const ValueKey(
                                          'vault-full-window',
                                        ),
                                        icon: Icons.open_in_full,
                                        tooltip: l10n.desktopMiniPlayerExpand,
                                        onPressed: () => unawaited(
                                          setDesktopMiniPlayer(open: false),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const Positioned.fill(
                          child: IgnorePointer(
                            child: CustomPaint(
                              painter: _VaultScreenPainter(glare: true),
                            ),
                          ),
                        ),
                      ],
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
