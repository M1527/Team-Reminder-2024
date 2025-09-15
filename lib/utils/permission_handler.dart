import 'package:device_info_plus/device_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionHandler {
  PermissionHandler._();

  static late PermissionHandler _instance;

  static PermissionHandler getInstance() {
    _instance = PermissionHandler._();
    return _instance;
  }

  List<Permission> permissions = [Permission.storage];

  Future<void> initializePermission() async {
    final androidInfo = await DeviceInfoPlugin().androidInfo;
    if (androidInfo.version.sdkInt > 32) {
      permissions = [
        Permission.photos,
      ];
    }
  }

  bool isPermissionGranted = false;

  Future<bool> checkPermissions() async {
    await initializePermission();
    bool requestAllPermissionsGranted = true;
    for (final Permission perm in permissions) {
      final PermissionStatus status = await perm.request();
      if (status == PermissionStatus.permanentlyDenied ||
          status == PermissionStatus.denied) {
        requestAllPermissionsGranted = false;
      }
    }
    isPermissionGranted = requestAllPermissionsGranted;
    return requestAllPermissionsGranted;
  }
}
