class CharacterModel {
  final int id;
  final String name;
  final String status;
  final String species;
  final String type;
  final String gender;
  final String origin;
  final String location;
  final String image;

  CharacterModel({
    required this.id,
    required this.name,
    required this.status,
    required this.species,
    required this.type,
    required this.gender,
    required this.origin,
    required this.location,
    required this.image,
  });

  factory CharacterModel.fromJson(Map<String, dynamic> json) {
    int parseInt(dynamic value) {
      if (value is int) return value;
      if (value is String) return int.tryParse(value) ?? 0;
      return 0;
    }

    String parseString(dynamic value) {
      if (value is String) return value;
      return '';
    }

    String parseNestedOrString(dynamic value) {
      if (value is Map) {
        final nested = value['name'];
        if (nested is String) return nested;
      }
      if (value is String) return value;
      return '';
    }

    return CharacterModel(
      id: parseInt(json['id']),
      name: parseString(json['name']),
      status: parseString(json['status']),
      species: parseString(json['species']),
      type: parseString(json['type']),
      gender: parseString(json['gender']),
      origin: parseNestedOrString(json['origin']),
      location: parseNestedOrString(json['location']),
      image: parseString(json['image']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'status': status,
      'species': species,
      'type': type,
      'gender': gender,
      'origin': origin,
      'location': location,
      'image': image,
    };
  }
}
