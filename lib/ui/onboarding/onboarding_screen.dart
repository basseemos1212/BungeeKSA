import 'package:flutter/material.dart';
import '../widgets/onboarding_content.dart';
import 'onboarding_step.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize the fade animation controller
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    // Initialize the scale animation controller
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    // Define the fade animation (opacity transition)
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    // Define the scale animation (slight zoom-in)
    _scaleAnimation = Tween<double>(begin: 0.9, end: 1.0).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeInOut,
    ));

    // Start the animations
    _fadeController.forward();
    _scaleController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface, // Use theme background
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
                _fadeController.reset();
                _scaleController.reset();
                _fadeController.forward(); // Trigger fade animation when page changes
                _scaleController.forward(); // Trigger scale animation when page changes
              });
            },
            itemCount: onboardingSteps.length,
            itemBuilder: (context, index) => FadeTransition(
              opacity: _fadeAnimation, // Fade animation
              child: ScaleTransition(
                scale: _scaleAnimation, // Scale animation
                child: OnboardingContent(
                  image: onboardingSteps[index].image,
                  title: onboardingSteps[index].title,
                  description: onboardingSteps[index].description,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 80,
            left: 0,
            right: 0,
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  onboardingSteps.length,
                  (index) => buildDot(index),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 20,
            right: 20,
            child: TextButton(
              onPressed: () {
                if (_currentPage == onboardingSteps.length - 1) {
                  // Navigate to the main screen after onboarding
                  Navigator.pushReplacementNamed(context, '/home');
                } else {
                  _pageController.nextPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                }
              },
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: Text(
                  _currentPage == onboardingSteps.length - 1 ? "Get Started" : "Next",
                  key: ValueKey(_currentPage),
                  style: TextStyle(
                    fontSize: 18,
                    color: Theme.of(context).colorScheme.primary, // Use theme primary color
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildDot(int index) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: 10,
      width: _currentPage == index ? 20 : 10,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: _currentPage == index
            ? Theme.of(context).colorScheme.primary // Active dot color from theme
            : Colors.grey[400],
        borderRadius: BorderRadius.circular(5),
      ),
    );
  }
}
