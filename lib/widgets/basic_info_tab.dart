import 'package:flutter/material.dart';
import '../models/item.dart';

class BasicInfoTab extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController descriptionController;
  final TextEditingController brandController;
  final TextEditingController modelController;
  final TextEditingController serialNumberController;
  final TextEditingController locationController;
  final TextEditingController tagController;
  
  final String? selectedCategory;
  final ItemStatus selectedStatus;
  final ItemCondition selectedCondition;
  final List<String> tags;
  
  final Function(String?) onCategoryChanged;
  final Function(ItemStatus) onStatusChanged;
  final Function(ItemCondition) onConditionChanged;
  final Function(String) onAddTag;
  final Function(String) onRemoveTag;

  const BasicInfoTab({
    super.key,
    required this.nameController,
    required this.descriptionController,
    required this.brandController,
    required this.modelController,
    required this.serialNumberController,
    required this.locationController,
    required this.tagController,
    required this.selectedCategory,
    required this.selectedStatus,
    required this.selectedCondition,
    required this.tags,
    required this.onCategoryChanged,
    required this.onStatusChanged,
    required this.onConditionChanged,
    required this.onAddTag,
    required this.onRemoveTag,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 物品名称
          _buildSectionTitle('物品名称 *'),
          TextFormField(
            controller: nameController,
            decoration: InputDecoration(
              hintText: '请输入物品名称',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return '请输入物品名称';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),

          // 品牌和型号
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle('品牌'),
                    TextFormField(
                      controller: brandController,
                      decoration: InputDecoration(
                        hintText: '品牌',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle('型号'),
                    TextFormField(
                      controller: modelController,
                      decoration: InputDecoration(
                        hintText: '型号',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // 分类选择
          _buildSectionTitle('分类'),
          _buildCategorySelector(),
          const SizedBox(height: 20),

          // 状态和成色
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle('状态'),
                    _buildStatusSelector(),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle('成色'),
                    _buildConditionSelector(),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // 序列号
          _buildSectionTitle('序列号'),
          TextFormField(
            controller: serialNumberController,
            decoration: InputDecoration(
              hintText: '设备序列号（可选）',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // 存放位置
          _buildSectionTitle('存放位置'),
          TextFormField(
            controller: locationController,
            decoration: InputDecoration(
              hintText: '物品存放位置',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // 标签
          _buildSectionTitle('标签'),
          _buildTagsInput(),
          const SizedBox(height: 20),

          // 描述
          _buildSectionTitle('描述'),
          TextFormField(
            controller: descriptionController,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: '物品的详细描述（可选）',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildCategorySelector() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedCategory,
          isExpanded: true,
          hint: const Text('选择分类'),
          items: ItemCategory.categories.map((category) {
            return DropdownMenuItem<String>(
              value: category,
              child: Row(
                children: [
                  Icon(
                    ItemCategory.getCategoryIcon(category),
                    color: ItemCategory.getCategoryColor(category),
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Text(category),
                ],
              ),
            );
          }).toList(),
          onChanged: onCategoryChanged,
        ),
      ),
    );
  }

  Widget _buildStatusSelector() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<ItemStatus>(
          value: selectedStatus,
          isExpanded: true,
          items: ItemStatus.values.map((status) {
            return DropdownMenuItem<ItemStatus>(
              value: status,
              child: Row(
                children: [
                  Icon(
                    status.statusIcon,
                    color: status.statusColor,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(status.statusDisplayName),
                ],
              ),
            );
          }).toList(),
          onChanged: (value) => onStatusChanged(value!),
        ),
      ),
    );
  }

  Widget _buildConditionSelector() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<ItemCondition>(
          value: selectedCondition,
          isExpanded: true,
          items: ItemCondition.values.map((condition) {
            return DropdownMenuItem<ItemCondition>(
              value: condition,
              child: Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: condition.conditionColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(condition.conditionDisplayName),
                ],
              ),
            );
          }).toList(),
          onChanged: (value) => onConditionChanged(value!),
        ),
      ),
    );
  }

  Widget _buildTagsInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 标签输入框
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: tagController,
                decoration: InputDecoration(
                  hintText: '输入标签后按回车添加',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onSubmitted: onAddTag,
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: () => onAddTag(tagController.text),
              icon: const Icon(Icons.add),
            ),
          ],
        ),
        
        // 标签显示
        if (tags.isNotEmpty) ...[
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: tags.map((tag) {
              return Chip(
                label: Text(tag),
                deleteIcon: const Icon(Icons.close, size: 16),
                onDeleted: () => onRemoveTag(tag),
                backgroundColor: Colors.blue.withAlpha(26),
                side: BorderSide(color: Colors.blue.withAlpha(78)),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }
}

// 扩展枚举以添加显示属性
extension ItemStatusExtension on ItemStatus {
  String get statusDisplayName {
    switch (this) {
      case ItemStatus.active:
        return '在用';
      case ItemStatus.idle:
        return '闲置';
      case ItemStatus.damaged:
        return '损坏';
      case ItemStatus.sold:
        return '已出售';
      case ItemStatus.lost:
        return '丢失';
    }
  }

  Color get statusColor {
    switch (this) {
      case ItemStatus.active:
        return Colors.green;
      case ItemStatus.idle:
        return Colors.orange;
      case ItemStatus.damaged:
        return Colors.red;
      case ItemStatus.sold:
        return Colors.blue;
      case ItemStatus.lost:
        return Colors.grey;
    }
  }

  IconData get statusIcon {
    switch (this) {
      case ItemStatus.active:
        return Icons.check_circle;
      case ItemStatus.idle:
        return Icons.pause_circle;
      case ItemStatus.damaged:
        return Icons.error;
      case ItemStatus.sold:
        return Icons.sell;
      case ItemStatus.lost:
        return Icons.help;
    }
  }
}

extension ItemConditionExtension on ItemCondition {
  String get conditionDisplayName {
    switch (this) {
      case ItemCondition.newItem:
        return '全新';
      case ItemCondition.likeNew:
        return '几乎全新';
      case ItemCondition.excellent:
        return '优秀';
      case ItemCondition.good:
        return '良好';
      case ItemCondition.fair:
        return '一般';
      case ItemCondition.poor:
        return '较差';
    }
  }

  Color get conditionColor {
    switch (this) {
      case ItemCondition.newItem:
        return Colors.green;
      case ItemCondition.likeNew:
        return Colors.lightGreen;
      case ItemCondition.excellent:
        return Colors.blue;
      case ItemCondition.good:
        return Colors.orange;
      case ItemCondition.fair:
        return Colors.deepOrange;
      case ItemCondition.poor:
        return Colors.red;
    }
  }
}
