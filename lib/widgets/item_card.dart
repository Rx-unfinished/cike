import 'package:flutter/material.dart';
import '../models/item.dart';

class ItemCard extends StatelessWidget {
  final Item item;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const ItemCard({
    super.key,
    required this.item,
    this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(10),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 物品图片或图标
            _buildItemImage(),
            
            // 物品信息
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 状态标签
                    Row(
                      children: [
                        _buildStatusBadge(),
                        const Spacer(),
                        _buildCategoryBadge(),
                      ],
                    ),
                    const SizedBox(height: 8),
                    
                    // 物品名称
                    Text(
                      item.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    
                    // 品牌型号
                    if (item.brand != null || item.model != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        _buildBrandModel(),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    
                    const Spacer(),
                    
                    // 购买信息
                    _buildPurchaseInfo(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemImage() {
    return Container(
      height: 120,
      width: double.infinity,
      decoration: BoxDecoration(
        color: ItemCategory.getCategoryColor(item.category).withAlpha(26),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
      ),
      child: item.imageUrl != null && item.imageUrl!.isNotEmpty
          ? ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: Image.network(
                item.imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => _buildDefaultIcon(),
              ),
            )
          : _buildDefaultIcon(),
    );
  }

  Widget _buildDefaultIcon() {
    return Center(
      child: Icon(
        ItemCategory.getCategoryIcon(item.category),
        size: 48,
        color: ItemCategory.getCategoryColor(item.category),
      ),
    );
  }

  Widget _buildStatusBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: item.statusColor.withAlpha(26),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: item.statusColor.withAlpha(78)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            item.statusIcon,
            size: 12,
            color: item.statusColor,
          ),
          const SizedBox(width: 4),
          Text(
            item.statusDisplayName,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: item.statusColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryBadge() {
    if (item.category == null) return const SizedBox.shrink();
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        item.category!,
        style: TextStyle(
          fontSize: 9,
          color: Colors.grey[600],
        ),
      ),
    );
  }

  String _buildBrandModel() {
    final parts = <String>[];
    if (item.brand != null && item.brand!.isNotEmpty) {
      parts.add(item.brand!);
    }
    if (item.model != null && item.model!.isNotEmpty) {
      parts.add(item.model!);
    }
    return parts.join(' ');
  }

  Widget _buildPurchaseInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // 购买价格
        if (item.purchasePrice != null) ...[
          Row(
            children: [
              Icon(
                Icons.attach_money,
                size: 12,
                color: Colors.grey[500],
              ),
              const SizedBox(width: 2),
              Text(
                item.formattedPurchasePrice,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
        ],
        
        // 购买日期或持有天数
        Row(
          children: [
            Icon(
              Icons.schedule,
              size: 12,
              color: Colors.grey[500],
            ),
            const SizedBox(width: 2),
            Expanded(
              child: Text(
                _getPurchaseTimeText(),
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey[500],
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        
        // 成色
        const SizedBox(height: 4),
        Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: item.conditionColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              item.conditionDisplayName,
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _getPurchaseTimeText() {
    if (item.purchaseDate != null) {
      final days = item.daysOwned;
      if (days < 30) {
        return '$days天前购买';
      } else if (days < 365) {
        final months = (days / 30).floor();
        return '$months个月前购买';
      } else {
        final years = (days / 365).floor();
        return '$years年前购买';
      }
    } else {
      final days = DateTime.now().difference(item.createdAt).inDays;
      return '$days天前添加';
    }
  }
}

// 网格布局的物品卡片（紧凑版）
class ItemGridCard extends StatelessWidget {
  final Item item;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const ItemGridCard({
    super.key,
    required this.item,
    this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(10),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 简化的图片区域
            Container(
              height: 80,
              width: double.infinity,
              decoration: BoxDecoration(
                color: ItemCategory.getCategoryColor(item.category).withAlpha(26),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              ),
              child: Center(
                child: Icon(
                  ItemCategory.getCategoryIcon(item.category),
                  size: 32,
                  color: ItemCategory.getCategoryColor(item.category),
                ),
              ),
            ),
            
            // 紧凑的信息区域
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 状态指示器
                    Row(
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: item.statusColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            item.statusDisplayName,
                            style: TextStyle(
                              fontSize: 9,
                              color: item.statusColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    
                    // 物品名称
                    Text(
                      item.name,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    
                    const Spacer(),
                    
                    // 价格信息
                    if (item.purchasePrice != null) ...[
                      Text(
                        item.formattedPurchasePrice,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
