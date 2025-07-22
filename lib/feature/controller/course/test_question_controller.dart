import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/utility/snackbar.dart';
import '../../model/api_response_model.dart';
import '../../model/course/test_question_model.dart';
import '../../services/test_question_services.dart';

class LessonTestQuestionController extends GetxController {
  // Observable lists and variables
  final RxList<LessonTestQuestionModel> testQuestions =
      <LessonTestQuestionModel>[].obs;
  final Rx<LessonTestQuestionModel?> selectedTestQuestion =
      Rx<LessonTestQuestionModel?>(null);

  // Loading states
  final RxBool isLoading = false.obs;
  final RxBool isUpdating = false.obs;
  final RxBool isCreating = false.obs;
  final RxBool isDeleting = false.obs;
  final RxBool isFetchingById = false.obs;

  // Form controllers for create/update
  final TextEditingController titleController = TextEditingController();
  final TextEditingController lessonIdController = TextEditingController();
  final RxList<TextEditingController> questionControllers =
      <TextEditingController>[].obs;
  final RxInt selectedCorrectAnswer = 0.obs;

  // Error handling
  final RxString errorMessage = ''.obs;
  final RxBool hasError = false.obs;

  @override
  void onInit() {
    super.onInit();
    _initializeQuestionControllers();
    fetchTestQuestions();
  }

  @override
  void onClose() {
    titleController.dispose();
    lessonIdController.dispose();
    _disposeQuestionControllers();
    super.onClose();
  }

  // Initialize question controllers (default 1 question)
  void _initializeQuestionControllers() {
    questionControllers.clear();
    questionControllers.add(TextEditingController());
  }

  // Dispose question controllers
  void _disposeQuestionControllers() {
    for (var controller in questionControllers) {
      controller.dispose();
    }
    questionControllers.clear();
  }

  // Add a new question field
  void addQuestion() {
    if (questionControllers.length < 10) {
      questionControllers.add(TextEditingController());
    }
  }

  // Remove a question field
  void removeQuestion(int index) {
    if (questionControllers.length > 1 && index < questionControllers.length) {
      questionControllers[index].dispose();
      questionControllers.removeAt(index);

      if (selectedCorrectAnswer.value >= questionControllers.length) {
        selectedCorrectAnswer.value = questionControllers.length - 1;
      }
    }
  }

  // Fetch all test questions
  Future<void> fetchTestQuestions() async {
    try {
      isLoading.value = true;
      hasError.value = false;
      errorMessage.value = '';

      final ApiResponse<List<LessonTestQuestionModel>> response =
          await LessonTestQuestionService.getTestQuestionList(
            lessonId: lessonIdController.text.trim(),
          );

      if (response.success && response.data != null) {
        testQuestions.value = response.data!;
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
  Future<void> fetchTestQuestionById(String testId) async {
    try {
      isFetchingById.value = true;
      hasError.value = false;
      errorMessage.value = '';

      final ApiResponse<LessonTestQuestionModel> response =
          await LessonTestQuestionService.getTestQuestionById(
            lessonId: lessonIdController.text.trim(),
            testId: testId,
          );

      if (response.success && response.data != null) {
        selectedTestQuestion.value = response.data!;
        log(
          'Fetched test question by ID successfully: ${response.data!.title}',
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

      if (!_validateForm()) {
        return false;
      }

      List<TestQuestion> questions = questionControllers
          .map(
            (controller) =>
                TestQuestion(question: controller.text.trim(), options: []),
          )
          .where((q) => q.question.isNotEmpty)
          .toList();

      final ApiResponse<LessonTestQuestionModel> response =
          await LessonTestQuestionService.createTestQuestion(
            lessonId: lessonIdController.text.trim(),
            title: titleController.text.trim(),
            questions: questions,
            correctAnswer: selectedCorrectAnswer.value,
          );

      if (response.success && response.data != null) {
        testQuestions.add(response.data!);
        clearForm();
        log('Test question created successfully: ${response.data!.title}');
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

  // Delete a test question
  Future<bool> deleteTestQuestion(String testId) async {
    try {
      isDeleting.value = true;
      hasError.value = false;
      errorMessage.value = '';

      final ApiResponse<bool> response =
          await LessonTestQuestionService.deleteTestQuestion(
            lessonId: lessonIdController.text.trim(),
            testId: testId,
          );

      if (response.success) {
        testQuestions.removeWhere((question) => question.id == testId);
        log('Test question deleted successfully: $testId');
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

  // Update lesson test
  Future<bool> updateTestQuestion(String? testId) async {
    isUpdating.value = true;
    await Future.delayed(Duration(seconds: 2));
    isUpdating.value = false;

    return false;
  }

  void populateFormWithQuestion(LessonTestQuestionModel question) {
    titleController.text = question.title;
    lessonIdController.text = question.lessonId;
    selectedCorrectAnswer.value = question.correctAnswer;

    _disposeQuestionControllers();
    questionControllers.clear();
    for (int i = 0; i < question.questions.length; i++) {
      questionControllers.add(
        TextEditingController(text: question.questions[i].question),
      );
    }
  }

  void clearForm() {
    titleController.clear();
    lessonIdController.clear();
    selectedCorrectAnswer.value = 0;
    for (var controller in questionControllers) {
      controller.clear();
    }
  }

  bool _validateForm() {
    if (titleController.text.trim().isEmpty) {
      SnackBarMessage.showErrorMessage(
        error: 'Validation Error',
        'Title is required',
      );
      return false;
    }
    if (lessonIdController.text.trim().isEmpty) {
      SnackBarMessage.showErrorMessage(
        error: 'Validation Error',
        'Lesson ID is required',
      );
      return false;
    }
    List<String> questions = questionControllers
        .map((controller) => controller.text.trim())
        .where((q) => q.isNotEmpty)
        .toList();
    if (questions.isEmpty) {
      SnackBarMessage.showErrorMessage(
        error: 'Validation Error',
        'At least 1 question is required',
      );
      return false;
    }
    if (selectedCorrectAnswer.value < 0 ||
        selectedCorrectAnswer.value >= questions.length) {
      SnackBarMessage.showErrorMessage(
        error: 'Validation Error',
        'Please select a valid correct answer',
      );
      return false;
    }
    return true;
  }

  void selectTestQuestion(LessonTestQuestionModel? question) {
    selectedTestQuestion.value = question;
  }

  void clearSelectedTestQuestion() {
    selectedTestQuestion.value = null;
  }
}
