
import 'dart:convert';

import 'package:taskmaster_flutter/core/api_client.dart';

import '../../models/projects/ProjectDto.dart';
import '../../models/projects/ProjectRequest.dart';


class ProjectsApi {
  final ApiClient _client;

  ProjectsApi({ApiClient? client}) : _client = client ?? ApiClient();

  /// GET /api/v1/projects
  Future<List<ProjectDto>> getProjects() async {
    final res = await _client.get('api/v1/projects');
    final list = jsonDecode(res.body) as List;
    return list
        .map((e) => ProjectDto.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// POST /api/v1/projects
  Future<ProjectDto> createProject(ProjectCreateRequest body) async {
    final res = await _client.post(
      'api/v1/projects',
      body: body.toJson(),
    );
    final json = jsonDecode(res.body) as Map<String, dynamic>;
    return ProjectDto.fromJson(json);
  }

  /// GET /api/v1/projects/{projectId}
  Future<ProjectDto> getProject(int projectId) async {
    final res = await _client.get('api/v1/projects/$projectId');
    final json = jsonDecode(res.body) as Map<String, dynamic>;
    return ProjectDto.fromJson(json);
  }

  /// PUT /api/v1/projects/{id}
  Future<ProjectDto> updateProject(
      int id,
      ProjectUpdateRequest body,
      ) async {
    final res = await _client.put(
      'api/v1/projects/$id',
      body: body.toJson(),
    );
    final json = jsonDecode(res.body) as Map<String, dynamic>;
    return ProjectDto.fromJson(json);
  }

  /// DELETE /api/v1/projects/{id}
  Future<void> deleteProject(int id) async {
    await _client.delete('api/v1/projects/$id');
  }

  /// PUT /api/v1/projects/{projectId}/code
  Future<ProjectDto> setProjectCode(
      int projectId,
      ProjectCodeRequest body,
      ) async {
    final res = await _client.put(
      'api/v1/projects/$projectId/code',
      body: body.toJson(),
    );
    final json = jsonDecode(res.body) as Map<String, dynamic>;
    return ProjectDto.fromJson(json);
  }

  /// GET /api/v1/projects/member/{memberId}
  Future<List<ProjectDto>> getProjectsByMember(int memberId) async {
    final res =
    await _client.get('api/v1/projects/member/$memberId');
    final list = jsonDecode(res.body) as List;
    return list
        .map((e) => ProjectDto.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// GET /api/v1/projects/leader/{leaderId}
  Future<List<ProjectDto>> getProjectsByLeader(int leaderId) async {
    final res =
    await _client.get('api/v1/projects/leader/$leaderId');
    final list = jsonDecode(res.body) as List;
    return list
        .map((e) => ProjectDto.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// GET /api/v1/projects/join/{key}
  Future<ProjectDto> joinProjectByKey(String key) async {
    final res = await _client.get('api/v1/projects/join/$key');
    final json = jsonDecode(res.body) as Map<String, dynamic>;
    return ProjectDto.fromJson(json);
  }

  /// DELETE /api/v1/projects/{projectId}/members/{memberId}
  Future<void> removeMember(int projectId, int memberId) async {
    await _client.delete(
      'api/v1/projects/$projectId/members/$memberId',
    );
  }
}
