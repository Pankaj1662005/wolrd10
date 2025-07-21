import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Mindmapscreen extends StatefulWidget {
  const Mindmapscreen({super.key});

  @override
  State<Mindmapscreen> createState() => _MindmapscreenState();
}

class _MindmapscreenState extends State<Mindmapscreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: Text("Comming Soon!",                style: TextStyle(color: Colors.white, fontSize: 18),
          textAlign: TextAlign.center,),
      ),
    );
  }
}
