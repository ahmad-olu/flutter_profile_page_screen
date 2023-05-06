class Profile {
  final String id;
  final String name;
  String picture;
  //final String? username;
  final String email;
  final String phone;

  Profile({
    required this.id,
    required this.name,
    required this.picture,
    //this.username,
    required this.email,
    required this.phone,
  });

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      id: json['login']['uuid'],
      name: json['name']['first'] + ' ' + json['name']['last'],
      //username: json['username'],
      email: json['email'],
      phone: json['phone'],
      picture: json['picture']['large'],
    );
  }
}

class Photo {
  final String id;
  final String description;
  final String imageUrl;
  final String? thumb;

  Photo(
      {required this.id,
      required this.description,
      required this.imageUrl,
      required this.thumb});

  factory Photo.fromJson(Map<String, dynamic> json) {
    return Photo(
        id: json['id'],
        description: json['description'] ?? '',
        imageUrl: json['urls']['small'],
        thumb: json['urls']['thumb']);
  }
}
