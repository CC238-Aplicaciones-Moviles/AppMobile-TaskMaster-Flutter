import 'package:flutter/material.dart';
import 'package:taskmaster_flutter/models/projects/ProjectDto.dart';
import 'package:taskmaster_flutter/repository/UsersRepository.dart';
import 'package:taskmaster_flutter/models/user/UserDto.dart';

class ProjectMembers extends StatefulWidget {
  final ProjectDto project;
  final int? currentUserId;

  const ProjectMembers({
    Key? key,
    required this.project,
    required this.currentUserId,
  }) : super(key: key);

  @override
  State<ProjectMembers> createState() => _ProjectMembersState();
}

class _ProjectMembersState extends State<ProjectMembers> {
  List<UserDto> members = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadMembersFromUsers();
  }

  Future<void> _loadMembersFromUsers() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final users = await UsersRepository().getAll();

      final filtered = users.where((u) {
        try {
          return (u.projectIds).contains(widget.project.id);
        } catch (e) {
          return false;
        }
      }).toList();

      // Si no se encontró ninguno, al menos intenta añadir al usuario actual (si existe)
      if (filtered.isEmpty && widget.currentUserId != null) {
        try {
          final me = await UsersRepository().getById(widget.currentUserId!);
          filtered.add(me);
        } catch (_) {
          // ignorar
        }
      }

      setState(() {
        members = filtered;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _loading = false;
        _error = 'Error cargando miembros: $e';
      });
    }
  }

  Widget _buildAvatar(String? imageUrl, String name) {
    if (imageUrl != null && imageUrl.isNotEmpty) {
      return CircleAvatar(
        backgroundImage: NetworkImage(imageUrl),
      );
    } else {
      final initials = name.isNotEmpty
          ? name.trim().split(' ').map((s) => s.isNotEmpty ? s[0] : '').take(2).join()
          : '?';
      return CircleAvatar(child: Text(initials.toUpperCase()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Miembros'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? Center(child: Text(_error!, style: const TextStyle(color: Colors.red)))
                : members.isEmpty
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('No se encontraron miembros para este proyecto.'),
                          const SizedBox(height: 8),
                          ElevatedButton(
                            onPressed: _loadMembersFromUsers,
                            child: const Text('Reintentar'),
                          ),
                        ],
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        itemCount: members.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final u = members[index];
                          final fullName = '${u.name} ${u.lastName}'.trim();
                          return Card(
                            color: Colors.grey[200],
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              child: Row(
                                children: [
                                  _buildAvatar(u.imageUrl, fullName),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          fullName.isNotEmpty ? fullName : 'Sin nombre',
                                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                                        ),
                                        const SizedBox(height: 4),
                                        if (u.email.isNotEmpty)
                                          Text(
                                            u.email,
                                            style: const TextStyle(fontSize: 14, color: Colors.black54),
                                          ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
      ),
    );
  }
}
