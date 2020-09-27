import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

class Algrafx extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final graphr = GraphController();

    return GraphScreen(graphr);
  }
}

const double G = 2.0;

const double cG = 0.03;

const fBlue = const Color(0xff4FBDF6);

const fPurple = const Color(0xFF2D2F41);

const black = const Color(0xff000000);

class Config {
  final Color backgroundColor;
  final Color fillColor;
  final Color strokeColor;
  final bool applyForce;
  final bool liveColor;

  Config([
    this.backgroundColor = fPurple,
    this.fillColor = fBlue,
    this.strokeColor = Colors.black,
    this.applyForce = true,
    this.liveColor = true,
  ]);

  copyWith({
    Color backgroundColor,
    Color fillColor,
    Color strokeColor,
    bool applyForce,
    bool liveColor,
  }) =>
      Config(
        backgroundColor ?? this.backgroundColor,
        fillColor ?? this.fillColor,
        strokeColor ?? this.strokeColor,
        applyForce ?? this.applyForce,
        liveColor ?? this.liveColor,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Config &&
          runtimeType == other.runtimeType &&
          backgroundColor == other.backgroundColor &&
          fillColor == other.fillColor &&
          strokeColor == other.strokeColor &&
          applyForce == other.applyForce &&
          liveColor == other.liveColor;

  @override
  int get hashCode =>
      backgroundColor.hashCode ^
      fillColor.hashCode ^
      strokeColor.hashCode ^
      applyForce.hashCode ^
      liveColor.hashCode;
}

class Node {
  static final yellowFill = Paint()..color = Color(0x55FFEB3B);

  Offset gravity = Offset(0, G);

  Offset offset;

  Color color;

  Color strokeColor;

  final bool applyForce;

  bool liveColor;

  bool _freezed = false;

  double get x => offset.dx;
  double get y => offset.dy;

  Node(this.offset, this.color, this.strokeColor, this.applyForce,
      this.liveColor);

  update() {
    if (_freezed) return;

    if (applyForce) {
      offset += gravity;
      gravity *= 1 + cG;
    }

    if (liveColor) {
      if (color != black) {
        final hsl = HSLColor.fromColor(color);
        color = hsl.withLightness(max(hsl.lightness - 0.01, 0)).toColor();
      }

      if (strokeColor != null && strokeColor != black) {
        final strokeHsl = HSLColor.fromColor(strokeColor);
        strokeColor = strokeHsl
            .withLightness(max(strokeHsl.lightness - 0.01, 0))
            .toColor();
      }

      if (color.value == black.value && strokeColor.value == black.value) {
        liveColor = false;
        if (!applyForce) freeze();
      }
    }
  }

  freeze() => _freezed = true;

  void draw(Canvas canvas) {
    canvas.drawCircle(offset, 2, yellowFill);
  }
}

class Line {
  final List<Node> points;

  static final paint = Paint()..color = const Color(0xFF424242);

  Line(this.points);

  void draw(Canvas canvas) {
    canvas.drawLine(points.first.offset, points.last.offset, paint);
  }
}

class Polygon {
  final List<Node> nodes;
  final double distance;

  final List<Offset> previousPoints;

  final Color fillColor;
  final Color strokeColor;

  List<Offset> get points {
    final width = Offset(0, 30) * distance / 100;
    final c0 = nodes.first.offset - width;
    final c1 = nodes.last.offset - width;
    final c2 = nodes.last.offset + width;
    final c3 = nodes.first.offset + width;
    return [c0, c1, c2, c3];
  }

  Polygon(this.nodes, {this.previousPoints, this.fillColor, this.strokeColor})
      : distance = (nodes.first.offset - nodes.last.offset).distance;

  void draw(Canvas canvas) {
    final width = Offset(0, 30) * distance / 100;

    final paint = Paint()..color = fillColor;
    final c0 = previousPoints.first;
    final c1 =
        nodes.last.offset - width /*> Offset(0, 5) ? width : Offset(0, 5)*/;
    final c2 =
        nodes.last.offset + width /*> Offset(0, 5) ? width : Offset(0, 5)*/;
    final c3 = previousPoints.last;

    final path = Path()
      ..moveTo(c0.dx, c0.dy)
      ..lineTo(c1.dx, c1.dy)
      ..lineTo(c2.dx, c2.dy)
      ..lineTo(c3.dx, c3.dy)
      ..lineTo(c0.dx, c0.dy);
    canvas.drawPath(path, paint);

    if (strokeColor != null)
      canvas.drawPath(
          path,
          Paint()
            ..style = PaintingStyle.stroke
            ..color = strokeColor);
  }
}

class GraphController {
  GraphController() {
    _config = Config();
    _configStreamer.stream.listen((c) => _config = c);
  }

