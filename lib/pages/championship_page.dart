import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:sports/providers/championship_provider.dart';
import 'package:sports/models/championship.dart';
import 'package:sports/providers/entitlements.dart';
import 'package:sports/services/api_service.dart';

class ChampionshipsPage extends StatelessWidget {
  const ChampionshipsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) {
        final prov = ChampionshipsProvider(api: context.read<ApiService>());
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          final safeContext = context;
          await prov.loadChampionships();
          if (!safeContext.mounted) return;
          await prov.preloadLogos(safeContext);
        });
        return prov;
      },
      child: const ChampionshipsView(),
    );
  }
}

class ChampionshipsView extends StatelessWidget {
  const ChampionshipsView({super.key});
  final String module = "championships";

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<ChampionshipsProvider>();
    final entitlements = context.watch<Entitlements>();

    if (prov.loading || !prov.logosReady || !entitlements.isLoaded) {
      return const Center(child: CircularProgressIndicator());
    }

    final canRead = entitlements.can(module, "read");
    if (!canRead) {
      return const Center(child: Text("No tienes permiso para leer campeonatos."));
    }
    final canCreate = entitlements.can(module, "create");
    final canUpdate = entitlements.can(module, "update");
    final canDelete = entitlements.can(module, "delete");

    if (prov.error != null) {
      return Center(child: Text(prov.error!));
    }

    final championships = prov.championships;

    return Stack(
      children: [
        ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: championships.length,
          itemBuilder: (context, index) {
            final ch = championships[index];

            return ListTile(
              leading: prov.logoFor(ch.id) != null
                  ? CircleAvatar(backgroundImage: prov.logoFor(ch.id))
                  : CircleAvatar(child: Text(ch.name[0])),
              title: Text(ch.name),
              subtitle: Text("${ch.sport} • ${ch.scope ?? 'No scope'}"),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  canUpdate? IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () => _openDialog(context, ch: ch),
                  ) : Container(),
                  canDelete? IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () =>
                        context.read<ChampionshipsProvider>().deleteChampionship(ch.id),
                  ) : Container(),
                ],
              ),
            );
          },
        ),
        if (canCreate)
          Positioned(
            bottom: 24,
            right: 24,
            child: FloatingActionButton(
              onPressed: () => _openDialog(context),
              child: const Icon(Icons.add),
            ),
          ),
      ],
    );
  }

  void _openDialog(BuildContext context, {Championship? ch}) {
    final nameCtrl = TextEditingController(text: ch?.name ?? '');
    final sportCtrl = TextEditingController(text: ch?.sport ?? '');
    final scopeCtrl = TextEditingController(text: ch?.scope ?? '');
    final logoCtrl = TextEditingController(text: ch?.logoUrl ?? '');

    showDialog(
      context: context,
      builder: (context) {
        final isEdit = ch != null;

        return AlertDialog(
          title: Text(isEdit ? 'Edit Championship' : 'Add Championship'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: sportCtrl,
                decoration: const InputDecoration(labelText: 'Sport'),
              ),
              TextField(
                controller: scopeCtrl,
                decoration: const InputDecoration(labelText: 'Scope (optional)'),
              ),
              TextField(
                controller: logoCtrl,
                decoration: const InputDecoration(labelText: 'Logo ID (optional)'),
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
                final name = nameCtrl.text.trim();
                final sport = sportCtrl.text.trim();
                final scope = scopeCtrl.text.trim().isEmpty ? null : scopeCtrl.text.trim();
                final logo = logoCtrl.text.trim().isEmpty ? null : logoCtrl.text.trim();

                if (name.isEmpty || sport.isEmpty) return;

                final newCh = Championship(
                  id: "",
                  name: name,
                  sport: sport,
                  scope: scope,
                   logoUrl: logo,
                );

                final prov = context.read<ChampionshipsProvider>();

                if (isEdit) {
                  await prov.updateChampionship(newCh);
                } else {
                  await prov.createChampionship(newCh);
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