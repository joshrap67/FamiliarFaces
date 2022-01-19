import 'person_credit.dart';

class Person {
  int id = -1;
  String? name;
  String? profileImagePath;
  List<PersonCredit> credits = <PersonCredit>[];

  Person.fromJsonWithCombinedCredits(Map<String, dynamic> rawJson) {
    id = rawJson['id'];
    name = rawJson['name'];
    profileImagePath = rawJson['profile_image_path'];
    var rawCredits = rawJson['combined_credits']['cast'] as List<dynamic>;
    for (var rawCredit in rawCredits) {
      credits.add(new PersonCredit.fromJson(rawCredit));
    }
  }

  @override
  String toString() {
    return 'Id= $id ** Name= $name ** profileImagePath=$profileImagePath ** credits=$credits';
  }
}
