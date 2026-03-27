import 'package:dio/dio.dart';

import '../models/character_model.dart';

class RemoteDataSource {
  final Dio dio;

  RemoteDataSource(this.dio);

  Future<List<CharacterModel>> fetchCharacters(int page) async {
    final response = await dio.get('/character?page=$page');

    final results = response.data['results'] as List;

    return results.map((e) => CharacterModel.fromJson(e)).toList();
  }
}