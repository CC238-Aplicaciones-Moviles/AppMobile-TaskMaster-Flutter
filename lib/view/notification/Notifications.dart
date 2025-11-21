import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:taskmaster_flutter/bloc/users/UsersBloc.dart';
import 'package:taskmaster_flutter/sharedPreferences/TaskmasterPrefs.dart';
import '../../bloc/notifications/NotificationBloc.dart';

class Notifications extends StatefulWidget {
  final TaskmasterPrefs prefs;

  const Notifications({super.key, required this.prefs});

  @override
  State<Notifications> createState() => _NotificationsState();
}

class _NotificationsState extends State<Notifications> {
  final TextEditingController _searchController = TextEditingController();
  String _search = '';
  String? _userImageUrl;

  @override
  void initState() {
    super.initState();
    context.read<NotificationBloc>().add(LoadNotifications());
    _loadUserData();
  }

  void _loadUserData() async {
    final email = await widget.prefs.getEmailAsync();
    if (email.isNotEmpty && mounted) {
      context.read<UsersBloc>().add(UserRequestedByEmail(email));
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: BlocListener<UsersBloc, UsersState>(
        listener: (context, state) {
          if (state is UserLoadSuccess) {
            setState(() {
              _userImageUrl = state.user.imageUrl;
            });
          }
        },
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Título "Notificaciones"
                const Text(
                  'Notificaciones',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),

                // Barra de búsqueda rosada
                TextField(
                  controller: _searchController,
                  onChanged: (value) {
                    setState(() => _search = value.toLowerCase());
                  },
                  decoration: InputDecoration(
                    hintText: 'Buscar notificación',
                    filled: true,
                    fillColor: const Color(0xFFF9C4CF), // rosadito suave
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    suffixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Lista de notificaciones
                Expanded(
                  child: BlocBuilder<NotificationBloc, NotificationState>(
                    builder: (context, state) {
                      if (state is NotificationLoading) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (state is NotificationLoaded) {
                        // Filtro por búsqueda
                        final notifications = state.notifications.where((n) {
                          if (_search.isEmpty) return true;
                          final t = n.title.toLowerCase();
                          final m = n.message.toLowerCase();
                          return t.contains(_search) || m.contains(_search);
                        }).toList();

                        if (notifications.isEmpty) {
                          return const Center(
                              child: Text('No tienes notificaciones.'));
                        }

                        return ListView.builder(
                          itemCount: notifications.length,
                          itemBuilder: (context, index) {
                            final notification = notifications[index];

                            return Container(
                              margin: const EdgeInsets.only(bottom: 10),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF2F2F2),
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 4,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(10),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    // Avatar redondo
                                    CircleAvatar(
                                      radius: 24,
                                      backgroundColor: Colors.grey[300],
                                      backgroundImage: _userImageUrl != null
                                          ? NetworkImage(_userImageUrl!)
                                          : null,
                                      child: _userImageUrl == null
                                          ? const Icon(
                                              Icons.person,
                                              size: 28,
                                              color: Colors.white,
                                            )
                                          : null,
                                    ),
                                    const SizedBox(width: 12),
                                    // Texto de la notificación
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            notification.title,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            notification.message,
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey[700],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    // Campanita estética
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFCE4EC), // Fondo rosado muy suave
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: const Color(0xFFF8BBD0), // Borde rosado suave
                                          width: 1,
                                        ),
                                      ),
                                      child: const Icon(
                                        Icons.notifications_none_rounded,
                                        color: Color(0xFFD81B60), // Icono rosa oscuro
                                        size: 20,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
