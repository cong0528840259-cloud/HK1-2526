import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';

const Color penColor = Color(0xFF0054A6);

// ===== USER TEMPORARY =====
Map<String, String> users = {
  'admin': '123',
  '123': '123',
};

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyApIZAUr9mADtJ8ilavySzhgiPh_7oXriI",
      authDomain: "congiot.firebaseapp.com",
      databaseURL:
          "https://congiot-default-rtdb.asia-southeast1.firebasedatabase.app",
      projectId: "congiot",
      storageBucket: "congiot.firebasestorage.app",
      messagingSenderId: "751013521143",
      appId: "1:751013521143:web:554f51ffc1d74e7fb6d5f2",
      measurementId: "G-36MB5RV31J",
    ),
  );
  runApp(const EggIncubatorApp());
}

class EggIncubatorApp extends StatelessWidget {
  const EggIncubatorApp({super.key});
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginScreen(),
    );
  }
}

/// ================= LOGIN SCREEN (GIỮ NGUYÊN GIAO DIỆN CỦA BẠN) =================
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _user = TextEditingController();
  final _pass = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  void _login() {
    if (_formKey.currentState!.validate()) {
      if (users[_user.text] == _pass.text) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const DashboardScreen()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sai tài khoản hoặc mật khẩu')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(30),
          child: Column(
            children: [
              const Text('TRƯỜNG CĐ CÔNG THƯƠNG TP.HCM', style: TextStyle(fontWeight: FontWeight.bold)),
              const Text('KHOA ĐIỆN - ĐIỆN TỬ'),
              const SizedBox(height: 30),
              Container(
                padding: const EdgeInsets.all(25),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      const Text('LẬP TRÌNH IoT', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: penColor)),
                      const SizedBox(height: 10),
                      const Text('SVTH: Nguyễn Văn Công - Cao Thành Danh'),
                      const SizedBox(height: 5),
                      const Text('GIÁM SÁT MÁY ẤP TRỨNG', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w500)),
                      const SizedBox(height: 20),
                      _input(_user, 'Tên đăng nhập', Icons.person),
                      const SizedBox(height: 15),
                      _input(_pass, 'Mật khẩu', Icons.lock, isPass: true),
                      const SizedBox(height: 25),
                      ElevatedButton(
                        onPressed: _login,
                        style: ElevatedButton.styleFrom(backgroundColor: penColor, minimumSize: const Size(double.infinity, 45)),
                        child: const Text('ĐĂNG NHẬP', style: TextStyle(color: Colors.white)),
                      ),
                      TextButton(
                        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterScreen())),
                        child: const Text('Đăng ký tài khoản'),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),
              const Text('GVHD: NGUYỄN KIM SUYÊN'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _input(TextEditingController c, String h, IconData i, {bool isPass = false}) {
    return TextFormField(
      controller: c,
      obscureText: isPass,
      validator: (v) => v!.isEmpty ? 'Không được để trống' : null,
      decoration: InputDecoration(
        hintText: h,
        prefixIcon: Icon(i),
        filled: true,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
      ),
    );
  }
}

/// ================= REGISTER SCREEN (GIỮ NGUYÊN GIAO DIỆN CỦA BẠN) =================
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _user = TextEditingController();
  final _pass = TextEditingController();
  final _confirm = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: penColor, title: const Text('Đăng ký', style: TextStyle(color: Colors.white)), iconTheme: const IconThemeData(color: Colors.white)),
      body: Padding(
        padding: const EdgeInsets.all(30),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _input(_user, 'Tên đăng nhập', Icons.person),
              const SizedBox(height: 15),
              _input(_pass, 'Mật khẩu', Icons.lock, isPass: true),
              const SizedBox(height: 15),
              _input(_confirm, 'Nhập lại mật khẩu', Icons.lock, isPass: true, confirm: true),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    users[_user.text] = _pass.text;
                    Navigator.pop(context);
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: penColor, minimumSize: const Size(double.infinity, 45)),
                child: const Text('ĐĂNG KÝ', style: TextStyle(color: Colors.white))),
            ],
          ),
        ),
      ),
    );
  }

  Widget _input(TextEditingController c, String h, IconData i, {bool isPass = false, bool confirm = false}) {
    return TextFormField(
      controller: c,
      obscureText: isPass,
      validator: (v) {
        if (v!.isEmpty) return 'Không được để trống';
        if (confirm && v != _pass.text) return 'Mật khẩu không khớp';
        return null;
      },
      decoration: InputDecoration(hintText: h, prefixIcon: Icon(i), filled: true, border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none)),
    );
  }
}

