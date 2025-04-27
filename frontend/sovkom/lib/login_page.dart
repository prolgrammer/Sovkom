import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:sovkom/main.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  void initState() {
    super.initState();
    // Show the dialog when the screen is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showLoginDialog(context);
    });
  }

  // Function to show the dialog
  Future<void> _showLoginDialog(BuildContext context) async {
    await showDialog(
      context: context,
      barrierDismissible: true, // Allow dismissing by tapping outside
      builder: (BuildContext dialogContext) {
        return const Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12.0)),
          ),
          child: LoginDialogContent(),
        );
      },
    ).then((_) {
      // Navigate back or close the screen when the dialog is dismissed
      if (mounted) {
        Navigator.of(context).pop();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // White Background (Top)
          Container(color: Colors.white),
          CustomPaint(
            painter: MountainPainter(),
            size: Size.infinite,
          ),
        ],
      ),
    );
  }
}

class LoginDialogContent extends StatefulWidget {
  const LoginDialogContent({Key? key}) : super(key: key);

  @override
  _LoginDialogContentState createState() => _LoginDialogContentState();
}

class _LoginDialogContentState extends State<LoginDialogContent>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {}); // Rebuild when tab changes to update password field visibility
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: kIsWeb ? 600 : 300, // Wider for web
      padding: EdgeInsets.all(kIsWeb ? 32.0 : 16.0),
      child: kIsWeb ? _buildWebLayout(context) : _buildMobileLayout(context),
    );
  }

  Widget _buildWebLayout(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            // QR Code Section
            Expanded(
              child: Column(
                children: [
                  Image.asset(
                    'assets/qr.png',
                    width: 150,
                    height: 150,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Добавьте по QR-коду',
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Отсканируйте QR-код в приложении СБОЛ для входа',
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w400,
                      fontSize: 12,
                      color: Colors.black54,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Image.asset(
                    'assets/logo.png',
                    width: 100,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 32),
            // Form Section
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Align(
                    alignment: Alignment.center,
                    child: const Text(
                      'Вход',
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w600,
                        fontSize: 20,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  TabBar(
                    controller: _tabController,
                    labelColor: const Color(0xFF005BEA),
                    unselectedLabelColor: Colors.black54,
                    indicatorColor: const Color(0xFF005BEA),
                    indicatorWeight: 3,
                    labelStyle: const TextStyle(
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                    unselectedLabelStyle: const TextStyle(
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w400,
                      fontSize: 16,
                    ),
                    tabs: const [
                      Tab(text: 'Телефон'),
                      Tab(text: 'Почта'),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    height: 60,
                    child: TabBarView(
                      controller: _tabController,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        TextField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          decoration: InputDecoration(
                            hintText: 'Телефон',
                            filled: true,
                            fillColor: const Color(0xFFF5F5F5),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 20),
                            hintStyle: const TextStyle(
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.w400,
                              fontSize: 16,
                              color: Colors.black54,
                            ),
                            prefixStyle: const TextStyle(
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.w400,
                              fontSize: 16,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        TextField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            hintText: 'Почта',
                            filled: true,
                            fillColor: const Color(0xFFF5F5F5),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                            hintStyle: const TextStyle(
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.w400,
                              fontSize: 16,
                              color: Colors.black54,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (_tabController.index == 1) ...[
                    const SizedBox(height: 16),
                    Container(
                      height: 60,
                      child: TextField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          hintText: 'Пароль',
                          filled: true,
                          fillColor: const Color(0xFFF5F5F5),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                          hintStyle: const TextStyle(
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.w400,
                            fontSize: 16,
                            color: Colors.black54,
                          ),
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        final isPhoneTab = _tabController.index == 0;
                        final data = isPhoneTab
                            ? {'phone': _phoneController.text}
                            : {
                                'email': _emailController.text,
                                'password': _passwordController.text,
                              };

                        try {
                          final response = await http.post(
                            Uri.parse('$serverIp/users/login'),
                            headers: {'Content-Type': 'application/json'},
                            body: jsonEncode(data),
                          );

                          if (response.statusCode == 200) {
                            Navigator.pushNamed(context, '/profile');
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Ошибка входа: ${response.statusCode}')),
                            );
                          }
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Ошибка отправки запроса: $e')),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF005BEA),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Продолжить',
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Align(
          alignment: Alignment.center,
          child: const Text(
            'Вход',
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w600,
              fontSize: 18,
              color: Colors.black,
            ),
          ),
        ),
        const SizedBox(height: 16),
        TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF005BEA),
          unselectedLabelColor: Colors.black54,
          indicatorColor: const Color(0xFF005BEA),
          indicatorWeight: 3,
          labelStyle: const TextStyle(
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
          unselectedLabelStyle: const TextStyle(
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w400,
            fontSize: 14,
          ),
          tabs: const [
            Tab(text: 'Телефон'),
            Tab(text: 'Почта'),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          height: 60,
          child: TabBarView(
            controller: _tabController,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  hintText: 'Телефон',
                  filled: true,
                  fillColor: const Color(0xFFF5F5F5),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 20),
                  hintStyle: const TextStyle(
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w400,
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                  prefixStyle: const TextStyle(
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w400,
                    fontSize: 14,
                    color: Colors.black,
                  ),
                ),
              ),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  hintText: 'Почта',
                  filled: true,
                  fillColor: const Color(0xFFF5F5F5),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                  hintStyle: const TextStyle(
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w400,
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (_tabController.index == 1) ...[
          const SizedBox(height: 16),
          Container(
            height: 60,
            child: TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                hintText: 'Пароль',
                filled: true,
                fillColor: const Color(0xFFF5F5F5),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                hintStyle: const TextStyle(
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w400,
                  fontSize: 14,
                  color: Colors.black54,
                ),
              ),
            ),
          ),
        ],
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () async {
              final isPhoneTab = _tabController.index == 0;
              final data = isPhoneTab
                  ? {'phone': _phoneController.text}
                  : {
                      'email': _emailController.text,
                      'password': _passwordController.text,
                    };

              try {
                final response = await http.post(
                  Uri.parse('$serverIp/users/login'),
                  headers: {'Content-Type': 'application/json'},
                  body: jsonEncode(data),
                );

                if (response.statusCode == 200) {
                  Navigator.pushNamed(context, '/profile');
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Ошибка входа: ${response.statusCode}')),
                  );
                }
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Ошибка отправки запроса: $e')),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF005BEA),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Продолжить',
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class MountainPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = LinearGradient(
        colors: [
          Color(0xFFE6F0FA),
          Color(0xFFD6E6FF),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, size.height * 0.7, size.width, size.height * 0.3));

    final path = Path();
    // Начальная точка в левом нижнем углу
    path.moveTo(0, size.height);

    // Первая гора (низкая)
    path.lineTo(size.width * 0.10, size.height * 0.85);
    path.lineTo(size.width * 0.18, size.height * 0.92);

    // Вторая гора (высокая, острая)
    path.lineTo(size.width * 0.28, size.height * 0.65);

    // Третья гора (средняя)
    path.lineTo(size.width * 0.38, size.height * 0.80);

    // Четвертая гора (самая высокая, острая)
    path.lineTo(size.width * 0.50, size.height * 0.55);

    // Пятая гора (средняя)
    path.lineTo(size.width * 0.62, size.height * 0.78);

    // Шестая гора (низкая)
    path.lineTo(size.width * 0.72, size.height * 0.88);

    // Седьмая гора (острая)
    path.lineTo(size.width * 0.80, size.height * 0.60);

    // Восьмая гора (низкая) - теперь касается правой стенки наполовину
    path.lineTo(size.width, size.height * 0.50);

    // Завершаем в правом нижнем углу
    path.lineTo(size.width, size.height);

    // Замыкаем путь
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}