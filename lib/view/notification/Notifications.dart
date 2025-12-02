import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:taskmaster_flutter/bloc/Notifications/NotificationsBloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/notificattions/NotificationDto.dart';

class Notifications extends StatefulWidget {
  const Notifications({super.key});

  @override
  State<Notifications> createState() => _NotificationsState();
}

class _NotificationsState extends State<Notifications> {
  final TextEditingController _searchController = TextEditingController();
  String _filter = '';
  @override
  void initState() {
    super.initState();
    // Solicitar notificaciones al iniciar la pantalla
    context.read<NotificationsBloc>().add(const NotificationsFetchRequested());
    // Escuchar cambios en el buscador para actualizar el filtro
    _searchController.addListener(() {
      final text = _searchController.text;
      if (text != _filter) {
        setState(() {
          _filter = text;
        });
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    context.read<NotificationsBloc>().add(const NotificationsFetchRequested());
  }

  String _format(String sentAt) {
    try {
      final dt = DateTime.parse(sentAt);
      return DateFormat.yMMMd('es_ES').add_jm().format(dt);
    } catch (_) {
      return sentAt;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NotificationsBloc, NotificationsState>(
      builder: (context, state) {
        if (state is NotificationsLoadInProgress) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is NotificationsLoadSuccess) {
          final List<NotificationDto> items = state.notifications;
          // Filtrar por título (insensible a mayúsculas)
          final filteredItems = _filter.trim().isEmpty
              ? items
              : items.where((n) => n.title.toLowerCase().contains(_filter.toLowerCase())).toList();
          if (items.isEmpty) {
            return RefreshIndicator(
              onRefresh: _refresh,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  SizedBox(height: 200),
                  Center(child: Text('No tienes notificaciones')),
                ],
              ),
            );
          }

          // Si hay notificaciones pero el filtro no devuelve coincidencias, mostrar mensaje específico
          if (filteredItems.isEmpty) {
            return RefreshIndicator(
              onRefresh: _refresh,
              child: ListView(
                padding: const EdgeInsets.all(12),
                children: [
                  // Encabezado y buscador (como en itemBuilder index 0)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.fromLTRB(12.0, 36.0, 12.0, 8.0),
                        child: Text(
                          'Notificaciones',
                          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(12.0, 0, 12.0, 12.0),
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: 'Buscar notificación ',
                            prefixIcon: const Icon(Icons.search),
                            suffixIcon: _filter.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear),
                                    onPressed: () {
                                      _searchController.clear();
                                    },
                                  )
                                : null,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 80),
                  Center(child: Text('No se encontraron notificaciones', style: Theme.of(context).textTheme.bodyMedium)),
                ],
              ),
            );
          }

           return RefreshIndicator(
             onRefresh: _refresh,
             child: ListView.separated(
               padding: const EdgeInsets.all(12),
               itemCount: filteredItems.length + 1,
               separatorBuilder: (_, __) => const SizedBox(height: 8),
               itemBuilder: (context, index) {
                 if (index == 0) {
                   return Column(
                     crossAxisAlignment: CrossAxisAlignment.start,
                     children: [
                       const Padding(
                         padding: EdgeInsets.fromLTRB(12.0, 36.0, 12.0, 8.0),
                         child: Text(
                           'Notificaciones',
                           style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                         ),
                       ),
                       // Campo de búsqueda para filtrar por título
                       Padding(
                         padding: const EdgeInsets.fromLTRB(12.0, 0, 12.0, 12.0),
                         child: TextField(
                           controller: _searchController,
                           decoration: InputDecoration(
                             hintText: 'Buscar por título',
                             prefixIcon: const Icon(Icons.search),
                             suffixIcon: _filter.isNotEmpty
                                 ? IconButton(
                                     icon: const Icon(Icons.clear),
                                     onPressed: () {
                                       _searchController.clear();
                                     },
                                   )
                                 : null,
                             border: OutlineInputBorder(
                               borderRadius: BorderRadius.circular(8),
                             ),
                             contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                           ),
                         ),
                       ),
                     ],
                   );
                 }

                 final n = filteredItems[index - 1];
                 return Card(
                   color: Colors.grey[100],
                   elevation: 0,
                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                   child: Padding(
                     padding: const EdgeInsets.all(12),
                     child: Row(
                       children: [
                         // Imagen del proyecto a la izquierda
                         ClipRRect(
                           borderRadius: BorderRadius.circular(8),
                           child: SizedBox(
                             width: 56,
                             height: 56,
                             child: n.project != null && n.project!.imageUrl != null && n.project!.imageUrl!.isNotEmpty
                                 ? CachedNetworkImage(
                                     imageUrl: n.project!.imageUrl!,
                                     fit: BoxFit.cover,
                                     width: 56,
                                     height: 56,
                                     errorWidget: (context, url, error) => Image.asset('assets/img/ic_profile_placeholder3.png', fit: BoxFit.cover),
                                   )
                                 : Image.asset('assets/img/ic_profile_placeholder3.png', fit: BoxFit.cover),
                           ),
                         ),

                         const SizedBox(width: 12),

                         // Contenido de la notificación
                         Expanded(
                           child: Column(
                             crossAxisAlignment: CrossAxisAlignment.start,
                             children: [
                               Text(n.title, style: Theme.of(context).textTheme.titleMedium),
                               const SizedBox(height: 8),
                               Text(n.message, style: Theme.of(context).textTheme.bodyMedium),
                               const SizedBox(height: 8),
                               Align(
                                 alignment: Alignment.centerRight,
                                 child: Text(_format(n.sentAt), style: Theme.of(context).textTheme.bodySmall),
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
           );
        }
        if (state is NotificationsFailure) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Error: ${state.message}'),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: _refresh,
                  child: const Text('Reintentar'),
                ),
              ],
            ),
          );
        }

        // Estado inicial
        return const SizedBox.shrink();
      },
    );
  }
}
