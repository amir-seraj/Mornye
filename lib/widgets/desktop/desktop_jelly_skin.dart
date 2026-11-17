part of 'desktop_player_bar.dart';

// The jelly skin: a wet, glossy blob of lime plastic. A black screen and a
// seek track sink into it on the left above a row of bubble buttons, and a
// lime-slice speaker sits in a raised pod on the right.

const _jellyHighlight = Color(0xFFF2FF7A);
const _jellyLight = Color(0xFFC6F72A);
const _jellyMid = Color(0xFF8BDB12);
const _jellyDeep = Color(0xFF4C9A06);
const _jellyDark = Color(0xFF1F4A02);
const _jellyInk = Color(0xFFD9FF6A);

/// The blob: melted, uneven edges, swelling on the right around the pod.
Path _jellyBlobPath() => Path()
  ..moveTo(40, 72)
  ..cubicTo(78, 50, 200, 62, 296, 54)
  ..cubicTo(340, 50, 362, 36, 404, 44)
  ..cubicTo(452, 52, 464, 92, 460, 132)
  ..cubicTo(457, 182, 440, 214, 392, 212)
  ..cubicTo(336, 210, 252, 222, 152, 218)
  ..cubicTo(82, 216, 42, 214, 32, 182)
  ..cubicTo(22, 142, 20, 92, 40, 72)
  ..close();

const _jellyScreen = Rect.fromLTRB(54, 76, 300, 152);
const _jellySeek = Rect.fromLTRB(58, 162, 298, 178);
const _jellyPodCenter = Offset(392, 128);
const double _jellyPodRadius = 58;

class _JellyBlobClipper extends CustomClipper<Path> {
  const _JellyBlobClipper();

  @override
  Path getClip(Size size) => _jellyBlobPath();

  @override
  bool shouldReclip(_JellyBlobClipper oldClipper) => false;
}

/// A sunken well in the jelly: the plastic bulges into a bright lip around
/// it, and the inside falls into shadow.
void _jellyRecess(Canvas canvas, RRect well) {
  canvas.drawRRect(
    well.inflate(5),
    Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [_jellyDeep, _jellyMid, _jellyHighlight],
      ).createShader(well.inflate(5).outerRect),
  );
  canvas.drawRRect(
    well.inflate(5),
    Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [_jellyDark, _jellyDeep, _jellyHighlight],
        stops: [0, 0.35, 1],
      ).createShader(well.inflate(5).outerRect),
  );
  canvas.drawRRect(well, Paint()..color = _jellyDark);
  canvas.save();
  canvas.clipRRect(well);
  canvas.drawRRect(
    well.shift(const Offset(1, 3)),
    Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..color = _jellyDark.withValues(alpha: 0.9),
  );
  canvas.restore();
}

/// Paints the jelly: shadow, thick wet underside, the body with its depth
/// and rim light, specular streaks, and the wells the controls sit in.
class _JellyBlobPainter extends CustomPainter {
  const _JellyBlobPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final blob = _jellyBlobPath();
    final bounds = blob.getBounds();

