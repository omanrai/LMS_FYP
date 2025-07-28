// import 'dart:developer';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'dart:io';
// import '../../model/auth/user_model.dart';
// import '../../screen/main_screen.dart';
// import '../../services/api_services.dart';

// class LoginController extends GetxController {
//   final formKey = GlobalKey<FormState>();
//   final profileFormKey = GlobalKey<FormState>();
//   final emailController = TextEditingController();
//   final passwordController = TextEditingController();
//   final nameController = TextEditingController();

//   final RxBool isLoading = false.obs;
//   final RxBool isPasswordVisible = false.obs;
//   final RxBool isImageUploading = false.obs;

//   // Using Rx<UserModel?> for reactive user state management
//   final Rx<UserModel?> user = Rx<UserModel?>(null);
//   final Rx<File?> selectedProfileImage = Rx<File?>(null);

//   // Flag to control when the controller can be deleted
//   bool _canDelete = false;

//   @override
//   void onClose() {
//     // Only dispose controllers if we're allowed to delete
//     if (_canDelete) {
//       emailController.dispose();
//       passwordController.dispose();
//       nameController.dispose();
//     }
//     super.onClose();
//   }

//   // Renamed to avoid conflict with GetLifeCycleBase.onDelete field
//   void deleteController() {
//     if (_canDelete) {
//       super.onClose();
//     }
//   }

//   // Method to allow deletion (called during logout)
//   void allowDeletion() {
//     _canDelete = true;
//   }

//   // Method to reset controller state (useful for logout)
//   void resetState() {
//     emailController.clear();
//     passwordController.clear();
//     nameController.clear();
//     isLoading.value = false;
//     isPasswordVisible.value = false;
//     isImageUploading.value = false;
//     user.value = null;
//     selectedProfileImage.value = null;
//   }

//   void togglePasswordVisibility() {
//     isPasswordVisible.value = !isPasswordVisible.value;
//   }

//   void setImageUploading(bool value) {
//     isImageUploading.value = value;
//   }

//   void setSelectedProfileImage(File? image) {
//     selectedProfileImage.value = image;
//   }

//   String? validateEmail(String? value) {
//     if (value == null || value.isEmpty) {
//       return 'Email is required';
//     }
//     final emailRegExp = RegExp(
//       r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
//     );
//     if (!emailRegExp.hasMatch(value)) {
//       return 'Please enter a valid email address';
//     }
//     return null;
//   }

//   String? validatePassword(String? value) {
//     if (value == null || value.isEmpty) {
//       return 'Password is required';
//     }
//     return null;
//   }

//   String? validateName(String? value) {
//     if (value == null || value.isEmpty) {
//       return 'Name is required';
//     }
//     if (value.trim().length < 2) {
//       return 'Name must be at least 2 characters long';
//     }
//     if (value.trim().length > 50) {
//       return 'Name must not exceed 50 characters';
//     }
//     // Check if name contains only letters and spaces
//     final nameRegExp = RegExp(r'^[a-zA-Z\s]+$');
//     if (!nameRegExp.hasMatch(value.trim())) {
//       return 'Name can only contain letters and spaces';
//     }
//     return null;
//   }

//   Future<void> loginUser() async {
//     FocusScope.of(Get.context!).unfocus();
//     if (!formKey.currentState!.validate()) {
//       return;
//     }

//     isLoading.value = true;
//     try {
//       final response = await ApiService.loginUser(
//         emailController.text.trim(),
//         passwordController.text,
//       );

//       if (response.success && response.data != null) {
//         // Parse user into UserModel
//         user.value = UserModel.fromJson(response.data!);

//         // Check if user is suspended before proceeding
//         if (user.value!.isSuspended) {
//           Get.snackbar(
//             'Account Suspended',
//             'Your account has been suspended. Please contact support for assistance.',
//             snackPosition: SnackPosition.TOP,
//             backgroundColor: Colors.orange,
//             colorText: Colors.white,
//             duration: const Duration(seconds: 5),
//           );
//           // Clear user data and don't proceed with login
//           user.value = null;
//           return;
//         }

//         // Set the auth token for future API calls
//         if (user.value!.token.isNotEmpty) {
//           ApiService.setAuthToken(user.value!.token);
//         }

//         // Log values
//         log('Name from login controller: ${user.value!.name}');
//         log('Email from login controller: ${user.value!.email}');
//         log('token from login controller: ${user.value!.token}');

//         // Save UserModel using Get.put so it's accessible globally
//         Get.put<UserModel>(user.value!, permanent: true);

