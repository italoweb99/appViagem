
import 'package:flutter/material.dart';

import 'Home.dart';

class SplashScreen extends StatefulWidget{
  const SplashScreen({Key? key}) : super(key:key);
  @override
  State<SplashScreen> createState() => _SplashScreenState();

}

class _SplashScreenState extends State<SplashScreen>{
  @override
  void initState(){
    super.initState();
    Future.delayed(const Duration(seconds: 5),(){
      if (mounted){
        Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (_) => Home() ),
        );
      }
    });
  }
  @override
  Widget build(BuildContext context){
    return Scaffold(
      body: Container(
        color: Color(0xff290133),
        padding: EdgeInsets.all(60),
        child: Center(
          child: Image.asset("images/logo.png"),
        ),
      ),
    );
  }
}