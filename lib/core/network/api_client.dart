import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../constants/app_constants.dart';
import '../error/failure.dart';

/// Thin wrapper around [http.Client] that converts every low level error
/// into a [Failure], so upper layers never deal with transport exceptions.
class ApiClient {
  ApiClient(this._client);

  final http.Client _client;

  Future<Map<String, dynamic>> getJson(String url) async {
    try {
      final response = await _client
          .get(Uri.parse(url))
          .timeout(AppConstants.requestTimeout);

      if (response.statusCode != 200) {
        throw ServerFailure('Server error (${response.statusCode}).');
      }

      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) {
        throw const ServerFailure('Unexpected response format.');
      }
      return decoded;
    } on TimeoutException {
      throw const NetworkFailure('Request timed out.');
    } on http.ClientException {
      throw const NetworkFailure();
    } on FormatException {
      throw const ServerFailure('Invalid response from server.');
    }
  }
}
