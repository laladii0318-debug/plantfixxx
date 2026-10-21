
import 'dart:io';

import 'package:flutter/material.dart';

import 'detection_result_screen.dart';
import 'apiservices.dart';

class CropPreviewScreen extends StatefulWidget {
final String imagePath;

const CropPreviewScreen({
super.key,
required this.imagePath,
});

@override
State<CropPreviewScreen> createState() =>
_CropPreviewScreenState();
}

class _CropPreviewScreenState
extends State<CropPreviewScreen> {
bool isAnalyzing = false;

Future<void> analyzeCrop() async {
setState(() {
isAnalyzing = true;
});

try {
final result = await ApiService.detectDisease(
File(widget.imagePath),
);

if (!mounted) return;

Navigator.push(
context,
MaterialPageRoute(
builder: (context) => DetectionResultScreen(
imagePath: widget.imagePath,
result: result,
),
),
);
} catch (e) {
if (!mounted) return;

ScaffoldMessenger.of(context).showSnackBar(
SnackBar(
content: const Text(
'Unable to analyze the crop. Please check the server and try again.',
),
backgroundColor: Colors.red.shade700,
behavior: SnackBarBehavior.floating,
margin: const EdgeInsets.all(16),
shape: RoundedRectangleBorder(
borderRadius: BorderRadius.circular(12),
),
action: SnackBarAction(
label: 'Try Again',
textColor: Colors.white,
onPressed: analyzeCrop,
),
),
);
} finally {
if (mounted) {
setState(() {
isAnalyzing = false;
});
}
}
}

@override
Widget build(BuildContext context) {
return Scaffold(
backgroundColor: const Color(0xFFF7FAF7),
appBar: AppBar(
backgroundColor: const Color(0xFFF7FAF7),
elevation: 0,
title: const Text(
'Crop Preview',
style: TextStyle(
fontSize: 22,
fontWeight: FontWeight.bold,
color: Colors.black87,
),
),
),
body: SafeArea(
child: Padding(
padding: const EdgeInsets.all(20),
child: Column(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [
const Text(
'Review Your Crop Image',
style: TextStyle(
fontSize: 24,
fontWeight: FontWeight.bold,
),
),

const SizedBox(height: 8),

Text(
'Make sure the affected part of the crop is clearly visible before analysis.',
style: TextStyle(
fontSize: 14,
height: 1.5,
color: Colors.grey.shade600,
),
),

const SizedBox(height: 24),

Expanded(
child: Container(
width: double.infinity,
decoration: BoxDecoration(
color: Colors.white,
borderRadius:
BorderRadius.circular(24),
border: Border.all(
color: Colors.grey.shade200,
),
boxShadow: [
BoxShadow(
color: Colors.black.withValues(
alpha: 0.06,
),
blurRadius: 15,
offset: const Offset(0, 6),
),
],
),
padding: const EdgeInsets.all(10),
child: ClipRRect(
borderRadius:
BorderRadius.circular(18),
child: Image.file(
File(widget.imagePath),
fit: BoxFit.contain,
),
),
),
),

const SizedBox(height: 20),

Row(
children: [
Expanded(
child: OutlinedButton.icon(
onPressed: isAnalyzing
? null
    : () {
Navigator.pop(
context,
);
},
icon: const Icon(
Icons.refresh_rounded,
),
label: const Text(
'Choose Again',
style: TextStyle(
fontWeight:
FontWeight.w600,
),
),
style:
OutlinedButton.styleFrom(
foregroundColor:
Colors.green.shade700,
side: BorderSide(
color:
Colors.green.shade700,
),
minimumSize:
const Size(
double.infinity,
54,
),
shape:
RoundedRectangleBorder(
borderRadius:
BorderRadius.circular(
15,
),
),
),
),
),

const SizedBox(width: 12),

Expanded(
child: ElevatedButton.icon(
onPressed: isAnalyzing
? null
    : analyzeCrop,
icon: isAnalyzing
? const SizedBox(
width: 20,
height: 20,
child:
CircularProgressIndicator(
strokeWidth: 2,
valueColor:
AlwaysStoppedAnimation<
Color>(
Colors.white,
),
),
)
    : const Icon(
Icons.auto_awesome,
),
label: Text(
isAnalyzing
? 'Analyzing...'
    : 'Analyze Crop',
style: const TextStyle(
fontWeight:
FontWeight.bold,
),
),
style:
ElevatedButton.styleFrom(
backgroundColor:
Colors.green,
foregroundColor:
Colors.white,
disabledBackgroundColor:
Colors.green.shade300,
elevation: 0,
minimumSize:
const Size(
double.infinity,
54,
),
shape:
RoundedRectangleBorder(
borderRadius:
BorderRadius.circular(
15,
),
),
),
),
),
],
),

const SizedBox(height: 10),
],
),
),
),
);
}
}