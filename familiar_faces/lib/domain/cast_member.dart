class CastMember {
  late int id;
  String? name;
  String? characterName;
  String? profilePath;

  CastMember(this.id, this.name, this.characterName, this.profilePath);

  @override
  String toString() {
    return 'CastMember{id: $id, name: $name, characterName: $characterName, profilePath: $profilePath}';
  }
}
