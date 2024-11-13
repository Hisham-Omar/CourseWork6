import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'task.dart';

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  _TaskListScreenState createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  final TextEditingController _taskController = TextEditingController();
  List<Task> _tasks = [];

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    _database.child("tasks").onValue.listen((event) {
      final tasks = <Task>[];
      for (var element in event.snapshot.children) {
        final task =
            Task.fromMap(element.key!, element.value as Map<String, dynamic>);
        tasks.add(task);
      }
      setState(() {
        _tasks = tasks;
      });
    });
  }

  Future<void> _addTask() async {
    final taskName = _taskController.text.trim();
    if (taskName.isNotEmpty) {
      final newTask = _database.child("tasks").push();
      await newTask.set(Task(id: newTask.key!, name: taskName).toMap());
      _taskController.clear();
    }
  }

  Future<void> _toggleTaskCompletion(Task task) async {
    final taskRef = _database.child("tasks/${task.id}");
    await taskRef.update({'isCompleted': !task.isCompleted});
  }

  Future<void> _deleteTask(Task task) async {
    await _database.child("tasks/${task.id}").remove();
  }

  Future<void> _logout() async {
    await _auth.signOut();
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Tasks"),
        actions: [
          IconButton(icon: const Icon(Icons.logout), onPressed: _logout),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _taskController,
                    decoration: const InputDecoration(hintText: "Enter task"),
                  ),
                ),
                IconButton(icon: const Icon(Icons.add), onPressed: _addTask),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _tasks.length,
              itemBuilder: (context, index) {
                final task = _tasks[index];
                return ListTile(
                  title: Text(
                    task.name,
                    style: TextStyle(
                      decoration:
                          task.isCompleted ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  leading: Checkbox(
                    value: task.isCompleted,
                    onChanged: (_) => _toggleTaskCompletion(task),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => _deleteTask(task),
                  ),
                  subtitle: _buildSubTasks(task),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubTasks(Task task) {
    if (task.subTasks == null) return const SizedBox.shrink();
    return Column(
      children: task.subTasks!.entries.map((entry) {
        return ExpansionTile(
          title: Text(entry.key),
          children: entry.value
              .map((subTask) => ListTile(title: Text(subTask)))
              .toList(),
        );
      }).toList(),
    );
  }
}
