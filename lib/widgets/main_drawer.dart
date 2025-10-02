import 'package:flutter/material.dart';
import '../pages/note_list_page.dart';
import '../pages/income_expense_page.dart';
import '../pages/account_page.dart';
import '../pages/item_list_page.dart';

class MainDrawer extends StatelessWidget {
  const MainDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          // 头部
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Color.fromARGB(255, 172, 196, 157),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  '此刻',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  '记录生活的每个瞬间',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          
          // 菜单项
          ListTile(
            leading: const Icon(Icons.timeline),
            title: const Text('时间轴'),
            onTap: () {
              Navigator.pop(context);
              // 跳转到时间轴页面
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('时间轴功能开发中')),
              );
            },
          ),
          
          // 事件功能已移除
          
          ListTile(
            leading: const Icon(Icons.check_box),
            title: const Text('待办'),
            onTap: () {
              Navigator.pop(context);
              // 跳转到待办页面
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('待办功能开发中')),
              );
            },
          ),
          
          ListTile(
            leading: const Icon(Icons.note),
            title: const Text('笔记'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const NoteListPage(),
                ),
              );
            },
          ),
          
          ListTile(
            leading: const Icon(Icons.storage),
            title: const Text('库'),
            onTap: () {
              Navigator.pop(context);
              // 跳转到库页面
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('库功能开发中')),
              );
            },
          ),
          
          ListTile(
            leading: const Icon(Icons.local_offer),
            title: const Text('标签'),
            onTap: () {
              Navigator.pop(context);
              // 跳转到标签页面
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('标签功能开发中')),
              );
            },
          ),
          
          ListTile(
            leading: const Icon(Icons.analytics),
            title: const Text('统计'),
            onTap: () {
              Navigator.pop(context);
              // 跳转到统计页面
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('统计功能开发中')),
              );
            },
          ),
          
          ListTile(
            leading: const Icon(Icons.account_balance_wallet),
            title: const Text('收支'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const IncomeExpensePage(),
                ),
              );
            },
          ),
          
          ListTile(
            leading: const Icon(Icons.account_balance),
            title: const Text('账户'),
            onTap: () {
              Navigator.pop(context);
              // 跳转到账户页面
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AccountPage(),
                ),
              );
            },
          ),
          
          ListTile(
            leading: const Icon(Icons.inventory),
            title: const Text('物品'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ItemListPage(),
                ),
              );
            },
          ),
          
          const Spacer(),
          
          // 底部设置
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('设置'),
            onTap: () {
              Navigator.pop(context);
              // 跳转到设置页面
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('设置功能开发中')),
              );
            },
          ),
        ],
      ),
    );
  }
}