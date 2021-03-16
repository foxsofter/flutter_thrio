class People {
  People({required this.name, required this.age, required this.sex});

  People.fromJson(Map<String, dynamic> json) {
    name = json['name'] as String; // ignore: avoid_as
    age = json['age'] as int; // ignore: avoid_as
    sex = json['sex'] as String; // ignore: avoid_as
  }

  late final String name;
  late final int age;
  late final String sex;

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['name'] = name;
    data['age'] = age;
    data['sex'] = sex;
    return data;
  }
}