    canvas.drawShadow(blob.shift(const Offset(0, 14)), Colors.black, 12, false);
    // The thick underside, glowing where light passes through it.
    const depth = 12.0;
    for (var d = depth; d >= 1; d--) {
      canvas.drawPath(
        blob.shift(Offset(0, d)),
        Paint()..color = Color.lerp(_jellyMid, _jellyDark, d / depth)!,
      );
    }
    canvas.drawPath(
      blob.shift(const Offset(0, depth)),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = _jellyHighlight.withValues(alpha: 0.35)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2),
    );

    // The body.
    canvas.drawPath(
      blob,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [_jellyHighlight, _jellyLight, _jellyMid, _jellyDeep],
          stops: [0, 0.25, 0.6, 1],
        ).createShader(bounds),
    );
    canvas.save();
    canvas.clipPath(blob);
    // Light travels through the thick neck between the glass and speaker.
    canvas.drawRect(
      bounds,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(0.2, 0.2),
          radius: 0.85,
          colors: [
            _jellyDark.withValues(alpha: 0.6),
            _jellyDeep.withValues(alpha: 0),
          ],
        ).createShader(const Rect.fromLTRB(266, 55, 364, 213)),
    );
    // Depth: dark green pooling inside the edge, like thick translucent gel.
    canvas.drawPath(
      blob,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 26
        ..color = _jellyDark.withValues(alpha: 0.45)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12),
    );
    // Broad curvature reflection across the lower lobe, under the sharp rim.
    final belly = const Rect.fromLTRB(35, 174, 330, 218);
    canvas.drawRect(
      bounds,
      Paint()
        ..shader = RadialGradient(
          radius: 0.8,
          colors: [
            _jellyHighlight.withValues(alpha: 0.35),
            _jellyLight.withValues(alpha: 0),
          ],
        ).createShader(belly),
    );
    // Rim light along the bottom, where light refracts through the gel.
    canvas.drawPath(
      blob.shift(const Offset(0, -4)),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5
        ..color = _jellyHighlight.withValues(alpha: 0.75)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
    );
    // The wet top: a broad soft sheen and a sharp white streak.
    canvas.drawPath(
      blob.shift(const Offset(0, 5)),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 8
        ..color = Colors.white.withValues(alpha: 0.4)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );
    final streak = Path()
      ..moveTo(70, 66)
      ..cubicTo(140, 58, 230, 66, 296, 60)
      ..cubicTo(330, 57, 352, 48, 396, 50);
    canvas.drawPath(
      streak,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = 3.5
        ..color = Colors.white.withValues(alpha: 0.9),
    );
    canvas.drawPath(
      streak,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = 9
        ..color = Colors.white.withValues(alpha: 0.25)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );
    // A broad softbox reflection breaks into a tight streak as the gel curves.
    canvas.drawOval(
      const Rect.fromLTRB(35, 72, 59, 163),
      Paint()
        ..shader = RadialGradient(
          colors: [
            const Color(0xFFF6FFD8).withValues(alpha: 0.5),
            _jellyHighlight.withValues(alpha: 0),
          ],
        ).createShader(const Rect.fromLTRB(35, 72, 59, 163)),
    );
    canvas.drawOval(
      const Rect.fromLTWH(40, 86, 4, 19),
      Paint()..color = const Color(0xFFF5FFD9).withValues(alpha: 0.9),
    );
    canvas.drawOval(
      const Rect.fromLTWH(444, 100, 3, 14),
      Paint()..color = _jellyHighlight.withValues(alpha: 0.35),
    );
    // The lower edge refracts the same light in yellow-green, never white.
    final caustic = Path()
      ..moveTo(53, 200)
      ..cubicTo(126, 223, 236, 207, 305, 211);
    canvas.drawPath(
      caustic,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round
        ..shader = LinearGradient(
          colors: [
            _jellyHighlight.withValues(alpha: 0),
            _jellyHighlight.withValues(alpha: 0.7),
            _jellyHighlight.withValues(alpha: 0),
          ],
        ).createShader(const Rect.fromLTRB(53, 200, 305, 218)),
    );
    canvas.restore();
    canvas.drawPath(
      blob,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4
        ..color = _jellyDark.withValues(alpha: 0.8),
    );

    // The wells.
    _jellyRecess(
      canvas,
      RRect.fromRectAndRadius(_jellyScreen, const Radius.circular(14)),
    );
    _jellyRecess(
      canvas,
      RRect.fromRectAndRadius(_jellySeek, const Radius.circular(8)),
    );

    // The speaker pod: a raised dome of jelly with a well for the slice.
    final pod = Rect.fromCircle(
      center: _jellyPodCenter,
      radius: _jellyPodRadius,
    );
    canvas.drawCircle(
      _jellyPodCenter.translate(0, 6),
      _jellyPodRadius,
      Paint()
        ..color = _jellyDark.withValues(alpha: 0.5)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );
    canvas.drawCircle(
      _jellyPodCenter,
      _jellyPodRadius,
      Paint()
        ..shader = const RadialGradient(
          center: Alignment(-0.3, -0.5),
          colors: [_jellyHighlight, _jellyLight, _jellyMid, _jellyDeep],
          stops: [0, 0.35, 0.75, 1],
        ).createShader(pod),
    );
    canvas.drawArc(
      pod.deflate(4),
      math.pi * 1.1,
      math.pi * 0.8,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = 3
        ..color = Colors.white.withValues(alpha: 0.85),
    );
    canvas.drawCircle(
      _jellyPodCenter,
      _jellyPodRadius - 9,
      Paint()..color = _jellyDark,
    );
  }

  @override
  bool shouldRepaint(_JellyBlobPainter oldDelegate) => false;
}

/// The lime slice in the pod: rind, pith and juicy segments, swelling on
/// the beat.
class _JellySlicePainter extends CustomPainter {
  _JellySlicePainter(this.pulse) : super(repaint: pulse);

