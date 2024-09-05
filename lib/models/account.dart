class Account {
  final int id;
  String title;
  String email;
  String password;

  Account({
    required this.id,
    required this.title,
    required this.email,
    required this.password,
  });

  Map toJson(Account account) {
    return {
      "Id": account.id,
      "Email": account.email,
      "Title": account.title,
      "Password": account.password,
    };
  }

  factory Account.fromObject(Map<String, Object?> account) {
    return Account(
        id: int.parse(account["Id"].toString()),
        title: account["Title"].toString(),
        email: account["Email"].toString(),
        password: account["Password"].toString());
  }
}