//         // Make LoginController globally available
//         // Delete any existing instance first
//         if (Get.isRegistered<LoginController>()) {
//           Get.delete<LoginController>();
//         }
//         Get.put<LoginController>(this, permanent: true);

//         // Show success message
//         Get.snackbar(
//           'Success',
//           "Login successful",
//           snackPosition: SnackPosition.BOTTOM,
//           backgroundColor: Colors.green,
//           colorText: Colors.white,
//           duration: const Duration(seconds: 3),
//         );

//         // Navigate based on role
//         Get.offAll(() => MainScreen());
//       } else {
//         Get.snackbar(
//           'Error',
//           response.message,
//           snackPosition: SnackPosition.TOP,
//           backgroundColor: Colors.red,
//           colorText: Colors.white,
//           duration: const Duration(seconds: 3),
//         );
//       }
//     } catch (e) {
//       log('Login error: $e');
//       Get.snackbar(
//         'Error at LoginController',
//         'An unexpected error occurred: ${e.toString()}',
//         snackPosition: SnackPosition.TOP,
//         backgroundColor: Colors.red,
//         colorText: Colors.white,
//         duration: const Duration(seconds: 3),
//       );
//     } finally {
//       isLoading.value = false;
//     }
//   }

//   Future<void> updateProfile() async {
//     FocusScope.of(Get.context!).unfocus();

//     if (!profileFormKey.currentState!.validate()) {
//       return;
//     }

//     // Check if user is logged in
//     if (user.value == null) {
//       Get.snackbar(
//         'Error',
//         'User not found. Please login again.',
//         snackPosition: SnackPosition.TOP,
//         backgroundColor: Colors.red,
//         colorText: Colors.white,
//         duration: const Duration(seconds: 3),
//       );
//       return;
//     }

//     // Check if token exists
//     if (user.value!.token.isEmpty) {
//       Get.snackbar(
//         'Error',
//         'Authentication token not found. Please login again.',
//         snackPosition: SnackPosition.TOP,
//         backgroundColor: Colors.red,
//         colorText: Colors.white,
//         duration: const Duration(seconds: 3),
//       );
//       return;
//     }

//     isLoading.value = true;
//     await Future.delayed(
//       const Duration(milliseconds: 1000),
//     ); // Optional delay for UX
//     try {
//       // Set auth token BEFORE making the API call
//       log('Setting auth token before API call: ${user.value!.token}');
//       ApiService.setAuthToken(user.value!.token);

//       final response = await ApiService.updateUserProfile(
//         nameController.text.trim(),
//         imagePath: selectedProfileImage.value?.path,
//       );

//       if (response.success) {
//         // Update the local user model with new data
//         if (response.data != null) {
//           // If API returns updated user data, use it
//           if (response.data!.containsKey('user')) {
//             user.value = UserModel.fromJson(response.data!['user']);
//           } else {
//             // Otherwise, just update the name locally
//             user.value = UserModel(
//               id: user.value!.id,
//               name: nameController.text.trim(),
//               email: user.value!.email,
//               role: user.value!.role,
//               token: user.value!.token,
//               image: user.value!.image,
//               enrollments: [], // Keep existing image unless updated
//               notificationTokens: user.value!.notificationTokens,
//               isSuspended: user.value!.isSuspended,
//             );
//           }

//           // Update the global user instance
//           Get.delete<UserModel>();
//           Get.put<UserModel>(user.value!, permanent: true);

//           Get.back();
//         }

//         // Clear form
//         nameController.clear();
//         selectedProfileImage.value = null;

//         WidgetsBinding.instance.addPostFrameCallback((_) {
//           // Show success message
//           Get.snackbar(
//             'Success',
//             'Profile updated successfully',
//             snackPosition: SnackPosition.BOTTOM,
//             backgroundColor: Colors.green,
//             colorText: Colors.white,
//             duration: const Duration(seconds: 3),
//             margin: const EdgeInsets.all(16),
//           );
//         });
//         log('Profile updated successfully');
//         log('Updated name: ${user.value!.name}');
//       } else {
//         Get.snackbar(
//           'Error',
//           response.message.isNotEmpty
//               ? response.message
//               : 'Failed to update profile',
//           snackPosition: SnackPosition.TOP,
//           backgroundColor: Colors.red,
//           colorText: Colors.white,
//           duration: const Duration(seconds: 3),
//         );
//       }
//     } catch (e) {
//       log('Update profile error: $e');
//       Get.snackbar(
//         'Error',
//         'An unexpected error occurred: ${e.toString()}',
//         snackPosition: SnackPosition.TOP,
//         backgroundColor: Colors.red,
//         colorText: Colors.white,
//         duration: const Duration(seconds: 3),
//       );
//     } finally {
//       isLoading.value = false;
//     }
//   }
// }

