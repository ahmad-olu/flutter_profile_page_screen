import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:profile_page_app/model.dart';
import 'package:profile_page_app/secret_key.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _searchController = TextEditingController();
  late Future<List<Photo>> _photos;

  @override
  void initState() {
    super.initState();
    _searchController.text = 'cat';
    _photos = _fetchPhotos(_searchController.text);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<List<Photo>> _fetchPhotos(String query) async {
    final response = await http.get(Uri.parse(
        'https://api.unsplash.com/search/photos?query=$query&client_id=${EnvKey.accessKey}'));
    if (response.statusCode == 200) {
      final jsonMap = jsonDecode(response.body) as Map<String, dynamic>;
      final jsonList = jsonMap['results'] as List<dynamic>;
      final photos = jsonList.map((json) => Photo.fromJson(json)).toList();
      return photos;
    } else {
      throw Exception('Failed to fetch photos');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
                hintText: 'Search for images',
                filled: true,
                fillColor: Colors.blueGrey[700]),
            onSubmitted: (query) {
              setState(() {
                _photos = _fetchPhotos(query);
              });
            },
          ),
        ),
      ),
      body: FutureBuilder<List<Photo>>(
        future: _photos,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 8.0,
                mainAxisSpacing: 8.0,
                childAspectRatio: 0.8,
              ),
              itemCount: snapshot.data?.length ?? 0,
              itemBuilder: (context, index) {
                final photo = snapshot.data?[index];
                if (photo == null) {
                  return const Center(
                    child: Text('No Image'),
                  );
                }
                return Image.network(
                  photo.thumb!,
                  fit: BoxFit.cover,
                );
              },
            );
          } else if (snapshot.hasError) {
            return const Text('Failed to fetch photos');
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
