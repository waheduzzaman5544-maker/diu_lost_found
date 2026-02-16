class Item {
  final String id;
  final String type; // LOST / FOUND
  final String title;
  final String description;
  final String location;
  final String createdBy;
  final int createdAt;

  Item({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.location,
    required this.createdBy,
    required this.createdAt,
  
  });

  Map<String, dynamic> toMap() {
    return {
      "type": type,
      "title": title,
      "description": description,
      "location": location,
      "createdBy": createdBy,
      "createdAt": createdAt,
    
    };
  }
}