  List<List<Node>> polygons = [];

  StreamController<List<List<Node>>> _polygonStreamer = StreamController();

  Stream<List<List<Node>>> get polygon$ => _polygonStreamer.stream;

  List<Node> nodes = [];

  get isEmpty => nodes.isEmpty && polygons.isEmpty;

  Config _config;

  Config get config => _config;

  set config(Config value) {
    _config = value;
    _configStreamer.add(value);
  }

  StreamController<Config> _configStreamer =
      StreamController<Config>.broadcast()..add(Config());

  Stream<Config> get config$ => _configStreamer.stream;

  get backgroundColor => _config.backgroundColor;

  set backgroundColor(Color backgroundColor) =>
      _configStreamer.add(_config.copyWith(backgroundColor: backgroundColor));

  Color get fillColor => _config.fillColor;

  set fillColor(Color fillColor) =>
      _configStreamer.add(_config.copyWith(fillColor: fillColor));

  Color get strokeColor => _config.strokeColor;

  set strokeColor(Color strokeColor) =>
      _configStreamer.add(_config.copyWith(strokeColor: strokeColor));

  bool get applyForce => _config.applyForce;

  set applyForce(bool applyForce) =>
      _configStreamer.add(_config.copyWith(applyForce: applyForce));

  bool get liveColor => _config.liveColor;

  set liveColor(bool liveColor) =>
      _configStreamer.add(_config.copyWith(liveColor: liveColor));

  void dispose() {
    _configStreamer.close();
    _polygonStreamer.close();
  }

  void addPoint(Offset offset) {
    nodes.add(Node(
        offset, fillColor, strokeColor, config.applyForce, config.liveColor));
    //notifyListeners();
  }

  void update(Size size) {
    final filteredNodes = <Node>[];
    for (final node in nodes) {
      if (node.offset.dy < size.height) {
        node.update();
        filteredNodes.add(node);
      }
      nodes = filteredNodes;
    }
  }

  void clear() {
    nodes = [];
    polygons = [];
    _polygonStreamer.add(polygons);
  }

  void freeze() {
    polygons.add([for (final node in nodes) node..freeze()]);
    _polygonStreamer.add(polygons);
    nodes = [];
  }

  void undo() {
    if (polygons.isEmpty) return;

    polygons.removeLast();
    _polygonStreamer.add(polygons);
  }
}

class GraphScreen extends StatelessWidget {
  final GraphController controller;

  const GraphScreen(this.controller, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isMobileScreen = MediaQuery.of(context).size.width <= 900;
    final luminance = controller.config.backgroundColor.computeLuminance();
    final brightness = luminance > 0.5 ? Brightness.light : Brightness.dark;
    final iconColor =
        brightness == Brightness.light ? Colors.black54 : Colors.white54;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF444974),
        elevation: 0,
        title: Text('Algrafx'),
        centerTitle: true,
      ),
      endDrawer: isMobileScreen
          ? Theme(
              data: ThemeData.dark(),
              child:
                  SettingsDrawer(controller: controller, iconColor: iconColor),
            )
          : null,
      body: Stack(
        children: <Widget>[
          Graph(this.controller),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Appbar(controller: controller),
          ),
          OnBoarding(isMobileScreen
              ? 'Touch/Pan to draw & Tap to freeze'
              : 'Move your cursor to draw & Click or hit Space to freeze'),
        ],
      ),
    );
  }
}

class OnBoarding extends StatefulWidget {
  final String content;

  OnBoarding(this.content);

  @override
  _OnBoardingState createState() => _OnBoardingState();
}

class _OnBoardingState extends State<OnBoarding> {
  double opacity = 1;

  @override
  void initState() {
    Timer(Duration(seconds: 5), () => setState(() => opacity = 0));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: Duration(seconds: 1),
      opacity: opacity,
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(12.0),
          color: Colors.black54,
          child: Text(
            widget.content,
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }
}

class Graph extends StatelessWidget {
  final GraphController controller;

  Graph(this.controller);

