import 'person_credit_response.dart';

class PersonResponse {
  late int id;
  String? name;
  String? profileImagePath;
  String? birthday;
  String? deathDay;
  List<PersonCreditResponse> credits = <PersonCreditResponse>[];

  PersonResponse.fromJsonWithCombinedCredits(Map<String, dynamic> rawJson) {
    id = rawJson['id'];
    name = rawJson['name'];
    profileImagePath = rawJson['profile_path'];
    birthday = rawJson['birthday'];
    deathDay = rawJson['deathday'];
    var rawCredits = rawJson['combined_credits']['cast'] as List<dynamic>;
    for (var rawCredit in rawCredits) {
      credits.add(new PersonCreditResponse.fromJson(rawCredit));
    }
  }

  @override
  String toString() {
    return 'PersonResponse{id: $id, name: $name, profileImagePath: $profileImagePath, '
        'birthday: $birthday, deathDay: $deathDay, credits: $credits}';
  }
}
