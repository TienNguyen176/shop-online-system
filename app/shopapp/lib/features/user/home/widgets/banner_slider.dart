import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../../../core/config/app_config.dart';
import '../../../../models/product.dart';
import '../../product/screens/product_detail_screen.dart';

class BannerSlider extends StatefulWidget {
  final List<Product> products;

  const BannerSlider({super.key, required this.products});

  /// Tao state quan ly vong doi cua widget.
  @override
  State<BannerSlider> createState() => _BannerSliderState();
}

class _BannerSliderState extends State<BannerSlider> {
  int activeIndex = 0;

  /// Dong bo state khi widget cha cap nhat cau hinh.
  @override
  void didUpdateWidget(covariant BannerSlider oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (activeIndex >= widget.products.length && widget.products.isNotEmpty) {
      activeIndex = 0;
    }
  }

  /// Xay dung giao dien hien thi cho widget.
  @override
  Widget build(BuildContext context) {
    if (widget.products.isEmpty) {
      return const _BannerLoading();
    }

    return Column(
      children: [
        CarouselSlider.builder(
          itemCount: widget.products.length,
          itemBuilder: (context, index, realIndex) {
            final product = widget.products[index];
            final imageUrl =
                product.mainImage != null && product.mainImage!.isNotEmpty
                    ? "${AppConfig.apiUrl}/${product.mainImage}"
                    : null;

            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ProductDetailScreen(productId: product.id),
                  ),
                );
              },
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 22),
                decoration: BoxDecoration(
                  color: const Color(0xffbfdbfe),
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xff1d4ed8).withOpacity(0.14),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                clipBehavior: Clip.antiAlias,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (imageUrl != null)
                      CachedNetworkImage(
                        imageUrl: imageUrl,
                        fit: BoxFit.cover,
                        placeholder: (_, __) => _imageFallback(),
                        errorWidget: (_, __, ___) => _imageFallback(),
                      )
                    else
                      _imageFallback(),
                    Container(color: const Color(0xff1e3a8a).withOpacity(0.48)),
                    Positioned(
                      left: 20,
                      top: 18,
                      child: Text(
                        "SẢN PHẨM NỔI BẬT",
                        style: TextStyle(
                          color: const Color(0xffbfdbfe).withOpacity(0.95),
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 16,
                      right: 18,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.92),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.star_rounded,
                              color: Color(0xffffb020),
                              size: 16,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              product.ratingAvg.toStringAsFixed(1),
                              style: const TextStyle(
                                color: Color(0xff1f2937),
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      left: 20,
                      top: 42,
                      right: 96,
                      bottom: 62,
                      child: SingleChildScrollView(
                        physics: const NeverScrollableScrollPhysics(),
                        child: Text(
                          product.name,
                          softWrap: true,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            height: 1.16,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 20,
                      bottom: 18,
                      child: Container(
                        height: 38,
                        padding: const EdgeInsets.symmetric(horizontal: 18),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: const Color(0xff2563eb),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xff2563eb).withOpacity(0.28),
                              blurRadius: 14,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: const Text(
                          "Xem ngay",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
          options: CarouselOptions(
            height: 198,
            autoPlay: widget.products.length > 1,
            viewportFraction: 1,
            enlargeCenterPage: false,
            onPageChanged: (index, reason) {
              setState(() {
                activeIndex = index;
              });
            },
          ),
        ),
        const SizedBox(height: 10),
        AnimatedSmoothIndicator(
          activeIndex: activeIndex,
          count: widget.products.length,
          effect: const ExpandingDotsEffect(
            dotHeight: 6,
            dotWidth: 6,
            activeDotColor: Color(0xff2563eb),
            dotColor: Color(0xffbfdbfe),
          ),
        ),
      ],
    );
  }

  /// Hien thi giao dien thay the khi khong tai duoc du lieu.
  Widget _imageFallback() {
    return Container(
      color: const Color(0xffdbeafe),
      child: const Center(
        child: Icon(Icons.image_outlined, color: Color(0xff2563eb), size: 42),
      ),
    );
  }
}

class _BannerLoading extends StatelessWidget {
  const _BannerLoading();

  /// Xay dung giao dien hien thi cho widget.
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 178,
      margin: const EdgeInsets.symmetric(horizontal: 22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
      ),
      child: const Center(
        child: CircularProgressIndicator(color: Color(0xff2563eb)),
      ),
    );
  }
}
