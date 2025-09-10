// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';

// class SignUpPage extends StatefulWidget {
//   const SignUpPage({super.key});
//   @override
//   State<SignUpPage> createState() => _SignUpPageState();
// }

// class _SignUpPageState extends State<SignUpPage> {
//   final _name = TextEditingController();
//   final _email = TextEditingController();
//   final _pass  = TextEditingController();
//   bool _busy = false;
//   String? _err;

//   Future<void> _signup() async {
//     setState(() { _busy = true; _err = null; });
//     try {
//       final cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
//         email: _email.text.trim(),
//         password: _pass.text,
//       );

//       final user = cred.user!;
//       // Save display name
//       await user.updateDisplayName(_name.text.trim());
//       await user.reload();

//       // Send verification email
//       await user.sendEmailVerification();

//       if (!mounted) return;
//       // Go to verification page
//       Navigator.pushReplacementNamed(
//         context,
//         '/verify',
//         arguments: {'email': user.email, 'name': _name.text.trim()},
//       );
//     } on FirebaseAuthException catch (e) {
//       setState(() { _err = e.message; });
//     } catch (e) {
//       setState(() { _err = e.toString(); });
//     } finally {
//       if (mounted) setState(() { _busy = false; });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Sign Up')),
//       body: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           children: [
//             TextField(controller: _name, decoration: const InputDecoration(labelText: 'Name')),
//             const SizedBox(height: 12),
//             TextField(controller: _email, keyboardType: TextInputType.emailAddress, decoration: const InputDecoration(labelText: 'Email')),
//             const SizedBox(height: 12),
//             TextField(controller: _pass, obscureText: true, decoration: const InputDecoration(labelText: 'Password')),
//             const SizedBox(height: 24),
//             if (_err != null) Text(_err!, style: const TextStyle(color: Colors.red)),
//             const SizedBox(height: 8),
//             ElevatedButton(
//               onPressed: _busy ? null : _signup,
//               child: _busy
//                   ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2))
//                   : const Text('Create account'),
//             ),
//             const SizedBox(height: 12),
//             const Text('We sent a verification link to your email. Verify, then return.'),
//           ],
//         ),
//       ),
//     );
//   }
// }