  final _RetroPulse pulse;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final r = size.shortestSide / 2 * (0.96 + pulse.energy * 0.05);
    // Rind and pith.
    canvas.drawCircle(
      center,
      r,
      Paint()
        ..shader = const RadialGradient(
          colors: [_jellyLight, _jellyMid, _jellyDeep],
          stops: [0.8, 0.92, 1],
        ).createShader(Rect.fromCircle(center: center, radius: r)),
    );
    canvas.drawCircle(
      center,
      r * 0.88,
      Paint()..color = const Color(0xFFEFFFC0),
    );
    canvas.drawCircle(center, r * 0.82, Paint()..color = _jellyDark);
    // Segments.
    const count = 8;
    final segment = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFFE6FF8A),
          _jellyLight,
          _jellyMid.withValues(alpha: 0.9),
        ],
        stops: const [0, 0.5, 1],
      ).createShader(Rect.fromCircle(center: center, radius: r * 0.8));
    final outline = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = _jellyDark;
    for (var i = 0; i < count; i++) {
      final start = i * math.pi * 2 / count + 0.07;
      final sweep = math.pi * 2 / count - 0.14;
      final outer = Rect.fromCircle(center: center, radius: r * 0.78);
      final inner = Rect.fromCircle(center: center, radius: r * 0.14);
      final wedge = Path()
        ..arcTo(outer, start, sweep, true)
        ..arcTo(inner, start + sweep, -sweep, false)
        ..close();
      canvas.drawPath(wedge, segment);
      canvas.drawPath(wedge, outline);
      // A juice glint in each segment.
      final mid = start + sweep / 2;
      canvas.drawCircle(
        center + Offset(math.cos(mid), math.sin(mid)) * r * 0.52,
        r * 0.05,
        Paint()..color = Colors.white.withValues(alpha: 0.55),
      );
    }
    canvas.drawCircle(
      center,
      r * 0.08,
      Paint()..color = const Color(0xFFEFFFC0),
    );
    // Wet gloss over the whole slice.
    canvas.drawOval(
      Rect.fromLTRB(
        center.dx - r * 0.7,
        center.dy - r * 0.92,
        center.dx + r * 0.5,
        center.dy - r * 0.2,
      ),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.white.withValues(alpha: 0.5),
            Colors.white.withValues(alpha: 0),
          ],
        ).createShader(Rect.fromCircle(center: center, radius: r)),
    );
  }

  @override
  bool shouldRepaint(_JellySlicePainter oldDelegate) =>
      oldDelegate.pulse != pulse;
}

