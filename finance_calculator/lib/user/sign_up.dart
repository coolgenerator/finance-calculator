import 'package:flutter/material.dart';

class SignUpScreen extends StatelessWidget {
  const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: const Center(
        child: SizedBox(
          width: 400,
          child: Card(
            child: SignUpForm(),
          ),
        )
      ),
    );
  }
}

class SignUpForm extends StatefulWidget {
  const SignUpForm({super.key});

  @override
  State<SignUpForm> createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUpForm> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _emailController = TextEditingController();
  final _nameController = TextEditingController();

  double _formProgress = 0;
  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      onChanged: _updateFormProgress,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextFormField(
              controller: _usernameController,
              decoration: const InputDecoration(
                hintText: 'Username',
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextFormField(
              controller: _passwordController,
              decoration: const InputDecoration(
                hintText: 'Password',
              ),
              obscureText: true,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextFormField(
              controller: _confirmPasswordController,
              decoration: const InputDecoration(
                hintText: 'Confirm Password',
              ),
              obscureText: true,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(
                hintText: 'Email',
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                hintText: 'Name',
              ),
            ),
          ),
          Text('Sign Up Progress: $_formProgress'),
          ElevatedButton(
            onPressed: _formProgress == 1 ? _signUp : null,
            child: const Text('Sign Up'),
          ),
        ],
      ),
    );
  }
}
