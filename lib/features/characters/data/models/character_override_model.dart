class CharacterOverride {
  final int id;
  final String? name;
  final String? status;
  final String? species;
  final String? type;
  final String? gender;
  final String? origin;
  final String? location;

  CharacterOverride({
    required this.id,
    this.name,
    this.status,
    this.species,
    this.type,
    this.gender,
    this.origin,
    this.location,
  });

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
    };
  }

  factory CharacterOverride.fromJson(Map<String, dynamic> json) {
    return CharacterOverride(
      id: json['id'],
      name: json['name'],
      status: json['status'],
      species: json['species'],
      type: json['type'],
      gender: json['gender'],
      origin: json['origin'],
      location: json['location'],
    );
  }
}