import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../model/auth/user_model.dart';
import '../../screen/main_screen.dart';
import '../../services/api_services.dart';

class LoginController extends GetxController {
  final formKey = GlobalKey<FormState>();
  final profileFormKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final nameController = TextEditingController();

  final RxBool isLoading = false.obs;
  final RxBool isPasswordVisible = false.obs;
  final RxBool isImageUploading = false.obs;
  final RxBool isBiometricEnabled = false.obs;
  final RxBool canUseBiometrics = false.obs;

  // Using Rx<UserModel?> for reactive user state management
  final Rx<UserModel?> user = Rx<UserModel?>(null);
  final Rx<File?> selectedProfileImage = Rx<File?>(null);

  // Local authentication instance
  final LocalAuthentication _localAuth = LocalAuthentication();
  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();

  // Flag to control when the controller can be deleted
  bool _canDelete = false;

  @override
  void onInit() {
    super.onInit();
    _checkBiometricAvailability();
    _loadBiometricPreference();
  }

  @override
  void onClose() {
    // Only dispose controllers if we're allowed to delete
    if (_canDelete) {
      emailController.dispose();
      passwordController.dispose();
      nameController.dispose();
    }
    super.onClose();
  }

  // Renamed to avoid conflict with GetLifeCycleBase.onDelete field
  void deleteController() {
    if (_canDelete) {
      super.onClose();
    }
  }

  // Method to allow deletion (called during logout)
  void allowDeletion() {
    _canDelete = true;
  }

  // Method to reset controller state (useful for logout)
  void resetState() {
    emailController.clear();
    passwordController.clear();
    nameController.clear();
    isLoading.value = false;
    isPasswordVisible.value = false;
    isImageUploading.value = false;
    isBiometricEnabled.value = false;
    user.value = null;
    selectedProfileImage.value = null;
    secureStorage.delete(key: 'biometric_enabled');
  }

  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  void setImageUploading(bool value) {
    isImageUploading.value = value;
  }

  void setSelectedProfileImage(File? image) {
    selectedProfileImage.value = image;
  }

  Future<void> _checkBiometricAvailability() async {
    try {
      bool canCheck = await _localAuth.canCheckBiometrics;
      canUseBiometrics.value = canCheck;
      log('Biometric availability: $canCheck');
    } catch (e) {
      log('Error checking biometrics: $e');
      canUseBiometrics.value = false;
    }
  }

  Future<void> _loadBiometricPreference() async {
    try {
      String? value = await secureStorage.read(key: 'biometric_enabled');
      isBiometricEnabled.value = value == 'true' && canUseBiometrics.value;
      log('Biometric preference loaded: ${isBiometricEnabled.value}');
    } catch (e) {
      log('Error loading biometric preference: $e');
      isBiometricEnabled.value = false;
    }
  }

