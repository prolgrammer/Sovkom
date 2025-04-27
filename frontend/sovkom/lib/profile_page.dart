import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'dart:convert';
import 'package:sovkom/main.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int selectedTabIndex = 0;
  final ScrollController _scrollController = ScrollController();
  double _scale = 1.0;
  DateTime? selectedStartDate;
  DateTime? selectedEndDate;
  String? selectedCategoryFilter;

  List<Map<String, dynamic>> transactions = [
    {
      'name': 'Магнит',
      'category': 'Супермаркет',
      'amount': -149.99,
      'date': DateTime(2025, 4, 20),
      'items': [
        {'name': 'Хлеб', 'price': 40.00},
        {'name': 'Молоко', 'price': 55.00},
        {'name': 'Яйца', 'price': 54.99},
      ],
    },
    {
      'name': 'Столовая СГТУ',
      'category': 'Фастфуд',
      'amount': -187.00,
      'date': DateTime(2025, 4, 18),
      'items': [
        {'name': 'Борщ', 'price': 80.00},
        {'name': 'Компот', 'price': 30.00},
        {'name': 'Котлета', 'price': 77.00},
      ],
    },
    {
      'name': 'Покупка билета',
      'category': 'Ж/д билет',
      'amount': -37536.00,
      'date': DateTime(2025, 4, 10),
      'items': [
        {'name': 'Билет Сарат-Москва', 'price': 37536.00},
      ],
    },
    {
      'name': 'Лента',
      'category': 'Супермаркет',
      'amount': -5000.00,
      'date': DateTime(2025, 4, 15),
      'items': [
        {'name': 'Мясо', 'price': 1200.00},
        {'name': 'Овощи', 'price': 800.00},
        {'name': 'Крупы', 'price': 1000.00},
        {'name': 'Молочные продукты', 'price': 2000.00},
      ],
    },
    {
      'name': 'Починка крана',
      'category': 'Дом и ремонт',
      'amount': -9050.00,
      'date': DateTime(2025, 3, 27),
      'items': [
        {'name': 'Работа сантехника', 'price': 7000.00},
        {'name': 'Новые детали', 'price': 2050.00},
      ],
    },
    {
      'name': 'Макдоналдс',
      'category': 'Фастфуд',
      'amount': -5808.00,
      'date': DateTime(2025, 4, 5),
      'items': [
        {'name': 'Биг Мак', 'price': 200.00},
        {'name': 'Картошка фри', 'price': 100.00},
        {'name': 'Кола', 'price': 80.00},
        {'name': 'Прочее', 'price': 5428.00},
      ],
    },
    {
      'name': 'Перевод другу',
      'category': 'Переводы',
      'amount': -5518.00,
      'date': DateTime(2025, 4, 1),
      'items': [
        {'name': 'Перевод на карту', 'price': 5518.00},
      ],
    },
    {
      'name': 'Кофе',
      'category': 'Фастфуд',
      'amount': -400.00,
      'date': DateTime(2025, 4, 19),
      'items': [
        {'name': 'Капучино', 'price': 200.00},
        {'name': 'Круассан', 'price': 200.00},
      ],
    },
    {
      'name': 'Курьерская доставка',
      'category': 'Остальное',
      'amount': -9591.00,
      'date': DateTime(2025, 3, 30),
      'items': [
        {'name': 'Доставка', 'price': 1591.00},
        {'name': 'Товары', 'price': 8000.00},
      ],
    },
  ];

  bool _isLoading = true; // для показа загрузки
  bool _isError = false; // для обработки ошибок

  final Map<String, Color> categoryColors = {
    'Ж/д билет': Colors.blue,
    'Супермаркет': Colors.red,
    'Дом и ремонт': Colors.green,
    'Фастфуд': Colors.orange,
    'Переводы': Colors.cyan,
    'Остальное': Colors.grey,
  };

  final Map<String, IconData> categoryIcons = {
    'Ж/д билет': Icons.train,
    'Супермаркет': Icons.shopping_cart,
    'Дом и ремонт': Icons.home_repair_service,
    'Фастфуд': Icons.fastfood,
    'Переводы': Icons.compare_arrows,
    'Остальное': Icons.more_horiz,
  };

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    selectedStartDate = DateTime.now().subtract(const Duration(days: 30));
    selectedEndDate = DateTime.now();
    fetchTransactions();
  }

  void _scrollListener() {
    double offset = _scrollController.offset;
    double newScale = (1.0 - (offset / 300)).clamp(0.0, 1.0);

    if (newScale != _scale) {
      setState(() {
        _scale = newScale;
      });
    }
  }

  Future<void> _selectDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2023),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(
        start: selectedStartDate!,
        end: selectedEndDate!,
      ),
    );
    if (picked != null) {
      setState(() {
        selectedStartDate = picked.start;
        selectedEndDate = picked.end;
      });
    }
  }

  Future<void> fetchTransactions() async {
    try {
      final response = await http.get(Uri.parse('$serverIp/receipts/'));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);

        setState(() {
          transactions = data.map<Map<String, dynamic>>((item) {
            return {
              'name': item['shop'] ?? '',
              'category': item['category'] ?? 'Остальное',
              'amount': -(item['total'] ?? 0), // Минус, потому что это траты
              'date': DateTime.parse(item['created_at']),
              'items': (item['items'] as List<dynamic>).map<Map<String, dynamic>>((it) {
                return {
                  'name': it['name'],
                  'price': it['price'],
                };
              }).toList(),
            };
          }).toList();
          _isLoading = false;
        });
      } else {
        setState(() {
          _isError = true;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isError = true;
        _isLoading = false;
      });
    }
  }

  List<Map<String, dynamic>> get filteredTransactions {
    return transactions.where((tx) {
      final matchesDate = tx['date'].isAfter(selectedStartDate!.subtract(const Duration(days: 1))) &&
          tx['date'].isBefore(selectedEndDate!.add(const Duration(days: 1)));
      final matchesCategory = selectedCategoryFilter == null || tx['category'] == selectedCategoryFilter;
      return matchesDate && matchesCategory;
    }).toList();
  }

  Map<String, double> calculateCategorySums() {
    Map<String, double> categorySums = {};
    for (var tx in filteredTransactions) {
      String category = tx['category'];
      double amount = tx['amount'].abs();
      categorySums[category] = (categorySums[category] ?? 0) + amount;
    }
    return categorySums;
  }

  double calculateTotalSum() {
    return filteredTransactions.fold(0.0, (sum, tx) => sum + tx['amount'].abs());
  }


  @override
  Widget build(BuildContext context) {
    final categorySums = calculateCategorySums();
    final totalSum = calculateTotalSum();
    final isWebView = kIsWeb && MediaQuery.of(context).size.width > 800;

    if (isWebView) {
      // Веб-версия: header на всю ширину, профиль закреплён в левой колонке с белой подложкой, отступы справа и слева
      return Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          children: [
            Padding(
          padding: const EdgeInsets.symmetric(horizontal: 150.0),
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Левая колонка: Профиль закреплён, статистика с анимацией масштабирования
                    Expanded(
                      flex: 1,
                      child: Stack(
                        children: [
                          SingleChildScrollView(
                            controller: _scrollController,
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  const SizedBox(height: 80), // Высота для закреплённого профиля
                                  Transform.scale(
                                    scale: _scale,
                                    alignment: Alignment.topCenter,
                                    child: _buildStatistics(categorySums, totalSum),
                                  ),
                                  const SizedBox(height: 16),
                                  _buildCategoryList(categorySums),
                                  const SizedBox(height: 16),
                                  _buildTransactionsList(),
                                ],
                              ),
                            ),
                          ),
                          // Закреплённый профиль с белой подложкой
                          Positioned(
                            top: 0,
                            left: 0,
                            right: 0,
                            child: Container(
                              color: Colors.white,
                              padding: const EdgeInsets.only(bottom: 8),
                              child: _buildProfileInfo(),
                            ),
                          ),
                          // Уменьшенная версия статистики при прокрутке
                          AnimatedPositioned(
                            duration: const Duration(milliseconds: 250),
                            curve: Curves.easeInOut,
                            top: _scale < 0.53 ? 80 : 80, // Позиция под профилем
                            left: 0,
                            right: 0,
                            child: AnimatedOpacity(
                              duration: const Duration(milliseconds: 200),
                              opacity: _scale < 0.53 ? 1.0 : 0.0,
                              child: Container(
                                color: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            '${totalSum.toStringAsFixed(0)} ₽',
                                            style: const TextStyle(
                                              fontFamily: 'Montserrat',
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            textAlign: TextAlign.left,
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            '${DateFormat('dd.MM.yyyy').format(selectedStartDate!)} - ${DateFormat('dd.MM.yyyy').format(selectedEndDate!)}',
                                            style: const TextStyle(
                                              fontFamily: 'Montserrat',
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                            ),
                                            textAlign: TextAlign.left,
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(
                                      height: 80,
                                      width: 80,
                                      child: PieChart(
                                        dataMap: categorySums,
                                        chartType: ChartType.ring,
                                        ringStrokeWidth: 14,
                                        chartValuesOptions: const ChartValuesOptions(showChartValues: false),
                                        colorList: categorySums.keys.map((e) => categoryColors[e] ?? Colors.grey).toList(),
                                        animationDuration: Duration.zero,
                                        legendOptions: const LegendOptions(showLegends: false),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Правая колонка: Предложения
                    Expanded(
                      flex: 1,
                      child: SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Предложения',
                                style: TextStyle(
                                  fontFamily: 'Montserrat',
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),
                              _buildOffersGrid(),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
            Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: Center(
                child: SizedBox(
                  width: 240,
                  child: ElevatedButton(
                    onPressed: () async {
                      final picker = ImagePicker();
                      final pickedFile = await picker.pickImage(source: ImageSource.gallery);

                      if (pickedFile != null) {
                        final file = File(pickedFile.path);
                        await _uploadImage(file);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Чек успешно загружен!')),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF213A8B),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text(
                      'Загрузить чек',
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
    ],
        ),
      );
    } else {
      // Мобильная версия: без изменений
      return Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          children: [
            SafeArea(
              child: Column(
                children: [
                  _buildHeader(),
                  _buildProfileInfo(),
                  _buildTabs(),
                  Expanded(
                    child: selectedTabIndex == 0
                        ? SingleChildScrollView(
                      controller: _scrollController,
                      padding: const EdgeInsets.only(bottom: 100),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Transform.scale(
                            scale: _scale,
                            alignment: Alignment.topCenter,
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(left: 20, right: 20, top: 20),
                                    child: LayoutBuilder(
                                      builder: (context, constraints) {
                                        if (constraints.maxWidth > 400) {
                                          return Row(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Expanded(
                                                child: Padding(
                                                  padding: const EdgeInsets.only(top: 20),
                                                  child: Column(
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Padding(
                                                        padding: const EdgeInsets.only(left: 8),
                                                        child: Text(
                                                          '${totalSum.toStringAsFixed(0)} ₽',
                                                          style: const TextStyle(
                                                            fontFamily: 'Montserrat',
                                                            fontSize: 26,
                                                            fontWeight: FontWeight.bold,
                                                          ),
                                                        ),
                                                      ),
                                                      const SizedBox(height: 4),
                                                      TextButton.icon(
                                                        onPressed: _selectDateRange,
                                                        icon: const Icon(Icons.calendar_today, size: 18),
                                                        label: Text(
                                                          '${DateFormat('dd.MM.yyyy').format(selectedStartDate!)} - ${DateFormat('dd.MM.yyyy').format(selectedEndDate!)}',
                                                          style: const TextStyle(fontFamily: 'Montserrat', fontSize: 18, fontWeight: FontWeight.w500),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 16),
                                              SizedBox(
                                                height: 160,
                                                width: 160,
                                                child: PieChart(
                                                  dataMap: categorySums,
                                                  chartType: ChartType.ring,
                                                  ringStrokeWidth: 20,
                                                  chartValuesOptions: const ChartValuesOptions(showChartValues: false),
                                                  colorList: categorySums.keys.map((e) => categoryColors[e] ?? Colors.grey).toList(),
                                                  animationDuration: const Duration(milliseconds: 800),
                                                  legendOptions: const LegendOptions(showLegends: false),
                                                ),
                                              ),
                                            ],
                                          );
                                        } else {
                                          return Column(
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: [
                                              SizedBox(
                                                height: 160,
                                                width: 160,
                                                child: PieChart(
                                                  dataMap: categorySums,
                                                  chartType: ChartType.ring,
                                                  ringStrokeWidth: 20,
                                                  chartValuesOptions: const ChartValuesOptions(showChartValues: false),
                                                  colorList: categorySums.keys.map((e) => categoryColors[e] ?? Colors.grey).toList(),
                                                  animationDuration: const Duration(milliseconds: 800),
                                                  legendOptions: const LegendOptions(showLegends: false),
                                                ),
                                              ),
                                              const SizedBox(height: 16),
                                              Text(
                                                '${totalSum.toStringAsFixed(0)} ₽',
                                                style: const TextStyle(fontFamily: 'Montserrat', fontSize: 26, fontWeight: FontWeight.bold),
                                              ),
                                              const SizedBox(height: 4),
                                              TextButton.icon(
                                                onPressed: _selectDateRange,
                                                icon: const Icon(Icons.calendar_today, size: 18),
                                                label: Text(
                                                  '${DateFormat('dd.MM.yyyy').format(selectedStartDate!)} - ${DateFormat('dd.MM.yyyy').format(selectedEndDate!)}',
                                                  style: const TextStyle(fontFamily: 'Montserrat', fontSize: 18, fontWeight: FontWeight.w500),
                                                ),
                                              ),
                                            ],
                                          );
                                        }
                                      },
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                          _buildCategoryList(categorySums),
                          _buildTransactionsList(),
                        ],
                      ),
                    )
                        : ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        _buildLongCard(),
                        _buildLongCard(),
                        _buildHorizontalSquares(),
                        _buildLongCard(),
                        _buildLongCard(),
                        _buildLongCard(),
                        _buildHorizontalSquares(),
                        _buildLongCard(),
                        const SizedBox(height: 100),
                      ],
                    ),
                  )
                ],
              ),
            ),
            AnimatedPositioned(
              duration: Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              top: _scale < 0.53 ? 214 : 214,
              left: 0,
              right: 0,
              child: AnimatedOpacity(
                duration: Duration(milliseconds: 200),
                opacity: _scale < 0.53 ? 1.0 : 0.0,
                child: Container(
                  color: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${totalSum.toStringAsFixed(0)} ₽',
                              style: const TextStyle(
                                fontFamily: 'Montserrat',
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${DateFormat('dd.MM.yyyy').format(selectedStartDate!)} - ${DateFormat('dd.MM.yyyy').format(selectedEndDate!)}',
                              style: const TextStyle(
                                fontFamily: 'Montserrat',
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 80,
                        width: 80,
                        child: PieChart(
                          dataMap: categorySums,
                          chartType: ChartType.ring,
                          ringStrokeWidth: 14,
                          chartValuesOptions: const ChartValuesOptions(showChartValues: false),
                          colorList: categorySums.keys.map((e) => categoryColors[e] ?? Colors.grey).toList(),
                          animationDuration: Duration.zero,
                          legendOptions: const LegendOptions(showLegends: false),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: Center(
                child: SizedBox(
                  width: 240,
                  child: ElevatedButton(
                    onPressed: () {
                      _pickAndUploadImage(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF213A8B),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text(
                      'Загрузить чек',
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildHeader() => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    child: Row(
      children: [
        Image.asset('assets/logo.png', height: 24),
        const Spacer(),
        IconButton(icon: const Icon(Icons.logout), onPressed: () {}),
      ],
    ),
  );

  Widget _buildProfileInfo() => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    child: Row(
      children: [
        const CircleAvatar(radius: 30, backgroundColor: Colors.grey),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text('Бабич Алексей', style: TextStyle(fontFamily: 'Montserrat', fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 4),
              Text('knigopiss234@yandex.ru', style: TextStyle(fontFamily: 'Montserrat', fontSize: 14, color: Colors.grey)),
            ],
          ),
        ),
        IconButton(
          icon: const Icon(Icons.settings),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ProfileSettingsScreen()),
            );
          },
        ),
      ],
    ),
  );

  Widget _buildTabs() => Container(
    decoration: const BoxDecoration(
      border: Border(bottom: BorderSide(color: Colors.grey, width: 0.5)),
    ),
    child: Row(
      children: [
        _buildTabButton('Статистика', 0),
        _buildTabButton('Предложения', 1),
      ],
    ),
  );

  Widget _buildTabButton(String title, int index) => Expanded(
    child: GestureDetector(
      onTap: () => setState(() => selectedTabIndex = index),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            bottom: BorderSide(
              color: selectedTabIndex == index ? const Color(0xFF213A8B) : Colors.transparent,
              width: 3,
            ),
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          title,
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 16,
            fontWeight: selectedTabIndex == index ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    ),
  );

  Widget _buildStatistics(Map<String, double> categorySums, double totalSum) => Column(
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      SizedBox(
        height: 160,
        width: 160,
        child: PieChart(
          dataMap: categorySums,
          chartType: ChartType.ring,
          ringStrokeWidth: 20,
          chartValuesOptions: const ChartValuesOptions(showChartValues: false),
          colorList: categorySums.keys.map((e) => categoryColors[e] ?? Colors.grey).toList(),
          animationDuration: const Duration(milliseconds: 800),
          legendOptions: const LegendOptions(showLegends: false),
        ),
      ),
      const SizedBox(height: 16),
      Text(
        '${totalSum.toStringAsFixed(0)} ₽',
        style: const TextStyle(fontFamily: 'Montserrat', fontSize: 26, fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 4),
      TextButton.icon(
        onPressed: _selectDateRange,
        icon: const Icon(Icons.calendar_today, size: 18),
        label: Text(
          '${DateFormat('dd.MM.yyyy').format(selectedStartDate!)} - ${DateFormat('dd.MM.yyyy').format(selectedEndDate!)}',
          style: const TextStyle(fontFamily: 'Montserrat', fontSize: 18, fontWeight: FontWeight.w500),
        ),
      ),
    ],
  );

  Widget _buildCategoryList(Map<String, double> categorySums) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: categorySums.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final entry = categorySums.entries.elementAt(index);
          final isSelected = selectedCategoryFilter == entry.key;
          return GestureDetector(
            onTap: () {
              setState(() {
                if (selectedCategoryFilter == entry.key) {
                  selectedCategoryFilter = null;
                } else {
                  selectedCategoryFilter = entry.key;
                }
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF213A8B) : Colors.grey[200],
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: categoryColors[entry.key] ?? Colors.grey,
                    radius: 6,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${entry.key}: ${entry.value.toStringAsFixed(0)} ₽',
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 14,
                      color: isSelected ? Colors.white : Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    ),
  );

  Widget _buildHorizontalSquares() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: SizedBox(
        height: 150,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: 10,
          separatorBuilder: (context, index) => const SizedBox(width: 16),
          itemBuilder: (context, index) => Container(
            width: 150,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(child: Text('Square $index')),
          ),
        ),
      ),
    );
  }

  Widget _buildOffersGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1,
      ),
      itemCount: 6,
      itemBuilder: (context, index) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(child: Text('Square $index')),
        );
      },
    );
  }

  Widget _buildTransactionsList() {
    return Column(
      children: filteredTransactions.map((tx) {
        final dateFormatted = DateFormat('dd.MM.yyyy').format(tx['date']);
        return Column(
          children: [
            ExpansionTile(
              tilePadding: EdgeInsets.symmetric(horizontal: 16),
              childrenPadding: const EdgeInsets.symmetric(vertical: 8),
              leading: CircleAvatar(
                backgroundColor: categoryColors[tx['category']] ?? Colors.grey,
                child: Icon(
                  categoryIcons[tx['category']] ?? Icons.receipt,
                  color: Colors.white,
                  size: 16,
                ),
              ),
              title: Text(
                tx['name'],
                style: const TextStyle(fontFamily: 'Montserrat', fontSize: 16),
              ),
              subtitle: Text(
                '${tx['category']} • $dateFormatted',
                style: const TextStyle(fontFamily: 'Montserrat', fontSize: 12, color: Colors.grey),
              ),
              trailing: Text(
                '${tx['amount'].toStringAsFixed(2)} ₽',
                style: const TextStyle(fontFamily: 'Montserrat', fontSize: 16),
              ),
              children: (tx['items'] as List).map<Widget>((item) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(item['name'], style: const TextStyle(fontFamily: 'Montserrat', fontSize: 14)),
                      Text('${item['price'].toStringAsFixed(2)} ₽',
                          style: const TextStyle(fontFamily: 'Montserrat', fontSize: 14, color: Colors.grey)),
                    ],
                  ),
                );
              }).toList(),
            ),
            const Divider(height: 0),
          ],
        );
      }).toList(),
    );
  }
}

Widget _buildLongCard() {
  return Container(
    height: 150,
    margin: const EdgeInsets.only(bottom: 16),
    decoration: BoxDecoration(
      color: Colors.grey[300],
      borderRadius: BorderRadius.circular(12),
    ),
    child: const Center(
      child: Text(
        'Длинная карточка',
        style: TextStyle(
          fontFamily: 'Montserrat',
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
    ),
  );
}

class ProfileSettingsScreen extends StatefulWidget {
  const ProfileSettingsScreen({super.key});

  @override
  State<ProfileSettingsScreen> createState() => _ProfileSettingsScreenState();
}

class _ProfileSettingsScreenState extends State<ProfileSettingsScreen> {
  final TextEditingController _nameController = TextEditingController(text: 'Бабич Алексей');
  final TextEditingController _emailController = TextEditingController(text: 'knigopiss234@yandex.ru');
  final TextEditingController _phoneController = TextEditingController();
  String? _profileImage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Настройки профиля'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.5,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            Center(
              child: GestureDetector(
                onTap: () {
                  // здесь можно добавить выбор изображения
                },
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.grey[300],
                  backgroundImage: _profileImage != null ? AssetImage(_profileImage!) : null,
                  child: _profileImage == null
                      ? const Icon(Icons.camera_alt, size: 32, color: Colors.white70)
                      : null,
                ),
              ),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Имя',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Телефон',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF213A8B),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text(
                'Сохранить',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> _pickAndUploadImage(BuildContext context) async {
  final picker = ImagePicker();

  final pickedFile = await showModalBottomSheet<XFile?>(
    context: context,
    builder: (BuildContext bc) {
      return SafeArea(
        child: Wrap(
          children: <Widget>[
            ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Сделать снимок'),
                onTap: () async {
                  final photo = await picker.pickImage(source: ImageSource.camera);
                  Navigator.of(context).pop(photo);
                }),
            ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Выбрать из галереи'),
                onTap: () async {
                  final galleryImage = await picker.pickImage(source: ImageSource.gallery);
                  Navigator.of(context).pop(galleryImage);
                }),
          ],
        ),
      );
    },
  );

  if (pickedFile != null) {
    // Если пользователь выбрал или сделал снимок
    await _uploadImage(File(pickedFile.path));
  }
}
Future<void> _uploadImage(File imageFile) async {
  final request = http.MultipartRequest(
    'POST',
    Uri.parse('$serverIp/receipts/upload'),
  );

  request.files.add(await http.MultipartFile.fromPath('receipt', imageFile.path));

  try {
    final response = await request.send();

    if (response.statusCode == 200) {
      print('Чек успешно отправлен');
    } else {
      print('Ошибка загрузки: ${response.statusCode}');
    }
  } catch (e) {
    print('Ошибка при отправке чека: $e');
  }
}