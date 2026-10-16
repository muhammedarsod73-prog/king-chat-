import 'package:flutter/material.dart';
void main() => runApp(KingChatApp());
class KingChatApp extends StatefulWidget {
  @override
  State<KingChatApp> createState() => _KingChatAppState();
}
class _KingChatAppState extends State<KingChatApp> {
  bool isDark = false; bool isBN = true; bool isLocked = false;
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: isDark ? ThemeData.dark() : ThemeData.light(),
      home: isLocked ? LockScreen(onUnlock: () => setState(() => isLocked = false))
                     : MainScreen(isDark: isDark, isBN: isBN, onToggleDark: ()=>setState(()=>isDark=!isDark), onToggleLang: ()=>setState(()=>isBN=!isBN), onLock: ()=>setState(()=>isLocked=true)),
    );
  }
}
class ChatModel {
  String name, lastMsg, time, lastSeen, desc, inviteLink;
  int unread; bool isPinned, isArchived, isMuted, isBlocked, isOnline, isGroup, isAdmin;
  ChatModel({required this.name, required this.lastMsg, required this.time, this.unread=0, this.isPinned=false, this.isArchived=false, this.isMuted=false, this.isBlocked=false, this.isOnline=false, this.lastSeen='2:30 PM', this.isGroup=false, this.desc='', this.inviteLink='', this.isAdmin=false});
}
class MsgModel {
  String text, time, replyTo, reaction; bool isMe, isStar, isDeleted; int tick;
  MsgModel({required this.text, required this.isMe, required this.time, this.tick=1, this.isStar=false, this.isDeleted=false, this.replyTo='', this.reaction=''});
}
class StatusModel {
  String name, time; List<String> viewers;
  StatusModel({required this.name, required this.time, required this.viewers});
}
class MainScreen extends StatefulWidget {
  final bool isDark, isBN; final VoidCallback onToggleDark, onToggleLang, onLock;
  MainScreen({required this.isDark, required this.isBN, required this.onToggleDark, required this.onToggleLang, required this.onLock});
  @override
  State<MainScreen> createState() => _MainScreenState();
}
class _MainScreenState extends State<MainScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  String searchQuery=''; bool showArchived=false;
  List<ChatModel> chats = [
    ChatModel(name:'Abba ❤️', lastMsg:'Baba kemon achis?', time:'3:58 PM', unread:2, isPinned:true, isOnline:true, lastSeen:'Online'),
    ChatModel(name:'King Chat Group', lastMsg:'Rahim: King Chat Ready! 👑', time:'3:55 PM', unread:5, isGroup:true, desc:'King Chat Official', inviteLink:'https://king.chat/invite/xyz123', isAdmin:true),
    ChatModel(name:'Bhai', lastMsg:'APK ta install hoise?', time:'3:50 PM', unread:1, lastSeen:'today, 3:45 PM'),
    ChatModel(name:'Amma', lastMsg:'Bhat khaisos?', time:'2:30 PM', isMuted:true),
  ];
  List<StatusModel> statuses = [StatusModel(name:'Amma', time:'10 min ago', viewers:['Abba','Bhai']), StatusModel(name:'Bhai', time:'30 min ago', viewers:['Abba'])];
  @override
  void initState(){super.initState(); _tabController=TabController(length:4, vsync:this);}
  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(backgroundColor: Color(0xFF075E54), title: Text('King Chat', style: TextStyle(color:Colors.white, fontWeight:FontWeight.bold)),
        actions:[IconButton(icon:Icon(Icons.search, color:Colors.white), onPressed: _showSearch),
          PopupMenuButton<String>(onSelected:(v){if(v=='dark') widget.onToggleDark(); if(v=='lang') widget.onToggleLang(); if(v=='lock') widget.onLock();}, itemBuilder:(_)=>[
            PopupMenuItem(value:'dark', child:Text(widget.isDark?'Light Mode':'Dark Mode')),
            PopupMenuItem(value:'lang', child:Text(widget.isBN?'English':'Bangla')),
            PopupMenuItem(value:'lock', child:Text('App Lock')),
            PopupMenuItem(value:'starred', child:Text('Starred Messages')),
          ])],
        bottom: TabBar(controller:_tabController, indicatorColor:Colors.white, labelColor:Colors.white, unselectedLabelColor:Colors.white70, tabs:[Tab(text:'CHATS'), Tab(text:'STATUS'), Tab(text:'CALLS'), Tab(text:'GROUPS')]),
      ),
      body: TabBarView(controller:_tabController, children:[_buildChatsTab(), _buildStatusTab(), _buildCallsTab(), _buildGroupsTab()]),
      floatingActionButton: FloatingActionButton(backgroundColor:Color(0xFF25D366), child:Icon(Icons.message, color:Colors.white), onPressed:(){showModalBottomSheet(context:context, builder:(_)=>Column(mainAxisSize:MainAxisSize.min, children:[ListTile(leading:Icon(Icons.group_add), title:Text('New Group - Admin + Invite Link')), ListTile(leading:Icon(Icons.person_add), title:Text('New Contact - Contact Sync'))]));}),
    );
  }
  Widget _buildChatsTab(){
    var filtered = chats.where((c){if(showArchived) return c.isArchived; if(c.isArchived) return false; if(searchQuery.isEmpty) return true; return c.name.toLowerCase().contains(searchQuery.toLowerCase());}).toList();
    filtered.sort((a,b)=>(b.isPinned?1:0)-(a.isPinned?1:0));
    return Column(children:[
      if(!showArchived) ListTile(leading:Icon(Icons.archive), title:Text('Archived (${chats.where((c)=>c.isArchived).length})'), onTap:()=>setState(()=>showArchived=true)),
      if(showArchived) ListTile(leading:Icon(Icons.arrow_back), title:Text('Back'), onTap:()=>setState(()=>showArchived=false)),
      Expanded(child:ListView.separated(itemCount:filtered.length, separatorBuilder:(_,__ )=>Divider(height:0), itemBuilder:(ctx,i){
        var c=filtered[i];
        return ListTile(
          leading: CircleAvatar(backgroundColor:Color(0xFF128C7E), child:Text(c.name[0], style:TextStyle(color:Colors.white))),
          title: Row(children:[if(c.isPinned) Icon(Icons.push_pin, size:14), if(c.isMuted) Icon(Icons.volume_off, size:14), Expanded(child:Text(c.name, style:TextStyle(fontWeight:FontWeight.bold)))]),
          subtitle: Text(c.lastMsg, maxLines:1),
          trailing: Column(crossAxisAlignment:CrossAxisAlignment.end, children:[Text(c.time, style:TextStyle(color:c.unread>0?Color(0xFF25D366):Colors.grey, fontSize:12)), if(c.unread>0) Container(margin:EdgeInsets.only(top:4), padding:EdgeInsets.symmetric(horizontal:6, vertical:2), decoration:BoxDecoration(color:Color(0xFF25D366), borderRadius:BorderRadius.circular(10)), child:Text('${c.unread}', style:TextStyle(color:Colors.white, fontSize:12)))]),
          onTap:()=>Navigator.push(context, MaterialPageRoute(builder:(_)=>ChatDetailScreen(chat:c, isBN:widget.isBN))),
          onLongPress:()=>showModalBottomSheet(context:context, builder:(_)=>Column(mainAxisSize:MainAxisSize.min, children:[
            ListTile(leading:Icon(Icons.push_pin), title:Text(c.isPinned?'Unpin':'Pin Chat'), onTap:(){setState(()=>c.isPinned=!c.isPinned); Navigator.pop(context);}),
            ListTile(leading:Icon(Icons.volume_off), title:Text(c.isMuted?'Unmute Chat':'Mute Chat'), onTap:(){setState(()=>c.isMuted=!c.isMuted); Navigator.pop(context);}),
            ListTile(leading:Icon(Icons.archive), title:Text(c.isArchived?'Unarchive':'Archive'), onTap:(){setState(()=>c.isArchived=!c.isArchived); Navigator.pop(context);}),
            ListTile(leading:Icon(Icons.block, color:Colors.red), title:Text(c.isBlocked?'Unblock':'Block', style:TextStyle(color:Colors.red)), onTap:(){setState(()=>c.isBlocked=!c.isBlocked); Navigator.pop(context);}),
          ])),
        );
      })),
    ]);
  }
  Widget _buildStatusTab(){
    return ListView(children:[
      ListTile(leading:Stack(children:[CircleAvatar(radius:28, child:Icon(Icons.person)), Positioned(bottom:0,right:0,child:CircleAvatar(radius:10, backgroundColor:Color(0xFF25D366), child:Icon(Icons.add, size:14, color:Colors.white)))]), title:Text('My Status'), subtitle:Text('Tap to add status update'), onTap:(){
        TextEditingController c=TextEditingController(); showDialog(context:context, builder:(_)=>AlertDialog(title:Text('Add Text Status'), content:TextField(controller:c, decoration:InputDecoration(hintText:'Type status...')), actions:[TextButton(onPressed:(){if(c.text.isNotEmpty) setState(()=>statuses.insert(0, StatusModel(name:'You', time:'Just now', viewers:[]))); Navigator.pop(context);}, child:Text('Post'))]));
      }),
      Divider(), Padding(padding:EdgeInsets.all(12), child:Text('Recent updates', style:TextStyle(color:Colors.grey, fontWeight:FontWeight.bold))),
     ...statuses.map((s)=>ListTile(leading:Container(padding:EdgeInsets.all(2), decoration:BoxDecoration(shape:BoxShape.circle, border:Border.all(color:Color(0xFF25D366), width:2)), child:CircleAvatar(child:Text(s.name[0]))), title:Text(s.name), subtitle:Text(s.time), onTap:(){showDialog(context:context, builder:(_)=>AlertDialog(title:Text(s.name), content:Column(mainAxisSize:MainAxisSize.min, crossAxisAlignment:CrossAxisAlignment.start, children:[Text('Status at ${s.time}'), SizedBox(height:10), Text('Viewed by ${s.viewers.length}:', style:TextStyle(fontWeight:FontWeight.bold)),...s.viewers.map((v)=>Text('• $v'))]), actions:[TextButton(onPressed:()=>Navigator.pop(context), child:Text('Close'))]));})),
    ]);
  }
  Widget _buildCallsTab(){
    return ListView(children:[
      ListTile(leading:CircleAvatar(backgroundColor:Color(0xFF25D366), child:Icon(Icons.link, color:Colors.white)), title:Text('Create call link'), subtitle:Text('Share a link for your King Chat call')),
      Divider(),
      ListTile(leading:CircleAvatar(child:Text('A')), title:Text('Abba ❤️'), subtitle:Row(children:[Icon(Icons.call_received, size:16, color:Colors.green), Text(' Today, 3:58 PM')]), trailing:Icon(Icons.videocam, color:Color(0xFF075E54))),
      ListTile(leading:CircleAvatar(child:Text('B')), title:Text('Bhai'), subtitle:Row(children:[Icon(Icons.call_made, size:16, color:Colors.red), Text(' Yesterday, 8:30 PM')]), trailing:Icon(Icons.call, color:Color(0xFF075E54))),
    ]);
  }
  Widget _buildGroupsTab(){
    var groups=chats.where((c)=>c.isGroup).toList();
    return ListView.builder(itemCount:groups.length, itemBuilder:(_,i){var g=groups[i]; return ListTile(leading:CircleAvatar(backgroundColor:Colors.orange, child:Icon(Icons.group, color:Colors.white)), title:Text(g.name), subtitle:Text(g.desc), trailing:g.isAdmin?Chip(label:Text('Admin', style:TextStyle(fontSize:10))):null, onTap:()=>showDialog(context:context, builder:(_)=>AlertDialog(title:Text(g.name), content:Column(mainAxisSize:MainAxisSize.min, crossAxisAlignment:CrossAxisAlignment.start, children:[Text('Description: ${g.desc}'), SizedBox(height:8), Text('Invite Link:', style:TextStyle(fontWeight:FontWeight.bold)), SelectableText(g.inviteLink, style:TextStyle(color:Colors.blue)), Text('Admin System: You')]), actions:[TextButton(onPressed:()=>Navigator.pop(context), child:Text('Share Link')), TextButton(onPressed:()=>Navigator.pop(context), child:Text('Close'))])));});
  }
  void _showSearch(){showDialog(context:context, builder:(_)=>AlertDialog(title:Text('Message Search'), content:TextField(onChanged:(v)=>setState(()=>searchQuery=v), decoration:InputDecoration(hintText:'Search chats...', prefixIcon:Icon(Icons.search)), autofocus:true), actions:[TextButton(onPressed:(){setState(()=>searchQuery=''); Navigator.pop(context);}, child:Text('Clear')), TextButton(onPressed:()=>Navigator.pop(context), child:Text('Search'))]));}
}
class ChatDetailScreen extends StatefulWidget {
  final ChatModel chat; final bool isBN;
  ChatDetailScreen({required this.chat, required this.isBN});
  @override
  State<ChatDetailScreen> createState()=>_ChatDetailScreenState();
}
class _ChatDetailScreenState extends State<ChatDetailScreen> {
  List<MsgModel> msgs=[MsgModel(text:'Baba kemon achis?', isMe:false, time:'3:58 PM', tick:2), MsgModel(text:'Alhamdulillah valo achi Abba ❤️', isMe:true, time:'3:58 PM', tick:3, reaction:'❤️'), MsgModel(text:'Bhat khaisos?', isMe:false, time:'3:59 PM', isStar:true)];
  TextEditingController input=TextEditingController();
  bool isTyping=false, showEmoji=false, disappearing=false, isRecording=false;
  void send(){if(input.text.trim().isEmpty) return; setState((){msgs.add(MsgModel(text:input.text, isMe:true, time:'4:30 PM', tick:1)); input.clear(); isTyping=true;}); Future.delayed(Duration(seconds:1), ()=>setState(()=>isTyping=false)); Future.delayed(Duration(seconds:1), ()=>setState(()=>msgs.last.tick=2)); Future.delayed(Duration(seconds:2), ()=>setState(()=>msgs.last.tick=3)); if(disappearing) Future.delayed(Duration(seconds:5), (){if(mounted) setState(()=>msgs.removeLast());});}
  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(backgroundColor:Color(0xFF075E54), title:Column(crossAxisAlignment:CrossAxisAlignment.start, children:[Text(widget.chat.name, style:TextStyle(fontSize:16, color:Colors.white)), Text(isTyping?'typing...':widget.chat.isOnline?'Online':'Last seen ${widget.chat.lastSeen}', style:TextStyle(fontSize:12, color:Colors.white70))]),
        actions:[IconButton(icon:Icon(Icons.videocam, color:Colors.white), onPressed:(){}), IconButton(icon:Icon(Icons.call, color:Colors.white), onPressed:(){}),
          PopupMenuButton(onSelected:(v){if(v=='disappear') setState(()=>disappearing=!disappearing); if(v=='block') setState(()=>widget.chat.isBlocked=!widget.chat.isBlocked);}, itemBuilder:(_)=>[
            PopupMenuItem(value:'search', child:Text('🔍 Message Search')),
            PopupMenuItem(value:'disappear', child:Text(disappearing?'Disappearing ON':'Disappearing OFF')),
            PopupMenuItem(value:'wallpaper', child:Text('Chat Wallpaper')),
            PopupMenuItem(value:'mute', child:Text('Mute Chat')),
            PopupMenuItem(value:'block', child:Text(widget.chat.isBlocked?'Unblock':'Block')),
            PopupMenuItem(value:'star', child:Text('Star Message')),
          ])],
      ),
      body: Column(children:[
        if(widget.chat.isBlocked) Container(color:Colors.yellow[100], padding:EdgeInsets.all(8), child:Text('You blocked this contact. Tap to unblock.', textAlign:TextAlign.center)),
        if(disappearing) Container(color:Colors.orange[100], padding:EdgeInsets.all(6), child:Row(children:[Icon(Icons.timer, size:16), SizedBox(width:4), Text('Disappearing messages ON - 5 sec', style:TextStyle(fontSize:12))])),
        Expanded(child:ListView.builder(padding:EdgeInsets.all(8), itemCount:msgs.length, itemBuilder:(_,i){var m=msgs[i]; if(m.isDeleted) return Center(child:Container(margin:EdgeInsets.symmetric(vertical:4), padding:EdgeInsets.all(8), decoration:BoxDecoration(color:Colors.grey[300], borderRadius:BorderRadius.circular(8)), child:Text('🚫 Deleted'))); return Align(alignment:m.isMe?Alignment.centerRight:Alignment.centerLeft, child:GestureDetector(onLongPress:()=>showModalBottomSheet(context:context, builder:(_)=>Column(mainAxisSize:MainAxisSize.min, children:[
          ListTile(leading:Icon(Icons.reply), title:Text('Reply'), onTap:(){Navigator.pop(context); setState(()=>m.replyTo=m.text);}),
          ListTile(leading:Icon(Icons.forward), title:Text('Forward'), onTap:(){Navigator.pop(context); ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text('Forwarded')));}),
          ListTile(leading:Icon(Icons.emoji_emotions), title:Text('Reaction ❤️'), onTap:(){setState(()=>m.reaction='❤️'); Navigator.pop(context);}),
          ListTile(leading:Icon(Icons.star), title:Text(m.isStar?'Unstar':'Star'), onTap:(){setState(()=>m.isStar=!m.isStar); Navigator.pop(context);}),
          ListTile(leading:Icon(Icons.delete, color:Colors.red), title:Text('Delete For Everyone', style:TextStyle(color:Colors.red)), onTap:(){setState(()=>m.isDeleted=true); Navigator.pop(context);}),
          ListTile(leading:Icon(Icons.delete_outline), title:Text('Delete For Me'), onTap:(){setState(()=>msgs.removeAt(i)); Navigator.pop(context);}),
        ])), child:Container(margin:EdgeInsets.symmetric(vertical:2), padding:EdgeInsets.symmetric(horizontal:12, vertical:8), constraints:BoxConstraints(maxWidth:MediaQuery.of(context).size.width*0.75), decoration:BoxDecoration(color:m.isMe?Color(0xFFDCF8C6):Colors.white, borderRadius:BorderRadius.circular(8)), child:Column(crossAxisAlignment:CrossAxisAlignment.start, children:[
          if(m.replyTo.isNotEmpty) Container(padding:EdgeInsets.all(4), margin:EdgeInsets.only(bottom:4), decoration:BoxDecoration(color:Colors.black12, borderRadius:BorderRadius.circular(4), border:Border(left:BorderSide(color:Color(0xFF075E54), width:3))), child:Text(m.replyTo, style:TextStyle(fontSize:12))),
          Text(m.text), if(m.reaction.isNotEmpty) Text(m.reaction), Row(mainAxisSize:MainAxisSize.min, children:[if(m.isStar) Icon(Icons.star, size:12, color:Colors.orange), Text(m.time, style:TextStyle(fontSize:10, color:Colors.grey)), SizedBox(width:4), if(m.isMe) Icon(m.tick==1?Icons.check:Icons.done_all, size:14, color:m.tick==3?Colors.blue:Colors.grey)]),
        ]))));})),
        if(showEmoji) Container(height:100, color:Colors.grey[200], child:GridView.count(crossAxisCount:8, children:['😊','❤️','😂','👍','👑','🔥','😍','🙏'].map((e)=>InkWell(onTap:(){input.text+=e; setState(()=>showEmoji=false);}, child:Center(child:Text(e, style:TextStyle(fontSize:22))))).toList())),
        Container(color:Colors.white, padding:EdgeInsets.symmetric(horizontal:8, vertical:4), child:Row(children:[
          IconButton(icon:Icon(Icons.emoji_emotions_outlined), onPressed:()=>setState(()=>showEmoji=!showEmoji)),
          Expanded(child:TextField(controller:input, decoration:InputDecoration(hintText:widget.isBN?'মেসেজ লিখুন...':'Type a message', border:InputBorder.none))),
          IconButton(icon:Icon(Icons.attach_file), onPressed:()=>showModalBottomSheet(context:context, builder:(_)=>Column(mainAxisSize:MainAxisSize.min, children:[ListTile(leading:Icon(Icons.image, color:Colors.purple), title:Text('Image - Gallery/Camera')), ListTile(leading:Icon(Icons.insert_drive_file, color:Colors.blue), title:Text('File Send - Document/PDF')), ListTile(leading:Icon(Icons.audiotrack, color:Colors.orange), title:Text('Voice Message - Audio'))]))),
          IconButton(icon:Icon(isRecording?Icons.stop:Icons.mic, color:isRecording?Colors.red:Colors.grey), onPressed:()=>setState(()=>isRecording=!isRecording)),
          CircleAvatar(backgroundColor:Color(0xFF25D366), child:IconButton(icon:Icon(Icons.send, color:Colors.white), onPressed:send)),
        ])),
      ]),
    );
  }
}
class LockScreen extends StatefulWidget {
  final VoidCallback onUnlock; LockScreen({required this.onUnlock});
  @override
  State<LockScreen> createState()=>_LockScreenState();
}
class _LockScreenState extends State<LockScreen> {
  String pin='';
  @override
  Widget build(BuildContext context){
    return Scaffold(backgroundColor:Color(0xFF075E54), body:Center(child:Column(mainAxisAlignment:MainAxisAlignment.center, children:[
      Icon(Icons.lock, size:80, color:Colors.white), SizedBox(height:20),
      Text('King Chat Locked', style:TextStyle(color:Colors.white, fontSize:22, fontWeight:FontWeight.bold)), SizedBox(height:20),
      Text('Enter PIN: 1234', style:TextStyle(color:Colors.white70)), SizedBox(height:20),
      Row(mainAxisAlignment:MainAxisAlignment.center, children:List.generate(4, (i)=>Container(margin:EdgeInsets.all(6), width:16, height:16, decoration:BoxDecoration(shape:BoxShape.circle, color:pin.length>i?Colors.white:Colors.white24)))),
      SizedBox(height:20),
      Wrap(spacing:10, runSpacing:10, children:List.generate(10, (i){return InkWell(onTap:(){setState(()=>pin+= (i==9?'0':'${i+1}')); if(pin=='1234') widget.onUnlock(); if(pin.length>4) setState(()=>pin='');}, child:Container(width:70, height:70, decoration:BoxDecoration(shape:BoxShape.circle, color:Colors.white24), child:Center(child:Text(i==9?'0':'${i+1}', style:TextStyle(color:Colors.white, fontSize:22)))));}),)
    ])));
  }
}
