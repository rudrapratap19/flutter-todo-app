import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'auth_service.dart';
import 'todo_model.dart';
import 'todo_service.dart';
import 'add_todo_screen.dart';

class TodoListScreen extends StatefulWidget {
  const TodoListScreen({super.key});
  @override
  State<TodoListScreen> createState() => _TodoListScreenState();
}

class _TodoListScreenState extends State<TodoListScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthService>();
    final todoService = context.watch<TodoService>();
    final categories = ['Work', 'Home', 'Personal', 'Others'];
    final priorities = ['high', 'medium', 'low'];

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Todos'),
        actions: [
          IconButton(
              icon: const Icon(Icons.cloud_download),
              tooltip: 'Sync Todos',
              onPressed: () async {
                await todoService.fetchTodos();
                ScaffoldMessenger.of(context)
                    .showSnackBar(const SnackBar(content: Text('Synced todos')));
              }),
          IconButton(
              icon: const Icon(Icons.file_copy),
              tooltip: 'Export to CSV',
              onPressed: () async {
                await todoService.exportTodos();
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Todos copied to clipboard')));
              }),
          IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () async {
                await auth.signOut();
              }),
          IconButton(
              icon: const Icon(Icons.add),
              tooltip: 'Add Todo',
              onPressed: () {
                Navigator.of(context)
                    .push(MaterialPageRoute(builder: (_) => const AddTodoScreen()));
              }),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildProfile(auth),
            const SizedBox(height: 12),

            // Search and filters
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration:
                        const InputDecoration(labelText: 'Search todos', suffixIcon: Icon(Icons.search)),
                    onChanged: (val) {
                      todoService.searchQuery = val;
                      todoService.notifyListeners();
                    },
                  ),
                ),
                const SizedBox(width: 8),
                DropdownButton<String?>(
                  value: todoService.currentCategoryFilter.isEmpty
                      ? null
                      : todoService.currentCategoryFilter,
                  hint: const Text('Category'),
                  items: [null, ...categories]
                      .map((cat) => DropdownMenuItem<String?>(
                          value: cat, child: Text(cat ?? 'All')))
                      .toList(),
                  onChanged: (val) {
                    todoService.currentCategoryFilter = val ?? '';
                    todoService.notifyListeners();
                  },
                ),
                const SizedBox(width: 8),
                DropdownButton<String?>(
                  value: todoService.currentPriorityFilter.isEmpty
                      ? null
                      : todoService.currentPriorityFilter,
                  hint: const Text('Priority'),
                  items: [null, ...priorities]
                      .map((pri) => DropdownMenuItem<String?>(
                          value: pri, child: Text(pri ?? 'All')))
                      .toList(),
                  onChanged: (val) {
                    todoService.currentPriorityFilter = val ?? '';
                    todoService.notifyListeners();
                  },
                ),
              ],
            ),

            const SizedBox(height: 12),

            Expanded(child: _buildTodoList(todoService)),
          ],
        ),
      ),
    );
  }

  Widget _buildProfile(AuthService auth) {
    final user = auth.currentUser!;
    final displayName = user.userMetadata?['name'] ?? user.email ?? '';
    final avatarUrl = user.userMetadata?['picture'];
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: ListTile(
        leading: CircleAvatar(
          radius: 30,
          backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl) : null,
          child: avatarUrl == null ? const Icon(Icons.person, size: 30) : null,
        ),
        title: Text(displayName,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        subtitle: Text(user.email ?? ''),
      ),
    );
  }

  Widget _buildTodoList(TodoService todoService) {
    final todos = todoService.filteredTodos();

    if (todoService.loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (todos.isEmpty) {
      return const Center(child: Text('No todos available'));
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: todos.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final t = todos[index];
        final completed = todoService.completed[t.id] ?? false;
        final category = todoService.categories[t.id] ?? 'Others';
        final priority = todoService.priority[t.id] ?? 'medium';
        final recurring = todoService.recurring[t.id] ?? 'none';

        return Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 2,
          child: ListTile(
            leading: Checkbox(
              value: completed,
              onChanged: (val) {
                todoService.toggleCompleted(t.id);
              },
            ),
            title: Text(
              t.title,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                decoration: completed ? TextDecoration.lineThrough : null,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Due: ${DateFormat.yMd().add_jm().format(t.deadline)}',
                    style: TextStyle(color: Colors.indigo[700])),
                Text('Category: $category | Priority: $priority | Recurring: $recurring',
                    style: const TextStyle(fontSize: 12)),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                    icon: const Icon(Icons.repeat, color: Colors.green),
                    onPressed: () {
                      _showRecurringDialog(context, todoService, t.id, recurring);
                    }),
                IconButton(
                    icon: const Icon(Icons.edit, color: Colors.indigo),
                    onPressed: () {
                      _showEditDialog(context, todoService, t);
                    }),
                IconButton(
                    icon: const Icon(Icons.delete, color: Colors.redAccent),
                    onPressed: () {
                      todoService.deleteTodo(t.id);
                    }),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showRecurringDialog(BuildContext context, TodoService todoService, String todoId, String currentValue) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Set Recurring'),
        content: StatefulBuilder(builder: (context, setState) {
          return DropdownButton<String>(
            value: currentValue,
            items: ['none', 'daily', 'weekly', 'monthly'].map((e) {
              return DropdownMenuItem(value: e, child: Text(e));
            }).toList(),
            onChanged: (val) {
              todoService.setRecurring(todoId, val ?? 'none');
              Navigator.pop(context);
            },
          );
        }),
      ),
    );
  }

  void _showEditDialog(BuildContext context, TodoService todoService, dynamic todo) {
    final titleController = TextEditingController(text: todo.title);
    DateTime deadline = todo.deadline;
    String category = todoService.categories[todo.id] ?? 'Others';
    String priority = todoService.priority[todo.id] ?? 'medium';

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(builder: (context, setState) {
        return AlertDialog(
          title: const Text('Edit Todo'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: titleController, decoration: const InputDecoration(labelText: 'Title')),
              const SizedBox(height: 8),
              Text('Deadline: ${DateFormat.yMd().add_jm().format(deadline)}'),
              TextButton(
                child: const Text('Change Deadline'),
                onPressed: () async {
                  final pickedDate = await showDatePicker(
                      context: context,
                      initialDate: deadline,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365 * 20)));
                  if (pickedDate == null) return;
                  final pickedTime = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.fromDateTime(deadline));
                  if (pickedTime == null) return;
                  setState(() {
                    deadline = DateTime(pickedDate.year, pickedDate.month, pickedDate.day, pickedTime.hour, pickedTime.minute);
                  });
                },
              ),
              DropdownButton<String>(
                value: category,
                items: ['Work', 'Home', 'Personal', 'Others']
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (val) {
                  setState(() {
                    category = val ?? 'Others';
                    todoService.setCategory(todo.id, category);
                  });
                },
              ),
              DropdownButton<String>(
                value: priority,
                items: ['high', 'medium', 'low']
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (val) {
                  setState(() {
                    priority = val ?? 'medium';
                    todoService.setPriority(todo.id, priority);
                  });
                },
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            TextButton(onPressed: () async {
              todo.title = titleController.text.trim();
              todo.deadline = deadline;
              await todoService.updateTodo(todo);
              Navigator.pop(context);
            }, child: const Text('Save')),
          ],
        );
      }),
    );
  }
}
