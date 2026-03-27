import 'package:dio/dio.dart';
import 'package:rick_and_morty_app/core/utils/constants.dart';

class DioClient {
  final Dio dio = Dio(
    BaseOptions(
      baseUrl: AppConstants.baseUrl,
      connectTimeout: const Duration(seconds: 10),
    ),
  );
}