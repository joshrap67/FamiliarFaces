class Cast {
  late int id;
  String? name;
  String? characterName;

  Cast.fromJson(Map<String, dynamic> json) {
    this.id = json['id'];
    this.name = json['name'];
    this.characterName = json['character_name'];
  }

  Cast(this.id, this.name, this.characterName);
}
