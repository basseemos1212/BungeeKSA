
class OnboardingStep {
  final String image;
  final String title;
  final String description;

  OnboardingStep({
    required this.image,
    required this.title,
    required this.description,
  });
}

final List<OnboardingStep> onboardingSteps = [
  OnboardingStep(
    image: 'assets/images/step1.png',
    title: 'See Classes',
    description: 'Browse and explore the available classes to find the best fit.',
  ),
  OnboardingStep(
    image: 'assets/images/step2.png',
    title: 'Book Your Class',
    description: 'Easily book a class that fits your schedule in just a few taps.',
  ),
  OnboardingStep(
    image: 'assets/images/step3.png',
    title: 'Scan Your Barcode',
    description: 'Arrive at the center, scan the barcode, and get ready to train!',
  ),
  OnboardingStep(
    image: 'assets/images/step4.png',
    title: 'Train & Enjoy',
    description: 'Train with the best, enjoy the experience, and reach your goals!',
  ),
];
