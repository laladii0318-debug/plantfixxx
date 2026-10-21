
import 'package:flutter/material.dart';
import 'login_screen.dart';
class OnboardingScreen extends StatefulWidget {
const OnboardingScreen({super.key});

@override
State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
final PageController _pageController = PageController();

int _currentPage = 0;

final List<Map<String, String>> _pages = [
{
'image': 'assets/images/onboardpic1.jpeg',
'title': 'Welcome to PlantFix',
'description':
'Your smart AI-powered crop doctor that helps you understand and protect your crops.',
},
{
'image': 'assets/images/onboardpic2.jpeg',
'title': 'Detect Crop Diseases',
'description':
'Take a photo of your crop and let AI help identify possible diseases quickly.',
},
{
'image': 'assets/images/onboardpic3.jpeg',
'title': 'Scan your crop',
'description':
'Get helpful treatment and prevention guidance to keep your crops healthy.',
},
];

@override
void dispose() {
_pageController.dispose();
super.dispose();
}

void _nextPage() {
  if (_currentPage < _pages.length - 1) {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  } else {
    Navigator
        .
    pushReplacement
      (
      context
      ,
      MaterialPageRoute
        (
        builder
            :
            (context) =>
        const
        LoginScreen
          (
        )
        ,
      )
      ,
    );
  }
}

@override
Widget build(BuildContext context) {
return Scaffold(
body: SafeArea(
child: Column(
children: [
Expanded(
child: PageView.builder(
controller: _pageController,
itemCount: _pages.length,
onPageChanged: (index) {
setState(() {
_currentPage = index;
});
},
itemBuilder: (context, index) {
final page = _pages[index];

return Padding(
padding: const EdgeInsets.symmetric(horizontal: 24),
child: Column(
mainAxisAlignment: MainAxisAlignment.center,
children: [
Image.asset(
page['image']!,
height: 280,
width: double.infinity,
fit: BoxFit.contain,
),

const SizedBox(height: 40),

Text(
page['title']!,
textAlign: TextAlign.center,
style: const TextStyle(
fontSize: 30,
fontWeight: FontWeight.bold,
),
),

const SizedBox(height: 16),

Text(
page['description']!,
textAlign: TextAlign.center,
style: TextStyle(
fontSize: 17,
height: 1.5,
color: Colors.grey.shade600,
),
),
],
),
);
},
),
),

Row(
mainAxisAlignment: MainAxisAlignment.center,
children: List.generate(
_pages.length,
(index) => AnimatedContainer(
duration: const Duration(milliseconds: 300),
margin: const EdgeInsets.symmetric(horizontal: 4),
height: 8,
width: _currentPage == index ? 24 : 8,
decoration: BoxDecoration(
color: _currentPage == index
? Colors.green
    : Colors.grey.shade300,
borderRadius: BorderRadius.circular(10),
),
),
),
),

const SizedBox(height: 30),

Padding(
padding: const EdgeInsets.symmetric(horizontal: 24),
child: SizedBox(
width: double.infinity,
height: 55,
child: ElevatedButton(
onPressed: _nextPage,
child: Text(
_currentPage == _pages.length - 1
? 'Get Started'
    : 'Next',
style: const TextStyle(
fontSize: 18,
fontWeight: FontWeight.w600,
),
),
),
),
),

const SizedBox(height: 24),
],
),
),
);
}
}

