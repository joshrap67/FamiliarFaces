class CastResponse {
  late int id;
  String? name;
  String? characterName;
  String? profilePath;

  CastResponse(this.id, this.name, this.characterName, this.profilePath);

  @override
  String toString() {
    return 'CastResponse{id: $id, name:$name, characterName: $characterName, profilePath: $profilePath}';
  }
}
