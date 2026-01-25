import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:sports/models/sport.dart';
import 'package:sports/providers/sports_provider.dart';
import 'package:sports/providers/entitlements.dart';
import 'package:sports/services/api_service.dart';

class SportsPage extends StatelessWidget {
  const SportsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) {
        final prov = SportsProvider(api: context.read<ApiService>());
        // Ejecutar después del primer frame
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          final safeContext = context;
          await prov.loadSports();
          if (!safeContext.mounted) return; // seguridad
          await prov.preloadLogos(safeContext); // precarga de los logos
        });
        return prov;
      },
      child: const SportsView(),
    );
  }
}

class SportsView extends StatelessWidget {
  const SportsView({super.key});
  final String module = "sports";

  @override
  Widget build(BuildContext context) {
    final sportsProv = context.watch<SportsProvider>();
    final entitlements = context.watch<Entitlements>();

    // 1. Manejo de estados de carga y error sin Scaffold extra
    if (sportsProv.loading || !sportsProv.logosReady || !entitlements.isLoaded) {
      return const Center(child: CircularProgressIndicator());
    }

    final canRead = entitlements.can(module, "read");
    if (!canRead) {
      return const Center(child: Text("No tienes permiso para leer deportes."));
    }

    final canCreate = entitlements.can(module, "create");
    final canUpdate = entitlements.can(module, "update");
    final canDelete = entitlements.can(module, "delete");

    if (sportsProv.error != null) {
      return Center(child: Text(sportsProv.error!));
    }

    final sports = sportsProv.sports;

    return Stack(children: [
      ListView.builder(padding: const EdgeInsets.all(16),
        itemCount: sports.length,
        itemBuilder: (context, index) {
          final sport = sports[index];

          return ListTile(
            leading: sportsProv.logoFor(sport.name) != null
              ? CircleAvatar(backgroundImage: sportsProv.logoFor(sport.name),)
              : CircleAvatar(child: Text(sport.name.isNotEmpty ? sport.name[0] : '?'),),
            title: Text(sport.name),
            subtitle: Text(sport.logoUrl ?? 'No logo'),
            trailing: Row(mainAxisSize: MainAxisSize.min,
              children: [
                canUpdate? IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => _openSportDialog(context, sport: sport),
                ) : Container(),
                canDelete? IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () =>
                      context.read<SportsProvider>().deleteSport(sport.name),
                ) : Container(),
              ],
            )
          );
        },
      ),
      // Posicionamos el botón manualmente ya que no hay Scaffold interno
      if (canCreate)
        Positioned(
          bottom: 24,
          right: 24,
          child: FloatingActionButton(
            onPressed: () => _openSportDialog(context),
            child: const Icon(Icons.add),
          ),
        ),
    ]);
  }

  void _openSportDialog(BuildContext context, {Sport? sport}) {
    final nameController = TextEditingController(text: sport?.name ?? '');
    final logoController = TextEditingController(text: sport?.logoUrl ?? '');

    showDialog(
      context: context,
      builder: (context) {
        final isEdit = sport != null;

        return AlertDialog(
          title: Text(isEdit ? 'Edit Sport' : 'Add Sport'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Name'),
                readOnly: isEdit,
              ),
              TextField(
                controller: logoController,
                decoration:
                const InputDecoration(labelText: 'Logo ID (optional)'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final name = nameController.text.trim();
                final logoId = logoController.text.trim().isEmpty
                    ? null
                    : logoController.text.trim();

                if (name.isEmpty) return;

                final newSport = Sport(name: name, logoUrl: logoId);
                final prov = context.read<SportsProvider>();

                if (isEdit) {
                  await prov.updateSport(newSport);
                } else {
                  await prov.createSport(newSport);
                }

                if (context.mounted) Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }
}