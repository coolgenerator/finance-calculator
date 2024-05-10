import 'package:flutter/material.dart';
import 'package:finance_calculator/widgets/my_drawer.dart';
// import 'dart:convert';
// import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: MainScreen(),
    );
  }
}

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Financial Calculator')),
      drawer: const MyDrawer(),
      body: const Center(
        child: Text('Welcome to Business Finance Calculator!'),
      )
    );
  }
}