  @override
  Widget build(BuildContext context) {
    //print('Graph.build... ');
    final size = MediaQuery.of(context).size;
    return RawKeyboardListener(
      focusNode: FocusNode(),
      autofocus: true,
      onKey: (event) {
        if (event.data.keyLabel == ' ') controller.freeze();
      },
      child: StreamBuilder<Color>(
          initialData: fPurple,
          stream:
              controller.config$.map<Color>((Config c) => c.backgroundColor),
          builder: (context, snapshot) {
            return Container(
              constraints: BoxConstraints.expand(),
              color: snapshot.data ?? fPurple,
              child: _buildCanvasStack(size),
            );
          }),
    );
  }

  Stack _buildCanvasStack(Size size) {
    return Stack(
      children: <Widget>[
        StreamBuilder<List<List<Node>>>(
          stream: controller.polygon$,
          builder: (context, snapshot) => BackgroundCanvas(
            freezedNodes: snapshot.data ?? [],
            size: size,
          ),
        ),
        LiveCanvas(size: size, controller: controller),
      ],
    );
  }
}

class LiveCanvas extends StatefulWidget {
  final Size size;
  final GraphController controller;

  const LiveCanvas({
    Key key,
    @required this.size,
    @required this.controller,
  }) : super(key: key);

  @override
  _LiveCanvasState createState() => _LiveCanvasState();
}

class _LiveCanvasState extends State<LiveCanvas> with TickerProviderStateMixin {
  AnimationController anim;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    print('_LiveCanvasState.didChangeDependencies... ');
  }

  @override
  void initState() {
    anim = AnimationController(vsync: this, duration: Duration(seconds: 1))
      ..addListener(() {
        widget.controller.update(widget.size);
        if (widget.controller.nodes.isEmpty) anim.stop();
      })
      ..forward()
      ..repeat();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
        onHover: widget.controller.config.applyForce
            ? (event) {
                widget.controller.addPoint(event.localPosition);
                anim
                  ..forward()
                  ..repeat();
              }
            : null,
        onEnter: (event) {
          widget.controller.addPoint(event.localPosition);
          anim
            ..forward()
            ..repeat();
        },
        child: GestureDetector(
            onTap: widget.controller.freeze,
            onPanUpdate: (event) {
              widget.controller.addPoint(event.localPosition);
              anim
                ..forward()
                ..repeat();
            },
            onPanEnd: widget.controller.config.applyForce
                ? null
                : (_) => widget.controller.freeze(),
            child: AnimatedBuilder(
              animation: anim,
              builder: (c, _) {
                return RepaintBoundary(
                  child: CustomPaint(
                    size: widget.size,
                    painter: LivePainter(widget.controller.nodes),
                  ),
                );
              },
            )));
  }
}

class LivePainter extends CustomPainter {
  List<Node> nodes;

  LivePainter(this.nodes);

  static final Paint dummyRectPaint = Paint()
    ..color = Color.fromARGB(0, 255, 255, 255)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 0.0;

  @override
  void paint(Canvas canvas, Size size) {
    //print('GraphPainter.paint... ${nodes.length}');

    canvas.drawRect(Offset.zero & size, dummyRectPaint);

    for (int i = 0; i < nodes.length; i++) {
      final node = nodes[i];
      if (node.offset.dy < size.height) node.draw(canvas);

      if (i > 0) {
        final l = Line([nodes[i - 1], nodes[i]]);
        l.draw(canvas);
      }

      if (i > 2) {
        final prevR = Polygon([nodes[i - 2], nodes[i - 1]]);
        final r = Polygon(
          [nodes[i - 1], nodes[i]],
          previousPoints: [prevR.points[1], prevR.points[2]],
          fillColor: nodes[i].color,
          strokeColor: nodes[i].strokeColor,
        );
        r.draw(canvas);
      }
    }
  }

  @override
  bool shouldRepaint(LivePainter oldDelegate) {
    return true;
  }
}

class BackgroundCanvas extends StatelessWidget {
  final List<List<Node>> freezedNodes;
  final Size size;

  const BackgroundCanvas({Key key, this.freezedNodes, this.size})
      : super(key: key);

  Widget build(BuildContext context) {
    //print('BackgroundCanvas.build... ${freezedNodes.length}');
    return RepaintBoundary(
      child: CustomPaint(
        size: size,
        isComplex: true,
        willChange: false,
        painter: BackgroundPainter(freezedNodes),
      ),
    );
  }
}

