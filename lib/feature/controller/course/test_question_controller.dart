// test_question_controller.dart

import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/utility/snackbar.dart';
import '../../model/api_response_model.dart';
import '../../model/course/test_question_model.dart';
import '../../services/test_question_services.dart';

class TestQuestionController extends GetxController {
  // Observable lists and variables
  final RxList<TestQuestionModel> testQuestions = <TestQuestionModel>[].obs;
  final RxList<TestQuestionModel> filteredTestQuestions =
      <TestQuestionModel>[].obs;
  final Rx<TestQuestionModel?> selectedTestQuestion = Rx<TestQuestionModel?>(
    null,
  );

  // Loading states
  final RxBool isLoading = false.obs;
  final RxBool isCreating = false.obs;
  final RxBool isUpdating = false.obs;
  final RxBool isDeleting = false.obs;
  final RxBool isFetchingById = false.obs;

  // Search and filter
  final RxString searchQuery = ''.obs;
  final RxString selectedLessonId = ''.obs;

  // Form controllers for create/update
  final TextEditingController questionController = TextEditingController();
  final TextEditingController lessonIdController = TextEditingController();
  final RxList<TextEditingController> optionControllers =
      <TextEditingController>[].obs;
  final RxInt selectedCorrectAnswer = 0.obs;

  // Error handling
  final RxString errorMessage = ''.obs;
  final RxBool hasError = false.obs;

  @override
  void onInit() {
    super.onInit();
    // Initialize with default options
    _initializeOptionControllers();
    // Load test questions when controller is initialized
    fetchTestQuestions();

    // Listen to search query changes
    debounce(
      searchQuery,
      (_) => _filterTestQuestions(),
      time: const Duration(milliseconds: 500),
    );
    debounce(
      selectedLessonId,
      (_) => _filterTestQuestions(),
      time: const Duration(milliseconds: 300),
    );
  }

  @override
  void onClose() {
    // Dispose controllers
    questionController.dispose();
    lessonIdController.dispose();
    _disposeOptionControllers();
    super.onClose();
  }

  // Initialize option controllers (default 3 options)
  void _initializeOptionControllers() {
    optionControllers.clear();
    for (int i = 0; i < 3; i++) {
      optionControllers.add(TextEditingController());
    }
  }

  // Dispose option controllers
  void _disposeOptionControllers() {
    for (var controller in optionControllers) {
      controller.dispose();
    }
    optionControllers.clear();
  }

  // Add a new option field
  void addOption() {
    if (optionControllers.length < 6) {
      // Limit to 6 options
      optionControllers.add(TextEditingController());
    }
  }

  // Remove an option field
  void removeOption(int index) {
    if (optionControllers.length > 2 && index < optionControllers.length) {
      // Minimum 2 options
      optionControllers[index].dispose();
      optionControllers.removeAt(index);

      // Adjust correct answer if needed
      if (selectedCorrectAnswer.value >= optionControllers.length) {
        selectedCorrectAnswer.value = optionControllers.length - 1;
      }
    }
  }

  // Fetch all test questions
  Future<void> fetchTestQuestions() async {
    try {
      isLoading.value = true;
      hasError.value = false;
      errorMessage.value = '';

      await Future.delayed(Duration(seconds: 2));

      final ApiResponse<List<TestQuestionModel>> response =
          await TestQuestionService.getTestQuestionList();

      if (response.success && response.data != null) {
        testQuestions.value = response.data!;
        _filterTestQuestions();
        log('Fetched ${testQuestions.length} test questions successfully');
      } else {
        hasError.value = true;
        errorMessage.value = response.message;
        log('Failed to fetch test questions: ${response.message}');
        SnackBarMessage.showErrorMessage(
          'Failed to load test questions ${response.message}',
        );
      }
    } catch (e) {
      hasError.value = true;
      errorMessage.value = 'An unexpected error occurred';
      log('Error fetching test questions: $e');
      SnackBarMessage.showErrorMessage('An unexpected error occurred');
    } finally {
      isLoading.value = false;
    }
  }

