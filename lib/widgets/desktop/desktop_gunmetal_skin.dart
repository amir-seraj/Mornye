part of 'desktop_player_bar.dart';

// The gunmetal skin: a heavy, asymmetric metal pebble. A chrome-ringed
// obsidian dome plays and pauses on the left, chrome keys skip underneath,
// and a curved glass screen on the right glows green behind the track.

const _gunLight = Color(0xFF6A717A);
const _gunMid = Color(0xFF353A41);
const _gunDark = Color(0xFF15171A);
const _gunEdge = Color(0xFF050607);
const _gunGreen = Color(0xFFB6FF3A);
const _gunGreenGlow = Color(0xFF6CFF12);
const _gunText = Color(0xFFD8FF8A);

/// The shell: a pebble that swells to the upper right.
Path _gunShellPath() => Path()
  ..moveTo(30, 196)
  ..cubicTo(14, 120, 92, 66, 196, 50)
  ..cubicTo(300, 34, 430, 16, 458, 76)
  ..cubicTo(482, 128, 456, 200, 404, 238)
  ..cubicTo(352, 276, 250, 286, 168, 282)
  ..cubicTo(86, 278, 40, 248, 30, 196)
  ..close();

// The screen pod: the chrome ring, and the glass inside it.
final _gunBezel = RRect.fromLTRBAndCorners(
  160,
  60,
  436,
  238,
  topLeft: const Radius.elliptical(96, 76),
  topRight: const Radius.elliptical(110, 80),
  bottomRight: const Radius.elliptical(96, 76),
  bottomLeft: const Radius.elliptical(80, 70),
);
final _gunGlass = _gunBezel.deflate(13);

// The play dome on the left.
const _gunDomeCenter = Offset(112, 150);
const double _gunDomeRadius = 38;

class _GunShellClipper extends CustomClipper<Path> {
  const _GunShellClipper();

  @override
  Path getClip(Size size) => _gunShellPath();

  @override
  bool shouldReclip(_GunShellClipper oldClipper) => false;
}

/// Paints the metal: extruded side wall, brushed face, bevels, the green
/// accent line, the chrome rings and the screen's sunken well.
class _GunShellPainter extends CustomPainter {
  const _GunShellPainter();

