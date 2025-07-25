import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../model/auth/user_model.dart';
import '../../screen/main_screen.dart';
import '../../services/api_services.dart';
import '../../services/course_services.dart';

class LoginController extends GetxController {
  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final RxBool isLoading = false.obs;
  final RxBool isPasswordVisible = false.obs;

  // Using Rx<UserModel?> for reactive user state management
  final Rx<UserModel?> user = Rx<UserModel?>(null);

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  // Method to reset controller state (useful for logout)
  void resetState() {
    emailController.clear();
    passwordController.clear();
    isLoading.value = false;
    isPasswordVisible.value = false;
    user.value = null;
  }

  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    final emailRegExp = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    if (!emailRegExp.hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    return null;
  }

  Future<void> loginUser() async {
    FocusScope.of(Get.context!).unfocus();
    if (!formKey.currentState!.validate()) {
      return;
    }

    isLoading.value = true;
    try {
      final response = await ApiService.loginUser(
        emailController.text.trim(),
        passwordController.text,
      );

      if (response.success && response.data != null) {
        // Parse user into UserModel
        user.value = UserModel.fromJson(response.data!);

        // Log values
        log('Name from login controller: ${user.value!.name}');
        log('Email from login controller: ${user.value!.email}');
        log('token from login controller: ${user.value!.token}');

        // Save UserModel using Get.put so it's accessible globally
        Get.put<UserModel>(user.value!, permanent: true);

        // Show success message
        Get.snackbar(
          'Success',
          "Login successful",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );

        // Navigate based on role
        Get.offAll(() => MainScreen());
      } else {
        Get.snackbar(
          'Error',
          response.message,
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
      }
    } catch (e) {
      log('Login error: $e');
      Get.snackbar(
        'Error at LoginController',
        'An unexpected error occurred: ${e.toString()}',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    } finally {
      isLoading.value = false;
    }
  }
}
