import 'package:flutter/material.dart';

class CreditsScreen extends StatefulWidget {
  @override
  _CreditsScreenState createState() => _CreditsScreenState();
}

class _CreditsScreenState extends State<CreditsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _leftToRightAnimation;
  late Animation<Offset> _rightToLeftAnimation;

  @override
  void initState() {
    super.initState();

    // Set up animation controller
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    // Set up left to right animation
    _leftToRightAnimation = Tween<Offset>(
      begin: const Offset(-10.0, 0.0),
      end: const Offset(0.0, 0.0),
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 1.0, curve: Curves.easeIn),
      ),
    );

    // Set up right to left animation
    _rightToLeftAnimation = Tween<Offset>(
      begin: const Offset(10.0, 0.0),
      end: const Offset(0.0, 0.0),
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 1.0, curve: Curves.easeIn),
      ),
    );

    // Start the animation
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'The Developers',
          style: TextStyle(color: Theme.of(context).primaryColor),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        shadowColor: Colors.white,
        iconTheme: IconThemeData(
          color: Theme.of(context).primaryColor,
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Credits To The Following Developers: ', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 40),
            SlideTransition(
              position: _leftToRightAnimation,
              child: const Text('Joana Marie B. Mejias', style: TextStyle(fontSize: 18)),
            ),
            const SizedBox(height: 20),
            SlideTransition(
              position: _rightToLeftAnimation,
              child: const Text(
                'Christian Nikko P. Torremocha', style: TextStyle(fontSize: 18),
              ),
            ),
            const SizedBox(height: 20),
            SlideTransition(
              position: _leftToRightAnimation,
              child: const Text('Ydelle T. Logroño', style: TextStyle(fontSize: 18)),
            ),
            const SizedBox(height: 20),
            SlideTransition(
              position: _rightToLeftAnimation,
              child: const Text(
                'Jenel S. Bautista', style: TextStyle(fontSize: 18),
              ),
            ),
        ],
        ),
      )
    );
  }
}
