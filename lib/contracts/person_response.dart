import 'person_credit_response.dart';

class PersonResponse {
  int id;
  String? name;
  String? profileImagePath;
  DateTime? birthday;
  DateTime? deathDay;
  List<PersonCreditResponse> credits = <PersonCreditResponse>[];

  PersonResponse(this.id, this.name, this.profileImagePath, this.birthday, this.deathDay, this.credits);

  @override
  String toString() {
    return 'PersonResponse{id: $id, name: $name, profileImagePath: $profileImagePath, credits: $credits}';
  }
}