  Future<bool> enableBiometrics() async {
    if (!canUseBiometrics.value) {
      Get.snackbar(
        'Error',
        'Biometric authentication is not available on this device.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
      return false;
    }

    try {
      bool authenticated = await _localAuth.authenticate(
        localizedReason: 'Authenticate to enable biometric login',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );

      if (authenticated) {
        await secureStorage.write(key: 'biometric_enabled', value: 'true');
        isBiometricEnabled.value = true;
        Get.snackbar(
          'Success',
          'Biometric authentication enabled.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
        return true;
      } else {
        Get.snackbar(
          'Error',
          'Biometric authentication failed.',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
        return false;
      }
    } catch (e) {
      log('Error enabling biometrics: $e');
      Get.snackbar(
        'Error',
        'An unexpected error occurred: $e',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
      return false;
    }
  }

  Future<bool> authenticateWithBiometrics() async {
    if (!isBiometricEnabled.value || !canUseBiometrics.value) {
      return false;
    }

    try {
      bool authenticated = await _localAuth.authenticate(
        localizedReason: 'Authenticate to log in to LMS',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );
      return authenticated;
    } catch (e) {
      log('Biometric authentication error: $e');
      Get.snackbar(
        'Error',
        'Biometric authentication failed: $e',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
      return false;
    }
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

  String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Name is required';
    }
    if (value.trim().length < 2) {
      return 'Name must be at least 2 characters long';
    }
    if (value.trim().length > 50) {
      return 'Name must not exceed 50 characters';
    }
    final nameRegExp = RegExp(r'^[a-zA-Z\s]+$');
    if (!nameRegExp.hasMatch(value.trim())) {
      return 'Name can only contain letters and spaces';
    }
    return null;
  }

  Future<void> loginUser({bool useBiometrics = false}) async {
    if (useBiometrics) {
      bool authenticated = await authenticateWithBiometrics();
      if (!authenticated || user.value == null) {
        Get.snackbar(
          'Error',
          'Biometric login failed or user not found.',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
        return;
      }
      isLoading.value = true;
      try {
        // Verify token is still valid
        if (user.value!.token.isNotEmpty) {
          ApiService.setAuthToken(user.value!.token);
          Get.offAll(() => MainScreen());
          Get.snackbar(
            'Success',
            'Logged in with biometrics',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green,
            colorText: Colors.white,
            duration: const Duration(seconds: 3),
          );
        } else {
          Get.snackbar(
            'Error',
            'Invalid session. Please log in with email and password.',
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.red,
            colorText: Colors.white,
            duration: const Duration(seconds: 3),
          );
        }
      } catch (e) {
        log('Biometric login error: $e');
        Get.snackbar(
          'Error',
          'An unexpected error occurred: $e',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
      } finally {
        isLoading.value = false;
      }
      return;
    }

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
        user.value = UserModel.fromJson(response.data!);

        if (user.value!.isSuspended) {
          Get.snackbar(
            'Account Suspended',
            'Your account has been suspended. Please contact support for assistance.',
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.orange,
            colorText: Colors.white,
            duration: const Duration(seconds: 5),
          );
          user.value = null;
          return;
        }

        if (user.value!.token.isNotEmpty) {
          ApiService.setAuthToken(user.value!.token);
        }

        log('Name from login controller: ${user.value!.name}');
        log('Email from login controller: ${user.value!.email}');
        log('Token from login controller: ${user.value!.token}');

        Get.put<UserModel>(user.value!, permanent: true);

        if (Get.isRegistered<LoginController>()) {
          Get.delete<LoginController>();
        }
        Get.put<LoginController>(this, permanent: true);

        Get.snackbar(
          'Success',
          'Login successful',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );

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

  Future<void> updateProfile() async {
    FocusScope.of(Get.context!).unfocus();

    if (!profileFormKey.currentState!.validate()) {
      return;
    }

    if (user.value == null) {
      Get.snackbar(
        'Error',
        'User not found. Please login again.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
      return;
    }

    if (user.value!.token.isEmpty) {
      Get.snackbar(
        'Error',
        'Authentication token not found. Please login again.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
      return;
    }

    isLoading.value = true;
    await Future.delayed(const Duration(milliseconds: 1000));
    try {
      log('Setting auth token before API call: ${user.value!.token}');
      ApiService.setAuthToken(user.value!.token);

      final response = await ApiService.updateUserProfile(
        nameController.text.trim(),
        imagePath: selectedProfileImage.value?.path,
      );

      if (response.success) {
        if (response.data != null) {
          if (response.data!.containsKey('user')) {
            user.value = UserModel.fromJson(response.data!['user']);
          } else {
            user.value = UserModel(
              id: user.value!.id,
              name: nameController.text.trim(),
              email: user.value!.email,
              role: user.value!.role,
              token: user.value!.token,
              image: user.value!.image,
              enrollments: [],
              notificationTokens: user.value!.notificationTokens,
              isSuspended: user.value!.isSuspended,
            );
          }

          Get.delete<UserModel>();
          Get.put<UserModel>(user.value!, permanent: true);

          Get.back();
        }

        nameController.clear();
        selectedProfileImage.value = null;

        WidgetsBinding.instance.addPostFrameCallback((_) {
          Get.snackbar(
            'Success',
            'Profile updated successfully',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green,
            colorText: Colors.white,
            duration: const Duration(seconds: 3),
            margin: const EdgeInsets.all(16),
          );
        });
        log('Profile updated successfully');
        log('Updated name: ${user.value!.name}');
      } else {
        Get.snackbar(
          'Error',
          response.message.isNotEmpty
              ? response.message
              : 'Failed to update profile',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
      }
    } catch (e) {
      log('Update profile error: $e');
      Get.snackbar(
        'Error',
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
