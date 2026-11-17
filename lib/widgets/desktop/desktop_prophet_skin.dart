part of 'desktop_player_bar.dart';

// A little roadside doomsayer, built from broad, deliberately planar facets.
// Coordinates share the fixed 360 × 520 window; only the LCD repaints per beat.
const _prophetInk = Color(0xFF282820);
const _prophetGreen = Color(0xFFA7D75A);
const _prophetBlue = Color(0xFF234B88);

Path _prophetPolygon(List<double> points) {
  final path = Path()..moveTo(points[0], points[1]);
  for (var i = 2; i < points.length; i += 2) {
    path.lineTo(points[i], points[i + 1]);
  }
  return path..close();
}

void _prophetFacet(Canvas canvas, int color, List<double> points) =>
    canvas.drawPath(_prophetPolygon(points), Paint()..color = Color(color));

/// Chunky cast metal, with actual planar bevels rather than a soft glow.
void _prophetBevel(Canvas canvas, Rect rect, {bool down = false}) {
  final x = rect.left, y = rect.top, r = rect.right, b = rect.bottom;
  canvas.drawRect(
    rect.shift(const Offset(2, 3)),
    Paint()..color = const Color(0xFF192B47),
  );
  canvas.drawRect(rect, Paint()..color = const Color(0xFF6E7478));
  _prophetFacet(canvas, down ? 0xFF697177 : 0xFFF0EEE2, [
    x,
    y,
    r,
    y,
    r - 5,
    y + 5,
    x + 5,
    y + 5,
    x + 5,
    b - 5,
    x,
    b,
  ]);
  _prophetFacet(canvas, down ? 0xFFC6C9C3 : 0xFF606970, [
    x,
    b,
    x + 5,
    b - 5,
    r - 5,
    b - 5,
    r - 5,
    y + 5,
    r,
    y,
    r,
    b,
  ]);
  canvas.drawRect(
    rect.deflate(5),
    Paint()..color = Color(down ? 0xFFA4AAA8 : 0xFFBEC3BF),
  );
  _skinGrain(canvas, rect.deflate(5), seed: 81, strength: .1, pitch: 2);
}

class _ProphetBodyPainter extends CustomPainter {
  const _ProphetBodyPainter({this.foreground = false});
  final bool foreground;

