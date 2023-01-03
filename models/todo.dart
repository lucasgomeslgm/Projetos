class Todo{

  Todo({required this.title, required this.dateTime});

  Todo.fromJson(Map<String, dynamic> json)
  : title = json['title'],
  dateTime =  DateTime.parse(json['date']);


  String title;
  DateTime dateTime;

  toJson(){
    return{
      'title': title,
      'dateTime': dateTime.toIso8601String(),
    };
  }

}