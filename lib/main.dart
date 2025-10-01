import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

void main() => runApp(const MyApp());

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isDarkMode = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fading Text Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: FadingTextAnimation(
        isDark: _isDarkMode,
        toggleTheme: () => setState(() => _isDarkMode = !_isDarkMode),
      ),
    );
  }
}

class FadingTextAnimation extends StatefulWidget {
  final VoidCallback toggleTheme;
  final bool isDark;

  const FadingTextAnimation({
    super.key,
    required this.toggleTheme,
    required this.isDark,
  });

  @override
  State<FadingTextAnimation> createState() => _FadingTextAnimationState();
}

class _FadingTextAnimationState extends State<FadingTextAnimation> {
  final PageController _pageController = PageController();
  int _pageIndex = 0;

  // one visibility flag per page
  final List<bool> _isVisible = [true, true];

  Color _textColor = Colors.blue;
  bool _showFrame = false;

  // custom image (only one now)
  // custom image (only one now)
  final String _customImage = "assets/salaar.jpg";

  Duration _durationFor(int page) =>
      (page == 0) ? const Duration(seconds: 1) : const Duration(seconds: 3);

  Curve _curveFor(int page) =>
      (page == 0) ? Curves.easeInOut : Curves.easeInOutCubic;

  void _toggleVisibilityForCurrentPage() {
    setState(() {
      _isVisible[_pageIndex] = !_isVisible[_pageIndex];
    });
  }

  void _openColorPicker() {
    Color tempColor = _textColor;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text('Pick Text Color'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Preview',
                      style: TextStyle(fontSize: 18, color: tempColor),
                    ),
                    const SizedBox(height: 12),
                    BlockPicker(
                      pickerColor: tempColor,
                      onColorChanged: (c) =>
                          setStateDialog(() => tempColor = c),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() => _textColor = tempColor);
                    Navigator.pop(context);
                  },
                  child: const Text('Apply'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Widget _pageIndicator() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(2, (i) {
        final selected = i == _pageIndex;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: selected ? 14 : 8,
          height: 8,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: selected
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).disabledColor,
          ),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final iconColor = Theme.of(context).appBarTheme.iconTheme?.color;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Fading Text Animation'),
        actions: [
          IconButton(
            icon: Icon(
              widget.isDark ? Icons.wb_sunny : Icons.nightlight_round,
              color: iconColor,
            ),
            onPressed: widget.toggleTheme,
            tooltip: 'Toggle theme',
          ),
          IconButton(
            icon: Icon(Icons.color_lens, color: iconColor),
            onPressed: _openColorPicker,
            tooltip: 'Pick text color',
          ),
        ],
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(36),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: _pageIndicator(),
          ),
        ),
      ),
      body: PageView(
        controller: _pageController,
        onPageChanged: (idx) => setState(() => _pageIndex = idx),
        children: [
          _buildFadePage(
            page: 0,
            text: 'Hello, Flutter!',
            textStyle: TextStyle(fontSize: 26, color: _textColor),
            imageWidth: 150,
          ),
          _buildFadePage(
            page: 1,
            text: 'Different Fade Duration!',
            textStyle: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              color: _textColor,
            ),
            imageWidth: 200,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _toggleVisibilityForCurrentPage,
        child: Icon(_isVisible[_pageIndex] ? Icons.pause : Icons.play_arrow),
        tooltip: _isVisible[_pageIndex]
            ? 'Pause (hide text)'
            : 'Play (show text)',
      ),
    );
  }

  Widget _buildFadePage({
    required int page,
    required String text,
    required TextStyle textStyle,
    double imageWidth = 160,
  }) {
    final visible = _isVisible[page];
    final duration = _durationFor(page);
    final curve = _curveFor(page);

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () => setState(() => _isVisible[page] = !_isVisible[page]),
              child: AnimatedOpacity(
                opacity: visible ? 1.0 : 0.0,
                duration: duration,
                curve: curve,
                child: Text(text, style: textStyle),
              ),
            ),
            const SizedBox(height: 24),
            if (page == 0)
              SwitchListTile(
                title: const Text('Show Frame Around Image'),
                value: _showFrame,
                onChanged: (val) => setState(() => _showFrame = val),
              ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 400),
              decoration: _showFrame
                  ? BoxDecoration(
                      border: Border.all(color: Colors.red, width: 3),
                      borderRadius: BorderRadius.circular(20),
                    )
                  : null,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.asset(
                  _customImage, // ✅ only one custom image (cat.jpg)
                  width: imageWidth,
                  height: imageWidth,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Page ${page + 1} • tap text to toggle fade • FAB toggles current page',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
