import 'package:flutter/material.dart';
import 'package:seekcam/features/auth/auth_screen.dart';
import 'package:seekcam/features/camera/camera_screen.dart';
import 'package:seekcam/features/router/routes.dart';
import 'package:seekcam/features/views/view_store_data_screen.dart';
import 'package:seekcam/features/handler/permission_handler_screen.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case Routes.permissionHandler:
        return _buildRoute(const PermissionHandlerScreen());
      case Routes.auth:
        return _buildRoute(const AuthScreen());
      case Routes.camera:
        return _buildRoute(const CameraScreen());
      case Routes.viewStoredData:
        return _buildRoute(const ViewStoredDataScreen());
      default:
        return _buildRoute(const PermissionHandlerScreen());
    }
  }

  static PageRouteBuilder _buildRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.ease;
        var tween = Tween<Offset>(begin: begin, end: end)
            .chain(CurveTween(curve: curve));
        var offsetAnimation = animation.drive(tween);

        return SlideTransition(
          position: offsetAnimation,
          child: child,
        );
      },
    );
  }
}