  @override
  void paint(Canvas canvas, Size size) {
    if (foreground) {
      // The right hand wraps over the board's thick edge, four blocky fingers.
      _prophetFacet(canvas, 0xFF9E6559, [
        309,
        271,
        326,
        267,
        337,
        277,
        334,
        302,
        321,
        310,
        308,
        302,
      ]);
      _prophetFacet(canvas, 0xFFE2AB91, [
        309,
        272,
        324,
        270,
        330,
        279,
        326,
        291,
        309,
        293,
      ]);
      for (var i = 0; i < 4; i++) {
        final y = 280.0 + i * 6;
        _prophetFacet(canvas, i.isEven ? 0xFFD69B83 : 0xFFC58B77, [
          306,
          y,
          321,
          y - 2,
          324,
          y + 3,
          320,
          y + 5,
          306,
          y + 5,
        ]);
      }
      _prophetFacet(canvas, 0xFFE8B59A, [
        323,
        273,
        331,
        279,
        328,
        292,
        321,
        289,
        322,
        281,
        315,
        278,
      ]);
      return;
    }
    // A shallow octagonal plinth with open sky (transparent window) around it.
    const ring = <double>[
      83.0,
      479,
      133,
      462,
      260,
      464,
      318,
      483,
      318,
      500,
      271,
      515,
      127,
      514,
      79,
      496,
    ];
    _prophetFacet(canvas, 0xFF713E22, ring);
    _prophetFacet(canvas, 0xFFD78432, [
      80,
      482,
      132,
      465,
      258,
      467,
      315,
      484,
      270,
      505,
      128,
      503,
    ]);
    _prophetFacet(canvas, 0xFF754B2D, [
      102,
      483,
      140,
      472,
      254,
      475,
      291,
      485,
      261,
      496,
      140,
      494,
    ]);
    _prophetFacet(canvas, 0xFFF1B85A, [
      80,
      482,
      132,
      465,
      258,
      467,
      315,
      484,
      305,
      488,
      255,
      472,
      134,
      470,
      91,
      487,
    ]);
    for (final (x, y, color) in <(double, double, int)>[
      (113, 486, 0xFF4C8793),
      (145, 499, 0xFFB85D4C),
      (276, 489, 0xFF849251),
      (252, 504, 0xFF5F7595),
    ]) {
      _prophetFacet(canvas, color, [x, y - 4, x + 10, y, x, y + 5, x - 10, y]);
    }
    // Shoes, then the broad cloak behind the board. Unequal triangles give
    // the silhouette weight without outlining every face like a cartoon.
    _prophetFacet(canvas, 0xFF443C33, [
      139,
      443,
      164,
      444,
      172,
      480,
      157,
      488,
      126,
      484,
      124,
      474,
    ]);
    _prophetFacet(canvas, 0xFF74634C, [
      138,
      454,
      157,
      451,
      161,
      475,
      126,
      480,
      124,
      474,
    ]);
    _prophetFacet(canvas, 0xFF393A32, [
      232,
      443,
      255,
      444,
      276,
      475,
      272,
      485,
      239,
      487,
      229,
      476,
    ]);
    _prophetFacet(canvas, 0xFF857154, [
      238,
      455,
      252,
      453,
      272,
      475,
      239,
      480,
      231,
      475,
    ]);
    _prophetFacet(canvas, 0xFF73442D, [
      140,
      157,
      213,
      158,
      269,
      210,
      298,
      449,
      259,
      466,
      112,
      459,
      88,
      424,
      104,
      240,
      77,
      207,
    ]);
    _prophetFacet(canvas, 0xFFA76537, [
      140,
      157,
      171,
      182,
      125,
      451,
      88,
      424,
      104,
      240,
      77,
      207,
    ]);
    _prophetFacet(canvas, 0xFFC08045, [
      109,
      220,
      140,
      177,
      151,
      205,
      119,
      369,
      96,
      422,
    ]);
    _prophetFacet(canvas, 0xFF533C30, [
      213,
      158,
      269,
      210,
      298,
      449,
      269,
      445,
      237,
      250,
      195,
      188,
    ]);
    // Raised arm: a substantial elbow and sleeve, with an open angular palm.
    _prophetFacet(canvas, 0xFF805334, [
      139,
      177,
      116,
      216,
      76,
      198,
      50,
      151,
      66,
      130,
      94,
      164,
    ]);
    _prophetFacet(canvas, 0xFFBC8050, [
      139,
      177,
      112,
      194,
      86,
      181,
      66,
      139,
      50,
      151,
      76,
      198,
      116,
      216,
    ]);
    _prophetFacet(canvas, 0xFF5D4937, [50, 151, 66, 130, 81, 151, 63, 168]);
    _prophetFacet(canvas, 0xFFC7907B, [
      56,
      146,
      43,
      129,
      38,
      112,
      24,
      100,
      28,
      94,
      44,
      103,
      35,
      80,
      40,
      76,
      51,
      98,
      47,
      69,
      53,
      67,
      60,
      94,
      63,
      74,
      69,
      76,
      68,
      104,
      78,
      99,
      83,
      105,
      72,
      123,
      69,
      138,
    ]);
    _prophetFacet(canvas, 0xFFE7B49A, [
      43,
      108,
      60,
      100,
      69,
      108,
      63,
      128,
      56,
      138,
      43,
      124,
    ]);
    // Hood: a crooked pointed crown and thick folded rim.
    _prophetFacet(canvas, 0xFF64665F, [
      118,
      151,
      126,
      112,
      154,
      70,
      187,
      55,
      211,
      95,
      225,
      156,
      199,
      183,
      145,
      177,
    ]);
    _prophetFacet(canvas, 0xFFB4B5A8, [
      126,
      112,
      154,
      70,
      187,
      55,
      171,
      104,
      141,
      149,
      118,
      151,
    ]);
    _prophetFacet(canvas, 0xFF92988D, [
      187,
      55,
      211,
      95,
      225,
      156,
      202,
      146,
      171,
      104,
    ]);
    _prophetFacet(canvas, 0xFF414A44, [
      141,
      131,
      173,
      105,
      202,
      129,
      211,
      159,
      189,
      179,
      147,
      165,
      132,
      151,
    ]);
    // Pink face, nose, heavy brow and tiny dark eyes.
    _prophetFacet(canvas, 0xFFC18D7D, [
      148,
      132,
      173,
      115,
      196,
      133,
      198,
      161,
      180,
      181,
      152,
      166,
      143,
      150,
    ]);
    _prophetFacet(canvas, 0xFFE0AE97, [
      148,
      132,
      173,
      115,
      179,
      143,
      165,
      164,
      148,
      155,
    ]);
    _prophetFacet(canvas, 0xFFAD796C, [
      179,
      143,
      196,
      133,
      198,
      161,
      180,
      181,
      173,
      163,
    ]);
    _prophetFacet(canvas, 0xFFF0C1A5, [173, 137, 182, 156, 171, 160, 166, 153]);
    _prophetFacet(canvas, 0xFF4C4B43, [148, 136, 162, 134, 162, 138, 150, 140]);
    _prophetFacet(canvas, 0xFF4C4B43, [181, 134, 194, 139, 192, 142, 182, 139]);
    canvas.drawRect(
      const Rect.fromLTWH(155, 140, 3, 3),
      Paint()..color = _prophetInk,
    );
    canvas.drawRect(
      const Rect.fromLTWH(185, 142, 3, 3),
      Paint()..color = _prophetInk,
    );
    // Moustache and a long, distinctly faceted beard, jutting off the chest.
    _prophetFacet(canvas, 0xFFBFC0AE, [
      148,
      155,
      165,
      161,
      174,
      157,
      187,
      163,
      198,
      155,
      201,
      180,
      183,
      211,
      168,
      229,
      143,
      192,
    ]);
    _prophetFacet(canvas, 0xFF92998F, [148, 155, 160, 176, 168, 229, 143, 192]);
    _prophetFacet(canvas, 0xFFDBD9C5, [160, 176, 174, 166, 181, 183, 168, 229]);
    _prophetFacet(canvas, 0xFF717C73, [
      181,
      183,
      198,
      155,
      201,
      180,
      183,
      211,
      168,
      229,
    ]);
    _prophetFacet(canvas, 0xFF555B53, [163, 163, 175, 162, 181, 166, 173, 169]);
    // Leather board straps, with a visible folded thickness.
    _prophetFacet(canvas, 0xFF483C2D, [132, 182, 142, 187, 128, 236, 119, 232]);
    _prophetFacet(canvas, 0xFFB39966, [132, 182, 137, 185, 123, 232, 119, 232]);
    _prophetFacet(canvas, 0xFF483C2D, [207, 180, 218, 184, 273, 233, 263, 236]);
    // Thick timber edge and a slightly irregular linen front.
    _prophetFacet(canvas, 0xFF756047, [
      101,
      218,
      309,
      214,
      323,
      225,
      321,
      473,
      109,
      479,
      98,
      466,
    ]);
    _prophetFacet(canvas, 0xFFAF9160, [309, 214, 323, 225, 321, 473, 309, 466]);
    final board = _prophetPolygon([101, 218, 309, 214, 309, 466, 98, 469]);
    canvas.drawPath(board, Paint()..color = const Color(0xFFD8CBA5));
    canvas.save();
    canvas.clipPath(board);
    // Stains sit beneath a real woven crosshatch, deterministic and static.
    final random = math.Random(92);
    for (var i = 0; i < 1800; i++) {
      final x = 98 + random.nextDouble() * 214;
      final y = 215 + random.nextDouble() * 255;
      canvas.drawRect(
        Rect.fromLTWH(
          x,
          y,
          1 + random.nextDouble() * 6,
          .7 + random.nextDouble() * 2,
        ),
        Paint()
          ..color = Color(
            i.isEven ? 0xFF897754 : 0xFFF8E8BE,
          ).withValues(alpha: .13),
      );
    }
    for (var y = 216.0; y < 470; y += 3) {
      canvas.drawLine(
        Offset(98, y),
        Offset(310, y + .5),
        Paint()..color = const Color(0xFF7C6B4A).withValues(alpha: .15),
      );
    }
    for (var x = 99.0; x < 310; x += 3) {
      canvas.drawLine(
        Offset(x, 215),
        Offset(x + 1, 469),
        Paint()..color = const Color(0xFFF4E8CA).withValues(alpha: .38),
      );
    }
    canvas.drawRect(
      const Rect.fromLTRB(98, 417, 310, 470),
      Paint()..color = _prophetBlue,
    );
    _skinGrain(
      canvas,
      const Rect.fromLTRB(98, 417, 310, 470),
      seed: 38,
      strength: .22,
      pitch: 1.5,
    );
    canvas.restore();
    // Frayed perimeter and metal fasteners preserve the handmade surface.
    canvas.drawPath(
      board,
      Paint()
        ..color = const Color(0xFFA28D61)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    for (final p in const [
      Offset(108, 225),
      Offset(301, 223),
      Offset(106, 461),
      Offset(301, 458),
    ]) {
      canvas.drawCircle(p, 2.3, Paint()..color = const Color(0xFF6D6854));
      canvas.drawLine(
        p.translate(-1, -1),
        p.translate(1, 1),
        Paint()..color = const Color(0xFFDED6B9),
      );
    }
  }

  @override
  bool shouldRepaint(_ProphetBodyPainter oldDelegate) =>
      oldDelegate.foreground != foreground;
}

class _ProphetButton extends StatelessWidget {
  const _ProphetButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onPressed,
    this.small = false,
    this.selected = false,
  });
  final IconData icon;
  final String label;
  final VoidCallback? onPressed;
  final bool small;
  final bool selected;

  @override
  Widget build(BuildContext context) => Semantics(
    selected: selected ? true : null,
    child: CustomPaint(
      painter: _ProphetButtonPainter(selected),
      child: SizedBox.square(
        dimension: small ? 23 : 40,
        child: IconButton(
          padding: EdgeInsets.zero,
          style: IconButton.styleFrom(
            shape: const RoundedRectangleBorder(),
            foregroundColor: _prophetBlue,
            disabledForegroundColor: const Color(0xFF7C8586),
            hoverColor: const Color(0x3359A4D3),
            focusColor: const Color(0x5559A4D3),
          ),
          onPressed: onPressed,
          icon: Icon(icon, size: small ? 13 : 27),
          tooltip: label,
        ),
      ),
    ),
  );
}

