
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

class ApiService {
static const String baseUrl = 'http://127.0.0.1:8000';

static const Duration _timeout = Duration(seconds: 30);

// =========================
// SIGN UP
// =========================
static Future<Map<String, dynamic>> signup({
required String name,
required String email,
required String password,
}) async {
try {
final uri = Uri.parse('$baseUrl/auth/signup');

final response = await http
    .post(
uri,
headers: {
'Content-Type': 'application/json',
},
body: jsonEncode({
'name': name,
'email': email,
'password': password,
}),
)
    .timeout(_timeout);

final responseBody = response.body;

if (response.statusCode == 200 || response.statusCode == 201) {
return jsonDecode(responseBody) as Map<String, dynamic>;
}

throw Exception(
_getErrorMessage(
'Signup failed',
response.statusCode,
responseBody,
),
);
} on SocketException {
throw Exception(
'Unable to connect to the server. Please make sure the backend is running.',
);
} on HttpException {
throw Exception(
'Network error occurred. Please check your connection.',
);
} on FormatException {
throw Exception(
'Invalid response received from the server.',
);
} on Exception catch (e) {
throw Exception(
_cleanExceptionMessage(e),
);
}
}

// =========================
// LOGIN
// =========================
static Future<Map<String, dynamic>> login({
required String email,
required String password,
}) async {
try {
final uri = Uri.parse('$baseUrl/auth/login');

final response = await http
    .post(
uri,
headers: {
'Content-Type': 'application/json',
},
body: jsonEncode({
'email': email,
'password': password,
}),
)
    .timeout(_timeout);

final responseBody = response.body;

if (response.statusCode == 200 || response.statusCode == 201) {
return jsonDecode(responseBody) as Map<String, dynamic>;
}

throw Exception(
_getErrorMessage(
'Login failed',
response.statusCode,
responseBody,
),
);
} on SocketException {
throw Exception(
'Unable to connect to the server. Please make sure the backend is running.',
);
} on HttpException {
throw Exception(
'Network error occurred. Please check your connection.',
);
} on FormatException {
throw Exception(
'Invalid response received from the server.',
);
} on Exception catch (e) {
throw Exception(
_cleanExceptionMessage(e),
);
}
}

// =========================
// CROP DISEASE DETECTION
// =========================
static Future<Map<String, dynamic>> detectDisease(
File imageFile,
) async {
try {
final uri = Uri.parse(
'$baseUrl/detection/detect',
);

final request = http.MultipartRequest(
'POST',
uri,
);

request.files.add(
await http.MultipartFile.fromPath(
'file',
imageFile.path,
),
);

final response = await request.send().timeout(
_timeout,
);

final responseBody =
await response.stream.bytesToString();

if (response.statusCode == 200) {
return jsonDecode(responseBody) as Map<String, dynamic>;
}

throw Exception(
_getErrorMessage(
'Detection failed',
response.statusCode,
responseBody,
),
);
} on SocketException {
throw Exception(
'Unable to connect to the detection server. Please make sure the backend is running.',
);
} on HttpException {
throw Exception(
'Network error occurred while uploading the image.',
);
} on FormatException {
throw Exception(
'Invalid response received from the detection server.',
);
} on Exception catch (e) {
throw Exception(
_cleanExceptionMessage(e),
);
}
}

// =========================
// ERROR MESSAGE
// =========================
static String _getErrorMessage(
String operation,
int statusCode,
String responseBody,
) {
String serverMessage = responseBody;

try {
final decoded = jsonDecode(responseBody);

if (decoded is Map<String, dynamic>) {
if (decoded['detail'] != null) {
serverMessage = decoded['detail'].toString();
} else if (decoded['message'] != null) {
serverMessage = decoded['message'].toString();
}
}
} catch (_) {
// Keep original response body.
}

if (serverMessage.trim().isEmpty) {
serverMessage = 'Server returned an error.';
}

return '$operation: $serverMessage';
}

// =========================
// CLEAN EXCEPTION MESSAGE
// =========================
static String _cleanExceptionMessage(
Exception exception,
) {
final message = exception.toString();

if (message.startsWith('Exception: ')) {
return message.substring(
'Exception: '.length,
);
}

return message;
}
}