  void _chromeRing(Canvas canvas, RRect outer, RRect inner) {
    final bounds = outer.outerRect;
    canvas.drawDRRect(
      outer,
      inner,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF515B65),
            Color(0xFFF0F4F7),
            Color(0xFFCAD3DB),
            Color(0xFF303942),
            Color(0xFF697580),
            Color(0xFFD0D8DF),
            Color(0xFF434C55),
          ],
          stops: [0, 0.18, 0.25, 0.31, 0.64, 0.81, 1],
        ).createShader(bounds),
    );
    // A highlight along the top of the ring and its two hard edges.
    canvas.save();
    canvas.clipRRect(outer);
    canvas.drawRRect(
      outer.shift(const Offset(0, 2)),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = Colors.white.withValues(alpha: 0.7),
    );
    canvas.restore();
    final edge = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..color = _gunEdge;
    canvas.drawRRect(outer, edge);
    canvas.drawRRect(inner, edge);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final shell = _gunShellPath();
    final bounds = shell.getBounds();

    canvas.drawShadow(
      shell.shift(const Offset(0, 10)),
      Colors.black,
      10,
      false,
    );
    // The side wall, so the shell sits thick off the desktop.
    const depth = 12.0;
    for (var d = depth; d >= 1; d--) {
      canvas.drawPath(
        shell.shift(Offset(0, d)),
        Paint()..color = Color.lerp(_gunDark, _gunEdge, d / depth)!,
      );
    }

    // The face: a cool metal gradient, lit from the upper left.
    canvas.drawPath(
      shell,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_gunLight, _gunMid, _gunDark, Color(0xFF0B0C0E)],
          stops: [0, 0.35, 0.75, 1],
        ).createShader(bounds),
    );

    canvas.save();
    canvas.clipPath(shell);
    // Brushed grain: fine horizontal strokes of varying strength.
    final grain = Paint()..strokeWidth = 0.45;
    final random = math.Random(7);
    for (var y = bounds.top; y < bounds.bottom; y += 1.5) {
      final light = random.nextBool();
      grain.color = (light ? Colors.white : Colors.black).withValues(
        alpha: 0.012 + random.nextDouble() * 0.025,
      );
      final start = bounds.left + random.nextDouble() * 60;
      final end = bounds.right - random.nextDouble() * 60;
      canvas.drawLine(Offset(start, y), Offset(end, y), grain);
    }
    _skinGrain(canvas, bounds, seed: 43, strength: 0.045, pitch: 3);
    // A broad specular sweep across the upper left.
    final sheen = Path()
      ..moveTo(40, 170)
      ..cubicTo(60, 100, 150, 62, 260, 50)
      ..lineTo(250, 78)
      ..cubicTo(160, 90, 90, 124, 70, 190)
      ..close();
    canvas.drawPath(
      sheen,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.16)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
    );
    // The bevel: a bright lip inside the top edge, deep shade at the bottom.
    canvas.drawPath(
      shell.shift(const Offset(1, 4)),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6
        ..color = Colors.white.withValues(alpha: 0.28)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
    );
    canvas.drawPath(
      shell.shift(const Offset(0, 1.5)),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = Colors.white.withValues(alpha: 0.5),
    );
    canvas.drawPath(
      shell.shift(const Offset(-2, -8)),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 14
        ..color = Colors.black.withValues(alpha: 0.55)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );
    canvas.restore();
    _skinRelief(
      canvas,
      shell,
      shade: _gunEdge.withValues(alpha: 0.85),
      light: const Color(0xFFBDC8D1).withValues(alpha: 0.6),
      width: 9,
    );

    // The green accent swept along the upper edge.
    final accent = Path()
      ..moveTo(58, 176)
      ..cubicTo(64, 118, 128, 80, 232, 64);
    canvas.drawPath(
      accent,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = 7
        ..color = _gunGreenGlow.withValues(alpha: 0.5)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
    );
    canvas.drawPath(
      accent,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = 2.5
        ..color = _gunGreen,
    );

    canvas.drawPath(
      shell,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6
        ..color = _gunEdge,
    );

    // The screen pod rises from the shell: its shadow, then the chrome.
    canvas.drawRRect(
      _gunBezel.shift(const Offset(0, 6)),
      Paint()
        ..color = Colors.black.withValues(alpha: 0.6)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );
    _chromeRing(canvas, _gunBezel, _gunGlass);

    // The dome's chrome collar.
    final collar = RRect.fromRectAndRadius(
      Rect.fromCircle(center: _gunDomeCenter, radius: _gunDomeRadius + 9),
      const Radius.circular(_gunDomeRadius + 9),
    );
    canvas.drawRRect(
      collar.shift(const Offset(0, 5)),
      Paint()
        ..color = Colors.black.withValues(alpha: 0.6)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
    );
    _chromeRing(
      canvas,
      collar,
      RRect.fromRectAndRadius(
        Rect.fromCircle(center: _gunDomeCenter, radius: _gunDomeRadius + 1),
        const Radius.circular(_gunDomeRadius + 1),
      ),
    );

    // The well the keys and the seek groove sit in.
    final keyWell = RRect.fromLTRBR(
      56,
      212,
      192,
      246,
      const Radius.circular(17),
    );
    canvas.drawRRect(
      keyWell,
      Paint()..color = Colors.black.withValues(alpha: 0.55),
    );
    canvas.drawRRect(
      keyWell.shift(const Offset(0, 1)),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = Colors.white.withValues(alpha: 0.18),
    );
  }

  @override
  bool shouldRepaint(_GunShellPainter oldDelegate) => false;
}

