import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class arifinProfilPage extends StatelessWidget {
  const arifinProfilPage({super.key});
  final String arifinDocId = "lpFLoTHeFTPRtfoESKnFoGzO3a42";
  
  @override
  Widget build(BuildContext context) {
     final double headerHeight = 400.0;
     final double contentStartPos = 360.0;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,