/// ================= DASHBOARD SCREEN (CÓ THÊM PHẦN CHỈNH NGƯỠNG) =================
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final database = FirebaseDatabase.instance.ref();
  
  // Controllers cho phần chỉnh ngưỡng nhiệt độ
  final _lowTempCtrl = TextEditingController();
  final _highTempCtrl = TextEditingController();

  double temp = 0;
  double humi = 0;
  bool fan = false;
  bool light = false;
  bool servo = false;
  bool buzzer = false;
  bool isAuto = false;

  @override
  void initState() {
    super.initState();
    _listenRealtimeData();
  }

  void _listenRealtimeData() {
    database.onValue.listen((event) {
      final snapshot = event.snapshot.value as Map<dynamic, dynamic>?;
      if (snapshot != null) {
        setState(() {
          final sensor = snapshot['sensor'] as Map<dynamic, dynamic>? ?? {};
          temp = (sensor['temperature'] ?? 0).toDouble();
          humi = (sensor['humidity'] ?? 0).toDouble();

          final control = snapshot['control'] as Map<dynamic, dynamic>? ?? {};
          fan = control['fan'] ?? false;
          light = control['light'] ?? false;
          servo = control['servo'] ?? false;
          buzzer = control['buzzer'] ?? false;
          isAuto = control['isAuto'] ?? false;
          
          // Tự cập nhật số lên ô nhập nếu ô nhập đang trống
          if(_lowTempCtrl.text.isEmpty) _lowTempCtrl.text = (control['tempLow'] ?? 37.0).toString();
          if(_highTempCtrl.text.isEmpty) _highTempCtrl.text = (control['tempHigh'] ?? 38.0).toString();
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: penColor,
        title: const Text('Hệ Thống Máy Ấp', style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white), 
            onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()))
          )
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _machineStatus(),
          const SizedBox(height: 20),
          
          // Khối Chế độ Auto
          Card(
            elevation: 4,
            color: isAuto ? Colors.orange.shade50 : Colors.blue.shade50,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: SwitchListTile(
              secondary: Icon(isAuto ? Icons.auto_mode : Icons.pan_tool, color: isAuto ? Colors.orange : penColor),
              title: Text(isAuto ? 'CHẾ ĐỘ TỰ ĐỘNG' : 'CHẾ ĐỘ BẰNG TAY', style: const TextStyle(fontWeight: FontWeight.bold)),
              value: isAuto,
              onChanged: (v) => database.child('control/isAuto').set(v),
            ),
          ),
          
          const SizedBox(height: 10),
          _info('🌡 Nhiệt độ hiện tại', '$temp °C'),
          _info('💧 Độ ẩm hiện tại', '$humi %'),
          
          const SizedBox(height: 20),

          // --- PHẦN CHỈNH NGƯỠNG NHIỆT ĐỘ ---
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: penColor.withOpacity(0.3))
            ),
            child: Column(
              children: [
                const Text('CÀI ĐẶT NGƯỠNG NHIỆT (°C)', style: TextStyle(fontWeight: FontWeight.bold, color: penColor)),
                const SizedBox(height: 15),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _lowTempCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Bật đèn khi <', border: OutlineInputBorder()),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: _highTempCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Tắt đèn khi >', border: OutlineInputBorder()),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                ElevatedButton.icon(
                  onPressed: () {
                    database.child('control').update({
                      'tempLow': double.tryParse(_lowTempCtrl.text) ?? 37.0,
                      'tempHigh': double.tryParse(_highTempCtrl.text) ?? 38.0,
                    });
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã lưu ngưỡng mới!')));
                  }, 
                  icon: const Icon(Icons.save, color: Colors.white),
                  label: const Text('LƯU NGƯỠNG', style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(backgroundColor: penColor, minimumSize: const Size(double.infinity, 45)),
                )
              ],
            ),
          ),

          const Padding(padding: EdgeInsets.symmetric(vertical: 15), child: Divider()),
          
          const Text('ĐIỀU KHIỂN THIẾT BỊ', style: TextStyle(fontWeight: FontWeight.bold, color: penColor, fontSize: 16)),
          const SizedBox(height: 10),

          _switch('🌀 Quạt hút', fan, isAuto ? null : (v) => database.child('control/fan').set(v)),
          _switch('💡 Đèn sưởi', light, isAuto ? null : (v) => database.child('control/light').set(v)),
          _switch('⚙ Động cơ Servo', servo, isAuto ? null : (v) => database.child('control/servo').set(v)),
          _switch('🔊 Cảnh báo (Buzzer)', buzzer, isAuto ? null : (v) => database.child('control/buzzer').set(v)),
        ],
      ),
    );
  }

  Widget _machineStatus() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [penColor, Color(0xFF0078FF)]),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Trạng thái hệ thống', style: TextStyle(color: Colors.white70)),
              Text('Đang hoạt động', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
            ],
          ),
          Icon(Icons.sensors, color: Colors.white, size: 40),
        ],
      ),
    );
  }

  Widget _info(String t, String v) => Card(child: ListTile(title: Text(t), trailing: Text(v, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: penColor))));

  Widget _switch(String t, bool v, Function(bool)? f) => Card(
        margin: const EdgeInsets.only(bottom: 8),
        child: SwitchListTile(title: Text(t, style: TextStyle(color: f == null ? Colors.grey : Colors.black)), value: v, onChanged: f),
      );
}