class BackgroundPainter extends CustomPainter {
  List<List<Node>> polygons;

  BackgroundPainter(this.polygons);

  @override
  void paint(Canvas canvas, Size size) {
    polygons.forEach(
      (nodes) {
        for (int i = 0; i < nodes.length; i++) {
          /*
          final node = nodes[i];
          if (node.offset.dy < size.height) node.draw(canvas);
          if (i > 0) {
            final l = Line([nodes[i - 1], nodes[i]]);
            l.draw(canvas);
          }
          */
          if (i > 2) {
            final prevR = Polygon([nodes[i - 2], nodes[i - 1]]);
            final r = Polygon(
              [nodes[i - 1], nodes[i]],
              previousPoints: [prevR.points[1], prevR.points[2]],
              fillColor: nodes[i].color,
              strokeColor: nodes[i].strokeColor,
            );
            r.draw(canvas);
          }
        }
      },
    );
  }

  @override
  bool shouldRepaint(BackgroundPainter oldDelegate) => true;
}

class Appbar extends StatefulWidget {
  final GraphController controller;

  const Appbar({Key key, this.controller}) : super(key: key);

  @override
  _AppbarState createState() => _AppbarState();
}

class _AppbarState extends State<Appbar> {
  void _openDrawer() {
    Scaffold.of(context).openEndDrawer();
  }

  @override
  Widget build(BuildContext context) {
    final isMobileScreen = MediaQuery.of(context).size.width <= 900;
    final controller = widget.controller;
    return StreamBuilder<Config>(
      initialData: Config(),
      stream: controller.config$,
      builder: (c, snapshot) {
        final config = snapshot.data ?? Config();

        final luminance = config.backgroundColor.computeLuminance();
        final brightness = luminance > 0.5 ? Brightness.light : Brightness.dark;
        final iconColor =
            brightness == Brightness.light ? Colors.black54 : Colors.white54;
        return Container(
          color: Colors.black12,
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(10),
                child: Text('AlGrafx', style: TextStyle(color: iconColor)),
              ),
              SettingsBar(
                direction: Axis.horizontal,
                config: config,
                controller: controller,
              ),
              if (isMobileScreen)
                IconButton(
                  icon: Icon(Icons.menu, color: iconColor),
                  onPressed: _openDrawer,
                ),
              if (!isMobileScreen)
                Row(
                  children: <Widget>[
                    Tooltip(
                      message: 'Undo',
                      child: IconButton(
                        icon: Icon(Icons.undo, color: iconColor),
                        onPressed: controller.undo,
                      ),
                    ),
                    Tooltip(
                      message: 'Clear',
                      child: IconButton(
                        icon: Icon(Icons.delete_forever, color: iconColor),
                        onPressed: controller.clear,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        );
      },
    );
  }
}

class ColorSelector extends StatefulWidget {
  final Color color;

  final String label;

  final Brightness brightness;

  final ValueChanged<Color> onColorSelection;
  final ValueChanged<Future<OverlayEntry>> onOpenOverlay;

  const ColorSelector({
    Key key,
    @required this.color,
    @required this.brightness,
    @required this.label,
    this.onColorSelection,
    this.onOpenOverlay,
  }) : super(key: key);

  @override
  _ColorSelectorState createState() => _ColorSelectorState();
}

class _ColorSelectorState extends State<ColorSelector> {
  Future<OverlayEntry> colorPicker;

  @override
  Widget build(BuildContext context) {
    final labelColor =
        widget.brightness == Brightness.light ? Colors.black54 : Colors.white54;
    return Row(
      children: <Widget>[
        Text(
          widget.label,
          style: TextStyle(color: labelColor.withOpacity(0.7)),
        ),
        if (widget.color != Colors.transparent)
          InkWell(
            onTap: () {
              if (colorPicker != null) {
                widget.onOpenOverlay(null);
                colorPicker = null;
                setState(() {});
              } else {
                colorPicker = _openColorPicker(context);
                widget.onOpenOverlay(colorPicker);
              }
            },
            child: Container(
              margin: EdgeInsets.all(8),
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                border: Border.all(color: labelColor, width: 2),
                color: widget.color,
              ),
            ),
          ),
      ],
    );
  }

  Future<OverlayEntry> _openColorPicker(BuildContext context) async {
    final renderer = context.findRenderObject() as RenderBox;
    final left =
        renderer.size.bottomLeft(renderer.localToGlobal(Offset.zero)).dx;

    OverlayState overlayState = Overlay.of(context);
    OverlayEntry overlayEntry;
    overlayEntry = OverlayEntry(
      builder: (_) => _buildColorPicker(
        context,
        left,
        MediaQuery.of(context).size.width,
        () => overlayEntry.remove(),
      ),
    );

    overlayState.insert(overlayEntry);
    return overlayEntry;
  }

  Widget _buildColorPicker(
    BuildContext context,
    double left,
    double width,
    VoidCallback onSelect,
  ) =>
      Positioned(
        top: 50.0,
        left: min(max(left - 80, 0), width - 200),
        child: _ColorPickerGrid(
          currentColor: widget.color,
          onSelect: () {
            onSelect();
            colorPicker = null;
            setState(() {});
          },
          onColorSelection: (c) {
            widget.onColorSelection(c);
            colorPicker = null;
            setState(() {});
          },
        ),
      );
}

class _ColorPickerGrid extends StatefulWidget {
  final ValueChanged<Color> onColorSelection;
  final VoidCallback onSelect;
  final Color currentColor;

  const _ColorPickerGrid({
    Key key,
    this.onColorSelection,
    this.onSelect,
    this.currentColor,
  }) : super(key: key);

  @override
  __ColorPickerGridState createState() => __ColorPickerGridState();
}

class __ColorPickerGridState extends State<_ColorPickerGrid> {
  Color currentColor;

  @override
  void initState() {
    currentColor = widget.currentColor;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      child: Material(
        color: Color(0x66333333),
        child: MouseRegion(
          onExit: (_) => widget.onSelect(),
          child: GridView.count(
            shrinkWrap: true,
            crossAxisCount: 6,
            children: [...Colors.primaries, Colors.white, Colors.black, fPurple]
                .map((c) => InkWell(
                      onTap: () {
                        widget.onSelect();
                        widget.onColorSelection(c);
                      },
                      child: Container(
                        margin: EdgeInsets.all(
                            c.value == currentColor.value ? 13 : 8),
                        width: c.value == currentColor.value ? 8 : 18,
                        height: c.value == currentColor.value ? 8 : 18,
                        color: c,
                      ),
                    ))
                .toList(),
          ),
        ),
      ),
    );
  }
}

class SettingsBar extends StatefulWidget {
  final Axis direction;
  final Config config;
  final GraphController controller;

