import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class DashboardScreen extends StatefulWidget {
 
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with SingleTickerProviderStateMixin {
  List<Map<String, dynamic>> data = [];
  bool isLoading = true;

  late AnimationController _animController;
  late Animation<double> _anim;

  final List<Color> chartColors = [
    const Color(0xFF4F8EF7),
    const Color(0xFFFF8C42),
    const Color(0xFFB06FE8),
    const Color(0xFF3DD68C),
    const Color(0xFFF85149),
  ];

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _anim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    getStatistic();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> getStatistic() async {
    try {
      final response = await http.get(
  Uri.parse("http://192.168.1.9:5000/api/Statistic"),
);
      if (response.statusCode == 200) {
        final List jsonData = jsonDecode(response.body);
        setState(() {
          data = jsonData.asMap().entries.map((e) {
            return {
              "title": e.value["title"],
              "percent": e.value["percent"],
              "color": chartColors[e.key % chartColors.length],
            };
          }).toList();
          isLoading = false;
        });
        _animController.forward();
      }
    } catch (e) {
      debugPrint("Lỗi API: $e");
      setState(() => isLoading = false);
    }
  }

  /// Sản phẩm có % cao nhất từ API
  Map<String, dynamic>? get _topItem {
    if (data.isEmpty) return null;
    return data.reduce((a, b) => a["percent"] > b["percent"] ? a : b);
  }

  /// Sản phẩm có % thấp nhất từ API
  Map<String, dynamic>? get _bottomItem {
    if (data.isEmpty) return null;
    return data.reduce((a, b) => a["percent"] < b["percent"] ? a : b);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    if (isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFF0D1117),
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF4F8EF7)),
        ),
      );
    }

    if (data.isEmpty) {
      return const Scaffold(
        backgroundColor: Color(0xFF0D1117),
        body: Center(
          child: Text(
            "Chưa có dữ liệu",
            style: TextStyle(color: Color(0xFF7D8590)),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),

              // ── SUMMARY CARDS: top vs bottom từ API ──
              Row(
                children: [
                  _StatCard(
                    label: _topItem!["title"],
                    value: "${_topItem!["percent"]}%",
                    badge: "Cao nhất",
                    isUp: true,
                  ),
                  const SizedBox(width: 10),
                  _StatCard(
                    label: _bottomItem!["title"],
                    value: "${_bottomItem!["percent"]}%",
                    badge: "Thấp nhất",
                    isUp: false,
                  ),
                ],
              ),

              const SizedBox(height: 14),

              // ── DONUT CARD ──
              _SectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Phân bổ danh mục",
                          style: TextStyle(
                            color: Color(0xFFF0F6FC),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF21262D),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            "${DateTime.now().year}",
                            style: const TextStyle(
                              color: Color(0xFF7D8590),
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    Center(
                      child: SizedBox(
                        width: size.width * 0.5,
                        height: size.width * 0.5,
                        child: AnimatedBuilder(
                          animation: _anim,
                          builder: (_, __) => Stack(
                            alignment: Alignment.center,
                            children: [
                              CustomPaint(
                                size: Size(size.width * 0.5, size.width * 0.5),
                                painter: _DonutPainter(data, _anim.value),
                              ),
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    "${data.fold<int>(0, (sum, e) => sum + (e["percent"] as int))}%",
                                    style: const TextStyle(
                                      color: Color(0xFFF0F6FC),
                                      fontSize: 20,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const Text(
                                    "Tổng",
                                    style: TextStyle(
                                      color: Color(0xFF7D8590),
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 18),

                    // Legend từ API
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                        childAspectRatio: 2.8,
                      ),
                      itemCount: data.length,
                      itemBuilder: (_, i) => _LegendItem(
                        color: data[i]["color"],
                        title: data[i]["title"],
                        percent: data[i]["percent"],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // ── BAR BREAKDOWN ──
              const Padding(
                padding: EdgeInsets.only(bottom: 10),
                child: Text(
                  "Chi tiết",
                  style: TextStyle(
                    color: Color(0xFFF0F6FC),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

              _SectionCard(
                child: Column(
                  children: data.asMap().entries.map((e) {
                    return Padding(
                      padding: EdgeInsets.only(
                        bottom: e.key < data.length - 1 ? 12 : 0,
                      ),
                      child: AnimatedBuilder(
                        animation: _anim,
                        builder: (_, __) => _BarRow(
                          label: e.value["title"],
                          percent: e.value["percent"],
                          color: e.value["color"],
                          animValue: _anim.value,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

// ── STAT CARD ──
class _StatCard extends StatelessWidget {
  final String label, value, badge;
  final bool isUp;
  const _StatCard({
    required this.label,
    required this.value,
    required this.badge,
    required this.isUp,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFF161B22),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFF21262D), width: 0.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label.toUpperCase(),
              style: const TextStyle(
                color: Color(0xFF7D8590),
                fontSize: 11,
                letterSpacing: 0.5,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                color: Color(0xFFF0F6FC),
                fontSize: 22,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(
                color: isUp
                    ? const Color(0xFF0D3226)
                    : const Color(0xFF2D1117),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isUp ? Icons.trending_up : Icons.trending_down,
                    size: 11,
                    color: isUp
                        ? const Color(0xFF3FB950)
                        : const Color(0xFFF85149),
                  ),
                  const SizedBox(width: 3),
                  Text(
                    badge,
                    style: TextStyle(
                      color: isUp
                          ? const Color(0xFF3FB950)
                          : const Color(0xFFF85149),
                      fontSize: 11,
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

// ── SECTION CARD ──
class _SectionCard extends StatelessWidget {
  final Widget child;
  const _SectionCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF161B22),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF21262D), width: 0.5),
      ),
      child: child,
    );
  }
}

// ── LEGEND ITEM ──
class _LegendItem extends StatelessWidget {
  final Color color;
  final String title;
  final int percent;
  const _LegendItem({
    required this.color,
    required this.title,
    required this.percent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF0D1117),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Color(0xFF7D8590),
                  fontSize: 11,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                "$percent%",
                style: const TextStyle(
                  color: Color(0xFFF0F6FC),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── BAR ROW ──
class _BarRow extends StatelessWidget {
  final String label;
  final int percent;
  final Color color;
  final double animValue;
  const _BarRow({
    required this.label,
    required this.percent,
    required this.color,
    required this.animValue,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 60,
          child: Text(
            label,
            style: const TextStyle(color: Color(0xFF7D8590), fontSize: 12),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Expanded(
          child: Container(
            height: 8,
            decoration: BoxDecoration(
              color: const Color(0xFF21262D),
              borderRadius: BorderRadius.circular(20),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: (percent / 100) * animValue,
              child: Container(
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        SizedBox(
          width: 32,
          child: Text(
            "$percent%",
            textAlign: TextAlign.right,
            style: const TextStyle(
              color: Color(0xFFF0F6FC),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

// ── DONUT PAINTER ──
class _DonutPainter extends CustomPainter {
  final List<Map<String, dynamic>> data;
  final double progress;

  _DonutPainter(this.data, this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 28
      ..strokeCap = StrokeCap.butt;

    double startAngle = -pi / 2;
    const gap = 0.04;

    for (int i = 0; i < data.length; i++) {
      final sweep = (data[i]["percent"] / 100) * 2 * pi * progress;
      paint.color = data[i]["color"];
      canvas.drawArc(
        Rect.fromCircle(
          center: Offset(size.width / 2, size.height / 2),
          radius: size.width / 2.4,
        ),
        startAngle + gap / 2,
        sweep - gap,
        false,
        paint,
      );
      startAngle += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutPainter old) =>
      old.progress != progress || old.data != data;
}