import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'login_page.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    const double maxWebWidth = 1920.0;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: kIsWeb
          ? AppBar(
        backgroundColor: const Color(0xFFC6C9FC),
        title: Padding(
          padding: const EdgeInsets.only(top: 16.0, left: 16.0),
          child: Image.asset('assets/logo.png', height: 48),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: TextButton(
              onPressed: () {
                showDialog(
                  context: context,
                  barrierColor: const Color.fromARGB(255, 230, 225, 225),
                  builder: (context) => const LoginScreen(),
                );
              },
              child: const Row(
                children: [
                  Text(
                    'Войти',
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w600,
                      fontSize: 18,
                      color: Color(0xFF213A8B),
                    ),
                  ),
                  SizedBox(width: 8),
                  Icon(
                    Icons.person,
                    color: Color(0xFF213A8B),
                    size: 24,
                  ),
                ],
              ),
            ),
          ),
        ],
        elevation: 0,
        toolbarHeight: 72,
      )
          : AppBar(
        backgroundColor: const Color(0xFFC6C9FC),
        leadingWidth: 200,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16.0, top: 18.0, bottom: 6.0), // Adjusted for alignment
          child: Image.asset('assets/logo.png', height: 56),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20.0, top: 12.0),
            child: TextButton(
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              onPressed: () {
                showDialog(
                  context: context,
                  barrierColor: const Color.fromARGB(255, 230, 225, 225),
                  builder: (context) => const LoginScreen(),
                );
              },
              child: const Row(
                children: [
                  Text(
                    'Войти',
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      height: 1.0,
                      letterSpacing: 0,
                      color: Color(0xFF213A8B),
                    ),
                  ),
                  SizedBox(width: 4),
                  Icon(
                    Icons.person,
                    color: Color(0xFF213A8B),
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: kIsWeb
          ? Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: maxWebWidth),
          child: _buildWebBody(context),
        ),
      )
          : _buildMobileBody(context),
      bottomNavigationBar: kIsWeb ? null : _buildBottomNavigationBar(context),
    );
  }

  Widget _buildWebBody(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              ClipPath(
                clipper: SmileClipper(),
                child: Container(
                  width: double.infinity,
                  color: const Color(0xFFC6C9FC),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 48.0,
                    vertical: 24.0,
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Загружайте чеки — получайте\nперсональные кешбэки и скидки.\nМы подскажем, где выгоднее.',
                                  style: TextStyle(
                                    fontFamily: 'Montserrat',
                                    fontWeight: FontWeight.w600,
                                    fontSize: 20,
                                    height: 1.4,
                                    letterSpacing: 0,
                                    color: Color(0xFF213A8B),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Image.asset(
                            'assets/banner.png',
                            width: 480,
                            height: 288,
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: () {},
                        child: const Text(
                          'Наши партнеры',
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.w500,
                            fontSize: 18,
                            height: 1.0,
                            letterSpacing: 0,
                            color: Color(0xFF213A8B),
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () {},
                        child: const Text(
                          'Все',
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.w400,
                            fontSize: 16,
                            height: 1.0,
                            letterSpacing: 0,
                            color: Color(0x80000000),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildPartnerBlock(
                          image: 'assets/halva.png',
                          text: 'METRO с ХАЛВОЙ\nРассрочка от 10 месяцев с подпиской',
                          isWeb: true,
                          textPosition: 'bottom',
                        ),
                        _buildPartnerBlock(
                          image: 'assets/almaz.png',
                          text: '12 месяцев рассрочки\nна покупку в категории «Ювелирные изделия»',
                          isWeb: true,
                          textPosition: 'bottom',
                        ),
                        _buildPartnerBlock(
                          image: 'assets/halva.png',
                          text: 'METRO с ХАЛВОЙ\nРассрочка от 10 месяцев с подпиской',
                          isWeb: true,
                          textPosition: 'bottom',
                        ),
                        _buildPartnerBlock(
                          image: 'assets/halva.png',
                          text: 'METRO с ХАЛВОЙ\nРассрочка от 10 месяцев с подпиской',
                          isWeb: true,
                          textPosition: 'bottom',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomLeft,
            child: Padding(
              padding: const EdgeInsets.only(left: 24.0, bottom: 24.0, top: 24.0),
              child: Image.asset(
                'assets/logo.png',
                width: 120,
                height: 64,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileBody(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          ClipPath(
            clipper: SmileClipper(),
            child: Container(
              color: const Color(0xFFC6C9FC),
              padding: const EdgeInsets.only(bottom: 48.0, top: 24.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 20.0),
                          child: const Text(
                            'Загружай чеки и получай\nперсональные предложения.\nМы подскажем,\nгде выгоднее!',
                            style: TextStyle(
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.w600,
                              fontSize: 18,
                              height: 1.2,
                              letterSpacing: 0,
                              color: Color(0xFF213A8B),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 16.0),
                        child: Image.asset(
                          'assets/banner.png',
                          width: 190,
                          height: 150,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 16.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: () {},
                        child: const Text(
                          'Наши партнеры',
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                            height: 1.0,
                            letterSpacing: 0,
                            color: Color(0xFF213A8B),
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () {},
                        child: const Text(
                          'Все',
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.w400,
                            fontSize: 14,
                            height: 1.0,
                            letterSpacing: 0,
                            color: Color(0x80000000),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildPartnerBlock(
                          image: 'assets/image1.png',
                          text: 'Онлайн:\nскидка 5%',
                          isWeb: false,
                        ),
                        _buildPartnerBlock(
                          image: 'assets/image2.png',
                          text: 'Мегафон:\nскидка',
                          isWeb: false,
                        ),
                        _buildPartnerBlock(
                          image: 'assets/image3.png',
                          text: 'Lady Sharm:\nкэшбэк 20%',
                          isWeb: false,
                          textPosition: 'bottom',
                        ),
                        _buildPartnerBlock(
                          image: 'assets/image2.png',
                          text: 'Мегафон:\nскидка',
                          isWeb: false,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 0),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    height: 120,
                    decoration: const BoxDecoration(
                      borderRadius:
                      BorderRadius.vertical(top: Radius.circular(12)),
                      image: DecorationImage(
                        image: AssetImage('assets/cashback.png'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16.0),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                      BorderRadius.vertical(bottom: Radius.circular(12)),
                    ),
                    child: const Text(
                      'Кэшбек-мания',
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                        height: 1.0,
                        letterSpacing: 0,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPartnerBlock({
    required String image,
    required String text,
    required bool isWeb,
    String textPosition = 'top',
  }) {
    return GestureDetector(
      onTap: () {},
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        child: Stack(
          children: [
            ClipRRect(
              child: Image.asset(
                image,
                width: isWeb ? 240 : 100,
                height: isWeb ? 180 : 100,
                fit: BoxFit.cover,
              ),
            ),
            Positioned(
              top: textPosition == 'top' ? 4 : null,
              bottom: textPosition == 'bottom' ? 0 : null,
              left: 0,
              right: 0,
              child: textPosition == 'bottom' && isWeb
                  ? ClipRRect(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(8),
                  bottomRight: Radius.circular(8),
                ),
                child: Container(
                  padding:
                  const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                  color: Colors.black.withOpacity(0.7),
                  child: Text(
                    text,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: Colors.white,
                    ),
                  ),
                ),
              )
                  : Text(
                text,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w600,
                  fontSize: isWeb ? 14 : 12,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      color: Colors.black.withOpacity(0.5),
                      offset: const Offset(1, 1),
                      blurRadius: 2,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.topCenter,
      children: [
        BottomAppBar(
          color: const Color(0xFFF5F5F5),
          child: Padding(
            padding: const EdgeInsets.only(top: 40.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Image.asset(
                  'assets/logo.png',
                  width: 100,
                  height: 60,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// Custom clipper for smile-like bottom edge
class SmileClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 50); // Start from bottom-left
    path.quadraticBezierTo(
      size.width / 2, size.height, // Control point at bottom-center
      size.width, size.height - 50, // End at bottom-right
    );
    path.lineTo(size.width, 0); // Top-right
    path.lineTo(0, 0); // Top-left
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}