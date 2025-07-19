import 'package:flutter/material.dart';
import 'package:flutter_fyp/feature/screen/auth/login_screen.dart';
import 'package:get/get.dart';
import 'dart:io';

import '../../../core/utility/model/image_picker_utils.dart';
import '../../controller/auth/register_controller.dart';

class RegistrationScreen extends StatelessWidget {
  final RegistrationController controller = Get.put(RegistrationController());

  RegistrationScreen({Key? key}) : super(key: key);

  Future<void> _pickImage() async {
    final File? selectedFile = await ImagePickerUtils.pickImageFromGallery(
      maxWidth: 1024,
      maxHeight: 1024,
      onStart: () => controller.setImageUploading(true),
      onEnd: () => controller.setImageUploading(false),
      onError: (error) {
        // Custom error handling if needed
        print('Image picker error: $error');
      },
    );

    if (selectedFile != null) {
      controller.setSelectedImage(selectedFile);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registration'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Image.asset('assets/logo.png', width: 150, height: 150),
            const SizedBox(height: 16),

            Form(
              key: controller.registerFormKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 20),

                  // Name Field
                  TextFormField(
                    controller: controller.nameController,
                    decoration: const InputDecoration(
                      labelText: 'Full Name',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person),
                    ),
                    validator: controller.validateName,
                    textCapitalization: TextCapitalization.words,
                  ),
                  const SizedBox(height: 16),

                  // Email Field
                  TextFormField(
                    controller: controller.emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.email),
                    ),
                    validator: controller.validateEmail,
                    keyboardType: TextInputType.emailAddress,
                    autocorrect: false,
                  ),
                  const SizedBox(height: 16),

                  // Password Field
                  Obx(
                    () => TextFormField(
                      controller: controller.passwordController,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.lock),
                        suffixIcon: IconButton(
                          icon: Icon(
                            controller.isPasswordVisible.value
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          onPressed: controller.togglePasswordVisibility,
                        ),
                      ),
                      validator: controller.validatePassword,
                      obscureText: !controller.isPasswordVisible.value,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Image Preview and Upload Section
                  Obx(
                    () => Column(
                      children: [
                        if (controller.selectedImage.value != null)
                          Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            child: Column(
                              children: [
                                Container(
                                  width: 120,
                                  height: 120,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: Colors.grey.shade300,
                                    ),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.file(
                                      controller.selectedImage.value!,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Selected Image',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),

                        // Image Upload Button
                        Container(
                          margin: const EdgeInsets.only(bottom: 24),
                          child: ElevatedButton.icon(
                            onPressed: controller.isImageUploading.value
                                ? null
                                : _pickImage,
                            icon: controller.isImageUploading.value
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  )
                                : const Icon(Icons.cloud_upload),
                            label: Text(
                              controller.isImageUploading.value
                                  ? 'Uploading...'
                                  : controller.selectedImage.value != null
                                  ? 'Change Image'
                                  : 'Upload Image',
                            ),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Register Link
                  TextButton(
                    onPressed: () => Get.to(() => LoginScreen()),
                    child: const Text('Already have an account? Login here'),
                  ),

                  const SizedBox(height: 32),

                  // Submit Button
                  Obx(
                    () => ElevatedButton(
                      onPressed: controller.isLoading.value
                          ? null
                          : controller.registerUser,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        textStyle: const TextStyle(fontSize: 16),
                      ),
                      child: controller.isLoading.value
                          ? const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 12),
                                Text('Registering...'),
                              ],
                            )
                          : const Text('Register'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
