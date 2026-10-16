import 'package:flutter/material.dart';
void main() { runApp(const KingChatApp()); }

class KingChatApp extends StatelessWidget {
  const KingChatApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF075E54),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF075E54),
          foregroundColor: Colors.white,
        ),
      ),
      home: const KingHome(),
    );
  }
}

class KingHome extends StatefulWidget {
  const KingHome({super.key});
  @override
  State<KingHome> createState() => _KingHomeState();
}

class _KingHomeState extends State<KingHome> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('King Chat', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold),
          tabs: const [
            Tab(text: 'CHATS'),
            Tab(text: 'STATUS'),
            Tab(text: 'CALLS'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          const ChatListScreen(),
          const StatusScreen(),
          const CallsScreen(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF25D366),
        onPressed: () {},
        child: const Icon(Icons.message, color: Colors.white),
      ),
    );
  }
}

class ChatListScreen extends StatelessWidget {
  const ChatListScreen({super.key});
  final List<Map<String, dynamic>> chats = const [
    {'name': 'Abba ❤️', 'msg': 'Baba kemon achis?', 'time': '3:58 PM', 'unread': 2, 'avatar': 'A'},
    {'name': 'King Chat Group', 'msg': 'Rahim: King Chat Ready! 👑', 'time': '3:55 PM', 'unread': 5, 'avatar': 'K'},
    {'name': 'Bhai', 'msg': 'APK ta install hoise?', 'time': '3:50 PM', 'unread': 1, 'avatar': 'B'},
    {'name': 'Amma', 'msg': 'Bhat khaisos?', 'time': '2:30 PM', 'unread': 0, 'avatar': 'M'},
  ];
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: ListView.separated(
        itemCount: chats.length,
        separatorBuilder: (c, i) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final chat = chats[index];
          return ListTile(
            leading: CircleAvatar(
              radius: 27,
              backgroundColor: const Color(0xFF128C7E),
              child: Text(chat['avatar'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)),
            ),
            title: Text(chat['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
            subtitle: Text(chat['msg'], maxLines: 1, overflow: TextOverflow.ellipsis),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(chat['time'], style: TextStyle(fontSize: 12, color: chat['unread'] > 0? const Color(0xFF25D366) : Colors.grey)),
                if (chat['unread'] > 0)
                  Container(
                    margin: const EdgeInsets.only(top: 5),
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(color: Color(0xFF25D366), shape: BoxShape.circle),
                    child: Text('${chat['unread']}', style: const TextStyle(color: Colors.white, fontSize: 12)),
                  ),
              ],
            ),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => ChatScreen(name: chat['name'], avatar: chat['avatar'])));
            },
          );
        },
      ),
    );
  }
}

class ChatScreen extends StatefulWidget {
  final String name;
  final String avatar;
  const ChatScreen({super.key, required this.name, required this.avatar});
  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final List<Map<String, dynamic>> messages = [
    {'text': 'Assalamu Alaikum! King Chat kemon laglo? 👑', 'isMe': false, 'time': '3:55 PM'},
    {'text': 'Walaikum Salam! Alhamdulillah onek sundor hoise!', 'isMe': true, 'time': '3:56 PM'},
    {'text': 'Ekhon Full WhatsApp design!', 'isMe': false, 'time': '3:57 PM'},
  ];
  final TextEditingController _controller = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leadingWidth: 80,
        leading: Row(
          children: [
            IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context)),
            CircleAvatar(backgroundColor: Colors.white, child: Text(widget.avatar, style: const TextStyle(color: Color(0xFF075E54), fontWeight: FontWeight.bold))),
          ],
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Text('online', style: TextStyle(fontSize: 12, color: Colors.white70)),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              color: const Color(0xFFE5DDD5),
              child: ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: messages.length,
                itemBuilder: (context, i) {
                  final msg = messages[i];
                  return Align(
                    alignment: msg['isMe']? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: msg['isMe']? const Color(0xFFDCF8C6) : Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(msg['text'], style: const TextStyle(fontSize: 16)),
                          const SizedBox(height: 4),
                          Text(msg['time'], style: TextStyle(fontSize: 11, color: Colors.grey[600])),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Row(
              children: [
                Expanded(child: TextField(controller: _controller, decoration: const InputDecoration(hintText: 'Message', border: InputBorder.none))),
                CircleAvatar(
                  backgroundColor: const Color(0xFF075E54),
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white, size: 20),
                    onPressed: () {
                      if (_controller.text.trim().isNotEmpty) {
                        setState(() {
                          messages.add({'text': _controller.text, 'isMe': true, 'time': 'now'});
                          _controller.clear();
                        });
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class StatusScreen extends StatelessWidget {
  const StatusScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Container(color: Colors.white, child: const Center(child: Text('Status Coming Soon 👑')));
  }
}

class CallsScreen extends StatelessWidget {
  const CallsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Container(color: Colors.white, child: const Center(child: Text('Calls Coming Soon 📞')));
  }
}
