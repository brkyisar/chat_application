class ChatUser {
  ChatUser({
    required this.image,
    required this.olusturulmaTarihi,
    required this.onlineMi,
    required this.sonGorulme,
    required this.about,
    required this.name,
    required this.id,
    required this.pushToken,
    required this.email,
  });
  late String image;
  late String olusturulmaTarihi;
  late bool onlineMi;
  late String sonGorulme;
  late String about;
  late String name;
  late String id;
  late String pushToken;
  late String email;

  ChatUser.fromJson(Map<String, dynamic> json) {
    image = json['image'] ?? '';
    olusturulmaTarihi = json['olusturulma_tarihi'] ?? '';
    onlineMi = json['online_mı'] ?? '';
    sonGorulme = json['son_gorulme'] ?? '';
    about = json['about'] ?? '';
    name = json['name'] ?? '';
    id = json['id'] ?? '';
    pushToken = json['push_token'] ?? '';
    email = json['email'] ?? '';
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['image'] = image;
    data['olusturulma_tarihi'] = olusturulmaTarihi;
    data['online_mı'] = onlineMi;
    data['son_gorulme'] = sonGorulme;
    data['about'] = about;
    data['name'] = name;
    data['id'] = id;
    data['push_token'] = pushToken;
    data['email'] = email;
    return data;
  }
}
