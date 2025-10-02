import 'package:flutter/material.dart';

class UserAvatar extends StatelessWidget {
  final double size;
  final VoidCallback? onTap;
  final String? imagePath;  // 新增：图片路径

  const UserAvatar({
    super.key,
    this.size = 40,
    this.onTap,
    this.imagePath,  // 可选参数
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size * 1.8,
        height: size * 1.8,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white,  // 头像框颜色
            width: 3,  // 头像框宽度
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(51),  // 20% 不透明度
              blurRadius: 8,
              spreadRadius: 2,
            ),
          ],
        ),
        child: CircleAvatar(
          radius: (size - 6) / 2,  // 减去边框宽度
          backgroundColor: Colors.grey[300],
          backgroundImage: imagePath != null 
            ? AssetImage('assets/images/avatar.jpg')  // 使用图片
            : null,
          child: imagePath == null 
            ? Icon(  // 没有图片时显示图标
                Icons.person,
                size: size,
                color: Colors.grey[600],
              )
            : null,
        ),
      ),
    );
  }
}