/// A convex jelly bubble in a dark socket, its glyph in black.
class _JellyBubble extends StatefulWidget {
  const _JellyBubble({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.diameter = 28,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;
  final double diameter;

  @override
  State<_JellyBubble> createState() => _JellyBubbleState();
}

class _JellyBubbleState extends State<_JellyBubble> {
  bool _hover = false;
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onPressed != null;
    final size = Size.square(widget.diameter);
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
              size: size,
              painter: _JellyBubblePainter(
                hover: _hover && enabled,
                down: _down,
              ),
              child: SizedBox.fromSize(
                size: size,
                child: Center(
                  child: Transform.translate(
                    offset: Offset(0, _down ? 1 : 0),
                    child: Icon(
                      widget.icon,
                      size: widget.diameter * 0.5,
                      color: const Color(0xFF0E2401),
                      shadows: [
                        Shadow(
                          color: Colors.white.withValues(alpha: 0.5),
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
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

class _JellyBubblePainter extends CustomPainter {
  const _JellyBubblePainter({required this.hover, required this.down});

  final bool hover;
  final bool down;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final r = size.shortestSide / 2;
    // The socket.
    canvas.drawCircle(center, r, Paint()..color = _jellyDark);
    canvas.drawCircle(
      center.translate(0, 1),
      r,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = _jellyHighlight.withValues(alpha: 0.6),
    );
    // The bubble.
    final br = r * (down ? 0.76 : 0.84);
    final bubble = Rect.fromCircle(center: center, radius: br);
    var colors = const [_jellyHighlight, _jellyLight, _jellyDeep];
    if (down) colors = const [_jellyMid, _jellyDeep, _jellyDark];
    if (hover && !down) {
      colors = [for (final c in colors) Color.lerp(c, Colors.white, 0.2)!];
    }
    canvas.drawCircle(
      center,
      br,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.3, -0.45),
          colors: colors,
          stops: const [0, 0.55, 1],
        ).createShader(bubble),
    );
    // A bright refraction at the bottom and a white gloss cap at the top.
    canvas.drawArc(
      bubble.deflate(1.5),
      math.pi * 0.2,
      math.pi * 0.6,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6
        ..color = _jellyHighlight.withValues(alpha: 0.9),
    );
    if (!down) {
      canvas.drawOval(
        Rect.fromLTRB(
          center.dx - br * 0.55,
          center.dy - br * 0.85,
          center.dx + br * 0.4,
          center.dy - br * 0.3,
        ),
        Paint()..color = Colors.white.withValues(alpha: 0.75),
      );
    }
    canvas.drawCircle(
      center,
      br,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = _jellyDark,
    );
  }

  @override
  bool shouldRepaint(_JellyBubblePainter oldDelegate) =>
      oldDelegate.hover != hover || oldDelegate.down != down;
}

/// The black glass screen: deep gloss, a green glow seeping in at the rim.
class _JellyScreenPainter extends CustomPainter {
  const _JellyScreenPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final glass = RRect.fromRectAndRadius(rect, const Radius.circular(12));
    canvas.drawRRect(
      glass,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF0D1508), Color(0xFF030802)],
        ).createShader(rect),
    );
    canvas.save();
    canvas.clipRRect(glass);
    canvas.drawRRect(
      glass,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 8
        ..color = _jellyMid.withValues(alpha: 0.35)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(_JellyScreenPainter oldDelegate) => false;
}

/// The glass's reflection, over the screen's contents.
class _JellyGlarePainter extends CustomPainter {
  const _JellyGlarePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final glare = Path()
      ..moveTo(10, 4)
      ..lineTo(size.width - 10, 4)
      ..quadraticBezierTo(size.width * 0.5, size.height * 0.42, 10, 4)
      ..close();
    canvas.drawPath(
      glare,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.white.withValues(alpha: 0.2),
            Colors.white.withValues(alpha: 0.02),
          ],
        ).createShader(Offset.zero & size),
    );
  }

  @override
  bool shouldRepaint(_JellyGlarePainter oldDelegate) => false;
}

extension _JellyLayout on _RetroMiniPlayerState {
  Widget _jellyLayout(
    BuildContext context, {
    required MediaItem? mediaItem,
    required bool playing,
    required bool loading,
  }) {
    final l10n = context.l10n;
    final controller = ref.read(musicPlayerControllerProvider);
    final enabled = mediaItem != null;
    const glow = [Shadow(color: _jellyMid, blurRadius: 2.5)];

    final bubbles = [
      (
        'jelly-previous',
        Icons.fast_rewind,
        l10n.nowPlayingPreviousTrack,
        enabled ? controller.previous : null,
      ),
      (
        'jelly-play-pause',
        playing ? Icons.pause : Icons.play_arrow,
        playing ? l10n.actionPause : l10n.tooltipPlay,
        enabled && !loading ? () => controller.togglePlayPause(playing) : null,
      ),
      (
        'jelly-stop',
        Icons.stop,
        l10n.desktopMiniPlayerStop,
        enabled
            ? () async {
                if (playing) await controller.togglePlayPause(true);
                await controller.seek(Duration.zero);
              }
            : null,
      ),
      (
        'jelly-next',
        Icons.fast_forward,
        l10n.nowPlayingNextTrack,
        enabled ? controller.next : null,
      ),
      (
        'jelly-full-window',
        Icons.eject,
        l10n.desktopMiniPlayerExpand,
        () => unawaited(setDesktopMiniPlayer(open: false)),
      ),
    ];
    final small = [
      (
        'jelly-minimize',
        Icons.remove,
        l10n.desktopMiniPlayerMinimize,
        () => unawaited(minimizeDesktopWindow()),
      ),
      (
        'jelly-visualizer',
        Icons.equalizer,
        l10n.desktopMiniPlayerVisualizer,
        () => _retroScope.value = _RetroScope
            .values[(_retroScope.value.index + 1) % _RetroScope.values.length],
      ),
      (
        'jelly-next-skin',
        Icons.palette,
        l10n.desktopMiniPlayerNextSkin,
        () => unawaited(setDesktopMiniPlayerSkin(_nextSkin(widget.skin))),
      ),
    ];

    return Material(
      type: MaterialType.transparency,
      child: DesktopVolumeScroll(
        child: OverflowBox(
          alignment: Alignment.topLeft,
          minWidth: _jellySkinSize.width,
          maxWidth: _jellySkinSize.width,
          minHeight: _jellySkinSize.height,
          maxHeight: _jellySkinSize.height,
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                const Positioned.fill(
                  child: RepaintBoundary(
                    child: CustomPaint(painter: _JellyBlobPainter()),
                  ),
                ),
                const Positioned.fill(
                  child: ClipPath(
                    clipper: _JellyBlobClipper(),
                    child: DesktopWindowDragArea(frameless: true),
                  ),
                ),
                // The screen.
                Positioned.fromRect(
                  rect: _jellyScreen,
                  child: IgnorePointer(
                    child: Stack(
                      children: [
                        const Positioned.fill(
                          child: CustomPaint(painter: _JellyScreenPainter()),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(12, 7, 12, 6),
                          child: DefaultTextStyle(
                            style: const TextStyle(
                              fontSize: 10,
                              height: 1.2,
                              color: _jellyInk,
                              shadows: glow,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        mediaItem?.title ??
                                            l10n.desktopPlayerIdle,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w800,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    const _RetroClock(
                                      style: TextStyle(
                                        fontSize: 13,
                                        height: 1,
                                        fontWeight: FontWeight.w800,
                                        color: _jellyInk,
                                        shadows: glow,
                                        fontFeatures: [
                                          FontFeature.tabularFigures(),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        mediaItem?.artist ?? '',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    _JellyTime(mediaItem: mediaItem),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Expanded(
                                  child: RepaintBoundary(
                                    child: ValueListenableBuilder<_RetroScope>(
                                      valueListenable: _retroScope,
                                      builder: (context, style, _) =>
                                          CustomPaint(
                                            painter: _RetroScopePainter(
                                              _pulse,
                                              style,
                                              core: const Color(0xFFEFFFA0),
                                              glowColor: _jellyMid,
                                            ),
                                          ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const Positioned.fill(
                          child: CustomPaint(painter: _JellyGlarePainter()),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned.fromRect(
                  rect: _jellySeek,
                  child: _JellySeek(mediaItem: mediaItem),
                ),
                // Bubble buttons.
                Positioned(
                  left: 60,
                  top: 183,
                  child: Row(
                    children: [
                      for (final (key, icon, tooltip, onPressed) in bubbles)
                        Padding(
                          padding: const EdgeInsets.only(right: 14),
                          child: _JellyBubble(
                            key: ValueKey(key),
                            icon: icon,
                            tooltip: tooltip,
                            onPressed: onPressed,
                            diameter: 32,
                          ),
                        ),
                    ],
                  ),
                ),
                // Small bubbles between the screen and the pod.
                Positioned(
                  left: 309,
                  top: 70,
                  child: Column(
                    children: [
                      for (final (key, icon, tooltip, onPressed) in small)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: _JellyBubble(
                            key: ValueKey(key),
                            icon: icon,
                            tooltip: tooltip,
                            onPressed: onPressed,
                            diameter: 18,
                          ),
                        ),
                    ],
                  ),
                ),
                // The lime slice speaker.
                Positioned.fromRect(
                  rect: Rect.fromCircle(
                    center: _jellyPodCenter,
                    radius: _jellyPodRadius - 12,
                  ),
                  child: IgnorePointer(
                    child: RepaintBoundary(
                      child: CustomPaint(painter: _JellySlicePainter(_pulse)),
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

/// Elapsed and total time, on the screen.
class _JellyTime extends ConsumerWidget {
  const _JellyTime({required this.mediaItem});

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
        fontSize: 10,
        fontFeatures: [FontFeature.tabularFigures()],
      ),
    );
  }
}

/// The seek track: a lime trail in the dark well, with a jelly thumb.
class _JellySeek extends ConsumerWidget {
  const _JellySeek({required this.mediaItem});

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
    return SliderTheme(
      data: SliderTheme.of(context).copyWith(
        trackHeight: 4,
        activeTrackColor: _jellyHighlight,
        inactiveTrackColor: const Color(0xFF0E2401),
        thumbColor: _jellyLight,
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
        overlayShape: const RoundSliderOverlayShape(overlayRadius: 10),
        overlayColor: Colors.white.withValues(alpha: 0.2),
      ),
      child: PlaybackSeekSlider(
        key: ValueKey(item?.id),
        position: position,
        duration: duration,
        playing: playing,
        onSeek: ref.read(musicPlayerControllerProvider).seek,
      ),
    );
  }
}
