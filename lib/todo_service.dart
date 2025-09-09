import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'notification_service.dart';
import 'todo_model.dart';
import 'package:csv/csv.dart';
import 'package:flutter/services.dart';

class TodoService extends ChangeNotifier {
  final SupabaseClient supabase = Supabase.instance.client;
  List todos = [];
  bool loading = false;

  // New local states for features
  Map<String, bool> completed = {};
  Map<String, String> categories = {};
  Map<String, String> priority = {};
  Map<String, String> recurring = {};

  String currentCategoryFilter = '';
  String currentPriorityFilter = '';
  String searchQuery = '';

  TodoService(SupabaseClient client) {
    _subscribeToTodos();
  }

  void _subscribeToTodos() {
    final uid = supabase.auth.currentUser?.id;
    if (uid == null) return;
    supabase
        .from('todos')
        .stream(primaryKey: ['id'])
        .eq('user_id', uid)
        .listen((List data) {
      todos = data.map((e) => TodoModel.fromMap(e)).toList();
      notifyListeners();
    });
  }

  Future fetchTodos() async {
    loading = true;
    notifyListeners();
    final uid = supabase.auth.currentUser?.id;
    if (uid == null) return;
    try {
      final data = await supabase
          .from('todos')
          .select()
          .eq('user_id', uid)
          .order('deadline', ascending: true);
      loading = false;
      todos = data.map((e) => TodoModel.fromMap(e)).toList();
      notifyListeners();
    } catch (e) {
      loading = false;
      debugPrint('fetch todos error: $e');
      notifyListeners();
      return;
    }
  }

  Future addTodo(String title, DateTime deadline) async {
    final uid = supabase.auth.currentUser!.id;
    final res = await supabase.from('todos').insert({
      'user_id': uid,
      'title': title,
      'deadline': deadline.toUtc().toIso8601String(),
    });
    if (res.error != null) {
      debugPrint('add todo error: ${res.error!.message}');
      throw res.error!;
    } else {
      final todoRec = (res.data as List).first;
      final t = TodoModel.fromMap(todoRec);
      await NotificationService().scheduleNotificationForTodo(t);
      notifyListeners();
    }
  }

  Future updateTodo(TodoModel todo) async {
    try {
      await supabase
          .from('todos')
          .update({
            'title': todo.title,
            'deadline': todo.deadline.toUtc().toIso8601String(),
            'reminder_sent': todo.reminderSent,
          })
          .eq('id', todo.id);
      await NotificationService().scheduleNotificationForTodo(todo);
      notifyListeners();
    } catch (e) {
      debugPrint('update todo error: $e');
      rethrow;
    }
  }

  Future deleteTodo(String id) async {
    try {
      await supabase.from('todos').delete().eq('id', id);
      await NotificationService().cancelNotification(id);
      // Remove local states
      completed.remove(id);
      categories.remove(id);
      priority.remove(id);
      recurring.remove(id);
      notifyListeners();
    } catch (e) {
      debugPrint('delete todo error: $e');
      rethrow;
    }
  }

  // ------- Local features logic -------
  void toggleCompleted(String id) {
    completed[id] = !(completed[id] ?? false);
    notifyListeners();
  }

  void setCategory(String id, String cat) {
    categories[id] = cat;
    notifyListeners();
  }

  void setPriority(String id, String pr) {
    priority[id] = pr;
    notifyListeners();
  }

  void setRecurring(String id, String cycle) {
    recurring[id] = cycle;
    notifyListeners();
  }

  // Filtering and searching
  List filteredTodos() {
    List out = todos;
    if (currentCategoryFilter.isNotEmpty) {
      out = out.where((t) => categories[t.id] == currentCategoryFilter).toList();
    }
    if (currentPriorityFilter.isNotEmpty) {
      out = out.where((t) => priority[t.id] == currentPriorityFilter).toList();
    }
    if (searchQuery.isNotEmpty) {
      out = out
          .where((t) =>
              t.title.toLowerCase().contains(searchQuery.toLowerCase()))
          .toList();
    }
    return out;
  }

  // Export as CSV
  Future<void> exportTodos() async {
    List<List<dynamic>> rows = [];

    rows.add([
      'title',
      'deadline',
      'completed',
      'category',
      'priority',
      'recurring'
    ]);
    for (var t in todos) {
      rows.add([
        t.title,
        t.deadline.toIso8601String(),
        completed[t.id] ?? false,
        categories[t.id] ?? '',
        priority[t.id] ?? '',
        recurring[t.id] ?? '',
      ]);
    }
    String csv = const ListToCsvConverter().convert(rows);
    await Clipboard.setData(ClipboardData(text: csv));
    // Now CSV is available in clipboard. You can add file save logic if needed.
  }
}
