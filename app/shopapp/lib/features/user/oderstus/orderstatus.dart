import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shopapp/models/order_model.dart';

class Orderstatus extends StatefulWidget {
  final int userId;

  const Orderstatus({
    super.key,
    required this.userId,
  });

  @override
  State<Orderstatus> createState() => _OrderstatusState();
}

class _OrderstatusState extends State<Orderstatus> {
  int selectedIndex = 0;
  bool isLoading = true;

  int? userId;
  List<OrderModel> orders = [];

  final List<String> tabs = [
    "chờ xác nhận",
    "chờ giao hàng",
    "đã giao",
  ];

  final List<String> apiStatus = [
    "PENDING",
    "SHIPPING",
    "DELIVERED",
  ];

  @override
  void initState() {
    super.initState();
    loadUserAndOrders();
  }

  Future<void> loadUserAndOrders() async {
    userId = widget.userId;

    if (userId != null) {
      fetchOrders();
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> fetchOrders() async {
    if (userId == null) return;

    setState(() {
      isLoading = true;
    });

    try {
      String status = apiStatus[selectedIndex];

      final url = Uri.parse(
        "http://192.168.1.239:5000/api/order/user/$userId/status/$status",
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);

        setState(() {
          orders = data
              .map((e) => OrderModel.fromJson(e))
              .toList();
        });
      } else {
        setState(() {
          orders = [];
        });
      }
    } catch (e) {
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

              /// Header
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(
                      Icons.arrow_back,
                      size: screenWidth * 0.07,
                    ),
                  ),
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
                  SizedBox(width: screenWidth * 0.1),
                ],
              ),

              SizedBox(height: screenHeight * 0.02),

              /// Tabs
              Wrap(
                spacing: screenWidth * 0.03,
                children: List.generate(
                  tabs.length,
                  (index) {
                    bool isSelected =
                        selectedIndex == index;

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedIndex = index;
                        });

                        fetchOrders();
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal:
                              screenWidth * 0.04,
                          vertical:
                              screenHeight * 0.012,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Colors.blue
                              : Colors.white,
                          borderRadius:
                              BorderRadius.circular(
                                  12),
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

              /// Order list
              Expanded(
                child: isLoading
                    ? const Center(
                        child:
                            CircularProgressIndicator(),
                      )
                    : orders.isEmpty
                        ? const Center(
                            child: Text(
                              "Không có đơn hàng",
                            ),
                          )
                        : ListView.builder(
                            itemCount: orders.length,
                            itemBuilder:
                                (context, index) {
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

  Widget orderItem(
    double screenWidth,
    double screenHeight,
    OrderModel order,
  ) {
    return Container(
      margin: EdgeInsets.only(
        bottom: screenHeight * 0.02,
      ),
      padding: EdgeInsets.all(
        screenWidth * 0.03,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.local_shipping_outlined,
                color: Colors.orange,
                size: screenWidth * 0.06,
              ),
              SizedBox(
                width: screenWidth * 0.02,
              ),
              Expanded(
                child: Text(
                  order.orderCode,
                  style: TextStyle(
                    fontSize:
                        screenWidth * 0.045,
                    fontWeight:
                        FontWeight.w500,
                  ),
                ),
              )
            ],
          ),

          SizedBox(
            height: screenHeight * 0.01,
          ),

          Text(
            "Người nhận: ${order.shippingName}",
          ),
          Text(
            "SĐT: ${order.shippingPhone}",
          ),
          Text(
            "Địa chỉ: ${order.shippingAddress}",
          ),

          SizedBox(
            height: screenHeight * 0.01,
          ),

          Text(
            "${order.totalPrice} đ",
            style: const TextStyle(
              color: Colors.red,
              fontWeight:
                  FontWeight.bold,
            ),
          )
        ],
      ),
    );
  }
}