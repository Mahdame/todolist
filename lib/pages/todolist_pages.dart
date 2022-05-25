import 'package:flutter/material.dart';
import 'package:todolist/models/todo.dart';
import 'package:todolist/repositories/todo_repository.dart';

import '../widgets/todolist_item.dart';

class TodolistPage extends StatefulWidget {
  TodolistPage({Key? key}) : super(key: key);

  @override
  State<TodolistPage> createState() => _TodolistPageState();
}

class _TodolistPageState extends State<TodolistPage> {
  final TextEditingController todoController = TextEditingController();
  final TodoRepository todoRepository = TodoRepository();

  List<Todo> todos = [];
  String? errorText;
  Todo? deletedTodo;
  int? deletedTodoPos;

  @override
  void initState() {
    super.initState();
    todoRepository.getTodoList().then((value) {
      setState(() {
        todos = value;
      });
    });
  }

  void onDelete(Todo todo) {
    deletedTodo = todo;
    deletedTodoPos = todos.indexOf(todo);

    setState(() {
      todos.remove(todo);
      todoRepository.saveTodoList(todos);
    });

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Tarefa \'${todo.title}\' removida com sucesso!'),
        action: SnackBarAction(
          label: 'DESFAZER',
          onPressed: () {
            setState(() {
              todos.insert(deletedTodoPos!, deletedTodo!);
            });
          },
        ),
        duration: const Duration(seconds: 5),
      ),
    );
  }

  void deleteAllTodos() {
    setState(() {
      todos.clear();
      todoRepository.saveTodoList(todos);
    });
  }

  void showConfirmationDialog() {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text('Deletar todas as tarefas!'),
              content: Text('Esta ação não é reversível! Tem certeza?'),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text('Cancelar')),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    deleteAllTodos();
                  },
                  child: Text(
                    'SIM!',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ],
            ));
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: todoController,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Adicione uma tarefa',
                          hintText: 'Estudar flutter',
                          errorText: errorText,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    ElevatedButton(
                      onPressed: () {
                        String text = todoController.text;

                        if (text.isEmpty) {
                          setState(() {
                            errorText = 'Este campo não pode estar vazio!';
                          });
                          return;
                        }

                        setState(
                          () {
                            Todo newTodo = Todo(
                              title: text,
                              dateTime: DateTime.now(),
                            );
                            todos.add(newTodo);
                            todoController.clear();
                            todoRepository.saveTodoList(todos);
                            errorText = null;
                          },
                        );
                      },
                      style: ElevatedButton.styleFrom(
                          primary: Colors.pinkAccent,
                          padding: EdgeInsets.all(14)),
                      child: Icon(Icons.add),
                    )
                  ],
                ),
                SizedBox(height: 20),
                Flexible(
                  child: ListView(
                    shrinkWrap: true,
                    children: [
                      for (Todo todo in todos)
                        TodolistItem(
                          todo: todo,
                          onDelete: onDelete,
                        ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child:
                          Text('Você possui ${todos.length} tarefas pendentes.'),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          showConfirmationDialog();
                        });
                      },
                      style: ElevatedButton.styleFrom(
                          primary: Colors.pinkAccent,
                          padding: EdgeInsets.all(14)),
                      child: Icon(
                        Icons.whatshot,
                        size: 30,
                      ),
                    )
                  ],
                ),
              ],
            ),
          ),
        ),
        backgroundColor: null,
      ),
    );
  }
}
