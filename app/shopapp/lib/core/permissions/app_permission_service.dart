import 'package:permission_handler/permission_handler.dart';

class AppPermissionService {
  const AppPermissionService();

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
