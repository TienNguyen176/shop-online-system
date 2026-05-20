import 'package:permission_handler/permission_handler.dart';

class AppPermissionService {
  const AppPermissionService();

  /// Yeu cau quyen hoac tac vu can thiet khi khoi dong.
  Future<void> requestStartupPermissions() async {
    final permissions = <Permission>[
      Permission.notification,
      Permission.camera,
      Permission.photos,
      Permission.videos,
      Permission.storage,
    ];

    for (final permission in permissions) {
      final status = await permission.status;
      if (status.isGranted || status.isLimited || status.isPermanentlyDenied) {
        continue;
      }

      await permission.request();
    }
  }
}
