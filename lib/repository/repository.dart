import 'package:happyscan/dao/document_dao.dart';
import 'package:happyscan/models/document_details.dart';

class DocumentRepository {
  final todoDao = DocumentDao();

  Future getAllTodos({String? query}) => todoDao.getTodos(query: query);

  Future getSearchAllTodos({String? query}) =>
      todoDao.getSearchTodos(query: query);

  Future insertTodo(DocumentDetails todo) => todoDao.createTodo(todo);

  Future updateTodo(DocumentDetails todo) => todoDao.updateTodo(todo);

  Future deleteTodoById(int id) => todoDao.deleteTodo(id);

  //We are not going to use this in the demo
  Future deleteAllTodos() => todoDao.deleteAllTodos();
}
