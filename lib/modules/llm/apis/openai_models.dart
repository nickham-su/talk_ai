import 'dart:convert';

import 'package:dio/dio.dart';

import '../../../shared/apis/new_dio.dart';

class OpenaiModelsApi {
  static const modelsPath = '/v1/models';

  static Future<List<String>> getModels({
    required String url, // 请求地址
    required String apiKey, // 请求密钥
  }) async {
    // 拼接请求地址
    url = Uri.parse(url).resolve(modelsPath).toString();

    final dio = newDio();

    final response = await dio.get(
      url,
      options: Options(
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
      ),
    );
    final modelList = ModelList.fromJson(response.data);
    return modelList.data.map((model) => model.id).toList();
  }
}

class Model {
  String id;
  String object;

  Model({
    required this.id,
    required this.object,
  });

  factory Model.fromJson(Map<String, dynamic> json) {
    return Model(
      id: json['id'],
      object: json['object'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'object': object,
    };
  }
}

class ModelList {
  List<Model> data;

  ModelList({required this.data});

  factory ModelList.fromJson(Map<String, dynamic> json) {
    List<Model> dataList = [];
    json['data'].forEach((modelJson) {
      dataList.add(Model.fromJson(modelJson));
    });
    return ModelList(
      data: dataList,
    );
  }

  Map<String, dynamic> toJson() {
    List<Map<String, dynamic>> dataJsonList = [];
    data.forEach((model) {
      dataJsonList.add(model.toJson());
    });
    return {
      'data': dataJsonList,
    };
  }
}
