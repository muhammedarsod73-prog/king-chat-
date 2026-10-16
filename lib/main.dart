import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const KingChatReal());
}

class KingChatReal extends StatelessWidget {
  const KingChatReal({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (c, snap) {
          if (snap.hasData) return const RealHome();
          return const LoginScreen();
        },
      ),
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}
class _LoginScreenState extends State<LoginScreen> {
  final phoneController = TextEditingController();
  final otpController = TextEditingController();
  String verId = "";
  bool otpSent = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF111B21),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("KING CHAT REAL LOGIN", style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            TextField(controller: phoneController, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(hintText: "+8801XXXXXXXXX", hintStyle: TextStyle(color: Colors.grey), border: OutlineInputBorder())),
            const SizedBox(height: 10),
            if(otpSent) TextField(controller: otpController, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(hintText: "OTP", border: OutlineInputBorder())),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00A884), minimumSize: const Size(double.infinity, 50)),
              onPressed: () async {
                if(!otpSent){
                  await FirebaseAuth.instance.verifyPhoneNumber(
                    phoneNumber: phoneController.text.trim(),
                    verificationCompleted: (c) async => await FirebaseAuth.instance.signInWithCredential(c),
                    verificationFailed: (e) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message!))),
                    codeSent: (id, t) => setState((){ verId = id; otpSent = true; }),
                    codeAutoRetrievalTimeout: (id) => verId = id,
                  );
                } else {
                  var cred = PhoneAuthProvider.credential(verificationId: verId, smsCode: otpController.text.trim());
                  await FirebaseAuth.instance.signInWithCredential(cred);
                }
              },
              child: Text(otpSent? "VERIFY OTP" : "SEND OTP", style: const TextStyle(color: Colors.white)),
            )
          ],
        ),
      ),
    );
  }
}

class RealHome extends StatelessWidget {
  const RealHome({super.key});
  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    return Scaffold(
      backgroundColor: const Color(0xFF111B21),
      appBar: AppBar(backgroundColor: const Color(0xFF202C33), title: const Text("King Chat REAL", style: TextStyle(color: Colors.white)), actions: [IconButton(onPressed: ()=>FirebaseAuth.instance.signOut(), icon: const Icon(Icons.logout, color: Colors.white))]),
      body: StreamBuilder(stream: FirebaseFirestore.instance.collection("users").snapshots(), builder: (c, snap){
        if(!snap.hasData) return const Center(child: CircularProgressIndicator());
        return ListView.builder(itemCount: snap.data!.docs.length, itemBuilder: (c, i){
          var user = snap.data!.docs[i];
          if(user.id == uid) return const SizedBox();
          return ListTile(leading: const CircleAvatar(child: Icon(Icons.person)), title: Text(user["phone"]?? "User", style: const TextStyle(color: Colors.white)), subtitle: const Text("Tap for Real Chat", style: TextStyle(color: Colors.grey)), onTap: ()=> Navigator.push(context, MaterialPageRoute(builder: (_)=> RealChatScreen(otherUid: user.id, otherPhone: user["phone"]))));
        });
      }),
      floatingActionButton: FloatingActionButton(backgroundColor: const Color(0xFF00A884), onPressed: () async { await FirebaseFirestore.instance.collection("users").doc(uid).set({"phone": FirebaseAuth.instance.currentUser!.phoneNumber, "uid": uid}); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("You are online!"))); }, child: const Icon(Icons.refresh)),
    );
  }
}

class RealChatScreen extends StatefulWidget {
  final String otherUid, otherPhone;
  const RealChatScreen({super.key, required this.otherUid, required this.otherPhone});
  @override
  State<RealChatScreen> createState() => _RealChatScreenState();
}
class _RealChatScreenState extends State<RealChatScreen> {
  final msgController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    final myUid = FirebaseAuth.instance.currentUser!.uid;
    final chatId = myUid.hashCode <= widget.otherUid.hashCode? "${myUid}_${widget.otherUid}" : "${widget.otherUid}_$myUid";
    return Scaffold(
      backgroundColor: const Color(0xFF0B141A),
      appBar: AppBar(backgroundColor: const Color(0xFF202C33), title: Text(widget.otherPhone, style: const TextStyle(color: Colors.white)), actions: const [Icon(Icons.call, color: Colors.white), SizedBox(width: 15), Icon(Icons.videocam, color: Colors.white), SizedBox(width: 10)]),
      body: Column(children: [
        Expanded(child: StreamBuilder(stream: FirebaseFirestore.instance.collection("chats").doc(chatId).collection("messages").orderBy("time").snapshots(), builder: (c, snap){
          if(!snap.hasData) return const Center(child: CircularProgressIndicator());
          return ListView.builder(itemCount: snap.data!.docs.length, itemBuilder: (c, i){
            var m = snap.data!.docs[i];
            bool isMe = m["sender"] == myUid;
            return Align(alignment: isMe? Alignment.centerRight : Alignment.centerLeft, child: Container(margin: const EdgeInsets.all(6), padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: isMe? const Color(0xFF005C4B) : const Color(0xFF202C33), borderRadius: BorderRadius.circular(8)), child: Text(m["text"], style: const TextStyle(color: Colors.white))));
          });
        })),
        Padding(padding: const EdgeInsets.all(8), child: Row(children: [Expanded(child: TextField(controller: msgController, style: const TextStyle(color: Colors.white), decoration: InputDecoration(hintText: "Real Message...", hintStyle: const TextStyle(color: Colors.grey), filled: true, fillColor: const Color(0xFF202C33), border: OutlineInputBorder(borderRadius: BorderRadius.circular(25))))), IconButton(onPressed: () async { if(msgController.text.trim().isEmpty) return; await FirebaseFirestore.instance.collection("chats").doc(chatId).collection("messages").add({"text": msgController.text.trim(), "sender": myUid, "time": FieldValue.serverTimestamp()}); msgController.clear(); }, icon: const Icon(Icons.send, color: Color(0xFF00A884))) ]))
      ]),
    );
  }
}
