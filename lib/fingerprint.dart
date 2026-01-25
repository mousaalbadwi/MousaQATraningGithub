import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:wave/wave.dart';
import 'package:wave/config.dart';

class FingerprintPage extends StatefulWidget {
  const FingerprintPage({Key? key}) : super(key: key);

  @override
  State<FingerprintPage> createState() => _FingerprintPageState();
}

class _FingerprintPageState extends State<FingerprintPage> {
  final LocalAuthentication auth = LocalAuthentication();
  bool isAuthenticating = false;
  String message = "ضع إصبعك على مستشعر الهاتف";

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 500), () {
      _startAuthentication();
    });
  }

  Future<void> _startAuthentication() async {
    if (isAuthenticating || !mounted) return;

    setState(() {
      isAuthenticating = true;
      message = "جاري التحقق من البصمة...";
    });

    try {
      bool authenticated = await auth.authenticate(
        localizedReason: 'ضع إصبعك على مستشعر البصمة',
        options: const AuthenticationOptions(biometricOnly: true),
      );
      if (!mounted) return;
      setState(() {
        message = authenticated ? "✅ تم التحقق بنجاح!" : "❌ لم يتم التعرف، حاول مرة أخرى.";
      });

      // أعد المحاولة تلقائيًا بعد ثانيتين إذا لم ينجح
      if (!authenticated) {
        Future.delayed(const Duration(seconds: 2), _startAuthentication);
      }

    } catch (e) {
      if (!mounted) return;
      setState(() {
        message = "حدث خطأ: $e";
      });
      // إعادة المحاولة بعد 2 ثانية
      Future.delayed(const Duration(seconds: 2), _startAuthentication);
    } finally {
      if (mounted) {
        setState(() {
          isAuthenticating = false;
        });
      }
    }
  }

  Widget _buildWaveCircle() {
    return ClipOval(
      child: SizedBox(
        width: 200,
        height: 200,
        child: WaveWidget(
          config: CustomConfig(
            gradients: [
              [Colors.blueAccent, Colors.blue.shade100],
              [Colors.purpleAccent, Colors.purple.shade100],
            ],
            durations: [3500, 5000],
            heightPercentages: [0.4, 0.45],
            blur: const MaskFilter.blur(BlurStyle.solid, 10),
            gradientBegin: Alignment.topLeft,
            gradientEnd: Alignment.bottomRight,
          ),
          size: const Size(double.infinity, double.infinity),
          waveAmplitude: 15,
          backgroundColor: Colors.black,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildWaveCircle(),
            const SizedBox(height: 70),
            const Icon(Icons.fingerprint, size: 80, color: Colors.white),
            const SizedBox(height: 50),
            Text(
              message,
              style: const TextStyle(color: Colors.white, fontSize: 20),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
