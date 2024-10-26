import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:gap/gap.dart';
import 'package:movies_list/models/movies.dart';
import 'package:http/http.dart' as http;

class MovieSearchScreen extends StatefulWidget {
  const MovieSearchScreen({super.key});

  @override
  State<MovieSearchScreen> createState() => _MovieSearchScreenState();
}

class _MovieSearchScreenState extends State<MovieSearchScreen> {
  final nameC = TextEditingController();
  final StreamController<dynamic> streamController = StreamController<dynamic>();
  Stream<dynamic>? stream;

  Movie? movie;

  searchMovie({required String movieName}) async {
    streamController.add('loading');

    final url =
        'https://www.omdbapi.com/?t=$movieName&plot=full&apikey=94e188aa';
    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);

        if (jsonResponse['Response'] == 'False') {
          streamController.add('Movie Not Found');
        } else {
          movie = Movie.fromJson(jsonResponse);
          streamController.add(movie);
        }
      } else {
        streamController.add('Something went wrong');
      }
    } catch (e) {
      streamController.add('Something went wrong');
    }
  }

  @override
  void initState() {
    stream = streamController.stream;
    streamController.add('empty');
    super.initState();
  }

  @override
  void dispose() {
    streamController.close();
    nameC.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: const Text('Movie Search'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: nameC,
              decoration: const InputDecoration(
                hintText: 'Movie Name',
                border: OutlineInputBorder(),
              ),
            ),
            const Gap(8),
            Row(
              children: [
                Expanded(
                    child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red, foregroundColor: Colors.white),
                  onPressed: () {
                    nameC.clear();
                    streamController.add('empty');
                  },
                  label: const Text('Clear'),
                  icon: const Icon(Icons.cancel),
                )),
                const Gap(16),
                Expanded(
                    child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green, foregroundColor: Colors.white),
                  onPressed: () {
                    final movieName = nameC.text.trim();

                    if (movieName.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text('Please provide movie name')));
                    } else {
                      searchMovie(movieName: movieName);
                    }
                  },
                  label: const Text('Search'),
                  icon: const Icon(Icons.search),
                )),
              ],
            ),
            Expanded(
              child: StreamBuilder<dynamic>(
                stream: stream,
                builder: (context, snapshot) {
                  if (snapshot.data == 'loading') {
                    return const SpinKitFadingCircle(
                      color: Colors.amber,
                    );
                  }

                  if (snapshot.data == 'empty') {
                    return const Text('Please provide movie name');
                  }

                  if (snapshot.data == 'Movie Not Found') {
                    return const Text('Movie Not Found');
                  }

                  if (snapshot.data == 'Something went wrong') {
                    return const Text('Something went wrong. Please try again.');
                  }

                  if (movie != null) {
                    return SingleChildScrollView(
                      child: Column(
                        children: [
                          Image.network(
                            movie!.poster!,
                            width: 300,
                            height: 300,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(Icons.error, size: 100);
                            },
                          ),
                          const Gap(10),
                          Text(
                            movie!.title!,
                            style: const TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          const Gap(10),
                          Text('Actors: ${movie!.actors!}'),
                          Text('Year: ${movie!.year!}'),
                          Text('Genre: ${movie!.genre!}'),
                          const Gap(10),
                          const Text('Plot:', style: TextStyle(fontWeight: FontWeight.bold)),
                          Text(movie!.plot!),
                        ],
                      ),
                    );
                  }
                  return const Text('Start your search!');
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