/// The glass: deep green with an orb of light that swells on the beat, the
/// visualizer low down, and a curved reflection across the top.
class _GunGlassPainter extends CustomPainter {
  _GunGlassPainter(this.pulse) : super(repaint: pulse);
  final _RetroPulse pulse;
  @override
  void paint(Canvas canvas, Size size) {
    final glass = RRect.fromRectAndCorners(
      Offset.zero & size,
      topLeft: _gunGlass.tlRadius,
      topRight: _gunGlass.trRadius,
      bottomRight: _gunGlass.brRadius,
      bottomLeft: _gunGlass.blRadius,
    );
    canvas.save();
    canvas.clipRRect(glass);
    final center = Offset(size.width * 0.5, size.height * 0.58);
    final radius = size.height * (0.42 + pulse.energy * 0.12);
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..shader = RadialGradient(
          colors: [
            const Color(0xFFBDFA68),
            _gunGreen,
            _gunGreenGlow.withValues(alpha: 0.55),
            _gunGreenGlow.withValues(alpha: 0),
          ],
          stops: const [0, 0.08, 0.38, 1],
        ).createShader(Rect.fromCircle(center: center, radius: radius)),
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(_GunGlassPainter oldDelegate) =>
      oldDelegate.pulse != pulse;
}

/// The glass surface is stationary while the orb breathes underneath it.
class _GunGlassSurfacePainter extends CustomPainter {
  const _GunGlassSurfacePainter({required this.reflection});
  final bool reflection;
  @override
  void paint(Canvas canvas, Size size) {
    final glass = RRect.fromRectAndCorners(
      Offset.zero & size,
      topLeft: _gunGlass.tlRadius,
      topRight: _gunGlass.trRadius,
      bottomRight: _gunGlass.brRadius,
      bottomLeft: _gunGlass.blRadius,
    );
    final rect = Offset.zero & size;
    canvas.save();
    canvas.clipRRect(glass);
    if (!reflection) {
      canvas.drawRect(
        rect,
        Paint()
          ..shader = const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF041203), Color(0xFF0E3A06), Color(0xFF031002)],
          ).createShader(rect),
      );
    } else {
      // Scanlines, faint, like a CRT under the glass.
      final scan = Paint()..color = Colors.black.withValues(alpha: 0.12);
      for (var y = 0.0; y < size.height; y += 3) {
        canvas.drawRect(Rect.fromLTWH(0, y, size.width, 1), scan);
      }
      // The glass's curve: a reflection across the top, a dark rim all round.
      final reflection = Path()
        ..addOval(
          Rect.fromLTRB(
            size.width * 0.04,
            -size.height * 0.35,
            size.width * 0.96,
            size.height * 0.42,
          ),
        );
      canvas.drawPath(
        reflection,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.white.withValues(alpha: 0.26),
              Colors.white.withValues(alpha: 0.02),
            ],
          ).createShader(rect),
      );
      canvas.drawRRect(
        glass,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 14
          ..color = Colors.black.withValues(alpha: 0.7)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 7),
      );
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_GunGlassSurfacePainter oldDelegate) =>
      oldDelegate.reflection != reflection;
}

/// A flat icon etched into the glass, glowing when the pointer is over it.
class _GunGlassButton extends StatefulWidget {
  const _GunGlassButton({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;

  @override
  State<_GunGlassButton> createState() => _GunGlassButtonState();
}

class _GunGlassButtonState extends State<_GunGlassButton> {
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
          padding: const EdgeInsets.all(4),
          child: Icon(
            widget.icon,
            size: 16,
            color: widget.onPressed == null
                ? _gunText.withValues(alpha: 0.3)
                : _down
                ? _gunGreen.withValues(alpha: 0.6)
                : _hover
                ? const Color(0xFFF0F6DF)
                : _gunText.withValues(alpha: 0.85),
            shadows: const [Shadow(color: _gunGreenGlow, blurRadius: 8)],
          ),
        ),
      ),
    ),
  );
}

