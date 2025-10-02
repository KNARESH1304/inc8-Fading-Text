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
      title: 'Fading Text Animation',
      debugShowCheckedModeBanner: false,
      theme: _buildLightTheme(),
      darkTheme: _buildDarkTheme(),
      themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: FadingTextAnimation(
        isDark: _isDarkMode,
        toggleTheme: () => setState(() => _isDarkMode = !_isDarkMode),
      ),
    );
  }

  ThemeData _buildLightTheme() {
    return ThemeData(
      brightness: Brightness.light,
      primarySwatch: Colors.blue,
      useMaterial3: true,
    );
  }

  ThemeData _buildDarkTheme() {
    return ThemeData(
      brightness: Brightness.dark,
      primarySwatch: Colors.blue,
      useMaterial3: true,
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

  final List<bool> _isVisible = [true, true];
  Color _textColor = Colors.blue;
  bool _showFrame = false;
  bool _isRotating = false;
  bool _isImageVisible = true;

  final String _customImage = "assets/salaar.jpg";

  Duration _durationFor(int page) =>
      (page == 0) ? const Duration(seconds: 1) : const Duration(seconds: 3);

  Curve _curveFor(int page) =>
      (page == 0) ? Curves.easeInOut : Curves.easeInOutCubicEmphasized;

  void _toggleVisibilityForCurrentPage() {
    setState(() {
      _isVisible[_pageIndex] = !_isVisible[_pageIndex];
    });
  }

  void _toggleRotation() {
    setState(() {
      _isRotating = !_isRotating;
    });
  }

  void _toggleImageVisibility() {
    setState(() {
      _isImageVisible = !_isImageVisible;
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
              title: const Text(
                'Choose Text Color',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        // FIXED: Use theme-aware color
                        color: Theme.of(context).colorScheme.surfaceVariant,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Preview Text',
                        style: TextStyle(
                          fontSize: 20,
                          color: tempColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    BlockPicker(
                      pickerColor: tempColor,
                      onColorChanged: (c) => setStateDialog(() => tempColor = c),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Color applies to all pages',
                      textAlign: TextAlign.center,
                      // FIXED: Use theme-aware text color
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
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
                  child: const Text('Apply Color'),
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        // FIXED: Use theme-aware background color
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.7),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(2, (i) {
          final selected = i == _pageIndex;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: selected ? 20 : 8,
            height: 8,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              // FIXED: Use theme-aware colors
              color: selected 
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.outline.withOpacity(0.5),
            ),
          );
        }),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fading Text Animation'),
        actions: [
          IconButton(
            icon: Icon(widget.isDark ? Icons.wb_sunny : Icons.nightlight_round),
            onPressed: widget.toggleTheme,
            tooltip: 'Toggle theme',
          ),
          IconButton(
            icon: const Icon(Icons.color_lens),
            onPressed: _openColorPicker,
            tooltip: 'Pick text color',
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 16),
          _pageIndicator(),
          const SizedBox(height: 8),
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (idx) => setState(() => _pageIndex = idx),
              children: [
                _buildFadePage(
                  page: 0,
                  text: 'Hello, Flutter! 🚀',
                  textStyle: TextStyle(
                    fontSize: 28,
                    color: _textColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                _buildFadePage(
                  page: 1,
                  text: 'Smooth Animations! ✨',
                  textStyle: TextStyle(
                    fontSize: 32,
                    color: _textColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (_pageIndex == 0) ...[
            FloatingActionButton.small(
              onPressed: _toggleRotation,
              heroTag: 'rotate',
              child: Icon(_isRotating ? Icons.stop : Icons.rotate_right),
            ),
            const SizedBox(height: 12),
            FloatingActionButton.small(
              onPressed: _toggleImageVisibility,
              heroTag: 'image',
              child: Icon(_isImageVisible ? Icons.visibility_off : Icons.visibility),
            ),
            const SizedBox(height: 12),
          ],
          FloatingActionButton(
            onPressed: _toggleVisibilityForCurrentPage,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Icon(
                _isVisible[_pageIndex] ? Icons.visibility_off : Icons.visibility,
                key: ValueKey(_isVisible[_pageIndex]),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFadePage({
    required int page,
    required String text,
    required TextStyle textStyle,
  }) {
    final visible = _isVisible[page];
    final duration = _durationFor(page);
    final curve = _curveFor(page);

    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Animated Text with Gesture Detector
          GestureDetector(
            onTap: () => setState(() => _isVisible[page] = !_isVisible[page]),
            child: AnimatedOpacity(
              opacity: visible ? 1.0 : 0.0,
              duration: duration,
              curve: curve,
              child: Text(
                text,
                style: textStyle,
                textAlign: TextAlign.center,
              ),
            ),
          ),
          
          const SizedBox(height: 32),
          
          // Image Section with Controls
          Card(
            elevation: 4,
            child: Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  if (page == 0) ...[
                    SwitchListTile(
                      title: Text(
                        'Show Frame Around Image',
                        // FIXED: Use theme-aware text color
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      value: _showFrame,
                      onChanged: (val) => setState(() => _showFrame = val),
                    ),
                    const SizedBox(height: 8),
                  ],
                  
                  // Animated Image Container with Frame Toggle
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 500),
                    decoration: _showFrame
                        ? BoxDecoration(
                            border: Border.all(
                              // FIXED: Use theme-aware primary color
                              color: Theme.of(context).colorScheme.primary,
                              width: 3,
                            ),
                            borderRadius: BorderRadius.circular(20),
                          )
                        : null,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(_showFrame ? 20 : 12),
                      child: AnimatedRotation(
                        turns: _isRotating ? 1 : 0,
                        duration: const Duration(seconds: 2),
                        curve: Curves.easeInOut,
                        child: AnimatedOpacity(
                          opacity: _isImageVisible ? 1.0 : 0.0,
                          duration: const Duration(milliseconds: 500),
                          child: Image.asset(
                            _customImage,
                            width: 200,
                            height: 200,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: 200,
                                height: 200,
                                // FIXED: Use theme-aware background color
                                color: Theme.of(context).colorScheme.surfaceVariant,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.image, 
                                      size: 50, 
                                      // FIXED: Use theme-aware icon color
                                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      'Add image to\nassets/salaar.jpg',
                                      textAlign: TextAlign.center,
                                      // FIXED: Use theme-aware text color
                                      style: TextStyle(
                                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Page Info
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              // FIXED: Use theme-aware background color
              color: Theme.of(context).colorScheme.surfaceVariant,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Text(
                  'Page ${page + 1}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    // FIXED: Use theme-aware primary color
                    color: Theme.of(context).colorScheme.primary,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Duration: ${duration.inSeconds}s • Tap text to toggle',
                  textAlign: TextAlign.center,
                  // FIXED: Use theme-aware text color
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                if (page == 0) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Use switches for frame & rotation',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      // FIXED: Use theme-aware text color
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}