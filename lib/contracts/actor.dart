import 'actor_credit.dart';

class Actor {
  int id;
  String? name;
  String? profileImagePath;
  DateTime? birthday;
  DateTime? deathDay;
  List<ActorCredit> credits = <ActorCredit>[];

  Actor(this.id, this.name, this.profileImagePath, this.birthday, this.deathDay, this.credits);

  @override
  String toString() {
    return 'Actor{id: $id, name: $name, profileImagePath: $profileImagePath, credits: $credits}';
  }
}
