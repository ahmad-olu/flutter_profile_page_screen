import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:http/http.dart' as http;

import 'package:profile_page_app/model.dart';
import 'package:profile_page_app/secret_key.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late Future<Profile> _profile;
  late Future<List<Photo>> _photos;

  @override
  void initState() {
    super.initState();
    _profile = _fetchProfile();
    _photos = _fetchPhotos();
  }

  Future<List<Photo>> _fetchPhotos() async {
    final response = await http.get(Uri.parse(
        'https://api.unsplash.com/photos/random?count=20&client_id=${EnvKey.accessKey}'));
    if (response.statusCode == 200) {
      final jsonList = jsonDecode(response.body) as List<dynamic>;
      final photos = jsonList.map((json) => Photo.fromJson(json)).toList();
      return photos;
    } else {
      throw Exception('Failed to fetch photos');
    }
  }

  Future<Profile> _fetchProfile() async {
    final response = await http.get(Uri.parse('https://randomuser.me/api/'));
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body)['results'][0];
      return Profile.fromJson(json);
    } else {
      throw Exception('Failed to fetch user data');
    }
  }

  // Future<Profile> _fetchProfile() async {
  //   final response = await http
  //       .get(Uri.parse('https://randomuser.me/api/'));
  //   if (response.statusCode == 200) {
  //     return Profile.fromJson(json.decode(response.body));
  //   } else {
  //     throw Exception('Failed to fetch profile');
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile Page'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Container(
                height: size.height * 0.3,
                decoration: BoxDecoration(color: Colors.blueGrey[200]),
                child: FutureBuilder<Profile>(
                  future: _profile,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      final profile = snapshot.data!;
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundImage:
                                CachedNetworkImageProvider(profile.picture),
                          ),
                          const SizedBox(height: 16),
                          Text(profile.name,
                              style: const TextStyle(
                                  fontSize: 24, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Text('Email: ${profile.email}'),
                          Text('Phone: ${profile.phone}'),
                        ],
                      );
                    } else if (snapshot.hasError) {
                      return Text('${snapshot.error}');
                    } else {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                  },
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: size.height * 0.6,
                child: FutureBuilder(
                  future: _photos,
                  builder: (context, snapshot) {
                    final val = snapshot.data;
                    if (snapshot.hasData) {
                      return MasonryGridView.count(
                        crossAxisCount: 4,
                        mainAxisSpacing: 8.0,
                        crossAxisSpacing: 8.0,
                        itemCount: val?.length ?? 0,
                        itemBuilder: (context, index) {
                          final photo = val?[index];
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      DetailScreen(photo: photo),
                                ),
                              );
                            },
                            child: Hero(
                              tag: photo!.id,
                              child: Image.network(
                                photo.imageUrl,
                                fit: BoxFit.cover,
                              ),
                            ),
                          );
                        },
                      );
                    } else if (snapshot.hasError) {
                      return Text('Failed to fetch photos');
                    } else {
                      return Center(child: CircularProgressIndicator());
                    }
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class DetailScreen extends StatelessWidget {
  final Photo photo;

  const DetailScreen({super.key, required this.photo});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(
        photo.description,
        maxLines: 3,
      )),
      body: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Hero(
          tag: photo.id,
          child: Image.network(
            photo.imageUrl,
            fit: BoxFit.cover,
            height: double.infinity,
            width: double.infinity,
            alignment: Alignment.center,
          ),
        ),
      ),
    );
  }
}
