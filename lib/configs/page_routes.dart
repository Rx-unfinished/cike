import 'package:flutter/material.dart';
import '../widgets/pages/messages_page.dart';

class PageRoutes {
  static Widget getPage({required String pageType}) {
    switch (pageType) {
      case 'messages':
        return MessagesPage();
      default:
        return Center(
          child: Text(
            '页面: $pageType',
            style: TextStyle(color: Colors.white),
          ),
        );
    }
  }
}
