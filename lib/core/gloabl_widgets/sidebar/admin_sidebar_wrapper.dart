import 'package:flutter/material.dart';
import 'package:greenbiller/core/app_theme.dart';
import 'package:greenbiller/core/gloabl_widgets/sidebar/admin_sidebar.dart';
import 'package:greenbiller/core/gloabl_widgets/sidebar/admin_topbar.dart';

class AdminSidebarWrapper extends StatelessWidget {
  final Widget child;
  final String title;
  final bool showSidebar;
  final Color? appColor;    // ✅ background color for AppBar
  final Color titleColor;   // ✅ new field for title text color

  const AdminSidebarWrapper({
    super.key,
    required this.child,
    required this.title,
    this.showSidebar = true,
    this.appColor,
    this.titleColor = Colors.white, // ✅ default = white
  });

  @override
  Widget build(BuildContext context) {
    final customTheme = AppTheme.theme.copyWith(
      appBarTheme: AppBarTheme(
        backgroundColor: appColor ?? AppTheme.theme.colorScheme.secondary,
        titleTextStyle: TextStyle(
          color: titleColor, // ✅ use custom or white
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: IconThemeData(
          color: titleColor, // ✅ icons match title color
        ),
      ),
    );

    return Theme(
      data: customTheme,
      child: Scaffold(
        appBar: AdminTopbar(title: title),
        drawer: showSidebar ?  AdminSidebar() : null,
        body: child,
      ),
    );
  }
}
