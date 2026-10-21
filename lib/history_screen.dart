
import 'package:flutter/material.dart';

import '/history_service.dart';

class HistoryScreen extends StatefulWidget {
const HistoryScreen({super.key});

@override
State<HistoryScreen> createState() =>
_HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
List<Map<String, dynamic>> _history = [];
bool _isLoading = true;

@override
void initState() {
super.initState();
_loadHistory();
}

Future<void> _loadHistory() async {
final history = await HistoryService.getHistory();

if (!mounted) {
return;
}

setState(() {
_history = history;
_isLoading = false;
});
}

Future<void> _clearHistory() async {
if (_history.isEmpty) {
return;
}

final shouldClear = await showDialog<bool>(
context: context,
builder: (context) {
return AlertDialog(
title: const Text('Clear History?'),
content: const Text(
'All saved scan results will be removed from this device.',
),
actions: [
TextButton(
onPressed: () {
Navigator.pop(context, false);
},
child: const Text('Cancel'),
),
ElevatedButton(
onPressed: () {
Navigator.pop(context, true);
},
child: const Text('Clear'),
),
],
);
},
);

if (shouldClear != true) {
return;
}

await HistoryService.clearHistory();

if (!mounted) {
return;
}

setState(() {
_history.clear();
});
}

String _formatDate(String? date) {
if (date == null || date.isEmpty) {
return '';
}

try {
final parsedDate = DateTime.parse(date);

return '${parsedDate.day.toString().padLeft(2, '0')}/'
'${parsedDate.month.toString().padLeft(2, '0')}/'
'${parsedDate.year}';
} catch (_) {
return '';
}
}

@override
Widget build(BuildContext context) {
return Scaffold(
backgroundColor: const Color(0xFFF7FAF7),
appBar: AppBar(
backgroundColor: const Color(0xFFF7FAF7),
elevation: 0,
centerTitle: false,
title: const Text(
'Scan History',
style: TextStyle(
fontSize: 24,
fontWeight: FontWeight.bold,
color: Colors.black87,
),
),
actions: [
if (_history.isNotEmpty)
IconButton(
onPressed: _clearHistory,
icon: const Icon(Icons.delete_outline),
tooltip: 'Clear history',
),
],
),
body: _isLoading
? const Center(
child: CircularProgressIndicator(
color: Colors.green,
),
)
    : _history.isEmpty
? _buildEmptyState()
    : _buildHistoryList(),
);
}

Widget _buildEmptyState() {
return ListView(
padding: const EdgeInsets.all(20),
children: [
const SizedBox(height: 30),
Container(
width: double.infinity,
padding: const EdgeInsets.all(24),
decoration: BoxDecoration(
color: Colors.white,
borderRadius: BorderRadius.circular(22),
border: Border.all(
color: Colors.grey.shade200,
),
),
child: Column(
children: [
Container(
width: 80,
height: 80,
decoration: BoxDecoration(
color: Colors.green.shade50,
shape: BoxShape.circle,
),
child: Icon(
Icons.history_rounded,
size: 42,
color: Colors.green.shade600,
),
),
const SizedBox(height: 18),
const Text(
'No Scan History',
style: TextStyle(
fontSize: 20,
fontWeight: FontWeight.bold,
),
),
const SizedBox(height: 8),
Text(
'Your crop disease detection results will appear here after you scan a crop.',
textAlign: TextAlign.center,
style: TextStyle(
fontSize: 14,
height: 1.5,
color: Colors.grey.shade600,
),
),
],
),
),
],
);
}

Widget _buildHistoryList() {
return ListView.builder(
padding: const EdgeInsets.all(20),
itemCount: _history.length,
itemBuilder: (context, index) {
final item = _history[index];

final crop =
item['crop']?.toString() ?? 'Unknown';

final disease =
item['disease']?.toString() ?? 'Unknown';

final confidence =
item['confidence'] is num
? (item['confidence'] as num).toDouble()
    : 0.0;

final date =
_formatDate(item['date']?.toString());

return Container(
margin: const EdgeInsets.only(bottom: 14),
padding: const EdgeInsets.all(18),
decoration: BoxDecoration(
color: Colors.white,
borderRadius: BorderRadius.circular(20),
border: Border.all(
color: Colors.grey.shade200,
),
),
child: Column(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [
Row(
children: [
Container(
width: 50,
height: 50,
decoration: BoxDecoration(
color: Colors.green.shade50,
borderRadius:
BorderRadius.circular(14),
),
child: Icon(
Icons.eco_outlined,
color: Colors.green.shade700,
size: 28,
),
),
const SizedBox(width: 14),
Expanded(
child: Column(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [
Text(
crop,
style: const TextStyle(
fontSize: 18,
fontWeight:
FontWeight.bold,
color: Color(0xFF2E7D32),
),
),
if (date.isNotEmpty)
Padding(
padding:
const EdgeInsets.only(
top: 3,
),
child: Text(
date,
style: TextStyle(
fontSize: 12,
color:
Colors.grey.shade600,
),
),
),
],
),
),
],
),

const SizedBox(height: 16),

Text(
disease,
style: const TextStyle(
fontSize: 19,
fontWeight: FontWeight.bold,
color: Color(0xFF1B5E20),
),
),

const SizedBox(height: 12),

Row(
children: [
const Icon(
Icons.analytics_outlined,
size: 19,
color: Colors.green,
),
const SizedBox(width: 7),
Text(
'Confidence: ${confidence.toStringAsFixed(2)}%',
style: const TextStyle(
fontSize: 14,
fontWeight: FontWeight.w600,
),
),
],
),

const SizedBox(height: 14),

SizedBox(
width: double.infinity,
height: 44,
child: OutlinedButton(
onPressed: () {
_showDetails(item);
},
style: OutlinedButton.styleFrom(
foregroundColor: Colors.green.shade700,
side: BorderSide(
color: Colors.green.shade300,
),
shape: RoundedRectangleBorder(
borderRadius:
BorderRadius.circular(12),
),
),
child: const Text(
'View Details',
style: TextStyle(
fontWeight: FontWeight.w600,
),
),
),
),
],
),
);
},
);
}

void _showDetails(Map<String, dynamic> item) {
showModalBottomSheet(
context: context,
backgroundColor: Colors.white,
isScrollControlled: true,
shape: const RoundedRectangleBorder(
borderRadius: BorderRadius.vertical(
top: Radius.circular(24),
),
),
builder: (context) {
return SafeArea(
child: SingleChildScrollView(
padding: const EdgeInsets.all(24),
child: Column(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [
Center(
child: Container(
width: 45,
height: 5,
decoration: BoxDecoration(
color: Colors.grey.shade300,
borderRadius:
BorderRadius.circular(10),
),
),
),

const SizedBox(height: 22),

const Text(
'Detection Details',
style: TextStyle(
fontSize: 22,
fontWeight: FontWeight.bold,
),
),

const SizedBox(height: 20),

_detailSection(
'Crop',
item['crop']?.toString() ??
'Unknown',
),

_detailSection(
'Disease',
item['disease']?.toString() ??
'Unknown',
),

_detailSection(
'Confidence',
'${item['confidence'] ?? 0}%',
),

_detailSection(
'Symptoms',
item['symptoms']?.toString() ??
'No information available.',
),

_detailSection(
'Causes',
item['causes']?.toString() ??
'No information available.',
),

_detailSection(
'Treatment',
item['treatment']?.toString() ??
'No information available.',
),

_detailSection(
'Prevention',
item['prevention']?.toString() ??
'No information available.',
),
],
),
),
);
},
);
}

Widget _detailSection(
String title,
String content,
) {
return Padding(
padding: const EdgeInsets.only(bottom: 18),
child: Column(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [
Text(
title,
style: const TextStyle(
fontSize: 15,
fontWeight: FontWeight.bold,
color: Color(0xFF2E7D32),
),
),
const SizedBox(height: 6),
Text(
content,
style: TextStyle(
fontSize: 13,
height: 1.5,
color: Colors.grey.shade700,
),
),
],
),
);
}
}

