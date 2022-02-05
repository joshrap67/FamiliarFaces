class CastResponse {
  late int id;
  String? name;
  String? characterName;
  String? profilePath;

  CastResponse.fromJson(Map<String, dynamic> json) {
    this.id = json['id'];
    this.name = json['name'];
    this.characterName = json['character'];
    this.profilePath = json['profile_path'];
  }

  CastResponse(this.id, this.name, this.characterName, this.profilePath);

  @override
  String toString() {
    return 'CastResponse{id: $id, name: $name, characterName: $characterName, profilePath: $profilePath}';
  }
}
