import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_fyp/feature/model/course/enrollment_model.dart';
import 'package:flutter_fyp/feature/screen/courses/test%20question/lesson_test_question.dart';
import 'package:get/get.dart';
import '../../../core/utility/dialog_utils.dart';
import '../../controller/auth/login_controller.dart';
import '../../controller/chat/group_chat_controller.dart';
import '../../controller/course/course_lesson_controller.dart';
import '../../controller/course/course_review_controller.dart';
import '../../model/course/course_lesson_model.dart';
import '../../model/course/course_model.dart';
import 'lesson/add_edit_lesson.dart';
import 'lesson/lesson_screen.dart';
import 'test question/quiz.dart';

class ViewCourseScreen extends StatefulWidget {
  final CourseModel course;
  final EnrollmentModel? enrollment;
  const ViewCourseScreen({Key? key, required this.course, this.enrollment})
    : super(key: key);

  @override
  State<ViewCourseScreen> createState() => _ViewCourseScreenState();
}

class _ViewCourseScreenState extends State<ViewCourseScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final CourseLessonController courseLessonController = Get.put(
    CourseLessonController(),
  );
  final CourseReviewController courseReviewController = Get.put(
    CourseReviewController(),
  );

  final GroupChatController groupChatController = GroupChatController();

  final LoginController loginController = Get.find<LoginController>();

  final RxInt _currentTabIndex = 0.obs;

  String enrollStatus = '';

  Map<String, double> lessonProgress = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      _currentTabIndex.value = _tabController.index;
    });

    enrollStatus = widget.enrollment!.status;
    log(enrollStatus);

    courseLessonController.setCurrentCourseId(widget.course.id);
    courseLessonController.fetchCourseLessons();

    courseReviewController.getReviewsForCourse(widget.course.id);

    groupChatController.setCourse(widget.course.id);
    groupChatController.setCurrentUser(loginController.user.value);
    groupChatController.setCurrentCourse(widget.course);
  }

  void _onProgressUpdate(String lessonId, double progress) {
    setState(() {
      lessonProgress[lessonId] = progress;
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (courseLessonController.isLoading.value) {
        return Scaffold(
          backgroundColor: const Color(0xFFF8FAFF),
          body: const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6366F1)),
            ),
          ),
        );
      }

      return Scaffold(
        body: CustomScrollView(
          slivers: [
            // _buildSliverAppBar(),
            SliverToBoxAdapter(
              child: Column(
                children: [
                  // _buildCourseHeader(),
                  _buildTabSection(),
                  _buildTabContent(),
                ],
              ),
            ),
          ],
        ),
        floatingActionButton: _buildFloatingActionButton(widget.course),
      );
    });
  }

  Widget _buildTabSection() {
    return Container(
      color: Colors.white,
      child: TabBar(
        isScrollable: true,
        controller: _tabController,
        labelColor: const Color(0xFF6366F1),
        unselectedLabelColor: const Color(0xFF6B7280),
        indicatorColor: const Color(0xFF6366F1),
        indicatorWeight: 3,
        labelStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        tabs: const [
          Tab(text: 'Overview'),
          Tab(text: 'Lessons'),
          // Tab(text: 'Reviews'),
          // Tab(text: 'Discussion'),
        ],
      ),
    );
  }

  Widget _buildTabContent() {
    return Container(
      height: 700,
      color: const Color(0xFFF8FAFF),
      child: TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(),
          _buildLessonsTab(),
          // _buildReviewsTab(),
          // _buildGroupChatTab(),
        ],
      ),
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('About This Course'),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.course.description,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color(0xFF374151),
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 20),
                _buildCourseDetails(),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _buildWhatYouLearn(),
        ],
      ),
    );
  }

  Widget _buildCourseDetails() {
    return Column(
      children: [
        const Divider(height: 24),

        _buildDetailRow('Course ID', widget.course.id),
        const Divider(height: 24),
        // _buildDetailRow('Total Lessons', '${widget.course.lessons.length}'),
        Obx(() {
          return _buildDetailRow(
            'Total Lessons',
            '${courseLessonController.lessons.length}',
          );
        }),

        const Divider(height: 24),
        _buildDetailRow('Version', 'v${widget.course.version}'),
        const Divider(height: 24),
        _buildDetailRow('Status', 'Active'),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF6B7280),
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF111827),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildWhatYouLearn() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'What you\'ll learn',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 16),
          ...List.generate(4, (index) {
            final learningPoints = [
              'Master the fundamentals of ${widget.course.title}',
              'Build practical projects and real-world applications',
              'Understand advanced concepts and best practices',
              'Get ready for professional development opportunities',
            ];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 2),
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(
                      Icons.check,
                      size: 14,
                      color: Color(0xFF10B981),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      learningPoints[index],
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF374151),
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildLessonsTab() {
    return LessonsTabWidget(
      course: widget.course,
      enrollment: widget.enrollment,
      courseLessonController: courseLessonController,
      loginController: loginController,
      onProgressUpdate: _onProgressUpdate,
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Color(0xFF111827),
      ),
    );
  }

  Widget _buildFloatingActionButton(CourseModel course) {
    if (_currentTabIndex.value == 2 || _currentTabIndex.value == 3) {
      return const SizedBox.shrink();
    } else {
      groupChatController.stopAutoRefresh();
    }
    return FloatingActionButton.extended(
      onPressed: () {
        Get.to(
          () => AddEditLessonScreen(course: course),
          // binding: BindingsBuilder(() {
          //   Get.lazyPut(() => CourseLessonController());
          // }),
        );
      },
      backgroundColor: const Color(0xFF6366F1),
      foregroundColor: Colors.white,
      elevation: 8,
      icon: const Icon(Icons.edit),
      label: const Text('Add Lesson'),
    );
  }
}
