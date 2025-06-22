import 'package:flutter/material.dart';
import 'package:localstorage/localstorage.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import 'package:gestion_tiempo/ui/add_entry_screen.dart';
import 'package:gestion_tiempo/ui/projects_screen.dart';
import 'package:gestion_tiempo/ui/tasks_screen.dart';
import 'package:gestion_tiempo/providers/entry_provider.dart';
import 'package:gestion_tiempo/providers/task_provider.dart';
import 'package:gestion_tiempo/providers/project_provider.dart';
import 'package:gestion_tiempo/models/entry.dart';

final LocalStorage storage = LocalStorage('entries_app');

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final storage = LocalStorage('entries_app');
  await storage.ready;
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => EntryProvider(storage: storage)),
        ChangeNotifierProvider(create: (_) => ProjectProvider(storage: storage)),
        ChangeNotifierProvider(create: (_) => TaskProvider(storage: storage)),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gestión Tiempo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 0, 203, 102),
        ),
      ),
      home: const MyHomePage(title: 'Time Tracker'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    final entries = context.watch<EntryProvider>().entries;
    final projProv  = context.watch<ProjectProvider>();
    final taskProv  = context.watch<TaskProvider>();

    // Pestaña "Por fecha": ordenada por fecha descendente
    final byDate = List.of(entries)
      ..sort((a, b) => b.date.compareTo(a.date));

    // Pestaña "Por proyecto": agrupada y ordenada por nombre de proyecto
    final byProject = Map<String, List<Entry>>();
    for (var e in entries) {
      final projName = projProv.getById(e.projectId)?.name ?? '';
      byProject.putIfAbsent(projName, () => []).add(e);
    }
    final sortedCategories = byProject.keys.toList()..sort();


    return DefaultTabController(
      length: 2,
      child: Scaffold(
        drawer: Drawer(
          child: Column(
             children: [
              DrawerHeader(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,                  
                  borderRadius: const BorderRadius.only(
                    bottomRight: Radius.circular(40),
                  ),
                ),
                child: const Align(
                  alignment: Alignment.bottomLeft,
                  child: Text(
                    'Menú',
                    style: TextStyle(color: Colors.white, fontSize: 24),
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.folder),
                iconColor: Theme.of(context).colorScheme.primary,
                title: const Text('Proyectos'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ProjectManagementScreen()),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.assignment),
                iconColor: Theme.of(context).colorScheme.primary,
                title: const Text('Tareas'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const TaskManagementScreen.TaskManagementScreen()),
                  );
                },
              ),
            ],
          ),
        ),
        appBar: AppBar(
          toolbarHeight: 80,
          iconTheme: const IconThemeData(color: Colors.white),
          backgroundColor: Theme.of(context).colorScheme.primary,
          centerTitle: true,
          title: Text(
            widget.title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          bottom: const TabBar(
            indicatorColor: Colors.white,
            labelStyle: TextStyle(fontWeight: FontWeight.bold),
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: [
              Tab(text: 'Todas las entradas'),
              Tab(text: 'Agrupado por proyecto'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            entries.isEmpty
              ? const Center(
                  child: Text(
                    'Aún no hay entradas',
                    style: TextStyle(fontSize: 18),
                  ),
                )
              :
              // Pestaña "Por fecha"
              ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: entries.length,
                itemBuilder: (context, index) {
                  final e = byDate[index];
                  final nameP = projProv.getById(e.projectId)?.name ?? '';
                  final nameT = taskProv.getById(e.taskId)?.name       ?? '';

                  return Dismissible(
                    key: Key(e.id),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 20),
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 166, 51, 43),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    onDismissed: (_) {
                      // Borra del provider
                      context.read<EntryProvider>().removeEntry(e.id);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Entrada eliminada')),
                      );
                    },

                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: ListTile(
                        title: Text(
                          'Proyecto: $nameP • ${e.hours} h',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          'Tarea: $nameT\n'
                          '${DateFormat.yMMMd().format(e.date)}'
                          '${e.notes != '' ? '\n${e.notes}' : ''}',
                        ),
                      ),
                    ),
                  );
                },
              ),
              entries.isEmpty
              ? const Center(
                  child: Text(
                    'Aún no hay entradas',
                    style: TextStyle(fontSize: 18),
                  ),
                )
              :
              // Pestaña "Por proyecto" (misma lista simple)
              ListView(
                padding: const EdgeInsets.all(16),
                children: sortedCategories.expand((projName) {
                  final list = byProject[projName]!;
                  list.sort((a, b) => a.taskId.compareTo(b.taskId));
                  return [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                          '$projName – Total: ${list.fold(0.0, (sum, e) => sum + e.hours).toStringAsFixed(1)} h',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    ...list.map((e) {
                      final nameT = taskProv.getById(e.taskId)?.name ?? '';
                      return Dismissible(
                        key: Key(e.id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          color: Colors.red,
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        onDismissed: (_) {
                          context.read<EntryProvider>().removeEntry(e.id);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Gasto eliminado')),
                          );
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: ListTile(
                            title: Text(
                              'Tarea: $nameT'
                            ),
                            subtitle: Text(
                              '${e.notes != '' ? '${e.notes}\n' : ''}'
                              '${DateFormat.yMMMd().format(e.date)}',
                            ),
                          ),
                        ),
                      );
                    }),
                  ];
                }).toList(),
              ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: Theme.of(context).colorScheme.primary,
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const AddEntryScreen(),
              ),
            );
          },
          tooltip: 'Añadir gasto',
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }
}
