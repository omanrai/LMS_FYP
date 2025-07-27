import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controller/auth/login_controller.dart';
import '../controller/course/course_review_controller.dart';
import '../model/auth/user_model.dart';
import 'AI/chat_AI_screen.dart';
import 'auth/login_screen.dart';
import 'auth/update_profile.dart';
import 'courses/course test/fetch_course.dart';
import 'courses/get_course.dart';
import 'courses/review/show_review.dart';
import 'teacher/teacher_course.dart';

// Main Screen with Bottom Navigation
class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  final LoginController loginController = Get.find<LoginController>();

  // Get role-specific data using reactive user
  String getRoleTitle(UserModel? user) {
    if (user == null) return 'Dashboard';
    switch (user.role.toLowerCase()) {
      case 'student':
        return 'Student Dashboard';
      case 'teacher':
        return 'Teacher Dashboard';
      case 'admin':
        return 'Admin Panel';
      default:
        return 'Dashboard';
    }
  }

  Color getRoleColor(UserModel? user) {
    if (user == null) return Colors.grey;
    switch (user.role.toLowerCase()) {
      case 'student':
        return Colors.blue;
      case 'teacher':
        return Colors.green;
      case 'admin':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final user = loginController.user.value;
      final roleColor = getRoleColor(user);
      return Scaffold(
        appBar: AppBar(
          backgroundColor: roleColor,
          foregroundColor: Colors.white,
          title: Text(getRoleTitle(user)),
          leading: Builder(
            builder: (context) => IconButton(
              icon: Icon(Icons.menu),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
          ),
        ),
        drawer: _buildDrawer(user, roleColor),
        body: _getBodyForIndex(_currentIndex, user, roleColor),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          selectedItemColor: roleColor,
          type: BottomNavigationBarType.fixed,
          items: [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(
              icon: Icon(Icons.notifications),
              label: 'Notifications',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: 'Settings',
            ),
          ],
        ),
      );
    });
  }

  Widget _getBodyForIndex(int index, UserModel? user, Color roleColor) {
    switch (index) {
      case 0:
        return _buildHomeScreen(user, roleColor);
      case 1:
        return _buildNotificationScreen(user, roleColor);
      case 2:
        return _buildSettingsScreen(user, roleColor);
      default:
        return _buildHomeScreen(user, roleColor);
    }
  }

  Widget _buildHomeScreen(UserModel? user, Color roleColor) {
    if (user == null) {
      return Center(child: CircularProgressIndicator());
    }

    return SafeArea(
      child: SingleChildScrollView(
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 20),
              // Welcome message with user name
              Text(
                'Welcome ${user.name ?? 'User'}!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: roleColor,
                ),
              ),
              // SizedBox(height: 30),
              // Role-specific welcome message
              // Text(
              //   getWelcomeMessage(user),
              //   style: TextStyle(fontSize: 18, color: Colors.grey[700]),
              //   textAlign: TextAlign.center,
              // ),
              SizedBox(height: 40),
              // Role-specific content
              _buildRoleSpecificContent(user),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleSpecificContent(UserModel user) {
    switch (user.role.toLowerCase()) {
      case 'student':
        return _buildStudentContent();
      case 'teacher':
        return _buildTeacherContent();
      case 'admin':
        return _buildAdminContent();
      default:
        return Container();
    }
  }

  Widget _buildStudentContent() {
    return Column(
      children: [
        SizedBox(height: 16),
        _buildDashboardCard(
          icon: Icons.book,
          title: 'My Courses',
          subtitle: 'View your enrolled courses',
          color: Colors.blue,
          onTap: () => Get.to(() => CourseScreen()),
        ),
        // SizedBox(height: 16),
        // _buildDashboardCard(
        //   icon: Icons.assignment,
        //   title: 'Assignments',
        //   subtitle: 'Check pending assignments',
        //   color: Colors.orange,
        // ),
        SizedBox(height: 16),
        _buildDashboardCard(
          icon: Icons.grade,
          title: 'Grades',
          subtitle: 'View your academic progress',
          color: Colors.green,
        ),
        SizedBox(height: 16),
        _buildDashboardCard(
          icon: Icons.reviews,
          title: 'Your Reviews',
          subtitle: 'View Courses Review',
          color: Colors.purple,
          onTap: () {
            Get.to(
              () => ReviewScreen(),
              binding: BindingsBuilder(() {
                Get.lazyPut(() => CourseReviewController());
              }),
            );
          },
        ),
        SizedBox(height: 16),
        _buildDashboardCard(
          icon: Icons.psychology,
          title: 'Ask AI Assistant',
          subtitle: 'Get help with your studies from AI',
          color: Colors.deepOrange,
          onTap: () => Get.to(() => ChatWithAIScreen()),
        ),
        SizedBox(height: 16),
        _buildDashboardCard(
          icon: Icons.quiz,
          title: 'Course Test',
          subtitle: 'Manage Course Test',
          color: Colors.amber,
          onTap: () => Get.to(() => FetchCourseScreen()),
        ),
      ],
    );
  }

  Widget _buildTeacherContent() {
    return Column(
      children: [
        _buildDashboardCard(
          icon: Icons.library_add_check,
          title: 'My Courses',
          subtitle: 'Manage your Courses',
          color: Colors.green,
          onTap: () {
            Get.to(() => CourseScreen());
          },
        ),
        _buildDashboardCard(
          icon: Icons.book,
          title: 'Enrollment',
          subtitle: 'Manage your student enrollment',
          color: Colors.blue,
          onTap: () {
            Get.to(() => TeacherCourseScreen());
          },
        ),

        // _buildDashboardCard(
        //   icon: Icons.fact_check,
        //   title: 'Test Question',
        //   subtitle: 'Manage your Test question',
        //   color: Colors.red,
        //   onTap: () {
        //     Get.to(() => LessonTestQuestionScreen());
        //   },
        // ),
        // SizedBox(height: 16),
        SizedBox(height: 16),
        _buildDashboardCard(
          icon: Icons.reviews,
          title: 'Course Review',
          subtitle: 'View and Manage Course Reviews',
          color: Colors.purple,
          onTap: () {
            Get.to(
              () => ReviewScreen(),
              binding: BindingsBuilder(() {
                Get.lazyPut(() => CourseReviewController());
              }),
            );
          },
        ),
        SizedBox(height: 16),
        _buildDashboardCard(
          icon: Icons.psychology,
          title: 'Ask AI Assistant',
          subtitle: 'Get help with your studies from AI',
          color: Colors.deepOrange,
          onTap: () => Get.to(() => ChatWithAIScreen()),
        ),
        SizedBox(height: 16),
        _buildDashboardCard(
          icon: Icons.quiz,
          title: 'Course Test',
          subtitle: 'Manage Course Test',
          color: Colors.amber,
          onTap: () => Get.to(() => FetchCourseScreen()),
        ),
      ],
    );
  }

  Widget _buildAdminContent() {
    return Column(
      children: [
        _buildDashboardCard(
          icon: Icons.dashboard,
          title: 'System Overview',
          subtitle: 'View system statistics',
          color: Colors.purple,
        ),
        SizedBox(height: 16),
        _buildDashboardCard(
          icon: Icons.manage_accounts,
          title: 'User Management',
          subtitle: 'Manage users and roles',
          color: Colors.red,
        ),
        SizedBox(height: 16),
        _buildDashboardCard(
          icon: Icons.settings_applications,
          title: 'System Settings',
          subtitle: 'Configure system preferences',
          color: Colors.indigo,
        ),
      ],
    );
  }

  Widget _buildDashboardCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    void Function()? onTap,
  }) {
    return Card(
      elevation: 4,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.2),
          child: Icon(icon, color: color),
        ),
        title: Text(
          title,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Text(subtitle),
        trailing: Icon(Icons.arrow_forward_ios, size: 16),
        onTap:
            onTap ??
            () {
              Get.snackbar(
                'Info',
                'Navigate to $title',
                snackPosition: SnackPosition.BOTTOM,
              );
            },
      ),
    );
  }

  Widget _buildNotificationScreen(UserModel? user, Color roleColor) {
    if (user == null) {
      return Center(child: CircularProgressIndicator());
    }

    return Container(
      padding: EdgeInsets.all(20),
      child: Column(
        children: [
          Text(
            'Notifications',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: roleColor,
            ),
          ),
          SizedBox(height: 20),
          Expanded(
            child: ListView.builder(
              itemCount: 5, // Demo notifications
              itemBuilder: (context, index) {
                return Card(
                  margin: EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: roleColor.withOpacity(0.2),
                      child: Icon(Icons.notifications, color: roleColor),
                    ),
                    title: Text('Notification ${index + 1}'),
                    subtitle: Text(
                      'This is a sample notification for ${user.role}',
                    ),
                    trailing: Text(
                      '${index + 1}h ago',
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsScreen(UserModel? user, Color roleColor) {
    if (user == null) {
      return Center(child: CircularProgressIndicator());
    }

    return Container(
      padding: EdgeInsets.all(20),
      child: Column(
        children: [
          Text(
            'Settings Panel',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: roleColor,
            ),
          ),
          SizedBox(height: 20),
          _buildSettingsItem(
            icon: Icons.person,
            title: 'Profile',
            subtitle: 'Manage your profile information',
            roleColor: roleColor,
          ),
          _buildSettingsItem(
            icon: Icons.security,
            title: 'Security',
            subtitle: 'Change password and security settings',
            roleColor: roleColor,
          ),
          _buildSettingsItem(
            icon: Icons.notifications_outlined,
            title: 'Notification Preferences',
            subtitle: 'Manage notification settings',
            roleColor: roleColor,
          ),
          _buildSettingsItem(
            icon: Icons.dark_mode,
            title: 'Theme',
            subtitle: 'Choose your preferred theme',
            roleColor: roleColor,
          ),
          _buildSettingsItem(
            icon: Icons.language,
            title: 'Language',
            subtitle: 'Select your language',
            roleColor: roleColor,
          ),
          _buildSettingsItem(
            icon: Icons.logout,
            title: 'Logout',
            subtitle: 'Sign out of your account',
            roleColor: roleColor,
            isLogout: true,
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color roleColor,
    bool isLogout = false,
  }) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isLogout
              ? Colors.red.withOpacity(0.2)
              : roleColor.withOpacity(0.2),
          child: Icon(icon, color: isLogout ? Colors.red : roleColor),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isLogout ? Colors.red : null,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(subtitle),
        trailing: Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          if (isLogout) {
            _showLogoutDialog();
          } else {
            if (title == 'Profile') {
              Get.to(() => ProfileScreen());
            } else {
              // Handle other settings navigation
              Get.snackbar(
                'Info',
                'Navigate to $title settings',
                snackPosition: SnackPosition.BOTTOM,
              );
            }
          }
        },
      ),
    );
  }

  Widget _buildDrawer(UserModel? user, Color roleColor) {
    if (user == null) {
      return Drawer(child: Center(child: CircularProgressIndicator()));
    }

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(color: roleColor),
            accountName: Text(user.name ?? 'User'),
            accountEmail: Text(user.email),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Text(
                (user.name ?? 'U')[0].toUpperCase(),
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: roleColor,
                ),
              ),
            ),
          ),
          ListTile(
            leading: Icon(Icons.home),
            title: Text('Home'),
            onTap: () {
              setState(() {
                _currentIndex = 0;
              });
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: Icon(Icons.person),
            title: Text('Profile'),
            onTap: () {
              Navigator.pop(context);
              Get.to(() => ProfileScreen());
            },
          ),
          ListTile(
            leading: Icon(Icons.help),
            title: Text('Help & Support'),
            onTap: () {
              Navigator.pop(context);
              Get.snackbar('Info', 'Navigate to Help & Support');
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.logout, color: Colors.red),
            title: Text('Logout', style: TextStyle(color: Colors.red)),
            onTap: () {
              Navigator.pop(context);
              _showLogoutDialog();
            },
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog() {
    Get.dialog(
      AlertDialog(
        title: Text('Logout'),
        content: Text('Are you sure you want to logout?'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: Text('Cancel')),
          TextButton(
            onPressed: () {
              Get.back();
              // Clear user data and reset controller state
              loginController.resetState();
              Get.delete<UserModel>();
              // Navigate to login screen
              Get.offAll(() => LoginScreen()); // Replace with your login screen
            },
            child: Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
