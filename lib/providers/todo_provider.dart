import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/todo.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError();
});

class TodoList extends Notifier<List<Todo>> {
  @override
  List<Todo> build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    final String? todosString = prefs.getString('todos');
    if (todosString != null) {
      try {
        final List<dynamic> jsonList = jsonDecode(todosString);
        return jsonList.map((e) => Todo.fromJson(e)).toList();
      } catch (e) {
        // Handle corruption or format change
        return [];
      }
    }
    return [];
  }

  Future<void> _saveTodos() async {
    final prefs = ref.read(sharedPreferencesProvider);
    final String todosString = jsonEncode(
      state.map((e) => e.toJson()).toList(),
    );
    await prefs.setString('todos', todosString);
  }

  void add(String title) {
    state = [
      ...state,
      Todo(id: DateTime.now().millisecondsSinceEpoch.toString(), title: title),
    ];
    _saveTodos();
  }

  void toggle(String id) {
    state = [
      for (final todo in state)
        if (todo.id == id)
          todo.copyWith(isCompleted: !todo.isCompleted)
        else
          todo,
    ];
    _saveTodos();
  }

  void remove(String id) {
    state = state.where((todo) => todo.id != id).toList();
    _saveTodos();
  }
}

final todoListProvider = NotifierProvider<TodoList, List<Todo>>(TodoList.new);
