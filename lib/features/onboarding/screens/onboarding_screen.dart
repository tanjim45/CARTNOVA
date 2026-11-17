
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<_OnboardingData> _pages = [
    _OnboardingData(
      title: 'Discover Amazing Products',
      description:
          'Explore thousands of products and find everything you need in one place.',
      icon: Icons.shopping_bag_rounded,
      color: const Color(0xFF6C4CEB),
    ),
    _OnboardingData(
      title: 'Easy & Secure Shopping',
      description:
          'Enjoy a smooth shopping experience with a simple and convenient checkout.',
      icon: Icons.local_shipping_rounded,
      color: const Color(0xFF168B9B),
    ),
    _OnboardingData(
      title: 'Everything You Love',
      description:
          'Save your favorite products and keep track of your orders anytime.',
      icon: Icons.favorite_rounded,
      color: const Color(0xFFE85D91),
    ),
  ];

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    } else {
      context.goNamed('login');
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => context.goNamed('login'),
                child: Text(
                  'Skip',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                itemBuilder: (context, index) {
                  final page = _pages[index];

                  return LayoutBuilder(
                    builder: (context, constraints) {
                      final illustrationHeight =
                          constraints.maxHeight * 0.48;

                      return SingleChildScrollView(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minHeight: constraints.maxHeight,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 28,
                              vertical: 12,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  height: illustrationHeight.clamp(200.0, 340.0),
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: page.color.withValues(alpha: 0.10),
                                    borderRadius: BorderRadius.circular(36),
                                  ),
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      Container(
                                        height: 190,
                                        width: 190,
                                        decoration: BoxDecoration(
                                          color: page.color.withValues(alpha: 0.12),
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      Container(
                                        height: 145,
                                        width: 145,
                                        decoration: BoxDecoration(
                                          color: page.color,
                                          borderRadius: BorderRadius.circular(42),
                                          boxShadow: [
                                            BoxShadow(
                                              color: page.color.withValues(
                                                alpha: 0.25,
                                              ),
                                              blurRadius: 30,
                                              offset: const Offset(0, 14),
                                            ),
                                          ],
                                        ),
                                        child: Icon(
                                          page.icon,
                                          size: 76,
                                          color: Colors.white,
                                        ),
                                      ),
                                      Positioned(
                                        top: 35,
                                        right: 35,
                                        child: Icon(
                                          Icons.auto_awesome_rounded,
                                          color: page.color,
                                          size: 34,
                                        ),
                                      ),
                                      Positioned(
                                        bottom: 35,
                                        left: 35,
                                        child: Icon(
                                          Icons.circle,
                                          color: page.color.withValues(
                                            alpha: 0.35,
                                          ),
                                          size: 22,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 38),
                                Text(
                                  page.title,
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.inter(
                                    fontSize: 25,
                                    fontWeight: FontWeight.w800,
                                    height: 1.3,
                                    color: theme.colorScheme.onSurface,
                                  ),
                                ),
                                const SizedBox(height: 14),
                                Text(
                                  page.description,
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    height: 1.7,
                                    color: theme.colorScheme.onSurface
                                        .withValues(alpha: 0.65),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(28, 12, 28, 28),
              child: Row(
                children: [
                  Row(
                    children: List.generate(
                      _pages.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        margin: const EdgeInsets.only(right: 7),
                        height: 8,
                        width: _currentPage == index ? 26 : 8,
                        decoration: BoxDecoration(
                          color: _currentPage == index
                              ? theme.colorScheme.primary
                              : theme.colorScheme.primary.withValues(
                                  alpha: 0.22,
                                ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                  ),
                  const Spacer(),
                  SizedBox(
                    height: 54,
                    child: FilledButton(
                      onPressed: _nextPage,
                      style: FilledButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        padding: const EdgeInsets.symmetric(horizontal: 26),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(17),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _currentPage == _pages.length - 1
                                ? 'Get Started'
                                : 'Continue',
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(width: 9),
                          const Icon(Icons.arrow_forward_rounded, size: 19),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingData {
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  const _OnboardingData({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });
}
