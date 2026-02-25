import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../themes/themes.dart';
import '../../../widgets/widgets.dart';
import '../controllers/login_controller.dart';

class LoginView extends GetView<LoginController> {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/background.jpg"),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.4),
              BlendMode.darken,
            ),
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: _buildLoginCard(),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginCard() {
    return Container(
      width: 420,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 24,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Form(
        key: controller.formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildLogo(),
            const SizedBox(height: AppSpacing.xl),
            _buildTitle(),
            const SizedBox(height: AppSpacing.xl),
            _buildUsernameField(),
            const SizedBox(height: AppSpacing.lg),
            _buildPasswordField(),
            const SizedBox(height: AppSpacing.xl),
            _buildSignInButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Column(
      children: [
        // Abstract dummy logo - simple geometric shape
        Container(
          width: 100,
          height: 100,
          // BoxDecoration dihapus sesuai permintaan
          child: Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(
                16,
              ), // Memberikan radius pada gambar
              child: Image(
                image: const AssetImage('assets/images/logo_ahass.jpg'),
                width: 56, // Ukuran diperbesar dari 32 ke 56
                height: 56, // Ukuran diperbesar dari 32 ke 56
                fit: BoxFit
                    .cover, // Memastikan gambar memenuhi area tanpa distorsi
                errorBuilder: (context, error, stackTrace) {
                  // Fallback jika logo tidak ada
                  return Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      Icons.motorcycle,
                      size: 32,
                      color: Colors.white,
                    ),
                  );
                },
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          'TOPSIS AHASS',
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
            letterSpacing: 1.2,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Sistem Pengambilan Keputusan',
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildTitle() {
    return Text(
      'Login',
      style: AppTextStyles.h3.copyWith(
        fontSize: 28,
        fontWeight: FontWeight.bold,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildUsernameField() {
    return CustomInput(
      label: 'Username',
      hint: 'Your Username',
      controller: controller.usernameController,
      keyboardType: TextInputType.text,
      prefixIcon: const Icon(Icons.person_outline),
      validator: controller.validateUsername,
      textInputAction: TextInputAction.next,
    );
  }

  Widget _buildPasswordField() {
    return Obx(
      () => CustomInput(
        label: 'Password',
        hint: 'Your Password',
        controller: controller.passwordController,
        obscureText: !controller.isPasswordVisible.value,
        prefixIcon: const Icon(Icons.lock_outline),
        suffixIcon: IconButton(
          icon: Icon(
            controller.isPasswordVisible.value
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
          ),
          onPressed: controller.togglePasswordVisibility,
        ),
        validator: controller.validatePassword,
        textInputAction: TextInputAction.done,
        onFieldSubmitted: (_) {
          if (!controller.isLoading.value) {
            controller.signIn();
          }
        },
      ),
    );
  }

  Widget _buildSignInButton() {
    return Obx(
      () => PrimaryButton(
        text: 'SIGN IN',
        onPressed: controller.isLoading.value ? null : controller.signIn,
        isLoading: controller.isLoading.value,
        backgroundColor: AppColors.loginButtonOrange,
        textColor: Colors.white,
        width: double.infinity,
        height: 52,
      ),
    );
  }
}
