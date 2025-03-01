import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'api/imgur_api_client.dart';
import 'bloc/favorites/favorites_bloc.dart';
import 'bloc/favorites/favorites_event.dart';
import 'bloc/gallery/gallery_bloc.dart';
import 'bloc/gallery/gallery_event.dart';
import 'bloc/recent_searches/recent_searches_bloc.dart';
import 'bloc/recent_searches/recent_searches_event.dart';
import 'repositories/imgur_repository.dart';
import 'screens/favorites_screen.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize dependencies
  final sharedPreferences = await SharedPreferences.getInstance();
  final httpClient = http.Client();
  final imgurApiClient = ImgurApiClient(httpClient: httpClient);
  final imgurRepository = ImgurRepository(
    apiClient: imgurApiClient,
    sharedPreferences: sharedPreferences,
  );
  
  runApp(MyApp(repository: imgurRepository));
}

class MyApp extends StatelessWidget {
  final ImgurRepository repository;
  
  const MyApp({super.key, required this.repository});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<GalleryBloc>(
          create: (context) => GalleryBloc(repository: repository)
            ..add(const LoadGalleryImages()),
        ),
        BlocProvider<FavoritesBloc>(
          create: (context) => FavoritesBloc(repository: repository)
            ..add(LoadFavorites()),
        ),
        BlocProvider<RecentSearchesBloc>(
          create: (context) => RecentSearchesBloc(repository: repository)
            ..add(const LoadRecentSearches()),
        ),
      ],
      child: MaterialApp(
        title: 'Imgur Gallery',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => const HomeScreen(),
          '/favorites': (context) => const FavoritesScreen(),
        },
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
