import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../model/course/course_model.dart';
import 'lesson/add_lesson.dart';

class ViewCourseScreen extends StatefulWidget {
  final CourseModel course;

  const ViewCourseScreen({Key? key, required this.course}) : super(key: key);

  @override
  State<ViewCourseScreen> createState() => _ViewCourseScreenState();
}

class _ViewCourseScreenState extends State<ViewCourseScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(),
          SliverToBoxAdapter(
            child: Column(
              children: [
                _buildCourseHeader(),
                _buildTabSection(),
                _buildTabContent(),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: _buildFloatingActionButton(widget.course),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      backgroundColor: const Color(0xFF6366F1),
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Background Image
            Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF6366F1),
                    Color(0xFF8B5CF6),
                    Color(0xFF06B6D4),
                  ],
                ),
              ),
              child: widget.course.coverImage != null
                  ? Image.network(
                      widget.course.coverImage!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Image.asset(
                          "assets/logo.png",
                          fit: BoxFit.cover,
                        );
                      },
                    )
                  : Image.asset("assets/logo.png", fit: BoxFit.cover),
            ),
            // Gradient Overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
                ),
              ),
            ),
            // Course Title at Bottom
            Positioned(
              bottom: 60,
              left: 20,
              right: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${widget.course.lessons.length} Lessons',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.course.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
                          offset: Offset(0, 2),
                          blurRadius: 4,
                          color: Colors.black45,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      leading: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.3),
          borderRadius: BorderRadius.circular(12),
        ),
        child: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
      ),
      actions: [
        Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.3),
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            icon: const Icon(Icons.share, color: Colors.white),
            onPressed: () {
              // Implement share functionality
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCourseHeader() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  widget.course.description,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color(0xFF6B7280),
                    height: 1.6,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildStatsRow(),
          const SizedBox(height: 20),
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildStatItem(
          icon: Icons.play_circle_outline,
          label: 'Lessons',
          value: '${widget.course.lessons.length}',
          color: const Color(0xFF10B981),
        ),
        _buildStatItem(
          icon: Icons.people_outline,
          label: 'Students',
          value: '0',
          color: const Color(0xFF3B82F6),
        ),
        _buildStatItem(
          icon: Icons.star_outline,
          label: 'Rating',
          value: '4.8',
          color: const Color(0xFFF59E0B),
        ),
        _buildStatItem(
          icon: Icons.access_time,
          label: 'Duration',
          value: '2h 30m',
          color: const Color(0xFF8B5CF6),
        ),
      ],
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF111827),
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: ElevatedButton.icon(
            onPressed: () {
              // Start course functionality
            },
            icon: const Icon(Icons.play_arrow, size: 24),
            label: const Text('Start Learning'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6366F1),
              foregroundColor: Colors.white,
              elevation: 3,
              shadowColor: const Color(0xFF6366F1).withOpacity(0.4),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {
              // Bookmark functionality
            },
            icon: const Icon(Icons.bookmark_border, size: 20),
            label: const Text('Save'),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF6366F1),
              side: const BorderSide(color: Color(0xFF6366F1), width: 2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTabSection() {
    return Container(
      color: Colors.white,
      child: TabBar(
        controller: _tabController,
        labelColor: const Color(0xFF6366F1),
        unselectedLabelColor: const Color(0xFF6B7280),
        indicatorColor: const Color(0xFF6366F1),
        indicatorWeight: 3,
        labelStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        tabs: const [
          Tab(text: 'Overview'),
          Tab(text: 'Lessons'),
          Tab(text: 'Reviews'),
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
        children: [_buildOverviewTab(), _buildLessonsTab(), _buildReviewsTab()],
      ),
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('About This Course'),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
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
        _buildDetailRow('Course ID', widget.course.id),
        const Divider(height: 24),
        _buildDetailRow('Total Lessons', '${widget.course.lessons.length}'),
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
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
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
                      color: const Color(0xFF10B981).withOpacity(0.1),
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
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Course Content'),
          const SizedBox(height: 16),
          widget.course.lessons.isEmpty
              ? _buildEmptyLessonsState()
              : _buildLessonsList(),
        ],
      ),
    );
  }

  Widget _buildEmptyLessonsState() {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: Column(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(40),
              ),
              child: const Icon(
                Icons.play_circle_outline,
                size: 40,
                color: Color(0xFF9CA3AF),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'No lessons yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF111827),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Lessons will appear here once they are added to the course',
              style: TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLessonsList() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: List.generate(
          widget.course.lessons.length,
          (index) => _buildLessonItem(index, widget.course.lessons[index]),
        ),
      ),
    );
  }

  Widget _buildLessonItem(int index, dynamic lesson) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: index < widget.course.lessons.length - 1
            ? const Border(bottom: BorderSide(color: Color(0xFFF3F4F6)))
            : null,
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF6366F1).withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Center(
              child: Text(
                '${index + 1}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF6366F1),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Lesson ${index + 1}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Duration: 15 min',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.play_circle_outline,
            color: const Color(0xFF6366F1),
            size: 24,
          ),
        ],
      ),
    );
  }

  Widget _buildReviewsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Student Reviews'),
          const SizedBox(height: 16),
          _buildEmptyReviewsState(),
        ],
      ),
    );
  }

  Widget _buildEmptyReviewsState() {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: Column(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(40),
              ),
              child: const Icon(
                Icons.star_outline,
                size: 40,
                color: Color(0xFF9CA3AF),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'No reviews yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF111827),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Be the first to leave a review for this course',
              style: TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
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
    return FloatingActionButton.extended(
      onPressed: () {
        // Add lesson functionality
        Get.to(() => AddLessonScreen(course: course));
      },
      backgroundColor: const Color(0xFF6366F1),
      foregroundColor: Colors.white,
      elevation: 8,
      icon: const Icon(Icons.edit),
      label: const Text('Add Lesson'),
    );
  }


}
