import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
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

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addSubject({
    required String subjectName,
    required String teacherName,
    required String course,
    required int creditHours,
  }) async {
    await _firestore.collection('subjects').add({
      'subjectName': subjectName,
      'teacherName': teacherName,
      'course': course,
      'creditHours': creditHours,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<QuerySnapshot> getSubjects() {
    return _firestore.collection('subjects').orderBy('createdAt').snapshots();
  }

  Future<void> initializeSampleData() async {
    final snapshot = await _firestore.collection('subjects').get();
    if (snapshot.size == 0) {
      await addSubject(
        subjectName: 'Mathematics',
        teacherName: 'Dr. Smith',
        course: 'Calculus I',
        creditHours: 3,
      );
      await addSubject(
        subjectName: 'Computer Science',
        teacherName: 'Prof. Johnson',
        course: 'Data Structures',
        creditHours: 4,
      );
      await addSubject(
        subjectName: 'Physics',
        teacherName: 'Dr. Brown',
        course: 'Mechanics',
        creditHours: 3,
      );
    }
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _firestoreService.initializeSampleData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('University App'),
        centerTitle: true,
        actions: [
          if (_currentIndex == 0)
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => _showAddSubjectDialog(context),
            ),
        ],
      ),
      drawer: const AppDrawer(),
      body: _currentIndex == 0 ? const SubjectList() : const LocalStorageExample(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.school), label: 'Subjects'),
          BottomNavigationBarItem(icon: Icon(Icons.storage), label: 'Storage'),
        ],
      ),
    );
  }

  Future<void> _showAddSubjectDialog(BuildContext context) async {
    final formKey = GlobalKey<FormState>();
    final subjectNameController = TextEditingController();
    final teacherNameController = TextEditingController();
    final courseController = TextEditingController();
    final creditHoursController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Subject'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: subjectNameController,
                decoration: const InputDecoration(labelText: 'Subject Name'),
                validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
              ),
              TextFormField(
                controller: teacherNameController,
                decoration: const InputDecoration(labelText: 'Teacher Name'),
                validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
              ),
              TextFormField(
                controller: courseController,
                decoration: const InputDecoration(labelText: 'Course'),
                validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
              ),
              TextFormField(
                controller: creditHoursController,
                decoration: const InputDecoration(labelText: 'Credit Hours'),
                keyboardType: TextInputType.number,
                validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState?.validate() ?? false) {
                await _firestoreService.addSubject(
                  subjectName: subjectNameController.text,
                  teacherName: teacherNameController.text,
                  course: courseController.text,
                  creditHours: int.parse(creditHoursController.text),
                );
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
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
            decoration: BoxDecoration(color: Colors.blue),
            child: Text(
              'Menu',
              style: TextStyle(color: Colors.white, fontSize: 24),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Home'),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            onTap: () => Navigator.pop(context),
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
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('subjects').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final subjects = snapshot.data?.docs ?? [];

        return SingleChildScrollView(
          child: Column(
            children: [
              Image.network(
                'https://via.placeholder.com/400x200?text=University+App',
                fit: BoxFit.cover,
                width: double.infinity,
                height: 200,
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: subjects.map((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    return _buildSubjectCard(
                      subjectName: data['subjectName'] ?? '',
                      teacherName: data['teacherName'] ?? '',
                      course: data['course'] ?? '',
                      creditHours: data['creditHours'] ?? 0,
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        );
      },
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
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              subjectName,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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