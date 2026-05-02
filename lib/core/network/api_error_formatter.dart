import 'package:dio/dio.dart';
import 'package:tarasense_mobile/core/config/app_config.dart';

String formatApiError(Object error, {bool includeUri = false}) {
  if (error is DioException) {
    final dynamic data = error.response?.data;
    final String? serverMessage = _extractServerMessage(data);
    final int? statusCode = error.response?.statusCode;
    final String requestUri = error.requestOptions.uri.toString();
    final String target = includeUri ? requestUri : error.requestOptions.path;

    if (serverMessage != null && serverMessage.isNotEmpty) {
      return serverMessage;
    }

    if (statusCode == 404) {
      return 'Endpoint not found at $target. '
          'The TARAsense mobile API route is not deployed on the server yet.';
    }

    if (statusCode == 401) {
      return 'Unauthorized request for $target. Please sign in again.';
    }

    if (statusCode == 403) {
      return 'You do not have permission to access $target.';
    }

    if (statusCode != null && statusCode >= 500) {
      return 'Server error while calling $target.';
    }

    if (error.type == DioExceptionType.connectionError) {
      return 'Cannot connect to API at ${AppConfig.apiBaseUrl}.';
    }

    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.sendTimeout) {
      return 'Request to $target timed out.';
    }

    return error.message ?? 'Request failed.';
  }

  if (error is FormatException) {
    return error.message;
  }

  return error.toString().replaceFirst('Exception: ', '');
}

String? _extractServerMessage(dynamic data) {
  if (data is Map && data['message'] != null) {
    return data['message'].toString();
  }
  return null;
}
