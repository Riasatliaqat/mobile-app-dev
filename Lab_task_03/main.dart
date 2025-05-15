import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'University App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final List<Widget> _screens = [
    const SubjectList(),
    const LocalStorageExample(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('University App'),
        centerTitle: true,
      ),
      drawer: const AppDrawer(),
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.school),
            label: 'Subjects',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.storage),
            label: 'Storage',
          ),
        ],
      ),
    );
  }
}

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
            child: Text(
              'Menu',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Home'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}

class SubjectList extends StatelessWidget {
  const SubjectList({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Image.network(
            'https://via.placeholder.com/400x200?text=University+App',
            fit: BoxFit.cover,
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                _buildSubjectCard(
                  subjectName: 'Mathematics',
                  teacherName: 'Dr. Smith',
                  course: 'Calculus I',
                  creditHours: 3,
                ),
                const SizedBox(height: 10),
                _buildSubjectCard(
                  subjectName: 'Computer Science',
                  teacherName: 'Prof. Johnson',
                  course: 'Data Structures',
                  creditHours: 4,
                ),
                const SizedBox(height: 10),
                _buildSubjectCard(
                  subjectName: 'Physics',
                  teacherName: 'Dr. Brown',
                  course: 'Mechanics',
                  creditHours: 3,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubjectCard({
    required String subjectName,
    required String teacherName,
    required String course,
    required int creditHours,
  }) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              subjectName,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text('Teacher: $teacherName'),
            Text('Course: $course'),
            Text('Credit Hours: $creditHours'),
          ],
        ),
      ),
    );
  }
}

class LocalStorageExample extends StatefulWidget {
  const LocalStorageExample({super.key});

  @override
  State<LocalStorageExample> createState() => _LocalStorageExampleState();
}

class _LocalStorageExampleState extends State<LocalStorageExample> {
  final TextEditingController _controller = TextEditingController();
  List<String> _records = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _saveData(String text) async {
    final prefs = await SharedPreferences.getInstance();
    _records.add(text);
    await prefs.setStringList('myData', _records);
    setState(() {});
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _records = prefs.getStringList('myData') ?? [];
    });
  }

  Future<void> _deleteItem(int index) async {
    final prefs = await SharedPreferences.getInstance();
    _records.removeAt(index);
    await prefs.setStringList('myData', _records);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          TextField(
            controller: _controller,
            decoration: const InputDecoration(
              labelText: "Enter text",
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () {
              final text = _controller.text.trim();
              if (text.isNotEmpty) {
                _saveData(text);
                _controller.clear();
              }
            },
            child: const Text("Save"),
          ),
          const SizedBox(height: 20),
          Text(
            "Saved Items (${_records.length})",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: _records.isEmpty
                ? const Center(child: Text("No saved items yet"))
                : ListView.builder(
              itemCount: _records.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_records[index]),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => _deleteItem(index),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}