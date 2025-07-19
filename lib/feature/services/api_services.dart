import 'dart:developer';

import 'package:dio/dio.dart';
import 'dart:io';
import '../../core/helpers/internet_connection.dart';
import '../model/api_response_model.dart';

class ApiService {
  static const String baseUrl = 'http://192.168.43.105:3000';
  static const String registerEndpoint = '/authentication/register';
  static const String loginEndpoint = '/authentication/login';

  static const Duration timeoutDuration = Duration(seconds: 30);

  static late Dio _dio;

  // Initialize Dio instance
  static void _initializeDio() {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: timeoutDuration,
        receiveTimeout: timeoutDuration,
        sendTimeout: timeoutDuration,
        headers: {'Accept': 'application/json'},
      ),
    );

    // Add interceptors for logging (optional)
    _dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        logPrint: (obj) => print(obj),
      ),
    );
  }

  static Future<ApiResponse<Map<String, dynamic>>> registerUser(
    String email,
    String password,
    String name, {
    String? imagePath, // Made optional and nullable
  }) async {
    try {
      // Check internet connection
      if (!await ConnectivityService.hasInternetConnection()) {
        return ApiResponse<Map<String, dynamic>>(
          success: false,
          message: 'No internet connection. Please check your network.',
        );
      }

      // Initialize Dio if not already done
      _initializeDio();

      // Debug print the values
      log('Debug - Email: $email');
      log('Debug - Password: $password');
      log('Debug - Name: $name');
      log('Debug - Image path: ${imagePath ?? "No image provided"}');

      if (email.isEmpty || password.isEmpty || name.isEmpty) {
        return ApiResponse<Map<String, dynamic>>(
          success: false,
          message: 'Email, password, and name cannot be empty.',
        );
      }

      // Check if image is provided and exists
      bool hasImage =
          imagePath != null &&
          imagePath.isNotEmpty &&
          File(imagePath).existsSync();

      Response response;

      if (hasImage) {
        // Create FormData for request with image
        FormData formData = FormData();

        // Add text fields explicitly as strings
        formData.fields.add(MapEntry('email', email.trim()));
        formData.fields.add(MapEntry('password', password));
        formData.fields.add(MapEntry('name', name.trim()));

        // Add image file
        final file = File(imagePath);
        formData.files.add(
          MapEntry(
            'image',
            await MultipartFile.fromFile(
              file.path,
              filename: file.path.split('/').last,
            ),
          ),
        );

        // Send request with FormData (multipart)
        response = await _dio.post(registerEndpoint, data: formData);
      } else {
        // Send request with JSON data only (no image)
        response = await _dio.post(
          registerEndpoint,
          data: {
            'email': email.trim(),
            'password': password,
            'name': name.trim(),
          },
          options: Options(contentType: 'application/json'),
        );
      }

      return _handleResponse(response);
    } on DioException catch (e) {
      return _handleDioError(e);
    } catch (e) {
      return ApiResponse<Map<String, dynamic>>(
        success: false,
        message: 'An unexpected error occurred at register: ${e.toString()}',
      );
    }
  }

  static Future<ApiResponse<Map<String, dynamic>>> loginUser(
    String email,
    String password,
  ) async {
    log('Debug - Email: $email');
    log('Debug - Password: $password');
    try {
      // Check internet connection
      if (!await ConnectivityService.hasInternetConnection()) {
        return ApiResponse<Map<String, dynamic>>(
          success: false,
          message: 'No internet connection. Please check your network.',
        );
      }

      // Initialize Dio if not already done
      _initializeDio();

      final response = await _dio.post(
        loginEndpoint,
        data: {'email': email, 'password': password},
        options: Options(contentType: 'application/json'),
      );

      return _handleResponse(response);
    } on DioException catch (e) {
      return _handleDioError(e);
    } catch (e) {
      return ApiResponse<Map<String, dynamic>>(
        success: false,
        message: 'An unexpected error occurred at Login: ${e.toString()}',
      );
    }
  }

  static ApiResponse<Map<String, dynamic>> _handleResponse(Response response) {
    try {
      final Map<String, dynamic> responseData =
          response.data is Map<String, dynamic>
          ? response.data
          : <String, dynamic>{};

      // Handle message that can be either String or List<String>
      String getMessage(dynamic message) {
        if (message is String) {
          return message;
        } else if (message is List) {
          return message.join(', ');
        }
        return '';
      }

      switch (response.statusCode) {
        case 200:
        case 201:
          return ApiResponse<Map<String, dynamic>>(
            success: true,
            message:
                getMessage(responseData['message']) ?? 'Request successful',
            data: responseData,
            statusCode: response.statusCode,
          );
        case 400:
          return ApiResponse<Map<String, dynamic>>(
            success: false,
            message: getMessage(responseData['message']) ?? 'Bad request',
            statusCode: response.statusCode,
          );
        case 401:
          return ApiResponse<Map<String, dynamic>>(
            success: false,
            message: 'Unauthorized access',
            statusCode: response.statusCode,
          );
        case 422:
          return ApiResponse<Map<String, dynamic>>(
            success: false,
            message: getMessage(responseData['message']) ?? 'Validation failed',
            data: responseData,
            statusCode: response.statusCode,
          );
        case 500:
          return ApiResponse<Map<String, dynamic>>(
            success: false,
            message: 'Server error. Please try again later.',
            statusCode: response.statusCode,
          );
        default:
          return ApiResponse<Map<String, dynamic>>(
            success: false,
            message:
                getMessage(responseData['message']) ?? 'Unknown error occurred',
            statusCode: response.statusCode,
          );
      }
    } catch (e) {
      print('[ApiService] Failed to parse response: $e');
      return ApiResponse<Map<String, dynamic>>(
        success: false,
        message: 'Failed to parse server response',
        statusCode: response.statusCode,
      );
    }
  }

  static ApiResponse<Map<String, dynamic>> _handleDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return ApiResponse<Map<String, dynamic>>(
          success: false,
          message: 'Connection timeout. Please check your internet connection.',
        );
      case DioExceptionType.connectionError:
        return ApiResponse<Map<String, dynamic>>(
          success: false,
          message: 'No internet connection. Please check your network.',
        );
      case DioExceptionType.badResponse:
        // Handle HTTP error responses
        if (e.response != null) {
          return _handleResponse(e.response!);
        }
        return ApiResponse<Map<String, dynamic>>(
          success: false,
          message: 'Server error occurred. Please try again.',
        );
      case DioExceptionType.cancel:
        return ApiResponse<Map<String, dynamic>>(
          success: false,
          message: 'Request was cancelled.',
        );
      case DioExceptionType.unknown:
        return ApiResponse<Map<String, dynamic>>(
          success: false,
          message: 'An unexpected error occurred. Please try again.',
        );
      default:
        return ApiResponse<Map<String, dynamic>>(
          success: false,
          message: 'Network error occurred: ${e.message}',
        );
    }
  }

  // Optional: Method to configure custom headers (e.g., for authentication)
  static void setAuthToken(String token) {
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  // Optional: Method to clear auth token
  static void clearAuthToken() {
    _dio.options.headers.remove('Authorization');
  }
}
