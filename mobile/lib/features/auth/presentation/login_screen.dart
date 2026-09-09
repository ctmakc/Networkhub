import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:networkhub/features/auth/providers/auth_provider.dart';
import 'package:networkhub/shared/widgets/error_snackbar.dart';
import 'package:networkhub/shared/widgets/loading_overlay.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _codeController = TextEditingController();
  final _emailFormKey = GlobalKey<FormState>();
  final _codeFormKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loginState = ref.watch(loginFlowProvider);
    final theme = Theme.of(context);

    ref.listen<AuthState>(loginFlowProvider, (prev, next) {
      if (next.step == AuthStep.authenticated) {
        // Auth notifier will refresh and router will redirect
        ref.read(authProvider.notifier).refresh();
        context.go('/scan');
      }
      if (next.errorMessage != null) {
        showErrorSnackbar(context, next.errorMessage!);
      }
    });

    return LoadingOverlay(
      isLoading: loginState.isLoading,
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Gap(48),
                Image.asset(
                  'assets/images/logo_mark.png',
                  height: 72,
                  width: 72,
                ),
                const Gap(16),
                Text(
                  'NetworkHub',
                  style: theme.textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const Gap(8),
                Text(
                  'Scan business cards, follow up with new connections.',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const Gap(48),
                if (loginState.step == AuthStep.emailInput)
                  _EmailInputSection(
                    controller: _emailController,
                    formKey: _emailFormKey,
                    onSubmit: () async {
                      if (_emailFormKey.currentState?.validate() ?? false) {
                        await ref
                            .read(loginFlowProvider.notifier)
                            .sendMagicLink(_emailController.text.trim());
                      }
                    },
                  )
                else if (loginState.step == AuthStep.codeSent)
                  _CodeInputSection(
                    controller: _codeController,
                    formKey: _codeFormKey,
                    email: loginState.email ?? '',
                    successMessage: loginState.successMessage,
                    onSubmit: () async {
                      if (_codeFormKey.currentState?.validate() ?? false) {
                        await ref
                            .read(loginFlowProvider.notifier)
                            .verifyCode(_codeController.text.trim());
                      }
                    },
                    onResend: () {
                      if (loginState.email != null) {
                        ref
                            .read(loginFlowProvider.notifier)
                            .sendMagicLink(loginState.email!);
                      }
                    },
                    onBack: () {
                      ref.read(loginFlowProvider.notifier).resetToEmailInput();
                      _codeController.clear();
                    },
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EmailInputSection extends StatelessWidget {
  const _EmailInputSection({
    required this.controller,
    required this.formKey,
    required this.onSubmit,
  });

  final TextEditingController controller;
  final GlobalKey<FormState> formKey;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Sign in with email',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const Gap(8),
          Text(
            'We\'ll send you a one-time login code.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const Gap(24),
          TextFormField(
            controller: controller,
            keyboardType: TextInputType.emailAddress,
            autocorrect: false,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => onSubmit(),
            decoration: const InputDecoration(
              labelText: 'Email address',
              hintText: 'you@company.com',
              prefixIcon: Icon(Icons.email_outlined),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your email';
              }
              final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
              if (!emailRegex.hasMatch(value.trim())) {
                return 'Please enter a valid email address';
              }
              return null;
            },
          ),
          const Gap(24),
          ElevatedButton(
            onPressed: onSubmit,
            child: const Text('Send login code'),
          ),
        ],
      ),
    );
  }
}

class _CodeInputSection extends StatelessWidget {
  const _CodeInputSection({
    required this.controller,
    required this.formKey,
    required this.email,
    required this.onSubmit,
    required this.onResend,
    required this.onBack,
    this.successMessage,
  });

  final TextEditingController controller;
  final GlobalKey<FormState> formKey;
  final String email;
  final String? successMessage;
  final VoidCallback onSubmit;
  final VoidCallback onResend;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Check your inbox',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const Gap(8),
          Text(
            'Enter the 6-digit code sent to',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          Text(
            email,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.primary,
            ),
          ),
          if (successMessage != null) ...[
            const Gap(12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    color: theme.colorScheme.primary,
                    size: 16,
                  ),
                  const Gap(8),
                  Expanded(
                    child: Text(
                      successMessage!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const Gap(24),
          TextFormField(
            controller: controller,
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.done,
            maxLength: 6,
            onFieldSubmitted: (_) => onSubmit(),
            decoration: const InputDecoration(
              labelText: 'Login code',
              hintText: '123456',
              prefixIcon: Icon(Icons.lock_outline),
              counterText: '',
            ),
            style: const TextStyle(
              fontSize: 24,
              letterSpacing: 8,
              fontWeight: FontWeight.bold,
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter the code';
              }
              if (value.length < 6) {
                return 'Code must be 6 digits';
              }
              return null;
            },
          ),
          const Gap(24),
          ElevatedButton(
            onPressed: onSubmit,
            child: const Text('Verify code'),
          ),
          const Gap(12),
          Row(
            children: [
              TextButton(
                onPressed: onBack,
                child: const Text('Change email'),
              ),
              const Gap(8),
              TextButton(
                onPressed: onResend,
                child: const Text('Resend code'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
