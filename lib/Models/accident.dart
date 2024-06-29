class Accident {
  late String id;
  late String titre;
  late String description;
  late String startDate;

  Accident(
      {required this.id, required this.titre, required this.description, required this.startDate});

  Accident.fromMap(Map<dynamic, dynamic> map, String id) {
    this.id = id;
    titre = map['titre'];
    description = map['description'];
    startDate = map['startDate'];
  }

}

