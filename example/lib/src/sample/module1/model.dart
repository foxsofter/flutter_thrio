class People {
  People({this.name, this.age, this.sex});

  People.fromJson(Map<String, dynamic> json) {
    name = json['name'] as String; // ignore: avoid_as
    age = json['age'] as int; // ignore: avoid_as
    sex = json['sex'] as String; // ignore: avoid_as
  }

  String name;
  int age;
  String sex;

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['name'] = name;
    data['age'] = age;
    data['sex'] = sex;
    return data;
  }
}
