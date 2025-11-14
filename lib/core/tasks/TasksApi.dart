
import 'dart:convert';

import '../../models/tasks/TaskDto.dart';
import '../../models/tasks/TaskRequest.dart';
import '../api_client.dart';

class TasksApi {
  final ApiClient _client;

  TasksApi({ApiClient? client}) : _client = client ?? ApiClient();

  /// GET /api/v1/tasks
  Future<List<TaskDto>> getTasks() async {
    final res = await _client.get('api/v1/tasks');
    final list = jsonDecode(res.body) as List;
    return list
        .map((e) => TaskDto.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// POST /api/v1/tasks
  Future<TaskDto> createTask(TaskCreateRequest body) async {
    final res = await _client.post(
      'api/v1/tasks',
      body: body.toJson(),
    );
    final json = jsonDecode(res.body) as Map<String, dynamic>;
    return TaskDto.fromJson(json);
  }

  /// GET /api/v1/tasks/{taskId}
  Future<TaskDto> getTask(int taskId) async {
    final res = await _client.get('api/v1/tasks/$taskId');
    final json = jsonDecode(res.body) as Map<String, dynamic>;
    return TaskDto.fromJson(json);
  }

  /// PUT /api/v1/tasks/{taskId}
  Future<TaskDto> updateTask(int taskId, TaskUpdateRequest body) async {
    final res = await _client.put(
      'api/v1/tasks/$taskId',
      body: body.toJson(),
    );
    final json = jsonDecode(res.body) as Map<String, dynamic>;
    return TaskDto.fromJson(json);
  }

  /// DELETE /api/v1/tasks/{taskId}
  Future<void> deleteTask(int taskId) async {
    await _client.delete('api/v1/tasks/$taskId');
  }

  /// PUT /api/v1/tasks/{taskId}/assign
  Future<TaskDto> assignTask(int taskId, int userId) async {
    final res = await _client.put(
      'api/v1/tasks/$taskId/assign',
      body: TaskAssignRequest(userId).toJson(),
    );
    final json = jsonDecode(res.body) as Map<String, dynamic>;
    return TaskDto.fromJson(json);
  }

  /// PUT /api/v1/tasks/{taskId}/unassign
  Future<TaskDto> unassignTask(int taskId, int userId) async {
    final res = await _client.put(
      'api/v1/tasks/$taskId/unassign',
      body: TaskAssignRequest(userId).toJson(),
    );
    final json = jsonDecode(res.body) as Map<String, dynamic>;
    return TaskDto.fromJson(json);
  }

  /// PUT /api/v1/tasks/{taskId}/status
  Future<TaskDto> updateTaskStatus(int taskId, String status) async {
    final res = await _client.put(
      'api/v1/tasks/$taskId/status',
      body: TaskStatusUpdateRequest(status).toJson(),
    );
    final json = jsonDecode(res.body) as Map<String, dynamic>;
    return TaskDto.fromJson(json);
  }

  /// GET /api/v1/tasks/user/{userId}
  Future<List<TaskDto>> getTasksByUser(int userId) async {
    try {
      print('🌐 TasksApi: GET /api/v1/tasks/user/$userId');
      final res = await _client.get('api/v1/tasks/user/$userId');
      print('✅ TasksApi: Response status ${res.statusCode}');
      print('📋 TasksApi: Response body: ${res.body}');
      
      final list = jsonDecode(res.body) as List;
      print('📊 TasksApi: Parseando ${list.length} tareas del JSON');
      
      final tasks = list
          .map((e) => TaskDto.fromJson(e as Map<String, dynamic>))
          .toList();
      
      print('✅ TasksApi: ${tasks.length} tareas convertidas exitosamente');
      return tasks;
    } catch (e, stackTrace) {
      print('❌ TasksApi Error en getTasksByUser($userId): $e');
      print('❌ Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// GET /api/v1/tasks/project/{projectId}
  Future<List<TaskDto>> getTasksByProject(int projectId) async {
    final res = await _client.get('api/v1/tasks/project/$projectId');
    final list = jsonDecode(res.body) as List;
    return list
        .map((e) => TaskDto.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// GET /api/v1/tasks/project/{projectId}/user/{userId}
  Future<List<TaskDto>> getTasksByProjectAndUser(
      int projectId,
      int userId,
      ) async {
    final res = await _client.get(
      'api/v1/tasks/project/$projectId/user/$userId',
    );
    final list = jsonDecode(res.body) as List;
    return list
        .map((e) => TaskDto.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// GET /api/v1/tasks/project/{projectId}/status/{status}
  Future<List<TaskDto>> getTasksByProjectAndStatus(
      int projectId,
      String status,
      ) async {
    final res = await _client.get(
      'api/v1/tasks/project/$projectId/status/$status',
    );
    final list = jsonDecode(res.body) as List;
    return list
        .map((e) => TaskDto.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// GET /api/v1/tasks/project/{projectId}/priority/{priority}
  Future<List<TaskDto>> getTasksByProjectAndPriority(
      int projectId,
      String priority,
      ) async {
    final res = await _client.get(
      'api/v1/tasks/project/$projectId/priority/$priority',
    );
    final list = jsonDecode(res.body) as List;
    return list
        .map((e) => TaskDto.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
