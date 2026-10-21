
import 'package:flutter/material.dart';
import 'apiservices.dart';

class SignupScreen extends StatefulWidget {
const SignupScreen({super.key});

@override
State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
final TextEditingController _nameController = TextEditingController();
final TextEditingController _emailController = TextEditingController();
final TextEditingController _phoneController = TextEditingController();
final TextEditingController _passwordController = TextEditingController();
final TextEditingController _confirmPasswordController =
TextEditingController();

bool _obscurePassword = true;
bool _obscureConfirmPassword = true;
bool _agreeTerms = false;
bool _isLoading = false;

@override
void dispose() {
_nameController.dispose();
_emailController.dispose();
_phoneController.dispose();
_passwordController.dispose();
_confirmPasswordController.dispose();
super.dispose();
}

Future<void> _createAccount() async {
final name = _nameController.text.trim();
final email = _emailController.text.trim();
final phone = _phoneController.text.trim();
final password = _passwordController.text.trim();
final confirmPassword = _confirmPasswordController.text.trim();

if (name.isEmpty ||
email.isEmpty ||
phone.isEmpty ||
password.isEmpty ||
confirmPassword.isEmpty) {
ScaffoldMessenger.of(context).showSnackBar(
const SnackBar(
content: Text('Please fill in all fields.'),
),
);
return;
}

if (password != confirmPassword) {
ScaffoldMessenger.of(context).showSnackBar(
const SnackBar(
content: Text('Passwords do not match.'),
),
);
return;
}

if (!_agreeTerms) {
ScaffoldMessenger.of(context).showSnackBar(
const SnackBar(
content: Text('Please agree to the Terms & Conditions.'),
),
);
return;
}

setState(() {
_isLoading = true;
});

try {
await ApiService.signup(
name: name,
email: email,
password: password,
);

if (!mounted) return;

ScaffoldMessenger.of(context).showSnackBar(
const SnackBar(
content: Text('Account created successfully!'),
backgroundColor: Colors.green,
),
);

Navigator.pop(context);
} catch (e) {
if (!mounted) return;

ScaffoldMessenger.of(context).showSnackBar(
SnackBar(
content: Text(
e.toString().replaceFirst('Exception: ', ''),
),
backgroundColor: Colors.red,
),
);
} finally {
if (mounted) {
setState(() {
_isLoading = false;
});
}
}
}

@override
Widget build(BuildContext context) {
final screenHeight = MediaQuery.of(context).size.height;

return Scaffold(
body: Stack(
children: [
Positioned.fill(
child: Image.asset(
'assets/images/login.jpeg',
fit: BoxFit.cover,
),
),

Positioned.fill(
child: Container(
color: Colors.black.withValues(alpha: 0.45),
),
),

SafeArea(
child: SingleChildScrollView(
child: Padding(
padding: const EdgeInsets.symmetric(horizontal: 24),
child: ConstrainedBox(
constraints: BoxConstraints(
minHeight: screenHeight -
MediaQuery.of(context).padding.top -
MediaQuery.of(context).padding.bottom,
),
child: Column(
mainAxisAlignment: MainAxisAlignment.center,
children: [
const SizedBox(height: 25),

Container(
width: 80,
height: 80,
padding: const EdgeInsets.all(10),
decoration: BoxDecoration(
color: Colors.white,
borderRadius: BorderRadius.circular(22),
),
child: Image.asset(
'assets/images/applogo.jpeg',
fit: BoxFit.contain,
),
),

const SizedBox(height: 14),

const Text(
'Create Account',
style: TextStyle(
color: Colors.white,
fontSize: 30,
fontWeight: FontWeight.bold,
),
),

const SizedBox(height: 5),

const Text(
'Join PlantFix today',
style: TextStyle(
color: Colors.white70,
fontSize: 15,
),
),

const SizedBox(height: 25),

Container(
padding: const EdgeInsets.all(22),
decoration: BoxDecoration(
color: Colors.white.withValues(alpha: 0.96),
borderRadius: BorderRadius.circular(28),
boxShadow: [
BoxShadow(
color: Colors.black.withValues(alpha: 0.15),
blurRadius: 20,
offset: const Offset(0, 10),
),
],
),
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
const Text(
'Sign Up',
style: TextStyle(
fontSize: 27,
fontWeight: FontWeight.bold,
),
),

const SizedBox(height: 5),

Text(
'Create your PlantFix account',
style: TextStyle(
color: Colors.grey.shade600,
fontSize: 14,
),
),

const SizedBox(height: 22),

const Text(
'Full Name',
style: TextStyle(
fontWeight: FontWeight.w600,
),
),

const SizedBox(height: 8),

TextField(
controller: _nameController,
textInputAction: TextInputAction.next,
decoration: InputDecoration(
hintText: 'Enter your full name',
prefixIcon: const Icon(
Icons.person_outline,
),
filled: true,
fillColor: Colors.grey.shade100,
border: OutlineInputBorder(
borderRadius: BorderRadius.circular(14),
borderSide: BorderSide.none,
),
),
),

const SizedBox(height: 16),

const Text(
'Email',
style: TextStyle(
fontWeight: FontWeight.w600,
),
),

const SizedBox(height: 8),

TextField(
controller: _emailController,
keyboardType: TextInputType.emailAddress,
textInputAction: TextInputAction.next,
decoration: InputDecoration(
hintText: 'Enter your email',
prefixIcon: const Icon(
Icons.email_outlined,
),
filled: true,
fillColor: Colors.grey.shade100,
border: OutlineInputBorder(
borderRadius: BorderRadius.circular(14),
borderSide: BorderSide.none,
),
),
),

const SizedBox(height: 16),

const Text(
'Phone Number',
style: TextStyle(
fontWeight: FontWeight.w600,
),
),

const SizedBox(height: 8),

TextField(
controller: _phoneController,
keyboardType: TextInputType.phone,
textInputAction: TextInputAction.next,
decoration: InputDecoration(
hintText: 'Enter your phone number',
prefixIcon: const Icon(
Icons.phone_outlined,
),
filled: true,
fillColor: Colors.grey.shade100,
border: OutlineInputBorder(
borderRadius: BorderRadius.circular(14),
borderSide: BorderSide.none,
),
),
),

const SizedBox(height: 16),

const Text(
'Password',
style: TextStyle(
fontWeight: FontWeight.w600,
),
),

const SizedBox(height: 8),

TextField(
controller: _passwordController,
obscureText: _obscurePassword,
textInputAction: TextInputAction.next,
decoration: InputDecoration(
hintText: 'Create a password',
prefixIcon: const Icon(
Icons.lock_outline,
),
suffixIcon: IconButton(
onPressed: () {
setState(() {
_obscurePassword =
!_obscurePassword;
});
},
icon: Icon(
_obscurePassword
? Icons.visibility_outlined
    : Icons.visibility_off_outlined,
),
),
filled: true,
fillColor: Colors.grey.shade100,
border: OutlineInputBorder(
borderRadius: BorderRadius.circular(14),
borderSide: BorderSide.none,
),
),
),

const SizedBox(height: 16),

const Text(
'Confirm Password',
style: TextStyle(
fontWeight: FontWeight.w600,
),
),

const SizedBox(height: 8),

TextField(
controller: _confirmPasswordController,
obscureText: _obscureConfirmPassword,
textInputAction: TextInputAction.done,
decoration: InputDecoration(
hintText: 'Confirm your password',
prefixIcon: const Icon(
Icons.lock_outline,
),
suffixIcon: IconButton(
onPressed: () {
setState(() {
_obscureConfirmPassword =
!_obscureConfirmPassword;
});
},
icon: Icon(
_obscureConfirmPassword
? Icons.visibility_outlined
    : Icons.visibility_off_outlined,
),
),
filled: true,
fillColor: Colors.grey.shade100,
border: OutlineInputBorder(
borderRadius: BorderRadius.circular(14),
borderSide: BorderSide.none,
),
),
),

const SizedBox(height: 12),

Row(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
SizedBox(
width: 24,
height: 24,
child: Checkbox(
value: _agreeTerms,
activeColor: Colors.green,
onChanged: (value) {
setState(() {
_agreeTerms = value ?? false;
});
},
),
),
const SizedBox(width: 8),
const Expanded(
child: Text(
'I agree to the Terms & Conditions and Privacy Policy.',
style: TextStyle(
fontSize: 13,
height: 1.4,
),
),
),
],
),

const SizedBox(height: 15),

SizedBox(
width: double.infinity,
height: 54,
child: ElevatedButton(
onPressed:
_isLoading ? null : _createAccount,
style: ElevatedButton.styleFrom(
backgroundColor: Colors.green,
foregroundColor: Colors.white,
disabledBackgroundColor:
Colors.green.shade300,
elevation: 0,
shape: RoundedRectangleBorder(
borderRadius:
BorderRadius.circular(14),
),
),
child: _isLoading
? const SizedBox(
width: 24,
height: 24,
child:
CircularProgressIndicator(
strokeWidth: 2.5,
color: Colors.white,
),
)
    : const Text(
'Create Account',
style: TextStyle(
fontSize: 17,
fontWeight: FontWeight.bold,
),
),
),
),

const SizedBox(height: 16),

Center(
child: TextButton(
onPressed: () {
Navigator.pop(context);
},
child: const Text.rich(
TextSpan(
text: 'Already have an account? ',
style: TextStyle(
color: Colors.black54,
),
children: [
TextSpan(
text: 'Login',
style: TextStyle(
color: Colors.green,
fontWeight: FontWeight.bold,
),
),
],
),
),
),
),
],
),
),

const SizedBox(height: 25),
],
),
),
),
),
),
],
),
);
}
}

