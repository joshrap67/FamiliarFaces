class Cast {
  late int id;
  String? name;
  String? characterName;
  String? profilePath;
  // todo order?

  Cast.fromJson(Map<String, dynamic> json) {
    this.id = json['id'];
    this.name = json['name'];
    this.characterName = json['character'];
    this.profilePath = json['profile_path'];
  }

  Cast(this.id, this.name, this.characterName, this.profilePath);
}
