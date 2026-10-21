
import 'dart:io';

import 'package:flutter/material.dart';

import 'history_service.dart';

class DetectionResultScreen extends StatefulWidget {
  final String imagePath;
  final Map<String, dynamic> result;

  const DetectionResultScreen({
    super.key,
    required this.imagePath,
    required this.result,
  });

  @override
  State<DetectionResultScreen> createState() =>
      _DetectionResultScreenState();
}

class _DetectionResultScreenState
    extends State<DetectionResultScreen> {
  bool _historySaved = false;

  String get crop {
    final value =
        widget.result['crop']?.toString().trim() ?? '';

    return value.isEmpty ? 'Unknown' : value;
  }

  String get disease {
    final value =
        widget.result['disease']?.toString().trim() ?? '';

    if (value.isEmpty) return 'Unknown';

    return value
        .replaceAll('___', ' - ')
        .replaceAll('_', ' ');
  }

  double? get confidenceValue {
    final value = widget.result['confidence'];

    final parsed = value is num
        ? value.toDouble()
        : double.tryParse(value?.toString() ?? '');

    if (parsed == null ||
        !parsed.isFinite ||
        parsed < 0 ||
        parsed > 100) {
      return null;
    }

    return parsed;
  }

  double get confidence => confidenceValue ?? 0;

  bool get hasValidConfidence => confidenceValue != null;

  bool get hasValidPrediction {
    final rawCrop =
        widget.result['crop']?.toString().trim() ?? '';

    final rawDisease =
        widget.result['disease']?.toString().trim() ?? '';

    return rawCrop.isNotEmpty &&
        rawDisease.isNotEmpty &&
        rawCrop.toLowerCase() != 'unknown' &&
        rawDisease.toLowerCase() != 'unknown';
  }

  bool get isReliablePrediction {
    final value = widget.result['reliable_prediction'];

    if (value is! bool) {
      return hasValidPrediction &&
          hasValidConfidence &&
          confidence >= 60;
    }

    return value &&
        hasValidPrediction &&
        hasValidConfidence;
  }

  String get confidenceLabel {
    if (!hasValidConfidence) return 'Unavailable';
    if (!isReliablePrediction) return 'Low confidence';
    if (confidence < 80) return 'Moderate confidence';

    return 'Higher confidence';
  }

  String get confidenceMessage {
    if (!hasValidPrediction) {
      return 'No valid crop disease result was returned. Please try another clear image.';
    }

    if (!hasValidConfidence) {
      return 'The confidence score is missing or invalid. Please analyze the image again.';
    }

    if (!isReliablePrediction) {
      final message = widget.result['message']?.toString();

      if (message != null && message.trim().isNotEmpty) {
        return message;
      }

      return 'The AI prediction has low confidence. Try a clearer image and verify the result with an agricultural professional.';
    }

    if (confidence < 80) {
      return 'The prediction is uncertain. Compare the symptoms and verify the result before taking action.';
    }

    return 'The model reports higher confidence, but the prediction is not guaranteed to be correct.';
  }

  List<String> get symptoms => _getList('symptoms');

  List<String> get causes => _getList('causes');

  List<String> get treatment => _getList('treatment');

  List<String> get prevention => _getList('prevention');

  List<String> _getList(String key) {
    final value = widget.result[key];

    if (value is List) {
      return value
          .map((item) => item.toString())
          .toList();
    }

    return [];
  }

  String _formatList(List<String> items) {
    if (items.isEmpty) {
      return 'No information available.';
    }

    return items.map((item) => '• $item').join('\n');
  }

  @override
  void initState() {
    super.initState();
    _saveToHistory();
  }

  Future<void> _saveToHistory() async {
    if (_historySaved ||
        !hasValidPrediction ||
        !hasValidConfidence) {
      return;
    }

    try {
      await HistoryService.addHistory(
        crop: crop,
        disease: disease,
        confidence: confidence,
        symptoms: _formatList(symptoms),
        causes: _formatList(causes),
        treatment: _formatList(treatment),
        prevention: _formatList(prevention),
      );

      _historySaved = true;
    } catch (e) {
      debugPrint('Failed to save detection history: $e');
    }
  }

  void _returnToHome() {
    Navigator.popUntil(
      context,
          (route) => route.isFirst,
    );
  }

  Color get _warningBackgroundColor {
    if (!hasValidPrediction || !hasValidConfidence) {
      return Colors.red.shade50;
    }

    if (!isReliablePrediction) {
      return Colors.orange.shade50;
    }

    if (confidence < 80) {
      return Colors.amber.shade50;
    }

    return Colors.green.shade50;
  }

  Color get _warningIconColor {
    if (!hasValidPrediction || !hasValidConfidence) {
      return Colors.red.shade700;
    }

    if (!isReliablePrediction) {
      return Colors.orange.shade800;
    }

    if (confidence < 80) {
      return Colors.amber.shade900;
    }

    return Colors.green.shade700;
  }

  IconData get _warningIcon {
    if (!hasValidPrediction || !hasValidConfidence) {
      return Icons.error_outline;
    }

    if (!isReliablePrediction) {
      return Icons.warning_amber_rounded;
    }

    if (confidence < 80) {
      return Icons.info_outline;
    }

    return Icons.check_circle_outline;
  }

  String get _warningTitle {
    if (!hasValidPrediction) {
      return 'Invalid Detection Result';
    }

    if (!hasValidConfidence) {
      return 'Confidence Unavailable';
    }

    if (!isReliablePrediction) {
      return 'Low Confidence — Verify Result';
    }

    return confidenceLabel;
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
          'Detection Result',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _returnToHome,
            icon: const Icon(Icons.close),
            tooltip: 'Close result',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              height: 240,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: Colors.grey.shade200,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: Image.file(
                  File(widget.imagePath),
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const Center(
                      child: Icon(
                        Icons.broken_image_outlined,
                        size: 50,
                        color: Colors.grey,
                      ),
                    );
                  },
                ),
              ),
            ),

            const SizedBox(height: 24),

            Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: isReliablePrediction
                        ? Colors.green.shade50
                        : Colors.orange.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isReliablePrediction
                        ? Icons.biotech_outlined
                        : Icons.warning_amber_rounded,
                    color: isReliablePrediction
                        ? Colors.green.shade700
                        : Colors.orange.shade700,
                    size: 25,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        hasValidPrediction
                            ? 'AI Detection Complete'
                            : 'Detection Needs Review',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 3),
                      const Text(
                        'PlantFix analyzed your crop image',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 22),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: Colors.grey.shade200,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Detected Crop',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    crop,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2E7D32),
                    ),
                  ),

                  const SizedBox(height: 18),

                  Text(
                    'Detected Disease',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    disease,
                    style: const TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1B5E20),
                    ),
                  ),

                  const SizedBox(height: 18),

                  Text(
                    'Confidence Score',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 8),

                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: LinearProgressIndicator(
                            value: confidence / 100,
                            minHeight: 10,
                            backgroundColor: Colors.grey.shade200,
                            color: !hasValidConfidence
                                ? Colors.grey
                                : !isReliablePrediction
                                ? Colors.orange
                                : confidence < 80
                                ? Colors.amber.shade700
                                : Colors.green,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        hasValidConfidence
                            ? '${confidence.toStringAsFixed(2)}%'
                            : 'N/A',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: !hasValidConfidence
                              ? Colors.grey
                              : !isReliablePrediction
                              ? Colors.orange.shade800
                              : confidence < 80
                              ? Colors.amber.shade800
                              : Colors.green,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _warningBackgroundColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    _warningIcon,
                    color: _warningIconColor,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _warningTitle,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          confidenceMessage,
                          style: const TextStyle(
                            fontSize: 13,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            _buildInformationCard(
              icon: Icons.search_outlined,
              iconColor: Colors.orange.shade700,
              backgroundColor: Colors.orange.shade50,
              title: 'Symptoms',
              description: _formatList(symptoms),
            ),

            const SizedBox(height: 14),

            _buildInformationCard(
              icon: Icons.help_outline,
              iconColor: Colors.red.shade700,
              backgroundColor: Colors.red.shade50,
              title: 'Causes',
              description: _formatList(causes),
            ),

            const SizedBox(height: 14),

            _buildInformationCard(
              icon: Icons.medical_services_outlined,
              iconColor: Colors.blue.shade700,
              backgroundColor: Colors.blue.shade50,
              title: 'Recommended Treatment',
              description: _formatList(treatment),
            ),

            const SizedBox(height: 14),

            _buildInformationCard(
              icon: Icons.shield_outlined,
              iconColor: Colors.green.shade700,
              backgroundColor: Colors.green.shade50,
              title: 'Prevention',
              description: _formatList(prevention),
            ),

            const SizedBox(height: 14),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: Colors.amber.shade100,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Colors.amber.shade800,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'PlantFix provides an AI-based prediction. '
                          'For important crop decisions, verify the '
                          'result with a qualified agricultural professional.',
                      style: TextStyle(
                        fontSize: 12,
                        height: 1.5,
                        color: Colors.amber.shade900,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton.icon(
                onPressed: _returnToHome,
                icon: const Icon(Icons.camera_alt_outlined),
                label: const Text(
                  'Scan Another Crop',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInformationCard({
    required IconData icon,
    required Color iconColor,
    required Color backgroundColor,
    required String title,
    required String description,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 25,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.5,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
