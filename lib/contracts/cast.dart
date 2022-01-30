class Cast {
  late int id;
  String? name;
  String? characterName;
  String? profilePath;

  Cast(this.id, this.name, this.characterName, this.profilePath);

  @override
  String toString() {
    return 'Cast{id: $id, name: $name, characterName: $characterName, profilePath: $profilePath}';
  }
}