  // Fetch test question by ID
  Future<void> fetchTestQuestionById(String questionId) async {
    try {
      isFetchingById.value = true;
      hasError.value = false;
      errorMessage.value = '';

      final ApiResponse<TestQuestionModel> response =
          await TestQuestionService.getTestQuestionById(questionId);

      if (response.success && response.data != null) {
        selectedTestQuestion.value = response.data!;
        log(
          'Fetched test question by ID successfully: ${response.data!.question}',
        );
      } else {
        hasError.value = true;
        errorMessage.value = response.message;
        log('Failed to fetch test question by ID: ${response.message}');
        SnackBarMessage.showErrorMessage(
          'Failed to load test question ${response.message}',
        );
      }
    } catch (e) {
      hasError.value = true;
      errorMessage.value = 'An unexpected error occurred';
      log('Error fetching test question by ID: $e');
      SnackBarMessage.showErrorMessage('An unexpected error occurred');
    } finally {
      isFetchingById.value = false;
    }
  }

  // Create a new test question
  Future<bool> createTestQuestion() async {
    try {
      isCreating.value = true;
      hasError.value = false;
      errorMessage.value = '';

      // Validate form
      if (!_validateForm()) {
        return false;
      }

      // Prepare options list
      List<String> options = optionControllers
          .map((controller) => controller.text.trim())
          .where((option) => option.isNotEmpty)
          .toList();

      final ApiResponse<TestQuestionModel> response =
          await TestQuestionService.createTestQuestion(
            question: questionController.text.trim(),
            options: options,
            correctAnswer: selectedCorrectAnswer.value,
            lessonId: lessonIdController.text.trim(),
          );

      if (response.success && response.data != null) {
        // Add the new test question to the list
        testQuestions.add(response.data!);
        _filterTestQuestions();

        // Clear form
        clearForm();

        log('Test question created successfully: ${response.data!.question}');
        SnackBarMessage.showSuccessMessage(
          'Test question created successfully',
        );
        return true;
      } else {
        hasError.value = true;
        errorMessage.value = response.message;
        log('Failed to create test question: ${response.message}');
        SnackBarMessage.showErrorMessage(
          'Failed to create test question ${response.message}',
        );
        return false;
      }
    } catch (e) {
      hasError.value = true;
      errorMessage.value = 'An unexpected error occurred';
      log('Error creating test question: $e');
      SnackBarMessage.showErrorMessage('An unexpected error occurred');
      return false;
    } finally {
      isCreating.value = false;
    }
  }

  // Update an existing test question
  Future<bool> updateTestQuestion(String questionId) async {
    try {
      isUpdating.value = true;
      hasError.value = false;
      errorMessage.value = '';

      // Validate form
      if (!_validateForm()) {
        return false;
      }

      // Prepare options list
      List<String> options = optionControllers
          .map((controller) => controller.text.trim())
          .where((option) => option.isNotEmpty)
          .toList();

      final ApiResponse<TestQuestionModel> response =
          await TestQuestionService.updateTestQuestion(
            questionId: questionId,
            question: questionController.text.trim(),
            options: options,
            correctAnswer: selectedCorrectAnswer.value,
            lessonId: lessonIdController.text.trim(),
          );

      if (response.success && response.data != null) {
        // Update the test question in the list
        final index = testQuestions.indexWhere((q) => q.id == questionId);
        if (index != -1) {
          testQuestions[index] = response.data!;
          _filterTestQuestions();
        }

        // Clear form
        clearForm();

        log('Test question updated successfully: ${response.data!.question}');
        SnackBarMessage.showSuccessMessage(
          'Test question updated successfully',
        );
        return true;
      } else {
        hasError.value = true;
        errorMessage.value = response.message;
        log('Failed to update test question: ${response.message}');
        SnackBarMessage.showErrorMessage(
          'Failed to update test question ${response.message}',
        );
        return false;
      }
    } catch (e) {
      hasError.value = true;
      errorMessage.value = 'An unexpected error occurred';
      log('Error updating test question: $e');
      SnackBarMessage.showErrorMessage('An unexpected error occurred');
      return false;
    } finally {
      isUpdating.value = false;
    }
  }

  // Delete a test question
  Future<bool> deleteTestQuestion(String questionId) async {
    try {
      isDeleting.value = true;
      hasError.value = false;
      errorMessage.value = '';

      final ApiResponse<bool> response =
          await TestQuestionService.deleteTestQuestion(questionId);

      if (response.success) {
        // Remove the test question from the list
        testQuestions.removeWhere((question) => question.id == questionId);
        _filterTestQuestions();

        log('Test question deleted successfully: $questionId');
        SnackBarMessage.showSuccessMessage(
          'Test question deleted successfully',
        );
        return true;
      } else {
        hasError.value = true;
        errorMessage.value = response.message;
        log('Failed to delete test question: ${response.message}');
        SnackBarMessage.showErrorMessage(
          'Failed to delete test question ${response.message}',
        );
        return false;
      }
    } catch (e) {
      hasError.value = true;
      errorMessage.value = 'An unexpected error occurred';
      log('Error deleting test question: $e');
      SnackBarMessage.showErrorMessage('An unexpected error occurred');
      return false;
    } finally {
      isDeleting.value = false;
    }
  }

