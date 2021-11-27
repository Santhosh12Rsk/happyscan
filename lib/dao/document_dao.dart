import 'package:happyscan/database/database.dart';
import 'package:happyscan/models/document_details.dart';

class DocumentDao {
  final dbProvider = DatabaseProvider.dbProvider;

  //Adds new Todo records
  Future<int> createTodo(DocumentDetails todo) async {
    final db = await dbProvider.database;
    var result = db.insert(documentTABLE, todo.toDatabaseJson());
    return result;
  }

  //Get All Todo items
  //Searches if query string was passed
  Future<List<DocumentDetails>> getTodos(
      {List<String>? columns, String? query}) async {
    final db = await dbProvider.database;

    List<Map<String, dynamic>> result = [];
    if (query != null) {
      if (query.isNotEmpty) {
        result = await db.query(documentTABLE,
            columns: columns,
            where: 'createDate LIKE ?',
            whereArgs: ["%$query%"]);
        //print('result $result');
      }
    } else {
      result = await db.query(documentTABLE, columns: columns);
    }

    List<DocumentDetails> todos = result.isNotEmpty
        ? result.map((item) => DocumentDetails.fromDatabaseJson(item)).toList()
        : [];
    return todos;
  }

  Future<List<DocumentDetails>> getTodoById(
      {List<String>? columns, String? query}) async {
    final db = await dbProvider.database;

    List<Map<String, dynamic>> result = [];
    if (query != null) {
      if (query.isNotEmpty) {
        result = await db.query(documentTABLE,
            columns: columns, where: 'id LIKE ?', whereArgs: ["%$query%"]);
      }
    } else {
      result = await db.query(documentTABLE, columns: columns);
    }

    List<DocumentDetails> todos = result.isNotEmpty
        ? result.map((item) => DocumentDetails.fromDatabaseJson(item)).toList()
        : [];
    return todos;
  }

  Future<List<DocumentDetails>> getSearchTodos(
      {List<String>? columns, String? query}) async {
    final db = await dbProvider.database;

    List<Map<String, dynamic>> result = [];
    if (query != null) {
      if (query.isNotEmpty) {
        result = await db.query(documentTABLE,
            columns: columns, where: 'docName LIKE ?', whereArgs: ["%$query%"]);
        //print('result $result');
      }
    } else {
      result = await db.query(documentTABLE, columns: columns);
    }

    List<DocumentDetails> todos = result.isNotEmpty
        ? result.map((item) => DocumentDetails.fromDatabaseJson(item)).toList()
        : [];
    return todos;
  }

  //Update Todo record
  Future<int> updateTodo(DocumentDetails todo) async {
    final db = await dbProvider.database;

    var result = await db.update(documentTABLE, todo.toDatabaseJson(),
        where: "id = ?", whereArgs: [todo.id]);

    return result;
  }

  //Delete Todo records
  Future<int> deleteTodo(int id) async {
    final db = await dbProvider.database;
    var result =
        await db.delete(documentTABLE, where: 'id = ?', whereArgs: [id]);

    return result;
  }

  //We are not going to use this in the demo
  Future deleteAllTodos() async {
    final db = await dbProvider.database;
    var result = await db.delete(
      documentTABLE,
    );

    return result;
  }
}
