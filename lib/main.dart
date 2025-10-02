import 'package:flutter/material.dart';
import 'services/supabase_service.dart';
import 'configs/page_routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseService.initialize();
  runApp(CikeApp());
}

class CikeApp extends StatelessWidget {
  const CikeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '此刻',
      theme: ThemeData(
        primarySwatch: Colors.green,
        useMaterial3: false,
      ),
      home: ChatPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});
  
  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final _currentPage = 'messages';

  Widget _buildCurrentPage() {
    return PageRoutes.getPage(
      pageType: _currentPage,
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    const minWidth = 1000.0;
    
    if (screenWidth < minWidth) {
      return Scaffold(
        body: Container(
          color: Color(0xFF2C3E50),
          child: Center(
            child: Text(
              '请将窗口调整至更大尺寸',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
              ),
            ),
          ),
        ),
      );
    }
    
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/hehua.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Row(
          children: [
            // 左侧：自适应宽度区域
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // 上部：数值图标区域
                    Container(
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(25),
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                          color: Colors.white.withAlpha(51),
                          width: 1,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          '数值图标区域',
                          style: TextStyle(color: Colors.white.withAlpha(179)),
                        ),
                      ),
                    ),
                    
                    SizedBox(height: 16),
                    
                    // 中部：导航按钮区域
                    Expanded(
                      child: Row(
                        children: [
                          // 左侧：导航按钮
                          Container(
                            width: 400,
                            decoration: BoxDecoration(
                              color: Colors.white.withAlpha(25),
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(
                                color: Colors.white.withAlpha(51),
                                width: 1,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                '导航按钮',
                                style: TextStyle(color: Colors.white.withAlpha(179)),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Container(),
                          ),
                        ],
                      ),
                    ),
                    
                    SizedBox(height: 16),
                    
                    // 下部：提醒卡片区域
                    Container(
                      height: 150,
                      width: 400,
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(25),
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                          color: Colors.white.withAlpha(51),
                          width: 1,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          '提醒卡片',
                          style: TextStyle(color: Colors.white.withAlpha(179)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 右侧：固定宽度内容区域
            Container(
              width: 480,
              padding: const EdgeInsets.all(16),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(25),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withAlpha(51),
                    width: 1,
                  ),
                ),
                child: _buildCurrentPage(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
