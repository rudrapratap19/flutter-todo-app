import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'todo_service.dart';

class AddTodoScreen extends StatefulWidget {
  const AddTodoScreen({super.key});
  @override
  State<AddTodoScreen> createState() => _AddTodoScreenState();
}

class _AddTodoScreenState extends State<AddTodoScreen> {
  final TextEditingController _titleController = TextEditingController();
  DateTime? _pickedDeadline;

  String tagInput = '';
  String priorityInput = 'medium';
  String recurringInput = 'none';

  @override
  Widget build(BuildContext context) {
    final todoService = context.read<TodoService>();
    final categories = ['Work', 'Home', 'Personal', 'Others'];
    final priorities = ['high', 'medium', 'low'];
    final recurringOptions = ['none', 'daily', 'weekly', 'monthly'];

    return Scaffold(
      appBar: AppBar(title: const Text('Add Todo')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Text(
                    _pickedDeadline == null
                        ? 'No deadline chosen'
                        : '${_pickedDeadline!.toLocal()}'.split('.')[0],
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 3650)));
                    if (pickedDate == null) return;
                    final pickedTime =
                        await showTimePicker(context: context, initialTime: TimeOfDay.now());
                    if (pickedTime == null) return;
                    setState(() {
                      _pickedDeadline = DateTime(pickedDate.year, pickedDate.month,
                          pickedDate.day, pickedTime.hour, pickedTime.minute);
                    });
                  },
                  child: const Text('Pick Deadline'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: DropdownButton(
                    value: tagInput.isEmpty ? null : tagInput,
                    hint: const Text('Category'),
                    items: categories
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (val) => setState(() => tagInput = val ?? ''),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButton(
                    value: priorityInput,
                    items: priorities
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (val) => setState(() => priorityInput = val ?? 'medium'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButton(
                    value: recurringInput,
                    items: recurringOptions
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (val) => setState(() => recurringInput = val ?? 'none'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  final title = _titleController.text.trim();
                  if (title.isEmpty || _pickedDeadline == null) {
                    ScaffoldMessenger.of(context)
                        .showSnackBar(const SnackBar(content: Text('Please enter title and deadline')));
                    return;
                  }
                  await todoService.addTodo(title, _pickedDeadline!);

                  // Set additional info
                  final latestTodo = todoService.todos.last;
                  if (tagInput.isNotEmpty) todoService.setCategory(latestTodo.id, tagInput);
                  todoService.setPriority(latestTodo.id, priorityInput);
                  todoService.setRecurring(latestTodo.id, recurringInput);

                  // Clear all fields and update UI
                  _titleController.clear();
                  setState(() {
                    _pickedDeadline = null;
                    tagInput = '';
                    priorityInput = 'medium';
                    recurringInput = 'none';
                  });

                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Todo added!')));
                  Navigator.of(context).pop();
                },
                child: const Text('Add Todo'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
