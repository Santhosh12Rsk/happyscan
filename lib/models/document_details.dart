import 'dart:typed_data';

class DocumentDetails {
  int? id;
  //description is the text we see on
  //main screen card text
  String? docName;

  String? createDate;

  int? docType;

  Uint8List? image;

  //isDone used to mark what Todo item is completed
  bool isDone = false;
  //When using curly braces { } we note dart that
  //the parameters are optional
  DocumentDetails(
      {this.id,
      this.docName,
      this.createDate,
      this.docType,
      this.image,
      this.isDone = false});
  factory DocumentDetails.fromDatabaseJson(Map<String, dynamic> data) =>
      DocumentDetails(
        //This will be used to convert JSON objects that
        //are coming from querying the database and converting
        //it into a Todo object
        id: data['id'],
        docName: data['docName'],
        createDate: data['createDate'],
        docType: data['docType'],
        image: data['image'],
        //Since sqlite doesn't have boolean type for true/false
        //we will 0 to denote that it is false
        //and 1 for true
        isDone: data['is_done'] == 0 ? false : true,
      );
  Map<String, dynamic> toDatabaseJson() => {
        //This will be used to convert Todo objects that
        //are to be stored into the datbase in a form of JSON
        "id": id,
        "docName": docName,
        "createDate": createDate,
        "docType": docType,
        "image": image,
        "is_done": isDone == false ? 0 : 1,
      };
}
