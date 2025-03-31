import 'package:flutter/material.dart';
import 'dart:async';

class ThemedScaffold extends StatefulWidget {
  final Widget? body;
  final PreferredSizeWidget? appBar;
  final Widget? floatingActionButton;
  final Widget? drawer;
  final Widget? bottomNavigationBar;
  final String? title;
  final Widget? child;

  const ThemedScaffold({
    this.body,
    this.appBar,
    this.floatingActionButton,
    this.drawer,
    this.bottomNavigationBar,
    this.child,
    this.title,
    super.key,
  });

  @override
  _ThemedScaffoldState createState() => _ThemedScaffoldState();
}

class _ThemedScaffoldState extends State<ThemedScaffold> {
  int _currentIndex = 0;
  final List<String> images = [
    'assets/image1.jpg',
    'assets/image2.jpg',
    'assets/image3.jpg',
    'assets/image4.jpg',
    'assets/image5.jpg',
  ];

  Timer? _timer; // Store the timer reference

  @override
  void initState() {
    super.initState();
    _startSlideshow();
  }

  void _startSlideshow() {
    _timer?.cancel(); // Cancel any existing timer before starting a new one
    _timer = Timer.periodic(const Duration(seconds: 5), (Timer timer) {
      if (!mounted) {
        timer.cancel(); // Ensure the timer stops if the widget is no longer in the tree
        return;
      }
      setState(() {
        _currentIndex = (_currentIndex + 1) % images.length;
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel(); // Cancel the timer to prevent calling setState() after dispose
    _timer = null; // Remove the reference to avoid potential memory leaks
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.appBar, // Optional AppBar
      body: Stack(
        children: [
          // Full-screen Slideshow
          Positioned.fill(
            child: AnimatedSwitcher(
              duration: const Duration(seconds: 1),
              child: Image.asset(
                images[_currentIndex],
                key: ValueKey<String>(images[_currentIndex]),
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
              ),
            ),
          ),

          // Gradient Overlay
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.blue.shade900.withOpacity(0.9),
                    Colors.purple.shade600.withOpacity(0.8),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),

          // Page Content
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.title != null) //  Title is optional
                Center(
                  child: Text(
                    widget.title!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              if (widget.title != null) const SizedBox(height: 20), // Adds spacing only if title exists
              Expanded(child: widget.child ?? widget.body ?? Container()), //  Optional child/body
            ],
          ),
        ],
      ),
      floatingActionButton: widget.floatingActionButton, // Optional FAB
      drawer: widget.drawer, // Optional Drawer
      bottomNavigationBar: widget.bottomNavigationBar, // Optional Bottom Nav Bar
    );
  }
}
