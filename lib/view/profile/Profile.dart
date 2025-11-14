import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taskmaster_flutter/sharedPreferences/TaskmasterPrefs.dart';
import '../../bloc/users/UsersBloc.dart';
import '../../bloc/projects/ProjectsBloc.dart';
import '../../models/user/UserDto.dart';
import '../../models/user/UserUpdateRequest.dart';

class Profile extends StatefulWidget {
  final TaskmasterPrefs prefs;

  const Profile({super.key, required this.prefs});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  late TextEditingController _usernameController;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  late TextEditingController _salaryController;

  bool _obscurePassword = true;
  bool _isLoading = false;
  String? _error;
  String? _imageUrl;
  late TextEditingController _imageUrlController;

  late TextEditingController _projectKeyController;
  bool _isJoiningProject = false;

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _salaryController = TextEditingController();
    _imageUrlController = TextEditingController();
    _projectKeyController = TextEditingController();

    _loadUserData();
  }

  void _loadUserData() async {
    final email = await widget.prefs.getEmail();
    if (email != null) {
      context.read<UsersBloc>().add(UserRequestedByEmail(email));
    }

    final password = await widget.prefs.getPassword();
    if (password != null) {
      _passwordController.text = password;
    }
  }

  void _updateProfile() {
    final salary = double.tryParse(_salaryController.text);
    final (name, lastName) = _splitUsername(_usernameController.text);

    final updateRequest = UserUpdateRequest(
      name: name,
      lastName: lastName,
      salary: salary,
      imageUrl: _imageUrl,
    );

    setState(() {
      _isLoading = true;
    });

    context.read<UsersBloc>().add(UserUpdateRequested(updateRequest));
  }

  void _joinProject() {
    final key = _projectKeyController.text.trim();
    if (key.isEmpty) return;

    setState(() {
      _isJoiningProject = true;
    });

    context.read<ProjectsBloc>().add(ProjectJoinByKeyRequested(key));
  }

  (String, String) _splitUsername(String username) {
    final parts = username.split(' ');
    if (parts.isEmpty) return ('', '');
    if (parts.length == 1) return (parts[0], '');
    return (parts[0], parts.sublist(1).join(' '));
  }

  void _logout() async {
    await widget.prefs.clearToken();
    Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
  }

  void _showImageUrlDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cambiar imagen'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Pega el enlace (PNG/JPG):'),
            const SizedBox(height: 16),
            TextField(
              controller: _imageUrlController,
              decoration: const InputDecoration(
                hintText: 'https://ejemplo.com/imagen.jpg',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _imageUrl = _imageUrlController.text.isEmpty ? null : _imageUrlController.text;
              });
              Navigator.of(context).pop();
            },
            child: const Text('Usar'),
          ),
        ],
      ),
    );
  }

  void _openJoinProjectDialog() {

    final projectsBloc = context.read<ProjectsBloc>();

    showDialog(
      context: context,
      useRootNavigator: false,
      builder: (context) => BlocProvider.value(
        value: projectsBloc,
        child: Builder(
          builder: (dialogContext) => BlocListener<ProjectsBloc, ProjectsState>(
            listener: (dialogContext, state) {
              if (state is ProjectJoinSuccess) {
                ScaffoldMessenger.of(dialogContext).showSnackBar(
                  SnackBar(
                    content: Text('Te has unido al proyecto: ${state.project.name}'),
                    backgroundColor: Colors.green,
                  ),
                );
                setState(() {
                  _isJoiningProject = false;
                });
                Navigator.of(dialogContext).pop();
                _projectKeyController.clear();
              }

              if (state is ProjectsFailure) {
                ScaffoldMessenger.of(dialogContext).showSnackBar(
                  SnackBar(
                    content: Text('Error: ${state.message}'),
                    backgroundColor: Colors.red,
                  ),
                );
                setState(() {
                  _isJoiningProject = false;
                });
              }
            },
            child: AlertDialog(
              title: const Text(
                'Unirse a un proyecto',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Ingrese el código de un proyecto y ser parte de su grupo',
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFFF99),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey),
                    ),
                    child: TextField(
                      controller: _projectKeyController,
                      decoration: const InputDecoration(
                        hintText: '#FFFFYY1234',
                        border: InputBorder.none,
                        hintStyle: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
              actions: [
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: _isJoiningProject ? null : () => Navigator.of(dialogContext).pop(),
                        child: const Text('Cancelar', style: TextStyle(fontSize: 16)),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isJoiningProject ? null : _joinProject,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFA62424),
                          foregroundColor: Colors.white,
                        ),
                        child: _isJoiningProject
                            ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                            : const Text('Unirse', style: TextStyle(fontSize: 16)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _salaryController.dispose();
    _imageUrlController.dispose();
    _projectKeyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: BlocConsumer<UsersBloc, UsersState>(
        listener: (context, state) {
          if (state is UserLoadSuccess) {
            _usernameController.text = '${state.user.name} ${state.user.lastName}';
            _emailController.text = state.user.email;
            _salaryController.text = state.user.salary?.toString() ?? '';
            _imageUrl = state.user.imageUrl;
            setState(() {
              _isLoading = false;
            });
          }

          if (state is UserUpdateSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Perfil actualizado correctamente'),
                backgroundColor: Colors.green,
              ),
            );
            setState(() {
              _isLoading = false;
            });
          }

          if (state is UsersLoadInProgress) {
            setState(() {
              _isLoading = true;
            });
          }

          if (state is UsersFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error: ${state.message}'),
                backgroundColor: Colors.red,
              ),
            );
            setState(() {
              _isLoading = false;
              _error = state.message;
            });
          }
        },
        builder: (context, state) {
          if (state is UsersLoadInProgress && _usernameController.text.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          return Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 40),
                    const Text(
                      'Perfil',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 20),
                    GestureDetector(
                      onTap: _showImageUrlDialog,
                      child: Container(
                        width: 140,
                        height: 140,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFFEAEAEA),
                          border: Border.all(color: Colors.grey[400]!),
                        ),
                        child: _imageUrl != null && _imageUrl!.isNotEmpty
                            ? ClipOval(
                          child: Image.network(
                            _imageUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(Icons.person, size: 50, color: Colors.grey);
                            },
                          ),
                        )
                            : const Icon(Icons.person, size: 50, color: Colors.grey),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Formulario
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.brown[900]!, width: 1),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Column(
                        children: [
                          _buildFormField(label: 'UserName', controller: _usernameController, enabled: true),
                          const Divider(color: Colors.brown, thickness: 1),
                          _buildFormField(label: 'Email', controller: _emailController, enabled: false),
                          const Divider(color: Colors.brown, thickness: 1),
                          _buildPasswordField(),
                          const Divider(color: Colors.brown, thickness: 1),
                          _buildFormField(
                            label: 'Pago por Hora',
                            controller: _salaryController,
                            enabled: true,
                            keyboardType: TextInputType.number,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),


                    Row(
                      children: [
                        Expanded(
                          child: _buildActionButton(
                            text: 'Unirte a un proyecto',
                            onPressed: _openJoinProjectDialog,
                            backgroundColor: const Color(0xFFFFE4E1),
                            textColor: Colors.brown[900]!,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(child: _buildSaveButton()),
                      ],
                    ),

                    const SizedBox(height: 20),
                    TextButton(
                      onPressed: _isLoading ? null : _logout,
                      child: const Text(
                        'Cerrar sesión',
                        style: TextStyle(color: Colors.red, fontSize: 16),
                      ),
                    ),

                    if (_error != null) ...[
                      const SizedBox(height: 8),
                      Text(_error!, style: const TextStyle(color: Colors.red)),
                    ],
                  ],
                ),
              ),

              if (_isLoading && state is! UsersLoadInProgress)
                Container(color: Colors.black54, child: const Center(child: CircularProgressIndicator())),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      height: 50,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _updateProfile,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFA62424),
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: _isLoading
            ? Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)),
            const SizedBox(width: 8),
            const Text("Guardar Cambios", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
          ],
        )
            : const Text("Guardar Cambios", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
      ),
    );
  }

  Widget _buildFormField({
    required String label,
    required TextEditingController controller,
    required bool enabled,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 12, color: Colors.brown[900])),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          enabled: enabled,
          keyboardType: keyboardType,
          decoration: const InputDecoration(border: InputBorder.none, contentPadding: EdgeInsets.zero, isDense: true),
          style: TextStyle(fontSize: 16, color: enabled ? Colors.brown[900] : Colors.brown[900]!.withOpacity(0.6)),
        ),
      ],
    );
  }

  Widget _buildPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Contraseña', style: TextStyle(fontSize: 12, color: Colors.brown)),
        const SizedBox(height: 4),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _passwordController,
                readOnly: true,
                obscureText: _obscurePassword,
                decoration: const InputDecoration(border: InputBorder.none, contentPadding: EdgeInsets.zero, isDense: true),
                style: const TextStyle(fontSize: 16, color: Colors.brown),
              ),
            ),
            IconButton(
              icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off, color: Colors.brown, size: 25),
              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required String text,
    required VoidCallback onPressed,
    required Color backgroundColor,
    required Color textColor,
  }) {
    return SizedBox(
      height: 50,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: textColor,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Text(text, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: textColor)),
      ),
    );
  }
}