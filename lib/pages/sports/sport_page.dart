import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/sport.dart';
import '../../providers/sports_provider.dart';

class SportsPage extends StatefulWidget {
  const SportsPage({super.key});

  @override
  State<SportsPage> createState() => _SportsPageState();
}

class _SportsPageState extends State<SportsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SportsProvider>().loadSports();
    });
  }

  @override
  Widget build(BuildContext context) {
    final sportsProv = context.watch<SportsProvider>();

    if (sportsProv.loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (sportsProv.error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Sports')),
        body: Center(child: Text(sportsProv.error!)),
      );
    }

    final sports = sportsProv.sports;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sports'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openSportDialog(context),
        child: const Icon(Icons.add),
      ),
      body: ListView.builder(
        itemCount: sports.length,
        itemBuilder: (context, index) {
          final sport = sports[index];

          return ListTile(
            leading: CircleAvatar(
              child: Text(sport.name.isNotEmpty ? sport.name[0] : '?'),
            ),
            title: Text(sport.name),
            subtitle: Text(sport.logoId ?? 'No logo'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => _openSportDialog(context, sport: sport),
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () =>
                      context.read<SportsProvider>().deleteSport(sport.name),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _openSportDialog(BuildContext context, {Sport? sport}) {
    final nameController = TextEditingController(text: sport?.name ?? '');
    final logoController = TextEditingController(text: sport?.logoId ?? '');

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

                final newSport = Sport(name: name, logoId: logoId);
                final prov = context.read<SportsProvider>();

                if (isEdit) {
                  await prov.updateSport(newSport);
                } else {
                  await prov.addSport(newSport);
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