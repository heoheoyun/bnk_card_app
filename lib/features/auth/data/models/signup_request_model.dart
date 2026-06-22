class SignupRequestModel {
  final String  email;
  final String  password;
  final String  name;
  final String  phone;
  final List<int> agreedTermsIds;
  final String  residentFront;
  final String  genderCode;
  final String  address;
  final String? birthDate;
  final bool?   marketingAgree;
  final String? job;
  final String? incomeLevelCode;
  final int?    creditScore;

  const SignupRequestModel({
    required this.email,
    required this.password,
    required this.name,
    required this.phone,
    required this.agreedTermsIds,
    required this.residentFront,
    required this.genderCode,
    required this.address,
    this.birthDate,
    this.marketingAgree,
    this.job,
    this.incomeLevelCode,
    this.creditScore,
  });

  Map<String, dynamic> toJson() => {
    'email':          email,
    'password':       password,
    'name':           name,
    'phone':          phone,
    'agreedTermsIds': agreedTermsIds,
    'residentFront':  residentFront,
    'genderCode':     genderCode,
    'address':        address,
    if (birthDate      != null) 'birthDate':      birthDate,
    if (marketingAgree != null) 'marketingAgree': marketingAgree,
    if (job            != null) 'job':            job,
    if (incomeLevelCode!= null) 'incomeLevelCode':incomeLevelCode,
    if (creditScore    != null) 'creditScore':    creditScore,
  };
}