import 'person_credit.dart';

class Person {
  late int id;
  String? name;
  String? profileImagePath;
  String? birthday;
  String? deathDay;
  List<PersonCredit> credits = <PersonCredit>[];

  Person.fromJsonWithCombinedCredits(Map<String, dynamic> rawJson) {
    id = rawJson['id'];
    name = rawJson['name'];
    profileImagePath = rawJson['profile_path'];
	birthday = rawJson['birthday'];
	deathDay = rawJson['deathday'];
    var rawCredits = rawJson['combined_credits']['cast'] as List<dynamic>;
    for (var rawCredit in rawCredits) {
      credits.add(new PersonCredit.fromJson(rawCredit));
    }
  }

  @override
  String toString() {
    return 'Person{id: $id, name: $name, profileImagePath: $profileImagePath, credits: $credits}';
  }
}
