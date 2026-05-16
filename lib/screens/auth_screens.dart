import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_theme.dart';

class WelcomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Sagiro', style: Theme.of(context).textTheme.displayLarge?.copyWith(color: AppTheme.primaryBlue)),
            const SizedBox(height: 16),
            Text('Instant transfers, 100% secure', style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => context.push('/register'),
              child: const Text('Create Account'),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => context.push('/login'),
              child: const Text('Log In'),
            )
          ],
        ),
      ),
    );
  }
}

class RegisterScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Register')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const TextField(decoration: InputDecoration(hintText: 'Email')),
            const SizedBox(height: 16),
            const TextField(decoration: InputDecoration(hintText: 'Phone')),
            const SizedBox(height: 16),
            const TextField(decoration: InputDecoration(hintText: 'Password'), obscureText: true),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => context.push('/verify-otp'),
                child: const Text('Continue'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class LoginScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Log In')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const TextField(decoration: InputDecoration(hintText: 'Email')),
            const SizedBox(height: 16),
            const TextField(decoration: InputDecoration(hintText: 'Password'), obscureText: true),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => context.go('/home'),
                child: const Text('Log In'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class VerifyOTPScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Verify OTP')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Enter the 6-digit code sent to your email'),
            const SizedBox(height: 32),
            const TextField(
              decoration: InputDecoration(hintText: '000000'),
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => context.go('/kyc-start'),
                child: const Text('Verify'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
