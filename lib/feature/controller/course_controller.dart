// course_controller.dart

import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../model/course/course_model.dart';
import '../model/api_response_model.dart';
import '../screen/widget/dismiss_dialog.dart';
import '../services/course_services.dart';

enum CourseLoadingState {
  initial,
  loading,
  loaded,
  error,
  creating,
  updating,
  deleting,
}

class CourseController extends GetxController {
  // Observable properties
  final _courses = <CourseModel>[].obs;
  final _loadingState = CourseLoadingState.initial.obs;
  final _errorMessage = ''.obs;
  final _selectedCourse = Rxn<CourseModel>();
  final Rx<File?> selectedImage = Rx<File?>(null);
  final RxBool isImageUploading = false.obs;
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final createCourseFormKey = GlobalKey<FormState>();

  // Getters
  List<CourseModel> get courses => _courses;
  CourseLoadingState get loadingState => _loadingState.value;
  String get errorMessage => _errorMessage.value;
  CourseModel? get selectedCourse => _selectedCourse.value;
  bool get isLoading => _loadingState.value == CourseLoadingState.loading;
  bool get isCreating => _loadingState.value == CourseLoadingState.creating;
  bool get isUpdating => _loadingState.value == CourseLoadingState.updating;
  bool get isDeleting => _loadingState.value == CourseLoadingState.deleting;
  bool get hasError => _loadingState.value == CourseLoadingState.error;
  bool get isEmpty =>
      _courses.isEmpty && _loadingState.value != CourseLoadingState.loading;

  // Statistics getters
  int get totalCourses => _courses.length;
  int get totalLessons =>
      _courses.fold(0, (sum, course) => sum + course.lessons.length);
  int get activeCourses => _courses.length; // Assuming all courses are active

  @override
  void onInit() {
    super.onInit();
    // initialize();
  }

  String? validateTitle(String? value) {
    if (value == null || value.isEmpty) {
      return 'Course Title cannot be empty';
    }
    return null;
  }

  String? validateDescription(String? value) {
    if (value == null || value.isEmpty) {
      return 'Course description cannot be empty';
    }
    return null;
  }

  void setSelectedImage(File? image) {
    selectedImage.value = image;
  }

  void setImageUploading(bool loading) {
    isImageUploading.value = loading;
  }

  // Set loading state
  void _setLoadingState(CourseLoadingState state) {
    _loadingState.value = state;
  }

  // Set error message and error state
  void _setError(String message) {
    _errorMessage.value = message;
    _setLoadingState(CourseLoadingState.error);
    log('CourseController Error: $message');
  }

  // Clear error
  void clearError() {
    _errorMessage.value = '';
    if (_loadingState.value == CourseLoadingState.error) {
      _setLoadingState(CourseLoadingState.loaded);
    }
  }

  // Fetch all courses
  Future<void> fetchCourses({bool showLoading = true}) async {
    FocusScope.of(Get.context!).unfocus();

    try {
      if (showLoading) {
        _setLoadingState(CourseLoadingState.loading);
      }
      _courses.clear(); // Clear existing courses before fetching new ones

      log('Fetching courses...');

      // Simulate delay
      await Future.delayed(const Duration(seconds: 2));

      final ApiResponse<List<CourseModel>> response =
          await CourseService.getCourseList();

      if (response.success && response.data != null) {
        _courses.assignAll(response.data!);
        _setLoadingState(CourseLoadingState.loaded);
        log('Successfully fetched ${_courses.length} courses');
      } else {
        _setError(response.message ?? 'Failed to fetch courses');
      }
    } catch (e) {
      _setError(
        'An unexpected error occurred while fetching courses: ${e.toString()}',
      );
    }
  }

  // Refresh courses (pull to refresh)
  Future<void> refreshCourses() async {
    await fetchCourses(showLoading: false);
  }

  // Create a new course - FIXED VERSION
  Future<bool> createCourse() async {
    FocusScope.of(Get.context!).unfocus();

    if (!createCourseFormKey.currentState!.validate()) {
      return false;
    }

    log('Creating course: ${titleController.text.trim()}');
    log('Description: ${descriptionController.text.trim()}');
    log('Selected Image: ${selectedImage.value?.path ?? 'No image selected'}');

    try {
      _setLoadingState(CourseLoadingState.creating);

      final ApiResponse<CourseModel> response =
          await CourseService.createCourse(
            titleController.text.trim(),
            descriptionController.text.trim(),
            image: selectedImage.value?.path,
          );

      if (response.success && response.data != null) {
        // Add the new course to the list ONLY
        _courses.insert(0, response.data!);
        _setLoadingState(CourseLoadingState.loaded);
        log('Successfully created course: ${response.data!.title}');

        showSuccessMessage('Course created successfully');

        // Clear form data
        _clearFormData();

        return true;
      } else {
        _setError(response.message ?? 'Failed to create course');
        return false;
      }
    } catch (e) {
      _setError(
        'An unexpected error occurred while creating course: ${e.toString()}',
      );
      return false;
    }
  }

  // Clear form data
  void _clearFormData() {
    titleController.clear();
    descriptionController.clear();
    selectedImage.value = null;
  }

