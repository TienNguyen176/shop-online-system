-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Máy chủ: 127.0.0.1
-- Thời gian đã tạo: Th5 19, 2026 lúc 06:22 PM
-- Phiên bản máy phục vụ: 10.4.32-MariaDB
-- Phiên bản PHP: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Cơ sở dữ liệu: `shop_db`
--

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `attributes`
--

CREATE TABLE `attributes` (
  `id` bigint(20) NOT NULL,
  `name` varchar(50) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Đang đổ dữ liệu cho bảng `attributes`
--

INSERT INTO `attributes` (`id`, `name`) VALUES
(1, 'Kích thước'),
(2, 'Màu sắc'),
(3, 'Chất liệu'),
(4, 'Loại da'),
(5, 'Dung tích'),
(6, 'Vùng cơ thể'),
(7, 'Kết nối'),
(8, 'Loại tai nghe'),
(9, 'Dung lượng pin');

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `attribute_values`
--

CREATE TABLE `attribute_values` (
  `id` bigint(20) NOT NULL,
  `attribute_id` bigint(20) DEFAULT NULL,
  `value` varchar(100) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Đang đổ dữ liệu cho bảng `attribute_values`
--

INSERT INTO `attribute_values` (`id`, `attribute_id`, `value`) VALUES
(1, 1, 'S'),
(2, 1, 'M'),
(3, 1, 'L'),
(4, 1, 'XL'),
(5, 1, 'XXL'),
(6, 1, '38'),
(7, 1, '39'),
(8, 1, '40'),
(9, 1, '41'),
(10, 1, '42'),
(11, 1, '43'),
(40, 3, 'Cotton'),
(41, 3, 'Polyester'),
(42, 3, 'Jean'),
(43, 3, 'Len'),
(44, 3, 'Lụa'),
(60, 4, 'Da dầu'),
(61, 4, 'Da khô'),
(62, 4, 'Da hỗn hợp'),
(63, 4, 'Da nhạy cảm'),
(80, 5, '30ml'),
(81, 5, '50ml'),
(82, 5, '100ml'),
(83, 5, '200ml'),
(84, 5, '500ml'),
(100, 6, 'Mặt'),
(101, 6, 'Toàn thân'),
(102, 6, 'Tóc'),
(103, 6, 'Tay'),
(104, 6, 'Chân'),
(120, 7, 'Jack 3.5mm'),
(121, 7, 'Type-C'),
(122, 7, 'Bluetooth'),
(123, 7, 'USB'),
(124, 7, 'Lightning'),
(140, 8, 'Có dây'),
(141, 8, 'Không dây'),
(160, 9, '10000mAh'),
(161, 9, '20000mAh'),
(162, 9, '30000mAh'),
(163, 9, '50000mAh'),
(200, 2, 'Đen'),
(201, 2, 'Trắng'),
(202, 2, 'Xám'),
(203, 2, 'Xanh Lam'),
(204, 2, 'Be'),
(205, 2, 'Đỏ'),
(206, 2, 'Xanh lá'),
(2077, 2, 'Hồng');

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `carts`
--

CREATE TABLE `carts` (
  `id` bigint(20) NOT NULL,
  `user_id` bigint(20) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Đang đổ dữ liệu cho bảng `carts`
--

INSERT INTO `carts` (`id`, `user_id`) VALUES
(2, 2);

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `cart_items`
--

CREATE TABLE `cart_items` (
  `id` bigint(20) NOT NULL,
  `cart_id` bigint(20) DEFAULT NULL,
  `variant_id` bigint(20) DEFAULT NULL,
  `quantity` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Đang đổ dữ liệu cho bảng `cart_items`
--

INSERT INTO `cart_items` (`id`, `cart_id`, `variant_id`, `quantity`) VALUES
(2, 2, 51, 1),
(3, 2, 55, 1);

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `categories`
--

CREATE TABLE `categories` (
  `id` bigint(20) NOT NULL,
  `name` varchar(255) NOT NULL,
  `slug` varchar(255) NOT NULL,
  `parent_id` bigint(20) DEFAULT NULL,
  `level` int(11) NOT NULL,
  `image` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Đang đổ dữ liệu cho bảng `categories`
--

INSERT INTO `categories` (`id`, `name`, `slug`, `parent_id`, `level`, `image`) VALUES
(1, 'Thời Trang Nam', 'thoi-trang-nam', NULL, 1, 'cat_men.png'),
(2, 'Thời Trang Nữ', 'thoi-trang-nu', NULL, 1, 'cat_women.png'),
(3, 'Mỹ Phẩm', 'my-pham', NULL, 1, 'cat_beauty.png'),
(4, 'Điện Tử', 'dien-tu', NULL, 1, 'cat_electronic.png'),
(5, 'Giày Dép', 'giay-dep', NULL, 1, 'cat_shoes.png'),
(11, 'Áo Nam', 'ao-nam', 1, 2, NULL),
(12, 'Quần Nam', 'quan-nam', 1, 2, NULL),
(13, 'Phụ Kiện Nam', 'phu-kien-nam', 1, 2, NULL),
(21, 'Áo Nữ', 'ao-nu', 2, 2, NULL),
(22, 'Quần Nữ', 'quan-nu', 2, 2, NULL),
(23, 'Váy', 'vay', 2, 2, NULL),
(24, 'Phụ Kiện Nữ', 'phu-kien-nu', 2, 2, NULL),
(31, 'Trang Điểm', 'trang-diem', 3, 2, NULL),
(32, 'Chăm Sóc Da', 'cham-soc-da', 3, 2, NULL),
(33, 'Chăm Sóc Tóc', 'cham-soc-toc', 3, 2, NULL),
(41, 'Âm Thanh', 'am-thanh', 4, 2, NULL),
(42, 'Phụ Kiện Số', 'phu-kien-so', 4, 2, NULL);

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `notifications`
--

CREATE TABLE `notifications` (
  `id` bigint(20) NOT NULL,
  `user_id` bigint(20) DEFAULT NULL,
  `title` varchar(255) DEFAULT NULL,
  `message` text DEFAULT NULL,
  `type` varchar(50) DEFAULT NULL,
  `is_read` tinyint(1) DEFAULT 0,
  `created_at` datetime DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `orders`
--

CREATE TABLE `orders` (
  `id` bigint(20) NOT NULL,
  `order_code` varchar(50) NOT NULL,
  `user_id` bigint(20) DEFAULT NULL,
  `status` varchar(50) DEFAULT 'PENDING',
  `subtotal_price` decimal(12,2) DEFAULT 0.00,
  `shipping_fee` decimal(12,2) DEFAULT 0.00,
  `total_price` decimal(12,2) DEFAULT NULL,
  `shipping_name` varchar(255) DEFAULT NULL,
  `shipping_phone` varchar(20) DEFAULT NULL,
  `shipping_address` text DEFAULT NULL,
  `created_at` datetime DEFAULT current_timestamp(),
  `updated_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Đang đổ dữ liệu cho bảng `orders`
--

INSERT INTO `orders` (`id`, `order_code`, `user_id`, `status`, `subtotal_price`, `shipping_fee`, `total_price`, `shipping_name`, `shipping_phone`, `shipping_address`, `created_at`, `updated_at`) VALUES
(21, 'ORD_1E53AB3C', NULL, 'PENDING', 500000.00, 0.00, 500000.00, 'Nguyễn Văn Tiền', NULL, NULL, '2026-04-15 16:28:42', NULL),
(22, 'ORD_B0FF8F94', NULL, 'PENDING', 500000.00, 0.00, 500000.00, 'Nguyễn Văn Tiền', NULL, NULL, '2026-04-15 16:35:36', NULL),
(23, 'ORD_4873DE91', NULL, 'PENDING', 500000.00, 0.00, 500000.00, 'Nguyễn Văn Tiền', NULL, NULL, '2026-04-15 16:38:53', NULL),
(25, 'ORD_5C771A6B', 2, 'PENDING', 500000.00, 0.00, 500000.00, 'Nguyễn Văn Tiền', '0588405161', '181 Tô Vĩnh Diện', '2026-05-13 10:32:51', NULL),
(26, 'ORD_A986356B', 2, 'PENDING', 500000.00, 0.00, 500000.00, 'Nguyễn Văn Tiền', '0588405161', '181 Tô Vĩnh Diện', '2026-05-13 10:33:12', NULL);

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `order_items`
--

CREATE TABLE `order_items` (
  `id` bigint(20) NOT NULL,
  `order_id` bigint(20) DEFAULT NULL,
  `product_id` bigint(20) DEFAULT NULL,
  `variant_id` bigint(20) DEFAULT NULL,
  `product_name` varchar(255) DEFAULT NULL,
  `variant_name` varchar(255) DEFAULT NULL,
  `quantity` int(11) DEFAULT NULL,
  `price` decimal(12,2) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Đang đổ dữ liệu cho bảng `order_items`
--

INSERT INTO `order_items` (`id`, `order_id`, `product_id`, `variant_id`, `product_name`, `variant_name`, `quantity`, `price`) VALUES
(18, 21, 0, 51, 'Pin Dự Phòng 20000mAh Siêu Trâu', '', 1, 500000.00),
(19, 22, 0, 51, 'Pin Dự Phòng 20000mAh Siêu Trâu', '', 1, 500000.00),
(20, 23, 0, 51, 'Pin Dự Phòng 20000mAh Siêu Trâu', '', 1, 500000.00),
(21, 25, 0, 51, 'Pin Dự Phòng 20000mAh Siêu Trâu', '', 1, 500000.00),
(22, 26, 0, 51, 'Pin Dự Phòng 20000mAh Siêu Trâu', '', 1, 500000.00);

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `payments`
--

CREATE TABLE `payments` (
  `id` bigint(20) NOT NULL,
  `order_id` bigint(20) DEFAULT NULL,
  `payment_method_id` bigint(20) DEFAULT NULL,
  `transaction_id` varchar(255) DEFAULT NULL,
  `amount` decimal(12,2) DEFAULT 0.00,
  `product_amount` decimal(12,2) DEFAULT 0.00,
  `shipping_fee` decimal(12,2) DEFAULT 0.00,
  `total_amount` decimal(12,2) DEFAULT 0.00,
  `status` varchar(50) DEFAULT 'PENDING',
  `vnp_response_code` varchar(20) DEFAULT NULL,
  `bank_code` varchar(50) DEFAULT NULL,
  `paid_at` datetime DEFAULT NULL,
  `created_at` datetime DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Đang đổ dữ liệu cho bảng `payments`
--

INSERT INTO `payments` (`id`, `order_id`, `payment_method_id`, `transaction_id`, `amount`, `product_amount`, `shipping_fee`, `total_amount`, `status`, `vnp_response_code`, `bank_code`, `paid_at`, `created_at`) VALUES
(20, 21, 2, NULL, 500000.00, 500000.00, 0.00, 500000.00, 'PENDING', NULL, NULL, NULL, '2026-04-15 16:28:42'),
(21, 22, 2, NULL, 500000.00, 500000.00, 0.00, 500000.00, 'PENDING', NULL, NULL, NULL, '2026-04-15 16:35:36'),
(22, 23, 2, NULL, 500000.00, 500000.00, 0.00, 500000.00, 'PENDING', NULL, NULL, NULL, '2026-04-15 16:38:53'),
(23, 25, 2, NULL, 500000.00, 500000.00, 0.00, 500000.00, 'PENDING', NULL, NULL, NULL, '2026-05-13 10:32:51'),
(24, 26, 2, NULL, 500000.00, 500000.00, 0.00, 500000.00, 'PENDING', NULL, NULL, NULL, '2026-05-13 10:33:12');

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `payment_methods`
--

CREATE TABLE `payment_methods` (
  `id` bigint(20) NOT NULL,
  `name` varchar(50) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Đang đổ dữ liệu cho bảng `payment_methods`
--

INSERT INTO `payment_methods` (`id`, `name`) VALUES
(1, 'COD'),
(2, 'VNPAY'),
(3, 'MOMO'),
(4, 'BANK_TRANSFER');

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `products`
--

CREATE TABLE `products` (
  `id` bigint(20) NOT NULL,
  `name` varchar(255) DEFAULT NULL,
  `description` text DEFAULT NULL,
  `category_id` bigint(20) DEFAULT NULL,
  `brand` varchar(255) DEFAULT NULL,
  `rating_avg` decimal(3,2) DEFAULT 0.00,
  `rating_count` int(11) DEFAULT 0,
  `sold_count` int(11) DEFAULT 0,
  `created_at` datetime DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Đang đổ dữ liệu cho bảng `products`
--

INSERT INTO `products` (`id`, `name`, `description`, `category_id`, `brand`, `rating_avg`, `rating_count`, `sold_count`, `created_at`) VALUES
(1, 'Áo Thun Nam Cotton Basic Coofandy', 'Áo thun nam chất liệu cotton co giãn, thoáng mát, form regular fit mặc hàng ngày.', 11, 'COOFANDY', 4.60, 1200, 320, '2026-04-15 01:22:09'),
(2, 'Áo Sơ Mi Nam Dài Tay Công Sở', 'Áo sơ mi nam cao cấp, phù hợp đi làm, form slim fit, dễ phối đồ.', 11, 'Dior', 4.70, 980, 210, '2026-04-15 01:22:09'),
(3, 'Áo Hoodie Nam Form Rộng Unisex', 'Áo hoodie nam nữ form rộng, chất nỉ dày, phù hợp mùa lạnh.', 11, 'Routine', 4.50, 1500, 540, '2026-04-15 01:22:09'),
(4, 'Áo Khoác Gió Nam Chống Nước', 'Áo khoác gió nam chống nước nhẹ, phù hợp đi phượt, thể thao.', 11, 'OUTDOOR', 4.40, 860, 190, '2026-04-15 01:22:09'),
(5, 'Quần Jean Nam Slim Fit Co Giãn', 'Quần jean nam co giãn nhẹ, form slim fit, dễ phối đồ.', 12, 'Levis', 4.60, 1340, 410, '2026-04-15 01:22:09'),
(6, 'Áo Thun Nữ Form Rộng Basic', 'Áo thun nữ form rộng, chất cotton mềm mại, mặc cực thoải mái.', 21, 'Lacoste', 4.70, 2100, 780, '2026-04-15 01:22:09'),
(7, 'Áo Croptop Nữ Thời Trang', 'Áo croptop nữ trẻ trung, dễ phối với quần jean, chân váy.', 21, 'Adidas', 4.50, 890, 260, '2026-04-15 01:22:09'),
(8, 'Áo Sơ Mi Nữ Hàn Quốc', 'Áo sơ mi nữ phong cách Hàn Quốc, nhẹ nhàng, thanh lịch.', 21, 'Nike', 4.60, 740, 180, '2026-04-15 01:22:09'),
(9, 'Quần Jean Nữ Ống Rộng', 'Quần jean nữ ống rộng, phong cách streetwear.', 22, 'Uniqlo', 4.70, 980, 320, '2026-04-15 01:22:09'),
(10, 'Quần Short Nữ Lưng Cao', 'Quần short nữ lưng cao, tôn dáng, dễ phối đồ.', 22, 'H&M', 4.50, 620, 150, '2026-04-15 01:22:09'),
(11, 'Váy Nữ Dáng Dài Thanh Lịch', 'Váy nữ dáng dài, phù hợp đi chơi, đi làm.', 23, 'Lovito', 4.60, 540, 120, '2026-04-15 01:22:09'),
(12, 'Váy Body Nữ Gợi Cảm', 'Váy body ôm sát, tôn dáng cực đẹp.', 23, 'GUMAC', 4.70, 480, 90, '2026-04-15 01:22:09'),
(13, 'Son Lì Lâu Trôi Cao Cấp', 'Son lì lâu trôi, lên màu chuẩn, không gây khô môi.', 31, '3CE', 4.80, 2300, 900, '2026-04-15 01:22:09'),
(14, 'Kem Nền Trang Điểm Che Phủ Tốt', 'Kem nền che phủ tốt, phù hợp nhiều loại da.', 31, 'Maybelline', 4.70, 1750, 640, '2026-04-15 01:22:09'),
(15, 'Sữa Rửa Mặt Dịu Nhẹ', 'Sữa rửa mặt làm sạch sâu, không gây kích ứng.', 32, 'Senka', 4.60, 2600, 1100, '2026-04-15 01:22:09'),
(16, 'Kem Dưỡng Ẩm Da Mặt', 'Kem dưỡng ẩm giúp da mềm mịn, cấp nước tốt.', 32, 'Innisfree', 4.70, 1900, 850, '2026-04-15 01:22:09'),
(17, 'Dầu Gội Phục Hồi Tóc Hư Tổn', 'Dầu gội phục hồi tóc, giúp tóc chắc khỏe.', 33, 'L’Oréal', 4.50, 1400, 530, '2026-04-15 01:22:09'),
(18, 'Tai Nghe Bluetooth Không Dây', 'Tai nghe bluetooth pin trâu, âm thanh sống động.', 41, 'Xiaomi', 4.60, 3200, 1500, '2026-04-15 01:22:09'),
(19, 'Tai Nghe Có Dây Jack 3.5mm', 'Tai nghe có dây giá rẻ, âm thanh ổn định.', 41, 'Sony', 4.40, 1100, 420, '2026-04-15 01:22:09'),
(20, 'Giày Sneaker Nam Nữ Thời Trang', 'Giày sneaker unisex, đế êm, phù hợp đi học, đi chơi.', 5, 'MLB', 4.70, 2100, 880, '2026-04-15 01:22:09'),
(21, 'Áo Polo Nam Cao Cấp', 'Áo polo nam lịch sự, phù hợp đi làm và đi chơi.', 11, 'Uniqlo', 4.60, 870, 260, '2026-04-15 01:22:09'),
(22, 'Chân Váy Nữ Xếp Ly', 'Chân váy nữ xếp ly phong cách Hàn Quốc.', 23, 'Shein', 4.50, 640, 190, '2026-04-15 01:22:09'),
(23, 'Nước Tẩy Trang Dịu Nhẹ', 'Nước tẩy trang làm sạch sâu, không gây kích ứng.', 32, 'Bioderma', 4.80, 2100, 980, '2026-04-15 01:22:09'),
(24, 'Loa Bluetooth Mini Chống Nước', 'Loa bluetooth mini, chống nước IPX7, âm bass mạnh.', 41, 'Anker', 4.70, 1500, 520, '2026-04-15 01:22:09'),
(25, 'Dép Sandal Nam Thoải Mái', 'Dép sandal nam nhẹ, êm chân, phù hợp đi chơi.', 5, 'Vento', 4.40, 430, 140, '2026-04-15 01:22:09'),
(26, 'Tai Nghe Có Dây Type-C', 'Tai nghe có dây giá rẻ, âm thanh ổn định.', 41, 'Sony', 4.40, 1100, 420, '2026-04-15 01:22:09'),
(27, 'Củ Sạc Nhanh 20W Type-C', 'Củ sạc nhanh hỗ trợ PD 20W, tương thích nhiều thiết bị.', 42, 'Anker', 4.70, 1250, 480, '2026-04-15 01:22:09'),
(28, 'Cáp Sạc Lightning Chính Hãng', 'Cáp sạc Lightning bền bỉ, hỗ trợ sạc nhanh và truyền dữ liệu.', 42, 'Baseus', 4.60, 980, 350, '2026-04-15 01:22:09'),
(29, 'Pin Dự Phòng 10000mAh Sạc Nhanh', 'Pin dự phòng dung lượng 10000mAh, hỗ trợ sạc nhanh PD/QC, thiết kế nhỏ gọn.', 42, 'Xiaomi', 4.70, 1850, 720, '2026-04-15 01:22:09'),
(30, 'Pin Dự Phòng 20000mAh Siêu Trâu', 'Pin dự phòng dung lượng lớn 20000mAh, sạc nhiều lần, phù hợp đi du lịch.', 42, 'Anker', 4.80, 2400, 980, '2026-04-15 01:22:09');

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `product_images`
--

CREATE TABLE `product_images` (
  `id` bigint(20) NOT NULL,
  `product_id` bigint(20) DEFAULT NULL,
  `image_url` text DEFAULT NULL,
  `is_main` tinyint(1) DEFAULT 0,
  `variant_id` bigint(20) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Đang đổ dữ liệu cho bảng `product_images`
--

INSERT INTO `product_images` (`id`, `product_id`, `image_url`, `is_main`, `variant_id`) VALUES
(1, 1, 'uploads/images/products/1/main.jpg', 1, NULL),
(2, 2, 'uploads/images/products/2/main.jpg', 1, NULL),
(3, 3, 'uploads/images/products/3/main.jpg', 1, NULL),
(4, 4, 'uploads/images/products/4/main.jpg', 1, NULL),
(5, 5, 'uploads/images/products/5/main.jpg', 1, NULL),
(6, 6, 'uploads/images/products/6/main.jpg', 1, NULL),
(7, 7, 'uploads/images/products/7/main.jpg', 1, NULL),
(8, 8, 'uploads/images/products/8/main.jpg', 1, NULL),
(9, 9, 'uploads/images/products/9/main.jpg', 1, NULL),
(10, 10, 'uploads/images/products/10/main.jpg', 1, NULL),
(11, 11, 'uploads/images/products/11/main.jpg', 1, NULL),
(12, 12, 'uploads/images/products/12/main.jpg', 1, NULL),
(13, 13, 'uploads/images/products/13/main.jpg', 1, NULL),
(14, 14, 'uploads/images/products/14/main.jpg', 1, NULL),
(15, 15, 'uploads/images/products/15/main.jpg', 1, NULL),
(16, 16, 'uploads/images/products/16/main.jpg', 1, NULL),
(17, 17, 'uploads/images/products/17/main.jpg', 1, NULL),
(18, 18, 'uploads/images/products/18/main.jpg', 1, NULL),
(19, 19, 'uploads/images/products/19/main.jpg', 1, NULL),
(20, 20, 'uploads/images/products/20/main.jpg', 1, NULL),
(21, 21, 'uploads/images/products/21/main.jpg', 1, NULL),
(22, 22, 'uploads/images/products/22/main.jpg', 1, NULL),
(23, 23, 'uploads/images/products/23/main.jpg', 1, NULL),
(24, 24, 'uploads/images/products/24/main.jpg', 1, NULL),
(25, 25, 'uploads/images/products/25/main.jpg', 1, NULL),
(26, 26, 'uploads/images/products/26/main.jpg', 1, NULL),
(27, 27, 'uploads/images/products/27/main.jpg', 1, NULL),
(28, 28, 'uploads/images/products/28/main.jpg', 1, NULL),
(29, 29, 'uploads/images/products/29/main.jpg', 1, NULL),
(30, 30, 'uploads/images/products/30/main.jpg', 1, NULL),
(64, 1, 'uploads/images/products/1/thumb.jpg', 0, NULL),
(65, 2, 'uploads/images/products/2/thumb.jpg', 0, NULL),
(66, 3, 'uploads/images/products/3/thumb.jpg', 0, NULL),
(67, 4, 'uploads/images/products/4/thumb.jpg', 0, NULL),
(68, 5, 'uploads/images/products/5/thumb.jpg', 0, NULL),
(69, 6, 'uploads/images/products/6/thumb.jpg', 0, NULL),
(70, 7, 'uploads/images/products/7/thumb.jpg', 0, NULL),
(71, 8, 'uploads/images/products/8/thumb.jpg', 0, NULL),
(72, 9, 'uploads/images/products/9/thumb.jpg', 0, NULL),
(73, 10, 'uploads/images/products/10/thumb.jpg', 0, NULL),
(74, 11, 'uploads/images/products/11/thumb.jpg', 0, NULL),
(75, 12, 'uploads/images/products/12/thumb.jpg', 0, NULL),
(76, 13, 'uploads/images/products/13/thumb.jpg', 0, NULL),
(77, 14, 'uploads/images/products/14/thumb.jpg', 0, NULL),
(78, 15, 'uploads/images/products/15/thumb.jpg', 0, NULL),
(79, 16, 'uploads/images/products/16/thumb.jpg', 0, NULL),
(80, 17, 'uploads/images/products/17/thumb.jpg', 0, NULL),
(81, 18, 'uploads/images/products/18/thumb.jpg', 0, NULL),
(82, 19, 'uploads/images/products/19/thumb.jpg', 0, NULL),
(83, 20, 'uploads/images/products/20/thumb.jpg', 0, NULL),
(84, 21, 'uploads/images/products/21/thumb.jpg', 0, NULL),
(85, 22, 'uploads/images/products/22/thumb.jpg', 0, NULL),
(86, 23, 'uploads/images/products/23/thumb.jpg', 0, NULL),
(87, 24, 'uploads/images/products/24/thumb.jpg', 0, NULL),
(88, 25, 'uploads/images/products/25/thumb.jpg', 0, NULL),
(89, 26, 'uploads/images/products/26/thumb.jpg', 0, NULL),
(90, 27, 'uploads/images/products/27/thumb.jpg', 0, NULL),
(91, 28, 'uploads/images/products/28/thumb.jpg', 0, NULL),
(92, 29, 'uploads/images/products/29/thumb.jpg', 0, NULL),
(93, 30, 'uploads/images/products/30/thumb.jpg', 0, NULL),
(127, 1, 'uploads/images/products/1/thumb1.jpg', 0, NULL),
(128, 2, 'uploads/images/products/2/thumb1.jpg', 0, NULL),
(129, 3, 'uploads/images/products/3/thumb1.jpg', 0, NULL),
(130, 4, 'uploads/images/products/4/thumb1.jpg', 0, NULL),
(131, 5, 'uploads/images/products/5/thumb1.jpg', 0, NULL),
(132, 6, 'uploads/images/products/6/thumb1.jpg', 0, NULL),
(133, 7, 'uploads/images/products/7/thumb1.jpg', 0, NULL),
(134, 8, 'uploads/images/products/8/thumb1.jpg', 0, NULL),
(135, 9, 'uploads/images/products/9/thumb1.jpg', 0, NULL),
(136, 10, 'uploads/images/products/10/thumb1.jpg', 0, NULL),
(137, 11, 'uploads/images/products/11/thumb1.jpg', 0, NULL),
(138, 12, 'uploads/images/products/12/thumb1.jpg', 0, NULL),
(139, 13, 'uploads/images/products/13/thumb1.jpg', 0, NULL),
(140, 14, 'uploads/images/products/14/thumb1.jpg', 0, NULL),
(141, 15, 'uploads/images/products/15/thumb1.jpg', 0, NULL),
(142, 16, 'uploads/images/products/16/thumb1.jpg', 0, NULL),
(143, 17, 'uploads/images/products/17/thumb1.jpg', 0, NULL),
(144, 18, 'uploads/images/products/18/thumb1.jpg', 0, NULL),
(145, 19, 'uploads/images/products/19/thumb1.jpg', 0, NULL),
(146, 20, 'uploads/images/products/20/thumb1.jpg', 0, NULL),
(147, 21, 'uploads/images/products/21/thumb1.jpg', 0, NULL),
(148, 22, 'uploads/images/products/22/thumb1.jpg', 0, NULL),
(149, 23, 'uploads/images/products/23/thumb1.jpg', 0, NULL),
(150, 24, 'uploads/images/products/24/thumb1.jpg', 0, NULL),
(151, 25, 'uploads/images/products/25/thumb1.jpg', 0, NULL),
(152, 26, 'uploads/images/products/26/thumb1.jpg', 0, NULL),
(153, 27, 'uploads/images/products/27/thumb1.jpg', 0, NULL),
(154, 28, 'uploads/images/products/28/thumb1.jpg', 0, NULL),
(155, 29, 'uploads/images/products/29/thumb1.jpg', 0, NULL),
(156, 30, 'uploads/images/products/30/thumb1.jpg', 0, NULL),
(190, 1, 'uploads/images/products/1/thumb2.jpg', 0, NULL),
(191, 2, 'uploads/images/products/2/thumb2.jpg', 0, NULL),
(192, 3, 'uploads/images/products/3/thumb2.jpg', 0, NULL),
(193, 4, 'uploads/images/products/4/thumb2.jpg', 0, NULL),
(194, 5, 'uploads/images/products/5/thumb2.jpg', 0, NULL),
(195, 6, 'uploads/images/products/6/thumb2.jpg', 0, NULL),
(196, 7, 'uploads/images/products/7/thumb2.jpg', 0, NULL),
(197, 8, 'uploads/images/products/8/thumb2.jpg', 0, NULL),
(198, 9, 'uploads/images/products/9/thumb2.jpg', 0, NULL),
(199, 10, 'uploads/images/products/10/thumb2.jpg', 0, NULL),
(200, 11, 'uploads/images/products/11/thumb2.jpg', 0, NULL),
(201, 12, 'uploads/images/products/12/thumb2.jpg', 0, NULL),
(202, 13, 'uploads/images/products/13/thumb2.jpg', 0, NULL),
(203, 14, 'uploads/images/products/14/thumb2.jpg', 0, NULL),
(204, 15, 'uploads/images/products/15/thumb2.jpg', 0, NULL),
(205, 16, 'uploads/images/products/16/thumb2.jpg', 0, NULL),
(206, 17, 'uploads/images/products/17/thumb2.jpg', 0, NULL),
(207, 18, 'uploads/images/products/18/thumb2.jpg', 0, NULL),
(208, 19, 'uploads/images/products/19/thumb2.jpg', 0, NULL),
(209, 20, 'uploads/images/products/20/thumb2.jpg', 0, NULL),
(210, 21, 'uploads/images/products/21/thumb2.jpg', 0, NULL),
(211, 22, 'uploads/images/products/22/thumb2.jpg', 0, NULL),
(212, 23, 'uploads/images/products/23/thumb2.jpg', 0, NULL),
(213, 24, 'uploads/images/products/24/thumb2.jpg', 0, NULL),
(214, 25, 'uploads/images/products/25/thumb2.jpg', 0, NULL),
(215, 26, 'uploads/images/products/26/thumb2.jpg', 0, NULL),
(216, 27, 'uploads/images/products/27/thumb2.jpg', 0, NULL),
(217, 28, 'uploads/images/products/28/thumb2.jpg', 0, NULL),
(218, 29, 'uploads/images/products/29/thumb2.jpg', 0, NULL),
(219, 30, 'uploads/images/products/30/thumb2.jpg', 0, NULL);

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `product_variants`
--

CREATE TABLE `product_variants` (
  `id` bigint(20) NOT NULL,
  `product_id` bigint(20) NOT NULL,
  `sku` varchar(120) DEFAULT NULL,
  `price` decimal(12,2) DEFAULT NULL,
  `stock_quantity` int(11) DEFAULT 0,
  `created_at` datetime DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Đang đổ dữ liệu cho bảng `product_variants`
--

INSERT INTO `product_variants` (`id`, `product_id`, `sku`, `price`, `stock_quantity`, `created_at`) VALUES
(1, 1, 'coo-1-s-den-cotton', 150000.00, 20, '2026-04-15 01:22:09'),
(2, 1, 'coo-1-m-trang-cotton', 152000.00, 42, '2026-04-15 01:22:09'),
(3, 1, 'coo-1-l-xam-cotton', 155000.00, 30, '2026-04-15 01:22:09'),
(4, 1, 'coo-1-xl-do-cotton', 155000.00, 20, '2026-04-15 01:22:09'),
(5, 2, 'dio-2-m-trang-lua', 299000.00, 25, '2026-04-15 01:22:09'),
(6, 2, 'dio-2-l-xanh-lam-lua', 320000.00, 20, '2026-04-15 01:22:09'),
(7, 2, 'dio-2-xl-hong-lua', 379000.00, 15, '2026-04-15 01:22:09'),
(8, 3, 'rou-3-m-den-polyester', 280000.00, 35, '2026-04-15 01:22:09'),
(9, 3, 'rou-3-l-xam-polyester', 350000.00, 30, '2026-04-15 01:22:09'),
(10, 4, 'out-4-l-den-polyester', 400000.00, 20, '2026-04-15 01:22:09'),
(11, 4, 'out-4-xl-xam-polyester', 420000.00, 15, '2026-04-15 01:22:09'),
(12, 21, 'uni-21-m-trang-cotton', 249000.00, 30, '2026-04-15 01:22:09'),
(13, 21, 'uni-21-l-xanh-lam-cotton', 250000.00, 25, '2026-04-15 01:22:09'),
(14, 5, 'lev-5-m-den-jean', 249000.00, 20, '2026-04-15 01:22:09'),
(15, 5, 'lev-5-l-xanh-lam-jean', 319000.00, 18, '2026-04-15 01:22:09'),
(16, 6, 'lac-6-s-trang-cotton', 180000.00, 40, '2026-04-15 01:22:09'),
(17, 6, 'lac-6-m-hong-cotton', 189000.00, 35, '2026-04-15 01:22:09'),
(18, 6, 'lac-6-m-xam-cotton', 199000.00, 35, '2026-04-15 01:22:09'),
(19, 7, 'adi-7-s-do-polyester', 150000.00, 30, '2026-04-15 01:22:09'),
(20, 7, 'adi-7-m-den-polyester', 150000.00, 25, '2026-04-15 01:22:09'),
(21, 8, 'nik-8-m-trang-lua', 280000.00, 20, '2026-04-15 01:22:09'),
(22, 8, 'nik-8-l-be-lua', 280000.00, 18, '2026-04-15 01:22:09'),
(23, 9, 'uni-9-m-xanh-lam-jean', 320000.00, 25, '2026-04-15 01:22:09'),
(24, 9, 'uni-9-l-den-jean', 320000.00, 20, '2026-04-15 01:22:09'),
(25, 10, 'hm-10-s-den-cotton', 200000.00, 30, '2026-04-15 01:22:09'),
(26, 10, 'hm-10-m-trang-cotton', 200000.00, 25, '2026-04-15 01:22:09'),
(27, 11, 'lov-11-s-trang-lua', 350000.00, 15, '2026-04-15 01:22:09'),
(28, 11, 'lov-11-m-hong-lua', 350000.00, 12, '2026-04-15 01:22:09'),
(29, 12, 'gum-12-s-do-polyester', 400000.00, 10, '2026-04-15 01:22:09'),
(30, 12, 'gum-12-m-den-polyester', 400000.00, 10, '2026-04-15 01:22:09'),
(31, 22, 'she-22-s-be-polyester', 220000.00, 20, '2026-04-15 01:22:09'),
(32, 22, 'she-22-m-xam-polyester', 220000.00, 18, '2026-04-15 01:22:09'),
(33, 13, '3ce-13-30ml-mat', 250000.00, 50, '2026-04-15 01:22:09'),
(34, 13, '3ce-13-50ml-mat', 300000.00, 40, '2026-04-15 01:22:09'),
(35, 14, 'may-14-30ml-mat', 280000.00, 35, '2026-04-15 01:22:09'),
(36, 14, 'may-14-50ml-mat', 320000.00, 30, '2026-04-15 01:22:09'),
(37, 15, 'sen-15-100ml-mat', 120000.00, 60, '2026-04-15 01:22:09'),
(38, 15, 'sen-15-200ml-mat', 180000.00, 50, '2026-04-15 01:22:09'),
(39, 16, 'inn-16-50ml-mat', 220000.00, 40, '2026-04-15 01:22:09'),
(40, 16, 'inn-16-100ml-mat', 300000.00, 35, '2026-04-15 01:22:09'),
(41, 17, 'loa-17-500ml-toc', 150000.00, 45, '2026-04-15 01:22:09'),
(42, 23, 'bio-23-100ml-mat', 180000.00, 50, '2026-04-15 01:22:09'),
(43, 23, 'bio-23-200ml-mat', 220000.00, 45, '2026-04-15 01:22:09'),
(44, 18, 'xia-18-bluetooth-khong-day', 600000.00, 50, '2026-04-15 01:22:09'),
(45, 19, 'son-19-jack-3-5-co-day', 200000.00, 40, '2026-04-15 01:22:09'),
(46, 24, 'ank-24-bluetooth', 500000.00, 30, '2026-04-15 01:22:09'),
(47, 26, 'son-26-type-c-co-day', 250000.00, 35, '2026-04-15 01:22:09'),
(48, 27, 'ank-27-type-c', 180000.00, 50, '2026-04-15 01:22:09'),
(49, 28, 'bas-28-lightning', 120000.00, 60, '2026-04-15 01:22:09'),
(50, 29, 'xia-29-10000mah', 300000.00, 40, '2026-04-15 01:22:09'),
(51, 30, 'ank-30-20000mah', 500000.00, 35, '2026-04-15 01:22:09'),
(52, 20, 'mlb-20-40-den', 700000.00, 20, '2026-04-15 01:22:09'),
(53, 20, 'mlb-20-41-trang', 700000.00, 18, '2026-04-15 01:22:09'),
(54, 25, 'ven-25-40-den', 250000.00, 25, '2026-04-15 01:22:09'),
(55, 25, 'ven-25-41-nau', 250000.00, 20, '2026-04-15 01:22:09');

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `return_requests`
--

CREATE TABLE `return_requests` (
  `id` bigint(20) NOT NULL,
  `order_id` bigint(20) DEFAULT NULL,
  `user_id` bigint(20) DEFAULT NULL,
  `reason` text DEFAULT NULL,
  `status` varchar(50) DEFAULT NULL,
  `created_at` datetime DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `reviews`
--

CREATE TABLE `reviews` (
  `id` bigint(20) NOT NULL,
  `user_id` bigint(20) DEFAULT NULL,
  `product_id` bigint(20) DEFAULT NULL,
  `rating` int(11) DEFAULT NULL,
  `comment` text DEFAULT NULL,
  `created_at` datetime DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `users`
--

CREATE TABLE `users` (
  `id` bigint(20) NOT NULL,
  `provider` varchar(20) NOT NULL,
  `provider_user_id` varchar(255) DEFAULT NULL,
  `email` varchar(255) DEFAULT NULL,
  `full_name` varchar(255) DEFAULT NULL,
  `avatar` text DEFAULT NULL,
  `role` varchar(20) DEFAULT 'USER',
  `created_at` datetime DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Đang đổ dữ liệu cho bảng `users`
--

INSERT INTO `users` (`id`, `provider`, `provider_user_id`, `email`, `full_name`, `avatar`, `role`, `created_at`) VALUES
(2, 'google', '117864927828221912387', '23211tt3255@mail.tdc.edu.vn', 'Nguyễn Văn Tiền', 'https://lh3.googleusercontent.com/a/ACg8ocJ8zI2DATRxoGNnS6cuDUSOkqgnKwWR5tS2-TZtMO0T5CyCoZk=s96-c', 'user', '2026-04-15 09:28:00');

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `user_addresses`
--

CREATE TABLE `user_addresses` (
  `id` bigint(20) NOT NULL,
  `user_id` bigint(20) DEFAULT NULL,
  `receiver_name` varchar(255) DEFAULT NULL,
  `phone` varchar(20) DEFAULT NULL,
  `address_line` text DEFAULT NULL,
  `province_id` int(11) DEFAULT NULL,
  `province_name` varchar(100) DEFAULT NULL,
  `district_id` int(11) DEFAULT NULL,
  `district_name` varchar(100) DEFAULT NULL,
  `ward_code` varchar(20) DEFAULT NULL,
  `ward_name` varchar(100) DEFAULT NULL,
  `is_default` tinyint(1) DEFAULT 0,
  `created_at` datetime DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Đang đổ dữ liệu cho bảng `user_addresses`
--

INSERT INTO `user_addresses` (`id`, `user_id`, `receiver_name`, `phone`, `address_line`, `province_id`, `province_name`, `district_id`, `district_name`, `ward_code`, `ward_name`, `is_default`, `created_at`) VALUES
(1, 2, 'Nguyễn Văn Tiền', '0588405161', '181 Tô Vĩnh Diện', 205, 'Bình Dương', 1540, 'Thành phố Dĩ An', '440505', 'Phường Đông Hòa', 1, '2026-05-19 23:07:43');

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `variant_attributes`
--

CREATE TABLE `variant_attributes` (
  `variant_id` bigint(20) NOT NULL,
  `attribute_value_id` bigint(20) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Đang đổ dữ liệu cho bảng `variant_attributes`
--

INSERT INTO `variant_attributes` (`variant_id`, `attribute_value_id`) VALUES
(1, 1),
(1, 40),
(1, 200),
(2, 2),
(2, 40),
(2, 201),
(3, 3),
(3, 40),
(3, 202),
(4, 4),
(4, 40),
(4, 205),
(5, 2),
(5, 44),
(5, 201),
(6, 3),
(6, 44),
(6, 203),
(7, 4),
(7, 44),
(7, 2077),
(8, 2),
(8, 41),
(8, 200),
(9, 3),
(9, 41),
(9, 202),
(10, 3),
(10, 41),
(10, 200),
(11, 4),
(11, 41),
(11, 202),
(12, 2),
(12, 40),
(12, 201),
(13, 3),
(13, 40),
(13, 203),
(14, 2),
(14, 42),
(14, 200),
(15, 3),
(15, 42),
(15, 203),
(16, 1),
(16, 40),
(16, 201),
(17, 2),
(17, 40),
(17, 2077),
(18, 2),
(18, 40),
(18, 202),
(19, 1),
(19, 41),
(19, 205),
(20, 2),
(20, 41),
(20, 200),
(21, 2),
(21, 44),
(21, 201),
(22, 3),
(22, 44),
(22, 204),
(23, 2),
(23, 42),
(23, 203),
(24, 3),
(24, 42),
(24, 200),
(25, 1),
(25, 40),
(25, 200),
(26, 2),
(26, 40),
(26, 201),
(27, 1),
(27, 44),
(27, 201),
(28, 2),
(28, 44),
(28, 2077),
(29, 1),
(29, 41),
(29, 205),
(30, 2),
(30, 41),
(30, 200),
(31, 1),
(31, 41),
(31, 204),
(32, 2),
(32, 41),
(32, 202),
(33, 80),
(33, 100),
(34, 81),
(34, 100),
(35, 80),
(35, 100),
(36, 81),
(36, 100),
(37, 82),
(37, 100),
(38, 83),
(38, 100),
(39, 81),
(39, 100),
(40, 82),
(40, 100),
(41, 84),
(41, 102),
(42, 82),
(42, 100),
(43, 83),
(43, 100),
(44, 122),
(44, 141),
(45, 120),
(45, 140),
(46, 122),
(47, 121),
(47, 140),
(48, 121),
(49, 124),
(50, 160),
(51, 161),
(52, 8),
(52, 200),
(53, 9),
(53, 201),
(54, 8),
(54, 200),
(55, 9),
(55, 204);

--
-- Chỉ mục cho các bảng đã đổ
--

--
-- Chỉ mục cho bảng `attributes`
--
ALTER TABLE `attributes`
  ADD PRIMARY KEY (`id`);

--
-- Chỉ mục cho bảng `attribute_values`
--
ALTER TABLE `attribute_values`
  ADD PRIMARY KEY (`id`),
  ADD KEY `attribute_id` (`attribute_id`);

--
-- Chỉ mục cho bảng `carts`
--
ALTER TABLE `carts`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `user_id` (`user_id`);

--
-- Chỉ mục cho bảng `cart_items`
--
ALTER TABLE `cart_items`
  ADD PRIMARY KEY (`id`),
  ADD KEY `cart_id` (`cart_id`),
  ADD KEY `variant_id` (`variant_id`);

--
-- Chỉ mục cho bảng `categories`
--
ALTER TABLE `categories`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `slug` (`slug`),
  ADD KEY `parent_id` (`parent_id`);

--
-- Chỉ mục cho bảng `notifications`
--
ALTER TABLE `notifications`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_notifications_user` (`user_id`);

--
-- Chỉ mục cho bảng `orders`
--
ALTER TABLE `orders`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `order_code` (`order_code`),
  ADD KEY `idx_orders_user` (`user_id`);

--
-- Chỉ mục cho bảng `order_items`
--
ALTER TABLE `order_items`
  ADD PRIMARY KEY (`id`),
  ADD KEY `order_id` (`order_id`),
  ADD KEY `variant_id` (`variant_id`);

--
-- Chỉ mục cho bảng `payments`
--
ALTER TABLE `payments`
  ADD PRIMARY KEY (`id`),
  ADD KEY `order_id` (`order_id`),
  ADD KEY `payment_method_id` (`payment_method_id`);

--
-- Chỉ mục cho bảng `payment_methods`
--
ALTER TABLE `payment_methods`
  ADD PRIMARY KEY (`id`);

--
-- Chỉ mục cho bảng `products`
--
ALTER TABLE `products`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_products_category_created` (`category_id`,`created_at`);

--
-- Chỉ mục cho bảng `product_images`
--
ALTER TABLE `product_images`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_main_image` (`product_id`,`is_main`);

--
-- Chỉ mục cho bảng `product_variants`
--
ALTER TABLE `product_variants`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `sku` (`sku`),
  ADD UNIQUE KEY `uk_sku` (`sku`),
  ADD KEY `idx_variants_product` (`product_id`);

--
-- Chỉ mục cho bảng `return_requests`
--
ALTER TABLE `return_requests`
  ADD PRIMARY KEY (`id`),
  ADD KEY `order_id` (`order_id`),
  ADD KEY `user_id` (`user_id`);

--
-- Chỉ mục cho bảng `reviews`
--
ALTER TABLE `reviews`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `user_id` (`user_id`,`product_id`),
  ADD KEY `idx_reviews_product` (`product_id`);

--
-- Chỉ mục cho bảng `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `provider_user_id` (`provider_user_id`);

--
-- Chỉ mục cho bảng `user_addresses`
--
ALTER TABLE `user_addresses`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_id` (`user_id`);

--
-- Chỉ mục cho bảng `variant_attributes`
--
ALTER TABLE `variant_attributes`
  ADD PRIMARY KEY (`variant_id`,`attribute_value_id`),
  ADD KEY `idx_variant_attr_value` (`attribute_value_id`);

--
-- AUTO_INCREMENT cho các bảng đã đổ
--

--
-- AUTO_INCREMENT cho bảng `attributes`
--
ALTER TABLE `attributes`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10;

--
-- AUTO_INCREMENT cho bảng `attribute_values`
--
ALTER TABLE `attribute_values`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3000;

--
-- AUTO_INCREMENT cho bảng `carts`
--
ALTER TABLE `carts`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT cho bảng `cart_items`
--
ALTER TABLE `cart_items`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT cho bảng `categories`
--
ALTER TABLE `categories`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=100;

--
-- AUTO_INCREMENT cho bảng `notifications`
--
ALTER TABLE `notifications`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT cho bảng `orders`
--
ALTER TABLE `orders`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=27;

--
-- AUTO_INCREMENT cho bảng `order_items`
--
ALTER TABLE `order_items`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=23;

--
-- AUTO_INCREMENT cho bảng `payments`
--
ALTER TABLE `payments`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=25;

--
-- AUTO_INCREMENT cho bảng `payment_methods`
--
ALTER TABLE `payment_methods`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT cho bảng `products`
--
ALTER TABLE `products`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=51;

--
-- AUTO_INCREMENT cho bảng `product_images`
--
ALTER TABLE `product_images`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=240;

--
-- AUTO_INCREMENT cho bảng `product_variants`
--
ALTER TABLE `product_variants`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=349;

--
-- AUTO_INCREMENT cho bảng `return_requests`
--
ALTER TABLE `return_requests`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT cho bảng `reviews`
--
ALTER TABLE `reviews`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT cho bảng `users`
--
ALTER TABLE `users`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT cho bảng `user_addresses`
--
ALTER TABLE `user_addresses`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- Các ràng buộc cho các bảng đã đổ
--

--
-- Các ràng buộc cho bảng `attribute_values`
--
ALTER TABLE `attribute_values`
  ADD CONSTRAINT `attribute_values_ibfk_1` FOREIGN KEY (`attribute_id`) REFERENCES `attributes` (`id`);

--
-- Các ràng buộc cho bảng `carts`
--
ALTER TABLE `carts`
  ADD CONSTRAINT `carts_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`);

--
-- Các ràng buộc cho bảng `cart_items`
--
ALTER TABLE `cart_items`
  ADD CONSTRAINT `cart_items_ibfk_1` FOREIGN KEY (`cart_id`) REFERENCES `carts` (`id`),
  ADD CONSTRAINT `cart_items_ibfk_2` FOREIGN KEY (`variant_id`) REFERENCES `product_variants` (`id`) ON DELETE CASCADE;

--
-- Các ràng buộc cho bảng `categories`
--
ALTER TABLE `categories`
  ADD CONSTRAINT `categories_ibfk_1` FOREIGN KEY (`parent_id`) REFERENCES `categories` (`id`);

--
-- Các ràng buộc cho bảng `notifications`
--
ALTER TABLE `notifications`
  ADD CONSTRAINT `notifications_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`);

--
-- Các ràng buộc cho bảng `orders`
--
ALTER TABLE `orders`
  ADD CONSTRAINT `orders_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`);

--
-- Các ràng buộc cho bảng `order_items`
--
ALTER TABLE `order_items`
  ADD CONSTRAINT `order_items_ibfk_1` FOREIGN KEY (`order_id`) REFERENCES `orders` (`id`),
  ADD CONSTRAINT `order_items_ibfk_2` FOREIGN KEY (`variant_id`) REFERENCES `product_variants` (`id`) ON DELETE CASCADE;

--
-- Các ràng buộc cho bảng `payments`
--
ALTER TABLE `payments`
  ADD CONSTRAINT `payments_ibfk_1` FOREIGN KEY (`order_id`) REFERENCES `orders` (`id`),
  ADD CONSTRAINT `payments_ibfk_2` FOREIGN KEY (`payment_method_id`) REFERENCES `payment_methods` (`id`);

--
-- Các ràng buộc cho bảng `products`
--
ALTER TABLE `products`
  ADD CONSTRAINT `products_ibfk_1` FOREIGN KEY (`category_id`) REFERENCES `categories` (`id`);

--
-- Các ràng buộc cho bảng `product_images`
--
ALTER TABLE `product_images`
  ADD CONSTRAINT `product_images_ibfk_1` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON DELETE CASCADE;

--
-- Các ràng buộc cho bảng `product_variants`
--
ALTER TABLE `product_variants`
  ADD CONSTRAINT `product_variants_ibfk_1` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON DELETE CASCADE;

--
-- Các ràng buộc cho bảng `return_requests`
--
ALTER TABLE `return_requests`
  ADD CONSTRAINT `return_requests_ibfk_1` FOREIGN KEY (`order_id`) REFERENCES `orders` (`id`),
  ADD CONSTRAINT `return_requests_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`);

--
-- Các ràng buộc cho bảng `reviews`
--
ALTER TABLE `reviews`
  ADD CONSTRAINT `reviews_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`),
  ADD CONSTRAINT `reviews_ibfk_2` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`);

--
-- Các ràng buộc cho bảng `user_addresses`
--
ALTER TABLE `user_addresses`
  ADD CONSTRAINT `user_addresses_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`);

--
-- Các ràng buộc cho bảng `variant_attributes`
--
ALTER TABLE `variant_attributes`
  ADD CONSTRAINT `variant_attributes_ibfk_1` FOREIGN KEY (`variant_id`) REFERENCES `product_variants` (`id`),
  ADD CONSTRAINT `variant_attributes_ibfk_2` FOREIGN KEY (`attribute_value_id`) REFERENCES `attribute_values` (`id`) ON DELETE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
