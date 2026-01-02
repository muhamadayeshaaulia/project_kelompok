import 'package:flutter/material.dart';

class template_vintage extends StatefulWidget {
  const template_vintage({super.key});

  @override
  State<template_vintage> createState() => _template_vintageState();
}

class _template_vintageState extends State<template_vintage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Dashboard"), actions: const []),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(10.0),
        child: Column(children: []),
      ),
    );
  }
}
