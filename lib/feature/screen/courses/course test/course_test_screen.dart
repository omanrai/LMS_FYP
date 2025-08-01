import 'package:flutter/material.dart';
import 'package:flutter_fyp/core/utility/dialog_utils.dart';
import 'package:get/get.dart';
import '../../../controller/course/course_test_controller.dart';
import '../../../model/course/course_model.dart';
import '../../../model/course/course_test_model.dart';
import 'add_edit_course_test.dart';

class CourseTestQuestionScreen extends StatelessWidget {
  final CourseModel course;
  final CourseTestController controller = Get.put(CourseTestController());
  // final CourseLessonModel lesson = Get.arguments as CourseLessonModel;

  CourseTestQuestionScreen({super.key, required this.course});

  @override
  Widget build(BuildContext context) {
    if (controller.courseIdController.text.isEmpty) {
      controller.courseIdController.text = course.id;

      controller.fetchTestQuestions();
    }
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: _buildAppBar(),
      body: _buildBody(),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFF6366F1),
      foregroundColor: Colors.white,
      elevation: 0,
      title: const Text(
        'Question Bank',
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_rounded),
        onPressed: () => Get.back(),
      ),
    );
  }

  Widget _buildBody() {
    return RefreshIndicator(
      onRefresh: () async {
        await controller.fetchTestQuestions();
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(children: [_buildStatsSection(), _buildQuestionsList()]),
      ),
    );
  }

  Widget _buildStatsSection() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      child: Row(
        children: [
          Expanded(
            child: Obx(
              () => _buildStatCard(
                title: course.title,
                subTitle: 'Total Questions',
                value: controller.testQuestions
                    .fold(0, (sum, test) => sum + test.questions.length)
                    .toString(), // Sum the number of questions
                icon: Icons.quiz_outlined,
                color: const Color(0xFF3B82F6),
                gradient: const LinearGradient(
                  colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String subTitle,
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required LinearGradient gradient,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Text(
              'Course Name : $title',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
                height: 1.5,
              ),
            ),
          ),

          const SizedBox(height: 12),
          Row(
            spacing: 10,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: Colors.white, size: 20),
              ),

              Text(
                value,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          Text(
            subTitle,
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withOpacity(0.9),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionsList() {
    return Obx(() {
      if (controller.isLoading.value) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                    ),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: const Center(
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 3,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Loading questions...',
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF64748B),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        );
      }

      if (controller.hasError.value) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Center(
            child: Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.red.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(40),
                    ),
                    child: const Icon(
                      Icons.error_outline_rounded,
                      size: 40,
                      color: Colors.red,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Oops! Something went wrong',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    controller.errorMessage.value,
                    style: const TextStyle(color: Color(0xFF64748B)),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: controller.fetchTestQuestions,
                    icon: const Icon(Icons.refresh_rounded),
                    label: const Text('Try Again'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }

      if (controller.testQuestions.isEmpty) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Center(
            child: Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF667EEA).withOpacity(0.1),
                          const Color(0xFF764BA2).withOpacity(0.1),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: const Icon(
                      Icons.quiz_outlined,
                      size: 50,
                      color: Color(0xFF667EEA),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'No questions yet',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Create your first question to get started',
                    style: TextStyle(color: Color(0xFF64748B)),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => _showCreateQuestionScreen(Get.context!),
                    icon: const Icon(Icons.add_rounded),
                    label: const Text('Create Question'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF667EEA),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }

      return Padding(
        padding: const EdgeInsets.fromLTRB(10, 8, 10, 50),
        child: Column(
          children: controller.testQuestions.asMap().entries.map((entry) {
            final index = entry.key;
            final question = entry.value;
            return _buildQuestionCard(question, Get.context!, index);
          }).toList(),
        ),
      );
    });
  }

  Widget _buildQuestionCard(
    CourseTestModel testQuestion,
    BuildContext context,
    int index,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Display the test title once at the top
                Center(
                  child: Text(
                    testQuestion.title.isNotEmpty
                        ? testQuestion.title
                        : 'No Title',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1E293B),
                      height: 1.5,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF10B981), Color(0xFF047857)],
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.book_rounded,
                            size: 14,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Test ID ${testQuestion.id}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: PopupMenuButton<String>(
                        icon: const Icon(
                          Icons.more_vert_rounded,
                          color: Color(0xFF64748B),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        onSelected: (value) async {
                          switch (value) {
                            // case 'edit':
                            //   _showEditQuestionScreen(context, testQuestion);
                            //   break;
                            case 'delete':
                              final confirmed = await DialogUtils.showConfirmDialog(
                                title: 'Delete Lesson Test',
                                message:
                                    'Are you sure you want to delete this lesson test?',
                                confirmText: 'Delete',
                                cancelText: 'Cancel',
                                icon: Icons.delete_forever,
                                isDangerous: true,
                              );
                              if (confirmed) {
                                controller.deleteTestQuestion(testQuestion.id);
                              }
                              break;
                          }
                        },
                        itemBuilder: (context) => [
                          // const PopupMenuItem(
                          //   value: 'edit',
                          //   child: Row(
                          //     children: [
                          //       Icon(
                          //         Icons.edit_rounded,
                          //         color: Color(0xFF3B82F6),
                          //         size: 18,
                          //       ),
                          //       SizedBox(width: 12),
                          //       Text('Edit Question'),
                          //     ],
                          //   ),
                          // ),
                          const PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(
                                  Icons.delete_rounded,
                                  color: Colors.red,
                                  size: 18,
                                ),
                                SizedBox(width: 12),
                                Text('Delete Question'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Display all questions
                ...testQuestion.questions.asMap().entries.map((entry) {
                  final questionIndex = entry.key;
                  final questionData = entry.value;
                  return _buildQuestionContent(
                    testQuestion,
                    questionData,
                    context,
                    index,
                    questionIndex,
                  );
                }),
              ],
            ),
          ),
          if (testQuestion.questions.isNotEmpty)
            Container(
              padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (testQuestion.createdAt != null)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.schedule_rounded,
                            size: 16,
                            color: Color(0xFF64748B),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Created ${_formatDateTime(testQuestion.createdAt!)}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF64748B),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildQuestionContent(
    CourseTestModel testQuestion,
    CourseTestQuestion questionData,
    BuildContext context,
    int testIndex,
    int questionIndex,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 25,
              height: 25,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  '${testIndex + 1}.${questionIndex + 1}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (questionData.question.isNotEmpty)
                    Text(
                      questionData.question,
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF64748B),
                        height: 1.5,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (questionData.options.isNotEmpty)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Answer Options',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 12),
              ...questionData.options.asMap().entries.map((entry) {
                final optionIndex = entry.key;
                final option = entry.value;
                final isCorrect = optionIndex == testQuestion.correctAnswer;

                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isCorrect
                        ? const Color(0xFF10B981).withOpacity(0.08)
                        : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isCorrect
                          ? const Color(0xFF10B981).withOpacity(0.3)
                          : const Color(0xFFE2E8F0),
                      width: isCorrect ? 1.5 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: isCorrect
                              ? const Color(0xFF10B981)
                              : const Color(0xFF94A3B8),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Center(
                          child: Text(
                            String.fromCharCode(65 + optionIndex),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          option,
                          style: TextStyle(
                            color: isCorrect
                                ? const Color(0xFF047857)
                                : const Color(0xFF374151),
                            fontWeight: isCorrect
                                ? FontWeight.w600
                                : FontWeight.w500,
                            height: 1.3,
                          ),
                        ),
                      ),
                      if (isCorrect)
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF10B981).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Icon(
                            Icons.check_rounded,
                            color: Color(0xFF047857),
                            size: 16,
                          ),
                        ),
                    ],
                  ),
                );
              }),
            ],
          ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildFloatingActionButton() {
    return Obx(() {
      // Only show the button if testQuestions is empty
      if (controller.testQuestions.isEmpty) {
        return Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
            ),
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF667EEA).withOpacity(0.4),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: FloatingActionButton.extended(
            onPressed: () => _showCreateQuestionScreen(Get.context!),
            backgroundColor: Colors.transparent,
            elevation: 0,
            icon: const Icon(Icons.add_rounded, color: Colors.white),
            label: const Text(
              'New Question',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        );
      } else {
        // Return an empty SizedBox when testQuestions is not empty
        return const SizedBox.shrink();
      }
    });
  }

  void _showCreateQuestionScreen(BuildContext context) {
    controller.clearForm();
    Get.to(() => AddEditCourseTestScreen(courseId: course.id));
  }

  void _showEditQuestionScreen(BuildContext context, CourseTestModel question) {
    controller.populateFormWithQuestion(question);
    Get.to(
      () =>
          AddEditCourseTestScreen(courseId: course.id, testQuestion: question),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} at ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
