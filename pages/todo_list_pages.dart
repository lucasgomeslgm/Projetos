import 'package:flutter/material.dart';
import 'package:todo_list/repository/todo_repository.dart';

import '../models/todo.dart';
import '../widget/todo_list-item.dart';

class TodoListPage extends StatefulWidget {
  const TodoListPage({Key? key}) : super(key: key);

  @override
  State<TodoListPage> createState() => _TodoListPageState();
}

class _TodoListPageState extends State<TodoListPage> {
  final TextEditingController todoController = TextEditingController();
  final TodoRepository todoRepository = TodoRepository();

  List<Todo> todos = [];
  Todo? deletedTodo;
  int? deletedTodoPos;
  String? errorText;

  @override
  void initState() {
    super.initState();
    todoRepository.getTodoList().then((value) {
      setState(() {
        todos = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: todoController,
                        decoration: InputDecoration(
                          border: const OutlineInputBorder(),
                          labelText: 'Adicione uma tarefa aqui',
                          hintText: 'Ex.: Estudar Flutter',
                          errorText: errorText,
                          focusedBorder: const OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Color(0xff00d7f3),
                              width: 3,
                            ),
                          ),
                          labelStyle: const TextStyle(
                            color: Color(0xff00d7f3),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: (){
                        String text = todoController.text;
                        if (text.isEmpty) {
                          setState(() {
                            errorText = 'O título não pode ser vazio!';
                          });
                          return;
                        }

                        setState(() {
                          Todo newTodo = Todo(
                            title: text,
                            dateTime: DateTime.now(),
                          );
                          todos.add(newTodo);
                          errorText = null;
                        });
                        todoController.clear();
                        todoRepository.saveTodoList(todos);

                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff010301),
                        padding: const EdgeInsets.all(20),
                      ),
                      child: const Icon(
                        Icons.add,
                        size: 20,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Flexible(
                  child: ListView(
                    shrinkWrap: true,
                    children: [
                      for(Todo todo in todos)
                      TodoListItem(
                        todo: todo,
                        onDelete: onDelete,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(child: Text('${todos.length} Tarefas pendentes')),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: showDeleteTodoConfirmation,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff010301),
                        padding: const EdgeInsets.all(20),
                      ),
                      child: const Text('Limpar tudo'),
                      ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
  void onDelete(Todo todo){
    deletedTodo = todo;
    deletedTodoPos = todos.indexOf(todo);
    setState(() {
      todos.remove(todo);
    });
    todoRepository.saveTodoList(todos);


    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Tarefa ${todo.title} foi removida com sucesso',
      style: TextStyle(color: Colors.black),),
      backgroundColor: Colors.white,
      action: SnackBarAction(
        label: 'Desfazer',
        onPressed: (){
          setState(() {
            todos.insert(deletedTodoPos!, deletedTodo!);
          });
          todoRepository.saveTodoList(todos);

        },
      ),
    ),
    );
  }

  void showDeleteTodoConfirmation(){
    showDialog(context: context, builder: (context) => AlertDialog(
      title: Text('Limpar tudo?'),
      content: Text('Você limpará todas as tarefas!'),
      actions: [
        TextButton(onPressed: (){Navigator.of(context).pop(); }, child: Text('Canelar')),
        TextButton(onPressed: (){Navigator.of(context).pop();deleteAllTodos();}, child: Text('Limpar tudo'))
      ],
    ));
  }
  void deleteAllTodos(){
    setState(() {
      todos.clear();
    });
    todoRepository.saveTodoList(todos);

  }
}

