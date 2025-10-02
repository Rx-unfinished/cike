import 'package:flutter/material.dart';
import '../models/tag.dart';
import '../services/tag_service.dart';

class TagsSelector extends StatelessWidget {
  final String query;  // 当前输入的标签文本（#后面的部分）
  final Function(String) onTagSelected;  // 选中标签的回调
  
  const TagsSelector({
    super.key,
    required this.query,
    required this.onTagSelected,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Tag>>(
      future: TagService().searchTags(query),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return SizedBox.shrink();  // 没有建议就不显示
        }

        final tags = snapshot.data!;
        
        return Container(
          constraints: BoxConstraints(maxHeight: 200),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(26),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: tags.length,
            itemBuilder: (context, index) {
              final tag = tags[index];
              return ListTile(
                dense: true,
                leading: Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: tag.flutterColor,
                    shape: BoxShape.circle,
                  ),
                ),
                title: Text('#${tag.name}'),
                onTap: () => onTagSelected(tag.name),
              );
            },
          ),
        );
      },
    );
  }
}