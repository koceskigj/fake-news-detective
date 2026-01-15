import 'package:flutter/material.dart';

void main() {
  runApp(
    const MaterialApp(
      debugShowCheckedModeBanner: false,git remote add origin https://github.com/koceskigj/fake-news-detective.git
      home: Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Text(
            'Flutter is working ✅',
            style: TextStyle(fontSize: 24, color: Colors.black),
          ),
        ),
      ),
    ),
  );
}