class _ProphetButtonPainter extends CustomPainter {
  const _ProphetButtonPainter(this.down);
  final bool down;
  @override
  void paint(Canvas canvas, Size size) =>
      _prophetBevel(canvas, Offset.zero & size, down: down);
  @override
  bool shouldRepaint(_ProphetButtonPainter oldDelegate) =>
      oldDelegate.down != down;
}

extension _ProphetLayout on _RetroMiniPlayerState {
  Widget _prophetLayout(
    BuildContext context, {
    required MediaItem? mediaItem,
    required bool playing,
    required bool loading,
  }) {
    final l10n = context.l10n;
    final controller = ref.read(musicPlayerControllerProvider);
    final enabled = mediaItem != null && !loading;
    return Material(
      type: MaterialType.transparency,
      child: DesktopVolumeScroll(
        child: OverflowBox(
          alignment: Alignment.topLeft,
          minWidth: _prophetSkinSize.width,
          maxWidth: _prophetSkinSize.width,
          minHeight: _prophetSkinSize.height,
          maxHeight: _prophetSkinSize.height,
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: Stack(
              children: [
                const Positioned.fill(
                  child: RepaintBoundary(
                    child: CustomPaint(painter: _ProphetBodyPainter()),
                  ),
                ),
                // Drag the hood or the slogan; all controls stay above these areas.
                const Positioned(
                  left: 118,
                  top: 55,
                  width: 107,
                  height: 160,
                  child: DesktopWindowDragArea(frameless: true),
                ),
                const Positioned(
                  left: 100,
                  top: 221,
                  width: 210,
                  height: 72,
                  child: DesktopWindowDragArea(frameless: true),
                ),
                Positioned(
                  left: 215,
                  top: 194,
                  child: Row(
                    children: [
                      _ProphetButton(
                        small: true,
                        icon: Icons.palette,
                        label: l10n.desktopMiniPlayerNextSkin,
                        onPressed: () => unawaited(
                          setDesktopMiniPlayerSkin(_nextSkin(widget.skin)),
                        ),
                      ),
                      const SizedBox(width: 3),
                      _ProphetButton(
                        small: true,
                        icon: Icons.remove,
                        label: l10n.desktopMiniPlayerMinimize,
                        onPressed: () => unawaited(minimizeDesktopWindow()),
                      ),
                      const SizedBox(width: 3),
                      _ProphetButton(
                        small: true,
                        icon: Icons.close,
                        label: l10n.extensionVerificationClose,
                        onPressed: () => unawaited(closeDesktopWindow()),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  left: 114,
                  top: 229,
                  width: 182,
                  height: 67,
                  child: IgnorePointer(
                    child: Transform.rotate(
                      angle: -.035,
                      child: Text(
                        l10n.desktopProphetSlogan,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontFamily: 'sans-serif',
                          fontSize: 32,
                          height: .98,
                          fontWeight: FontWeight.w900,
                          fontStyle: FontStyle.italic,
                          letterSpacing: -1.4,
                          color: _prophetInk,
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 115,
                  top: 294,
                  width: 180,
                  height: 15,
                  child: Tooltip(
                    message: mediaItem?.title ?? l10n.desktopPlayerIdle,
                    child: Text(
                      mediaItem?.title ?? l10n.desktopPlayerIdle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 10,
                        height: 1.2,
                        fontWeight: FontWeight.w700,
                        color: _prophetInk,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 118,
                  top: 312,
                  width: 176,
                  height: 35,
                  child: _ProphetTime(mediaItem: mediaItem),
                ),
                Positioned(
                  left: 113,
                  top: 352,
                  width: 186,
                  height: 36,
                  child: RepaintBoundary(
                    child: CustomPaint(painter: _ProphetBarsPainter(_pulse)),
                  ),
                ),
                Positioned(
                  left: 113,
                  top: 390,
                  width: 186,
                  height: 27,
                  child: _ProphetSeek(mediaItem: mediaItem),
                ),
                Positioned(
                  left: 115,
                  top: 425,
                  child: Row(
                    children: [
                      _ProphetButton(
                        key: const ValueKey('prophet-previous'),
                        icon: Icons.skip_previous,
                        label: l10n.nowPlayingPreviousTrack,
                        onPressed: enabled ? controller.previous : null,
                      ),
                      const SizedBox(width: 7),
                      _ProphetButton(
                        key: const ValueKey('prophet-play-pause'),
                        icon: Icons.play_arrow,
                        label: l10n.tooltipPlay,
                        selected: playing,
                        onPressed: enabled && !playing
                            ? () => controller.togglePlayPause(false)
                            : null,
                      ),
                      const SizedBox(width: 7),
                      _ProphetButton(
                        key: const ValueKey('prophet-pause'),
                        icon: Icons.pause,
                        label: l10n.actionPause,
                        selected: !playing,
                        onPressed: enabled && playing
                            ? () => controller.togglePlayPause(true)
                            : null,
                      ),
                      const SizedBox(width: 7),
                      _ProphetButton(
                        key: const ValueKey('prophet-next'),
                        icon: Icons.skip_next,
                        label: l10n.nowPlayingNextTrack,
                        onPressed: enabled ? controller.next : null,
                      ),
                    ],
                  ),
                ),
                Positioned(
                  left: 143,
                  top: 14,
                  width: 120,
                  height: 32,
                  child: _ProphetVolume(onVolume: _nudgeVolume),
                ),
                const Positioned.fill(
                  child: IgnorePointer(
                    child: CustomPaint(
                      painter: _ProphetBodyPainter(foreground: true),
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

/// Elapsed time uses actual seven-segment geometry, independent of fonts.
class _ProphetTime extends ConsumerWidget {
  const _ProphetTime({required this.mediaItem});
  final MediaItem? mediaItem;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final seconds = mediaItem == null
        ? 0
        : ref
              .watch(playbackPositionProvider)
              .inSeconds
              .clamp(0, mediaItem?.duration?.inSeconds ?? 0);
    final time =
        '${(seconds ~/ 60).toString().padLeft(2, '0')}:${(seconds % 60).toString().padLeft(2, '0')}';
    return Semantics(
      label: time,
      child: CustomPaint(painter: _ProphetDigitsPainter(time)),
    );
  }
}

class _ProphetDigitsPainter extends CustomPainter {
  const _ProphetDigitsPainter(this.time);
  final String time;
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect.inflate(3), const Radius.circular(9)),
      Paint()..color = const Color(0xFF8B8169),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(7)),
      Paint()..color = const Color(0xFF1F2A23),
    );
    const masks = [0x3F, 0x06, 0x5B, 0x4F, 0x66, 0x6D, 0x7D, 0x07, 0x7F, 0x6F];
    var x = (size.width - (time.length - 1) * 22 - 10) / 2;
    for (final char in time.split('')) {
      if (char == ':') {
        for (final y in [12.0, 23.0]) {
          canvas.drawRect(
            Rect.fromLTWH(x + 3, y, 3, 3),
            Paint()..color = _prophetGreen,
          );
        }
        x += 12;
        continue;
      }
      final digit = int.parse(char);
      final segments = <List<double>>[
        [3, 4, 15, 4, 17, 6, 15, 8, 3, 8, 1, 6],
        [16, 7, 19, 9, 18, 15, 16, 17, 14, 15, 15, 9],
        [16, 18, 18, 20, 17, 27, 15, 29, 13, 27, 14, 20],
        [2, 28, 14, 28, 16, 30, 14, 32, 2, 32, 0, 30],
        [0, 18, 2, 20, 1, 27, -1, 29, -3, 27, -2, 20],
        [1, 7, 3, 9, 2, 15, 0, 17, -2, 15, -1, 9],
        [2, 16, 14, 16, 16, 18, 14, 20, 2, 20, 0, 18],
      ];
      canvas.save();
      canvas.translate(x, 0);
      for (var i = 0; i < 7; i++) {
        canvas.drawPath(
          _prophetPolygon(segments[i]),
          Paint()
            ..color = masks[digit] & (1 << i) != 0
                ? _prophetGreen
                : const Color(0xFF34422B),
        );
      }
      canvas.restore();
      x += 24;
    }
  }

  @override
  bool shouldRepaint(_ProphetDigitsPainter oldDelegate) =>
      oldDelegate.time != time;
}

class _ProphetBarsPainter extends CustomPainter {
  _ProphetBarsPainter(this.pulse) : super(repaint: pulse);
  final _RetroPulse pulse;
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      (Offset.zero & size).inflate(3),
      Paint()..color = const Color(0xFF8E8267),
    );
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = const Color(0xFF202B24),
    );
    for (var i = 0; i < 28; i++) {
      final lit = (pulse.bars[i * 2] * 9).round();
      for (var row = 0; row < 8; row++) {
        canvas.drawRect(
          Rect.fromLTWH(
            3 + i * (size.width - 6) / 28,
            size.height - 4 - row * 4,
            4.5,
            2.5,
          ),
          Paint()..color = row < lit ? _prophetGreen : const Color(0xFF364332),
        );
      }
    }
  }

  @override
  bool shouldRepaint(_ProphetBarsPainter oldDelegate) =>
      oldDelegate.pulse != pulse;
}

class _ProphetSeek extends ConsumerStatefulWidget {
  const _ProphetSeek({required this.mediaItem});
  final MediaItem? mediaItem;
  @override
  ConsumerState<_ProphetSeek> createState() => _ProphetSeekState();
}

class _ProphetSeekState extends ConsumerState<_ProphetSeek> {
  double? _preview;
  @override
  void didUpdateWidget(_ProphetSeek oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.mediaItem?.id != widget.mediaItem?.id) _preview = null;
  }

  @override
  Widget build(BuildContext context) {
    final duration = widget.mediaItem?.duration?.inMilliseconds.toDouble() ?? 0;
    final position = widget.mediaItem == null
        ? 0.0
        : ref.watch(playbackPositionProvider).inMilliseconds.toDouble();
    return Semantics(
      label: context.l10n.desktopProphetSeek,
      child: SliderTheme(
        data: SliderTheme.of(context).copyWith(
          trackHeight: 5,
          activeTrackColor: _prophetGreen,
          inactiveTrackColor: const Color(0xFF59604A),
          thumbShape: const _ProphetThumb(),
          overlayShape: SliderComponentShape.noOverlay,
          padding: const EdgeInsets.symmetric(horizontal: 11),
        ),
        child: Slider(
          value: (_preview ?? position).clamp(0, duration > 0 ? duration : 1),
          max: duration > 0 ? duration : 1,
          onChanged: duration > 0 ? (v) => setState(() => _preview = v) : null,
          onChangeEnd: duration > 0
              ? (v) async {
                  try {
                    await ref
                        .read(musicPlayerControllerProvider)
                        .seek(Duration(milliseconds: v.round()));
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

class _ProphetThumb extends SliderComponentShape {
  const _ProphetThumb();
  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) => const Size(20, 19);
  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    _prophetBevel(
      context.canvas,
      Rect.fromCenter(center: center, width: 20, height: 17),
    );
    for (var i = -1; i <= 1; i++) {
      context.canvas.drawLine(
        center.translate(i * 3.0, -3),
        center.translate(i * 3.0, 3),
        Paint()..color = const Color(0xFF6D7775),
      );
    }
  }
}

class _ProphetVolume extends StatelessWidget {
  const _ProphetVolume({required this.onVolume});
  final ValueChanged<double> onVolume;

  @override
  Widget build(BuildContext context) => ValueListenableBuilder<double>(
    valueListenable: playbackOutputVolume,
    builder: (context, volume, _) => Semantics(
      label: context.l10n.desktopRetroVolume,
      value: '${(volume * 100).round()}%',
      increasedValue: '${((volume + .05).clamp(0, 1) * 100).round()}%',
      decreasedValue: '${((volume - .05).clamp(0, 1) * 100).round()}%',
      onIncrease: () => onVolume(.05),
      onDecrease: () => onVolume(-.05),
      child: Tooltip(
        message: context.l10n.desktopRetroVolume,
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapDown: (details) => onVolume(
              ((details.localPosition.dx - 35) / 80).clamp(0, 1) - volume,
            ),
            onHorizontalDragUpdate: (details) => onVolume(
              ((details.localPosition.dx - 35) / 80).clamp(0, 1) -
                  playbackOutputVolume.value,
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.volume_up,
                  color: Color(0xFFACAFA1),
                  size: 30,
                  shadows: [
                    Shadow(color: Color(0xFF3A4338), offset: Offset(2, 2)),
                  ],
                ),
                const SizedBox(width: 5),
                for (var i = 0; i < 10; i++)
                  Padding(
                    padding: const EdgeInsets.only(right: 2),
                    child: SizedBox(
                      width: 6,
                      height: 12 + i * 1.5,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: i < volume * 10
                              ? _prophetGreen
                              : const Color(0xFF657061),
                          border: Border.all(color: const Color(0xFF354031)),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
