import 'dart:async';

import 'package:happyscan/models/document_details.dart';
import 'package:happyscan/repository/repository.dart';

class DocumentBloc {
  //Get instance of the Repository
  final _todoRepository = DocumentRepository();

  //Stream controller is the 'Admin' that manages
  //the state of our stream of data like adding
  //new data, change the state of the stream
  //and broadcast it to observers/subscribers
  final _todoController = StreamController<List<DocumentDetails>>.broadcast();

  get todos => _todoController.stream;

  DocumentBloc() {
    getTodos();
  }

  getTodos({String? query}) async {
    //sink is a way of adding data reactively to the stream
    //by registering a new event
    _todoController.sink.add(await _todoRepository.getAllTodos(query: query));
  }

  getSearchTodos({String? query}) async {
    //sink is a way of adding data reactively to the stream
    //by registering a new event
    _todoController.sink
        .add(await _todoRepository.getSearchAllTodos(query: query));
  }

  addTodo(DocumentDetails todo) async {
    await _todoRepository.insertTodo(todo);
    getTodos();
  }

  updateTodo(DocumentDetails todo) async {
    await _todoRepository.updateTodo(todo);
    getTodos();
  }

  deleteTodoById(int id) async {
    _todoRepository.deleteTodoById(id);
    getTodos();
  }

  dispose() {
    _todoController.close();
  }
}
