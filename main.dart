import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';

void main() => runApp(const ChinakilaApp());

class ChinakilaApp extends StatelessWidget {
  const ChinakilaApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Chinakila Farm Manager',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF176B45)), useMaterial3: true),
    home: const HomeScreen(),
  );
}

class LocalQueue {
  static Database? _db;
  static Future<Database> get db async {
    if (_db != null) return _db!;
    final path = p.join(await getDatabasesPath(), 'chinakila_local.db');
    _db = await openDatabase(path, version: 1, onCreate: (db, version) async {
      await db.execute('''CREATE TABLE submissions(
        id TEXT PRIMARY KEY, module TEXT NOT NULL, officer_name TEXT NOT NULL,
        payload TEXT NOT NULL, created_at TEXT NOT NULL, sync_status TEXT NOT NULL
      )''');
    });
    return _db!;
  }
  static Future<void> saveDraft(String module, String officer, String payload) async {
    final database = await db;
    await database.insert('submissions', {
      'id': const Uuid().v4(), 'module': module, 'officer_name': officer,
      'payload': payload, 'created_at': DateTime.now().toIso8601String(),
      'sync_status': 'pending'
    });
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  final modules = const [
    ('Daily field report', Icons.assignment_outlined),
    ('Pond & fish management', Icons.water),
    ('Feeding & mortality', Icons.set_meal),
    ('Water quality & growth', Icons.science),
    ('Harvesting & fish sales', Icons.scale),
    ('Crop production', Icons.grass),
    ('Expenses & inventory', Icons.inventory_2),
    ('Activity tracker & GPS', Icons.location_on),
  ];
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('CHINAKILA FARM MANAGER'), backgroundColor: const Color(0xFF176B45), foregroundColor: Colors.white),
    body: ListView(padding: const EdgeInsets.all(16), children: [
      const Card(child: Padding(padding: EdgeInsets.all(18), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Welcome to Chinakila', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        SizedBox(height: 6), Text('Officer field portal • Offline-first collection')
      ]))),
      const SizedBox(height: 12),
      const Text('FARM MODULES', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
      const SizedBox(height: 8),
      ...modules.map((m) => Card(child: ListTile(leading: Icon(m.$2, color: const Color(0xFF176B45)), title: Text(m.$1), trailing: const Icon(Icons.chevron_right), onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => EntryScreen(module: m.$1)));
      }))),
    ]),
  );
}

class EntryScreen extends StatefulWidget {
  final String module;
  const EntryScreen({super.key, required this.module});
  @override
  State<EntryScreen> createState() => _EntryScreenState();
}
class _EntryScreenState extends State<EntryScreen> {
  final officer = TextEditingController();
  final notes = TextEditingController();
  bool saved = false;
  @override
  void dispose() { officer.dispose(); notes.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(widget.module)),
    body: ListView(padding: const EdgeInsets.all(16), children: [
      TextField(controller: officer, decoration: const InputDecoration(labelText: 'Officer full name *', border: OutlineInputBorder())),
      const SizedBox(height: 12),
      TextField(controller: notes, minLines: 4, maxLines: 7, decoration: const InputDecoration(labelText: 'Activity details / observations', border: OutlineInputBorder())),
      const SizedBox(height: 16),
      FilledButton.icon(onPressed: () async {
        if (officer.text.trim().isEmpty) return;
        await LocalQueue.saveDraft(widget.module, officer.text.trim(), notes.text.trim());
        if (mounted) setState(() => saved = true);
      }, icon: const Icon(Icons.save), label: const Text('Save offline')),
      if (saved) const Padding(padding: EdgeInsets.only(top: 12), child: Text('Saved on this phone. Synchronisation will be enabled after Kobo connection setup.', style: TextStyle(color: Colors.green))),
    ]),
  );
}
