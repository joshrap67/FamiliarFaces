import 'person_credit_response.dart';

class PersonResponse {
  int id;
  String? name;
  String? profileImagePath;
  List<PersonCreditResponse> credits = <PersonCreditResponse>[];

  PersonResponse(this.id, this.name, this.profileImagePath, this.credits);
}
