// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// // ...imports...

// class SignInPage extends StatefulWidget {
//   const SignInPage({super.key});
//   @override
//   State<SignInPage> createState() => _SignInPageState();
// }

// class _SignInPageState extends State<SignInPage> {
//   final _email = TextEditingController();
//   final _pass = TextEditingController();
//   bool _busy = false;
//   String? _err;

//   Future<void> _signin() async {
//     setState(() {
//       _busy = true;
//       _err = null;
//     });
//     try {
//       final cred = await FirebaseAuth.instance.signInWithEmailAndPassword(
//         email: _email.text.trim(),
//         password: _pass.text,
//       );
//       final user = cred.user;
//       if (user == null) return;

//       if (!user.emailVerified) {
//         setState(() {
//           _err = 'Please verify your email first.';
//         });
//       } else {
//         if (!mounted) return;
//         // Just close the SignIn page. Tabs screen stays. Only AppBar text updates.
//         Navigator.pop(context);
//       }
//     } on FirebaseAuthException catch (e) {
//       setState(() {
//         _err = e.message;
//       });
//     } catch (e) {
//       setState(() {
//         _err = e.toString();
//       });
//     } finally {
//       if (mounted)
//         setState(() {
//           _busy = false;
//         });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Sign In')),
//       body: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(children: [
//           TextField(
//               controller: _email,
//               decoration: const InputDecoration(labelText: 'Email')),
//           const SizedBox(height: 12),
//           TextField(
//               controller: _pass,
//               obscureText: true,
//               decoration: const InputDecoration(labelText: 'Password')),
//           const SizedBox(height: 24),
//           if (_err != null)
//             Text(_err!, style: const TextStyle(color: Colors.red)),
//           const SizedBox(height: 12),
//           ElevatedButton(
//             onPressed: _busy ? null : _signin,
//             child: _busy
//                 ? const SizedBox(
//                     width: 18,
//                     height: 18,
//                     child: CircularProgressIndicator(strokeWidth: 2))
//                 : const Text('Sign In'),
//           ),
//         ]),
//       ),
//     );
//   }
// }