  // Search and filter functions
  void updateSearchQuery(String query) {
    searchQuery.value = query.toLowerCase();
  }

  void updateLessonFilter(String lessonId) {
    selectedLessonId.value = lessonId;
  }

  void clearFilters() {
    searchQuery.value = '';
    selectedLessonId.value = '';
  }

  void _filterTestQuestions() {
    List<TestQuestionModel> filtered = testQuestions.toList();

    // Filter by search query
    if (searchQuery.value.isNotEmpty) {
      filtered = filtered.where((question) {
        return question.question.toLowerCase().contains(searchQuery.value) ||
            question.options.any(
              (option) => option.toLowerCase().contains(searchQuery.value),
            );
      }).toList();
    }

    // Filter by lesson ID
    if (selectedLessonId.value.isNotEmpty) {
      filtered = filtered
          .where((question) => question.lessonId == selectedLessonId.value)
          .toList();
    }

    filteredTestQuestions.value = filtered;
  }

  // Form management
  void populateFormWithQuestion(TestQuestionModel question) {
    questionController.text = question.question;
    lessonIdController.text = question.lessonId;
    selectedCorrectAnswer.value = question.correctAnswer;

    // Clear existing option controllers
    _disposeOptionControllers();
    optionControllers.clear();

    // Create controllers for each option
    for (int i = 0; i < question.options.length; i++) {
      optionControllers.add(TextEditingController(text: question.options[i]));
    }
  }

  void clearForm() {
    questionController.clear();
    lessonIdController.clear();
    selectedCorrectAnswer.value = 0;

    // Clear option controllers
    for (var controller in optionControllers) {
      controller.clear();
    }
  }

  bool _validateForm() {
    // Validate question
    if (questionController.text.trim().isEmpty) {
      SnackBarMessage.showErrorMessage(
        error: 'Validation Error',
        'Question is required',
      );
      return false;
    }

    // Validate lesson ID
    if (lessonIdController.text.trim().isEmpty) {
      SnackBarMessage.showErrorMessage(
        error: 'Validation Error',
        'Lesson ID is required',
      );
      return false;
    }

    // Validate options
    List<String> options = optionControllers
        .map((controller) => controller.text.trim())
        .where((option) => option.isNotEmpty)
        .toList();

    if (options.length < 2) {
      SnackBarMessage.showErrorMessage(
        error: 'Validation Error',
        'At least 2 options are required',
      );
      return false;
    }

    // Validate correct answer
    if (selectedCorrectAnswer.value < 0 ||
        selectedCorrectAnswer.value >= options.length) {
      SnackBarMessage.showErrorMessage(
        error: 'Validation Error',
        'Please select a valid correct answer',
      );
      return false;
    }

    return true;
  }

  // Utility functions
  void refreshTestQuestions() {
    fetchTestQuestions();
  }

  void selectTestQuestion(TestQuestionModel? question) {
    selectedTestQuestion.value = question;
  }

  void clearSelectedTestQuestion() {
    selectedTestQuestion.value = null;
  }

  // Get test questions by lesson ID
  List<TestQuestionModel> getQuestionsByLessonId(String lessonId) {
    return testQuestions
        .where((question) => question.lessonId == lessonId)
        .toList();
  }

  // Get total number of questions
  int get totalQuestionsCount => testQuestions.length;

  // Get filtered count
  int get filteredQuestionsCount => filteredTestQuestions.length;

  // Check if there are any questions for a specific lesson
  bool hasQuestionsForLesson(String lessonId) {
    return testQuestions.any((question) => question.lessonId == lessonId);
  }

  // Confirmation dialog for delete
  Future<bool> showDeleteConfirmation(String questionText) async {
    return await Get.dialog<bool>(
          AlertDialog(
            title: const Text('Delete Test Question'),
            content: Text(
              'Are you sure you want to delete this test question?\n\n"$questionText"\n\nThis action cannot be undone.',
            ),
            actions: [
              TextButton(
                onPressed: () => Get.back(result: false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Get.back(result: true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Delete'),
              ),
            ],
          ),
          barrierDismissible: false,
        ) ??
        false;
  }
}
