import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../auth/providers/auth_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final nameController = TextEditingController();

  File? _imageFile;
  bool _initialized = false;

  /// ===== BASE URL =====
  String getFullAvatarUrl(String? path) {
    if (path == null || path.isEmpty) return "";
    if (path.startsWith("http")) return path;
    return "http://192.168.1.148:5000$path";
  }

  /// ===== PICK IMAGE =====
  Future<void> pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);

    if (picked != null) {
      setState(() {
        _imageFile = File(picked.path);
      });
    }
  }

  /// ===== INIT DATA =====
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_initialized) {
      final user = context.read<AuthProvider>().user;

      if (user != null) {
        nameController.text = user['fullName'] ?? "";
      }

      _initialized = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.user;

    return Scaffold(
      appBar: AppBar(title: const Text("Thông tin cá nhân")),
      body:
          user == null
              ? const Center(child: Text("Không có dữ liệu"))
              : SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    /// ===== AVATAR =====
                    GestureDetector(
                      onTap: pickImage,
                      child: CircleAvatar(
                        radius: 50,
                        backgroundImage:
                            _imageFile != null
                                ? FileImage(_imageFile!)
                                : (user['avatar'] != null
                                    ? NetworkImage(
                                      getFullAvatarUrl(user['avatar']),
                                    )
                                    : null),
                        child:
                            _imageFile == null && user['avatar'] == null
                                ? const Icon(Icons.person, size: 40)
                                : null,
                      ),
                    ),

                    const SizedBox(height: 10),
                    const Text("Nhấn để chọn ảnh"),

                    const SizedBox(height: 20),

                    /// ===== FULL NAME =====
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: "Họ tên",
                        border: OutlineInputBorder(),
                      ),
                    ),

                    const SizedBox(height: 20),

                    /// ===== EMAIL =====
                    TextFormField(
                      initialValue: user['email'] ?? "",
                      readOnly: true,
                      decoration: const InputDecoration(
                        labelText: "Email",
                        border: OutlineInputBorder(),
                      ),
                    ),

                    const SizedBox(height: 30),

                    /// ===== SAVE =====
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed:
                            auth.loading
                                ? null
                                : () async {
                                  await auth.updateProfile(
                                    fullName: nameController.text,
                                    avatarPath: _imageFile?.path,
                                  );
                                  if (!mounted) return;

                                  /// HIỆN THÔNG BÁO
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text("Cập nhật thành công"),
                                      duration: Duration(milliseconds: 1200),
                                    ),
                                  );

                                  ///sang home
                                  Future.delayed(
                                    const Duration(milliseconds: 1200),
                                    () {
                                      if (mounted) {
                                        Navigator.pop(context);
                                      }
                                    },
                                  );
                                },

                        child:
                            auth.loading
                                ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                                : const Text("Lưu"),
                      ),
                    ),
                  ],
                ),
              ),
    );
  }
}