  const SettingsBar(
      {Key key, this.direction = Axis.vertical, this.config, this.controller})
      : super(key: key);

  @override
  _SettingsBarState createState() => _SettingsBarState();
}

class _SettingsBarState extends State<SettingsBar> {
  OverlayEntry _currentEntry;

  @override
  void dispose() {
    if (_currentEntry != null) {
      _currentEntry.remove();
      _currentEntry = null;
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isMobileScreen = MediaQuery.of(context).size.width <= 900;
    final luminance = widget.config.backgroundColor.computeLuminance();
    final brightness = luminance > 0.5 ? Brightness.light : Brightness.dark;
    final labelStyle = TextStyle(
        color:
            brightness == Brightness.light ? Colors.black54 : Colors.white54);

    return Flex(
      direction: widget.direction,
      crossAxisAlignment: widget.direction == Axis.vertical
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.center,
      children: <Widget>[
        ColorSelector(
          color: widget.config.backgroundColor,
          brightness: brightness,
          label: 'Background',
          onColorSelection: (c) {
            _currentEntry = null;
            widget.controller.backgroundColor = c;
          },
          onOpenOverlay: (entry) => _updateEntry(entry),
        ),
        SizedBox(width: 10),
        ColorSelector(
          color: widget.config.fillColor,
          brightness: brightness,
          label: 'Fill',
          onColorSelection: (c) {
            _currentEntry = null;
            widget.controller.fillColor = c;
          },
          onOpenOverlay: (entry) => _updateEntry(entry),
        ),
        if (!isMobileScreen) ...[
          Row(
            children: <Widget>[
              SizedBox(width: 10),
              Switch(
                value: widget.config.strokeColor != Colors.transparent,
                onChanged: (value) => widget.controller.strokeColor =
                    value ? Colors.black54 : Colors.transparent,
                activeColor: Colors.cyan,
                inactiveThumbColor: Colors.white,
                activeTrackColor: Colors.cyan.shade800,
                inactiveTrackColor: Colors.grey.shade700,
              ),
              ColorSelector(
                color: widget.config.strokeColor,
                brightness: brightness,
                label: isMobileScreen ? '' : 'Stroke',
                onColorSelection: (c) {
                  _currentEntry = null;
                  widget.controller.strokeColor = c;
                },
                onOpenOverlay: (entry) => _updateEntry(entry),
              ),
            ],
          ),
          const SizedBox(width: 15),
          Row(
            children: <Widget>[
              Text('Force', style: labelStyle),
              Switch(
                value: widget.config.applyForce,
                onChanged: (value) {
                  if (!value) _showNoForceOverlay();
                  widget.controller.applyForce = value;
                },
                activeColor: Colors.cyan,
                inactiveThumbColor: Colors.white,
                activeTrackColor: Colors.cyan.shade800,
                inactiveTrackColor: Colors.grey.shade700,
              ),
            ],
          ),
          const SizedBox(width: 15),
          Row(
            children: <Widget>[
              Text('Dynamic color', style: labelStyle),
              Switch(
                value: widget.config.liveColor,
                onChanged: (value) => widget.controller.liveColor = value,
                activeColor: Colors.cyan,
                inactiveThumbColor: Colors.white,
                activeTrackColor: Colors.cyan.shade800,
                inactiveTrackColor: Colors.grey.shade700,
              ),
            ],
          ),
        ]
      ],
    );
  }

  void _showNoForceOverlay() {
    OverlayState overlayState = Overlay.of(context);
    OverlayEntry overlayEntry;
    overlayEntry = OverlayEntry(
      builder: (_) => Center(
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(12),
            color: Color(0x66000000),
            width: 200,
            child: Text(
              'Click to draw',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
      ),
    );
    Future.delayed(Duration(seconds: 3), () => overlayEntry.remove());

    overlayState.insert(overlayEntry);
  }

  void _updateEntry(Future<OverlayEntry> entry) async {
    _clearOverlay();
    if (entry != null) _currentEntry = await entry;

    setState(() {});
  }

  void _clearOverlay() {
    print('_AppbarState._clearOverlay... $_currentEntry');
    if (_currentEntry != null) {
      _currentEntry.remove();
      _currentEntry = null;
    }
  }
}

class SettingsDrawer extends StatelessWidget {
  final GraphController controller;

  final Color iconColor;

  const SettingsDrawer({Key key, this.controller, this.iconColor})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: <Widget>[
            Align(
              alignment: Alignment.topRight,
              child: IconButton(
                icon: Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            StreamBuilder<bool>(
                initialData: true,
                stream: controller.config$
                    .map((c) => c.strokeColor != Colors.transparent),
                builder: (context, snapshot) {
                  return Column(
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text('Stroke'),
                          Switch(
                            value: controller.config.strokeColor !=
                                Colors.transparent,
                            onChanged: (value) => controller.strokeColor =
                                value ? Colors.black54 : Colors.transparent,
                            activeColor: Colors.cyan,
                            inactiveThumbColor: Colors.white,
                            activeTrackColor: Colors.cyan.shade800,
                            inactiveTrackColor: Colors.grey.shade700,
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text('Force' /*, style: labelStyle*/),
                          Switch(
                            value: controller.config.applyForce,
                            onChanged: (value) => controller.applyForce = value,
                            activeColor: Colors.cyan,
                            inactiveThumbColor: Colors.white,
                            activeTrackColor: Colors.cyan.shade800,
                            inactiveTrackColor: Colors.grey.shade700,
                          ),
                        ],
                      ),
                      const SizedBox(width: 15),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text('Dynamic color' /*, style: labelStyle*/),
                          Switch(
                            value: controller.config.liveColor,
                            onChanged: (value) => controller.liveColor = value,
                            activeColor: Colors.cyan,
                            inactiveThumbColor: Colors.white,
                            activeTrackColor: Colors.cyan.shade800,
                            inactiveTrackColor: Colors.grey.shade700,
                          ),
                        ],
                      ),
                    ],
                  );
                }),
            FlatButton.icon(
              label: Text('Undo'),
              icon: Icon(Icons.undo, color: iconColor),
              onPressed: controller.undo,
            ),
            FlatButton.icon(
              label: Text('Clear'),
              icon: Icon(Icons.delete_forever, color: iconColor),
              onPressed: controller.clear,
            ),
          ],
        ),
      ),
    );
  }
}