extension _GunmetalLayout on _RetroMiniPlayerState {
  Widget _gunmetalLayout(
    BuildContext context, {
    required MediaItem? mediaItem,
    required bool playing,
    required bool loading,
  }) {
    final l10n = context.l10n;
    final controller = ref.read(musicPlayerControllerProvider);
    final enabled = mediaItem != null;
    const glow = [Shadow(color: _gunGreenGlow, blurRadius: 3)];
    const dark = [Shadow(color: Colors.black, blurRadius: 4)];
    final glass = _gunGlass.outerRect;

    return Material(
      type: MaterialType.transparency,
      child: DesktopVolumeScroll(
        child: OverflowBox(
          alignment: Alignment.topLeft,
          minWidth: _gunmetalSkinSize.width,
          maxWidth: _gunmetalSkinSize.width,
          minHeight: _gunmetalSkinSize.height,
          maxHeight: _gunmetalSkinSize.height,
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                const Positioned.fill(
                  child: RepaintBoundary(
                    child: CustomPaint(painter: _GunShellPainter()),
                  ),
                ),
                const Positioned.fill(
                  child: ClipPath(
                    clipper: _GunShellClipper(),
                    child: DesktopWindowDragArea(frameless: true),
                  ),
                ),
                Positioned.fromRect(
                  rect: glass,
                  child: IgnorePointer(
                    child: RepaintBoundary(
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          const RepaintBoundary(
                            child: CustomPaint(
                              painter: _GunGlassSurfacePainter(
                                reflection: false,
                              ),
                            ),
                          ),
                          RepaintBoundary(
                            child: CustomPaint(
                              painter: _GunGlassPainter(_pulse),
                            ),
                          ),
                          const RepaintBoundary(
                            child: CustomPaint(
                              painter: _GunGlassSurfacePainter(
                                reflection: true,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                // The visualizer, low in the glass behind the text.
                Positioned(
                  left: glass.left + 56,
                  width: glass.width - 112,
                  top: glass.top + 98,
                  height: 26,
                  child: IgnorePointer(
                    child: Opacity(
                      opacity: 0.75,
                      child: RepaintBoundary(
                        child: ValueListenableBuilder<_RetroScope>(
                          valueListenable: _retroScope,
                          builder: (context, style, _) => CustomPaint(
                            painter: _RetroScopePainter(
                              _pulse,
                              style,
                              core: const Color(0xFFEFFFB0),
                              glowColor: _gunGreenGlow,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                // The track, centered in the glass.
                Positioned(
                  left: glass.left + 30,
                  width: glass.width - 60,
                  top: glass.top + 10,
                  child: IgnorePointer(
                    child: Column(
                      children: [
                        const _RetroClock(
                          style: TextStyle(
                            fontSize: 17,
                            height: 1,
                            fontWeight: FontWeight.w800,
                            color: _gunText,
                            shadows: glow,
                            fontFeatures: [FontFeature.tabularFigures()],
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          mediaItem?.title ?? l10n.desktopPlayerIdle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 14,
                            height: 1.2,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            shadows: [...glow, ...dark],
                          ),
                        ),
                        Text(
                          mediaItem?.artist ?? '',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 11,
                            height: 1.3,
                            color: _gunText.withValues(alpha: 0.9),
                            shadows: dark,
                          ),
                        ),
                        const SizedBox(height: 2),
                        _GunTime(mediaItem: mediaItem),
                      ],
                    ),
                  ),
                ),
                // Buttons etched along the bottom of the glass.
                Positioned(
                  left: glass.left,
                  width: glass.width,
                  top: glass.bottom - 34,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _GunGlassButton(
                        key: const ValueKey('gunmetal-visualizer'),
                        icon: Icons.equalizer,
                        tooltip: l10n.desktopMiniPlayerVisualizer,
                        onPressed: () => _retroScope.value =
                            _RetroScope.values[(_retroScope.value.index + 1) %
                                _RetroScope.values.length],
                      ),
                      const SizedBox(width: 18),
                      _GunGlassButton(
                        key: const ValueKey('gunmetal-next-skin'),
                        icon: Icons.flare,
                        tooltip: l10n.desktopMiniPlayerNextSkin,
                        onPressed: () => unawaited(
                          setDesktopMiniPlayerSkin(_nextSkin(widget.skin)),
                        ),
                      ),
                      const SizedBox(width: 18),
                      _GunGlassButton(
                        key: const ValueKey('gunmetal-full-window'),
                        icon: Icons.menu,
                        tooltip: l10n.desktopMiniPlayerExpand,
                        onPressed: () =>
                            unawaited(setDesktopMiniPlayer(open: false)),
                      ),
                    ],
                  ),
                ),
                // Window buttons on a chrome tab above the screen.
                Positioned(
                  left: 300,
                  top: 30,
                  child: Row(
                    children: [
                      _RetroPill(
                        key: const ValueKey('gunmetal-minimize'),
                        icon: Icons.remove,
                        tooltip: l10n.desktopMiniPlayerMinimize,
                        kind: _RetroPillKind.chrome,
                        size: const Size(28, 18),
                        iconSize: 13,
                        onPressed: () => unawaited(minimizeDesktopWindow()),
                      ),
                      const SizedBox(width: 6),
                      _RetroPill(
                        key: const ValueKey('gunmetal-expand'),
                        icon: Icons.close,
                        tooltip: l10n.desktopMiniPlayerExpand,
                        kind: _RetroPillKind.chrome,
                        size: const Size(28, 18),
                        iconSize: 13,
                        onPressed: () =>
                            unawaited(setDesktopMiniPlayer(open: false)),
                      ),
                    ],
                  ),
                ),
                // The play dome.
                Positioned(
                  left: _gunDomeCenter.dx - _gunDomeRadius,
                  top: _gunDomeCenter.dy - _gunDomeRadius,
                  child: _RetroPill(
                    key: const ValueKey('gunmetal-play-pause'),
                    icon: playing ? Icons.pause : Icons.play_arrow,
                    tooltip: playing ? l10n.actionPause : l10n.tooltipPlay,
                    kind: _RetroPillKind.obsidian,
                    size: const Size.square(_gunDomeRadius * 2),
                    iconSize: 36,
                    onPressed: enabled && !loading
                        ? () => controller.togglePlayPause(playing)
                        : null,
                  ),
                ),
                // Chrome keys in their well.
                Positioned(
                  left: 62,
                  top: 217,
                  child: Row(
                    children: [
                      _RetroPill(
                        key: const ValueKey('gunmetal-previous'),
                        icon: Icons.skip_previous,
                        tooltip: l10n.nowPlayingPreviousTrack,
                        kind: _RetroPillKind.chrome,
                        size: const Size(38, 24),
                        onPressed: enabled ? controller.previous : null,
                      ),
                      const SizedBox(width: 4),
                      _RetroPill(
                        key: const ValueKey('gunmetal-stop'),
                        icon: Icons.stop,
                        tooltip: l10n.desktopMiniPlayerStop,
                        kind: _RetroPillKind.chrome,
                        size: const Size(38, 24),
                        onPressed: enabled
                            ? () async {
                                if (playing) {
                                  await controller.togglePlayPause(true);
                                }
                                await controller.seek(Duration.zero);
                              }
                            : null,
                      ),
                      const SizedBox(width: 4),
                      _RetroPill(
                        key: const ValueKey('gunmetal-next'),
                        icon: Icons.skip_next,
                        tooltip: l10n.nowPlayingNextTrack,
                        kind: _RetroPillKind.chrome,
                        size: const Size(38, 24),
                        onPressed: enabled ? controller.next : null,
                      ),
                    ],
                  ),
                ),
                // The power LED: lit while playing, pulsing with the beat.
                Positioned(
                  left: 196,
                  top: 238,
                  width: 10,
                  height: 10,
                  child: IgnorePointer(
                    child: RepaintBoundary(
                      child: CustomPaint(
                        painter: _GunLedPainter(_pulse, playing: playing),
                      ),
                    ),
                  ),
                ),
                // Seek groove under the screen.
                Positioned(
                  left: 216,
                  top: 248,
                  width: 168,
                  height: 18,
                  child: _GunSeekGroove(mediaItem: mediaItem),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _GunLedPainter extends CustomPainter {
  _GunLedPainter(this.pulse, {required this.playing}) : super(repaint: pulse);

  final _RetroPulse pulse;
  final bool playing;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final lit = playing ? 0.55 + pulse.energy * 0.45 : 0.12;
    canvas.drawCircle(
      center,
      size.width,
      Paint()
        ..color = _gunGreenGlow.withValues(alpha: lit * 0.5)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );
    canvas.drawCircle(
      center,
      size.width / 2,
      Paint()..color = Color.lerp(const Color(0xFF1C3A0A), _gunGreen, lit)!,
    );
    canvas.drawCircle(
      center.translate(-1, -1.2),
      size.width / 6,
      Paint()..color = Colors.white.withValues(alpha: 0.7),
    );
  }

  @override
  bool shouldRepaint(_GunLedPainter oldDelegate) =>
      oldDelegate.pulse != pulse || oldDelegate.playing != playing;
}

/// Elapsed and total time, in the glass.
class _GunTime extends ConsumerWidget {
  const _GunTime({required this.mediaItem});

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
      style: TextStyle(
        fontSize: 10,
        color: _gunText.withValues(alpha: 0.8),
        shadows: const [Shadow(color: Colors.black, blurRadius: 4)],
        fontFeatures: const [FontFeature.tabularFigures()],
      ),
    );
  }
}

/// A recessed groove with a green-lit trail and a chrome playhead.
class _GunSeekGroove extends ConsumerWidget {
  const _GunSeekGroove({required this.mediaItem});

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
        color: Colors.black.withValues(alpha: 0.7),
        border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
      ),
      child: SliderTheme(
        data: SliderTheme.of(context).copyWith(
          trackHeight: 3,
          activeTrackColor: _gunGreen,
          inactiveTrackColor: const Color(0xFF22262B),
          thumbColor: const Color(0xFFE6EAEE),
          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
          overlayShape: const RoundSliderOverlayShape(overlayRadius: 9),
          overlayColor: _gunGreen.withValues(alpha: 0.2),
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
