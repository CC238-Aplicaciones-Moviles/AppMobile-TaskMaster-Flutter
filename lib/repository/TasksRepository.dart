
import '../core/tasks/TasksApi.dart';
import '../models/tasks/TaskDto.dart';
import '../models/tasks/TaskRequest.dart';

class TasksRepository {
  final TasksApi _api;

  TasksRepository({TasksApi? api}) : _api = api ?? TasksApi();

  Future<List<TaskDto>> getAll() => _api.getTasks();

  Future<TaskDto> create(TaskCreateRequest body) =>
      _api.createTask(body);

  Future<TaskDto> getById(int taskId) => _api.getTask(taskId);

  Future<TaskDto> update(int taskId, TaskUpdateRequest body) =>
      _api.updateTask(taskId, body);

  Future<void> delete(int taskId) => _api.deleteTask(taskId);

  Future<TaskDto> assign(int taskId, int userId) =>
      _api.assignTask(taskId, userId);

  Future<TaskDto> unassign(int taskId, int userId) =>
      _api.unassignTask(taskId, userId);

  Future<TaskDto> updateStatus(int taskId, String status) =>
      _api.updateTaskStatus(taskId, status);

  Future<List<TaskDto>> getByUser(int userId) =>
      _api.getTasksByUser(userId);

  Future<List<TaskDto>> getByProject(int projectId) =>
      _api.getTasksByProject(projectId);

  Future<List<TaskDto>> getByProjectAndUser(
      int projectId,
      int userId,
      ) =>
      _api.getTasksByProjectAndUser(projectId, userId);

  Future<List<TaskDto>> getByProjectAndStatus(
      int projectId,
      String status,
      ) =>
      _api.getTasksByProjectAndStatus(projectId, status);

  Future<List<TaskDto>> getByProjectAndPriority(
      int projectId,
      String priority,
      ) =>
      _api.getTasksByProjectAndPriority(projectId, priority);
}
