import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../../models/order_model.dart';

class Orderstatus extends StatefulWidget {
  final int userId; // nhận userId từ màn trước truyền qua

  const Orderstatus({
    super.key,
    required this.userId,
  });

  @override
  State<Orderstatus> createState() => _OrderstatusState();
}

class _OrderstatusState extends State<Orderstatus> {

  /// index tab đang chọn (0,1,2)
  int selectedIndex = 0;

  /// trạng thái loading API
  bool isLoading = true;

  /// lưu userId
  int? userId;

  /// danh sách đơn hàng
  List<OrderModel> orders = [];

  /// tên hiển thị trên UI
  final List<String> tabs = [
    "chờ xác nhận",
    "chờ giao hàng",
    "đã giao",
  ];

  /// status gửi lên API tương ứng với tab
  final List<String> apiStatus = [
    "PENDING",
    "SHIPPING",
    "DELIVERED",
  ];

  @override
  void initState() {
    super.initState();
    loadUserAndOrders(); // load dữ liệu khi mở màn
  }

  /// lấy userId và gọi API
  Future<void> loadUserAndOrders() async {
    userId = widget.userId;

    if (userId != null) {
      fetchOrders(); // gọi API
    } else {
      // nếu không có user
      setState(() {
        isLoading = false;
      });
    }
  }

  /// gọi API lấy danh sách đơn hàng theo status
  Future<void> fetchOrders() async {
    if (userId == null) return;

    setState(() {
      isLoading = true;
    });

    try {
      // lấy status tương ứng tab
      String status = apiStatus[selectedIndex];

      // build URL API
      final url = Uri.parse(
        "https://shopapp.ddns.net/api/order/user/$userId/status/$status",
      );

      // gọi GET API
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);

        // map JSON -> OrderModel
        setState(() {
          orders = data
              .map((e) => OrderModel.fromJson(e))
              .toList();
        });
      } else {
        // lỗi API
        setState(() {
          orders = [];
        });
      }
    } catch (e) {
      // lỗi network / parse
      print("API Error: $e");

      setState(() {
        orders = [];
      });
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {

    // lấy kích thước màn hình (responsive)
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.04,
          ),
          child: Column(
            children: [
              SizedBox(height: screenHeight * 0.01),

              /// ===== HEADER =====
              Row(
                children: [
                  // nút back
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(
                      Icons.arrow_back,
                      size: screenWidth * 0.07,
                    ),
                  ),

                  // title
                  Expanded(
                    child: Text(
                      "TÌNH TRẠNG ĐƠN HÀNG",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: screenWidth * 0.05,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  // spacing để cân layout
                  SizedBox(width: screenWidth * 0.1),
                ],
              ),

              SizedBox(height: screenHeight * 0.02),

              /// ===== TAB FILTER =====
              Wrap(
                spacing: screenWidth * 0.03,
                children: List.generate(
                  tabs.length,
                  (index) {

                    bool isSelected = selectedIndex == index;

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedIndex = index;
                        });

                        fetchOrders(); // load lại dữ liệu theo tab
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: screenWidth * 0.04,
                          vertical: screenHeight * 0.012,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Colors.blue
                              : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          tabs[index],
                          style: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : Colors.black,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              SizedBox(height: screenHeight * 0.02),

              /// ===== LIST ORDER =====
              Expanded(
                child: isLoading
                    ? const Center(
                        child: CircularProgressIndicator(),
                      )
                    : orders.isEmpty
                        ? const Center(
                            child: Text("Không có đơn hàng"),
                          )
                        : ListView.builder(
                            itemCount: orders.length,
                            itemBuilder: (context, index) {
                              return orderItem(
                                screenWidth,
                                screenHeight,
                                orders[index],
                              );
                            },
                          ),
              )
            ],
          ),
        ),
      ),
    );
  }

  /// ===== UI ITEM ĐƠN HÀNG =====
  Widget orderItem(
    double screenWidth,
    double screenHeight,
    OrderModel order,
  ) {
    return Container(
      margin: EdgeInsets.only(
        bottom: screenHeight * 0.02,
      ),
      padding: EdgeInsets.all(screenWidth * 0.03),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          /// mã đơn
          Row(
            children: [
              Icon(
                Icons.local_shipping_outlined,
                color: Colors.orange,
                size: screenWidth * 0.06,
              ),
              SizedBox(width: screenWidth * 0.02),
              Expanded(
                child: Text(
                  order.orderCode,
                  style: TextStyle(
                    fontSize: screenWidth * 0.045,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              )
            ],
          ),

          SizedBox(height: screenHeight * 0.01),

          /// thông tin người nhận
          Text("Người nhận: ${order.shippingName}"),
          Text("SĐT: ${order.shippingPhone}"),
          Text("Địa chỉ: ${order.shippingAddress}"),

          SizedBox(height: screenHeight * 0.01),

          /// tổng tiền
          Text(
            "${order.totalPrice} đ",
            style: const TextStyle(
              color: Colors.red,
              fontWeight: FontWeight.bold,
            ),
          )
        ],
      ),
    );
  }
}