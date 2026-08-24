import 'package:flutter/material.dart';
import 'package:task_trading_app/app/main_shell.dart';
import 'package:task_trading_app/core/app_colors/app_colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();

}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Future.delayed(Duration(
      seconds: 3,
    ),
      () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const MainShell(),))
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text("Trading App",style: TextStyle(color: AppColors.whiteColor,fontSize: 25),),
      ),
    );
  }
}
