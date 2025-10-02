import 'package:flutter/material.dart';

class MottoBar extends StatelessWidget {
  final String motto;

  const MottoBar({
    super.key,
    this.motto = '万里星途远，此刻花正开',  // 默认签名
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 8, right: 14, top: 10, bottom: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(128),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(26),
              blurRadius: 4,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Center(
          child: Text(
            motto,
            style: TextStyle(
              fontSize: 16,
              color: const Color.fromARGB(255, 60, 104, 55),
              fontStyle: FontStyle.italic,  // 斜体，增加格言感
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,  // 超长省略
          ),
        ),
      ),
    );
  }
}