import 'package:flutter/material.dart';
import '../models/item.dart';
import '../services/item_service.dart';
import '../widgets/item_card.dart';
import 'add_item_page.dart';

class ItemListPage extends StatefulWidget {
  const ItemListPage({super.key});

  @override
  State<ItemListPage> createState() => _ItemListPageState();
}

class _ItemListPageState extends State<ItemListPage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  
  List<Item> _allItems = [];
  List<Item> _filteredItems = [];
  Map<String, int> _categoryStats = {};
  Map<ItemStatus, int> _statusStats = {};
  
  bool _isLoading = true;
  bool _isGridView = true;
  ItemStatus? _selectedStatus;
  String? _selectedCategory;
  String _searchQuery = '';

  final List<ItemStatus> _statusTabs = [
    ItemStatus.active,
    ItemStatus.idle,
    ItemStatus.damaged,
    ItemStatus.sold,
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _statusTabs.length + 1, vsync: this);
    _tabController.addListener(_onTabChanged);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) {
      setState(() {
        if (_tabController.index == 0) {
          _selectedStatus = null; // 全部
        } else {
          _selectedStatus = _statusTabs[_tabController.index - 1];
        }
        _filterItems();
      });
    }
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final futures = await Future.wait([
        ItemService.getItems(),
        ItemService.getItemStatsByCategory(),
        ItemService.getItemStatsByStatus(),
      ]);

      setState(() {
        _allItems = futures[0] as List<Item>;
        _categoryStats = futures[1] as Map<String, int>;
        _statusStats = futures[2] as Map<ItemStatus, int>;
        _filterItems();
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('加载失败: $e')),
      );
    }
  }

  void _filterItems() {
    var filtered = _allItems.where((item) {
      // 状态筛选
      if (_selectedStatus != null && item.status != _selectedStatus) {
        return false;
      }
      
      // 分类筛选
      if (_selectedCategory != null && item.category != _selectedCategory) {
        return false;
      }
      
      // 搜索筛选
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        return item.name.toLowerCase().contains(query) ||
               (item.brand?.toLowerCase().contains(query) ?? false) ||
               (item.model?.toLowerCase().contains(query) ?? false) ||
               (item.description?.toLowerCase().contains(query) ?? false);
      }
      
      return true;
    }).toList();

    setState(() {
      _filteredItems = filtered;
    });
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
      _filterItems();
    });
  }

  void _showCategoryFilter() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '选择分类',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            
            // 全部分类选项
            ListTile(
              leading: const Icon(Icons.all_inclusive),
              title: const Text('全部分类'),
              trailing: _selectedCategory == null 
                  ? const Icon(Icons.check, color: Colors.blue) 
                  : null,
              onTap: () {
                setState(() {
                  _selectedCategory = null;
                  _filterItems();
                });
                Navigator.pop(context);
              },
            ),
            
            const Divider(),
            
            // 分类列表
            ...ItemCategory.categories.map((category) {
              final count = _categoryStats[category] ?? 0;
              return ListTile(
                leading: Icon(
                  ItemCategory.getCategoryIcon(category),
                  color: ItemCategory.getCategoryColor(category),
                ),
                title: Text(category),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$count',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                    if (_selectedCategory == category) ...[
                      const SizedBox(width: 8),
                      const Icon(Icons.check, color: Colors.blue),
                    ],
                  ],
                ),
                onTap: () {
                  setState(() {
                    _selectedCategory = category;
                    _filterItems();
                  });
                  Navigator.pop(context);
                },
              );
            }),
          ],
        ),
      ),
    );
  }

  void _handleItemTap(Item item) {
    // 跳转到物品详情页
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('查看${item.name}详情')),
    );
  }

  void _handleItemLongPress(Item item) {
    // 显示操作菜单
    _showItemMenu(item);
  }

  void _showItemMenu(Item item) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('编辑'),
              onTap: () {
                Navigator.pop(context);
                // 跳转到编辑页面
              },
            ),
            ListTile(
              leading: const Icon(Icons.build),
              title: const Text('添加维修记录'),
              onTap: () {
                Navigator.pop(context);
                // 添加维修记录
              },
            ),
            if (item.status != ItemStatus.sold) ...[
              ListTile(
                leading: const Icon(Icons.sell),
                title: const Text('出售'),
                onTap: () {
                  Navigator.pop(context);
                  // 出售物品
                },
              ),
            ],
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('删除', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                _confirmDelete(item);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(Item item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: Text('确定要删除物品"${item.name}"吗？此操作不可撤销。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () async {
              final navigator = Navigator.of(context);
              final messenger = ScaffoldMessenger.of(context);

              navigator.pop();
              final success = await ItemService.deleteItem(item.id!);

              if (!mounted) return;
              
              if (success) {
                _loadData();
                messenger.showSnackBar(
                  const SnackBar(content: Text('删除成功')),
                );
              } else {
                messenger.showSnackBar(
                  const SnackBar(content: Text('删除失败')),
                );
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('物品管理'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          // 视图切换按钮
          IconButton(
            icon: Icon(_isGridView ? Icons.view_list : Icons.grid_view),
            onPressed: () {
              setState(() {
                _isGridView = !_isGridView;
              });
            },
          ),
          
          // 分类筛选按钮
          IconButton(
            icon: Icon(
              Icons.filter_list,
              color: _selectedCategory != null ? Colors.blue : null,
            ),
            onPressed: _showCategoryFilter,
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(120),
          child: Column(
            children: [
              // 搜索框
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: '搜索物品名称、品牌或型号',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              _onSearchChanged('');
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.blue),
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                  ),
                  onChanged: _onSearchChanged,
                ),
              ),
              const SizedBox(height: 12),
              
              // 状态Tab
              TabBar(
                controller: _tabController,
                isScrollable: true,
                labelColor: Colors.blue,
                unselectedLabelColor: Colors.grey,
                indicatorColor: Colors.blue,
                tabs: [
                  Tab(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('全部'),
                        const SizedBox(width: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${_allItems.length}',
                            style: const TextStyle(fontSize: 10),
                          ),
                        ),
                      ],
                    ),
                  ),
                  ..._statusTabs.map((status) {
                    final count = _statusStats[status] ?? 0;
                    return Tab(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(status.icon, size: 16),
                          const SizedBox(width: 4),
                          Text(status.displayName),
                          const SizedBox(width: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: status.color.withAlpha(52),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '$count',
                              style: const TextStyle(fontSize: 10),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ],
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _filteredItems.isEmpty
              ? _buildEmptyState()
              : _buildItemsList(),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddItemPage(),
            ),
          );
          
          // 如果返回true，表示成功创建了物品，需要刷新列表
          if (result == true) {
            _loadData();
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            _searchQuery.isNotEmpty
                ? '没有找到匹配的物品'
                : _selectedCategory != null
                    ? '该分类下暂无物品'
                    : '还没有物品记录',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _searchQuery.isNotEmpty
                ? '尝试修改搜索关键词'
                : '点击右下角按钮添加物品',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemsList() {
    if (_isGridView) {
      return GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.8,
        ),
        itemCount: _filteredItems.length,
        itemBuilder: (context, index) {
          final item = _filteredItems[index];
          return ItemGridCard(
            item: item,
            onTap: () => _handleItemTap(item),
            onLongPress: () => _handleItemLongPress(item),
          );
        },
      );
    } else {
      return GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 1,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 2.5,
        ),
        itemCount: _filteredItems.length,
        itemBuilder: (context, index) {
          final item = _filteredItems[index];
          return ItemCard(
            item: item,
            onTap: () => _handleItemTap(item),
            onLongPress: () => _handleItemLongPress(item),
          );
        },
      );
    }
  }
}

// 扩展ItemStatus以添加显示属性
extension ItemStatusExtension on ItemStatus {
  String get displayName {
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

  IconData get icon {
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

  Color get color {
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
}
