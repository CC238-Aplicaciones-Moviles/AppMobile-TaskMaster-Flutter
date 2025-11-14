

import '../core/projects/ProjectsApi.dart';
import '../models/projects/ProjectDto.dart';
import '../models/projects/ProjectRequest.dart';

class ProjectsRepository {
  final ProjectsApi _api;

  ProjectsRepository({ProjectsApi? api}) : _api = api ?? ProjectsApi();

  /// GET /api/v1/projects
  Future<List<ProjectDto>> getAll() => _api.getProjects();

  /// POST /api/v1/projects
  Future<ProjectDto> create(ProjectCreateRequest body) =>
      _api.createProject(body);

  /// GET /api/v1/projects/{projectId}
  Future<ProjectDto> getById(int projectId) => _api.getProject(projectId);

  /// PUT /api/v1/projects/{id}
  Future<ProjectDto> update(int id, ProjectUpdateRequest body) =>
      _api.updateProject(id, body);

  /// DELETE /api/v1/projects/{id}
  Future<void> delete(int id) => _api.deleteProject(id);

  /// PUT /api/v1/projects/{projectId}/code
  Future<ProjectDto> setCode(int projectId, String code) =>
      _api.setProjectCode(projectId, ProjectCodeRequest(code));

  /// GET /api/v1/projects/member/{memberId}
  Future<List<ProjectDto>> getByMember(int memberId) =>
      _api.getProjectsByMember(memberId);

  /// GET /api/v1/projects/leader/{leaderId}
  Future<List<ProjectDto>> getByLeader(int leaderId) =>
      _api.getProjectsByLeader(leaderId);

  /// GET /api/v1/projects/join/{key}
  Future<ProjectDto> joinByKey(String key) =>
      _api.joinProjectByKey(key);

  /// DELETE /api/v1/projects/{projectId}/members/{memberId}
  Future<void> removeMember(int projectId, int memberId) =>
      _api.removeMember(projectId, memberId);
}