  // Show success message - separate method
  void showSuccessMessage(String message) {
    // Use a slight delay to ensure navigation completes first
    Future.delayed(const Duration(milliseconds: 300), () {
      Get.snackbar(
        'Success',
        message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.primaryColor,
        colorText: Get.theme.colorScheme.onPrimary,
        margin: const EdgeInsets.all(16),
        borderRadius: 8,
      );
    });
  }

  // Update an existing course
  Future<bool> updateCourse(
    String courseId,
    String title,
    String description, {
    String? imagePath,
  }) async {
    try {
      _setLoadingState(CourseLoadingState.updating);

      log('Updating course: $courseId');
      final ApiResponse<CourseModel> response =
          await CourseService.updateCourse(
            courseId,
            title,
            description,
            imagePath: imagePath,
          );

      if (response.success && response.data != null) {
        // Update the course in the list
        final index = _courses.indexWhere((course) => course.id == courseId);
        if (index != -1) {
          _courses[index] = response.data!;
        }
        _setLoadingState(CourseLoadingState.loaded);
        log('Successfully updated course: ${response.data!.title}');

        // Show success message
        showSuccessMessage('Course updated successfully');

        return true;
      } else {
        _setError(response.message ?? 'Failed to update course');
        return false;
      }
    } catch (e) {
      _setError(
        'An unexpected error occurred while updating course: ${e.toString()}',
      );
      return false;
    }
  }

  // Delete a course
  Future<bool> deleteCourse(String courseId) async {
    try {
      // Show non-dismissible loading dialog
      showNonDismissibleLoadingDialog('Deleting course...');

      log('Deleting course: $courseId');
      final ApiResponse<bool> response = await CourseService.deleteCourse(
        courseId,
      );

      // Hide loading dialog
      if (Get.isDialogOpen!) {
        Get.back();
      }

      if (response.success) {
        // Remove the course from the list
        _courses.removeWhere((course) => course.id == courseId);
        _setLoadingState(CourseLoadingState.loaded);
        log('Successfully deleted course: $courseId');

        // Show success message
        showSuccessMessage('Course deleted successfully');

        return true;
      } else {
        _setError(response.message ?? 'Failed to delete course');
        return false;
      }
    } catch (e) {
      // Hide loading dialog if still open
      if (Get.isDialogOpen!) {
        Get.back();
      }

      _setError(
        'An unexpected error occurred while deleting course: ${e.toString()}',
      );
      return false;
    }
  }

  // Select a course
  void selectCourse(CourseModel course) {
    _selectedCourse.value = course;
  }

  // Clear selected course
  void clearSelectedCourse() {
    _selectedCourse.value = null;
  }

  // Get course by ID
  CourseModel? getCourseById(String courseId) {
    try {
      return _courses.firstWhere((course) => course.id == courseId);
    } catch (e) {
      return null;
    }
  }

  // Search courses by title or description
  List<CourseModel> searchCourses(String query) {
    if (query.isEmpty) return _courses;

    final lowerQuery = query.toLowerCase();
    return _courses.where((course) {
      return course.title.toLowerCase().contains(lowerQuery) ||
          course.description.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  // Filter courses (you can extend this with more filters)
  List<CourseModel> filterCourses({int? minLessons, int? maxLessons}) {
    return _courses.where((course) {
      bool matchesMinLessons =
          minLessons == null || course.lessons.length >= minLessons;
      bool matchesMaxLessons =
          maxLessons == null || course.lessons.length <= maxLessons;

      return matchesMinLessons && matchesMaxLessons;
    }).toList();
  }



  // Reset controller
  void reset() {
    _courses.clear();
    _errorMessage.value = '';
    _selectedCourse.value = null;
    _setLoadingState(CourseLoadingState.initial);
  }

  // Debug method to print current state
  void debugPrintState() {
    log('=== CourseController State ===');
    log('Courses count: ${_courses.length}');
    log('Loading state: ${_loadingState.value}');
    log('Error message: ${_errorMessage.value}');
    log('Selected course: ${_selectedCourse.value?.title ?? 'None'}');
    log('============================');
  }




  // Show error dialog
  void showErrorDialog(String message) {
    Get.defaultDialog(
      title: 'Error',
      middleText: message,
      textConfirm: 'OK',
      confirmTextColor: Get.theme.colorScheme.onPrimary,
      buttonColor: Get.theme.primaryColor,
      onConfirm: () => Get.back(),
    );
  }

  // Show confirmation dialog
  Future<bool> showConfirmDialog({
    required String title,
    required String message,
    String confirmText = 'Yes',
    String cancelText = 'No',
  }) async {
    return await Get.defaultDialog<bool>(
          title: title,
          middleText: message,
          textConfirm: confirmText,
          textCancel: cancelText,
          confirmTextColor: Get.theme.colorScheme.onPrimary,
          buttonColor: Get.theme.primaryColor,
          onConfirm: () => Get.back(result: true),
          onCancel: () => Get.back(result: false),
        ) ??
        false;
  }

  @override
  void onClose() {
    titleController.dispose();
    descriptionController.dispose();
    super.onClose();
  }
}
