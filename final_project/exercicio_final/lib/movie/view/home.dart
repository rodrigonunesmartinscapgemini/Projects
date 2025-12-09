import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../controllers/items_controller.dart';
import '../models/model.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filteredMovies = ref.watch(filteredMoviesProvider);
    final queryNotifier = ref.read(searchQueryProvider.notifier);
    final allMovies = ref.watch(moviesProvider);
    final favoriteIds = ref.watch(favoritesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Final Exercise')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              _buildSearchBar(queryNotifier),
              const SizedBox(height: 24),
              _buildMoviesGrid(context, filteredMovies, favoriteIds),
              const SizedBox(height: 32),
              const Text(
                'Favorites',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              _buildFavoritesList(context, allMovies, favoriteIds),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar(StateController<String> queryNotifier) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        decoration: const InputDecoration(
            prefixIcon: Icon(Icons.search),
            hintText: 'Search movies...'),
        onChanged: (v) {
          queryNotifier.state = v;
        },
      ),
    );
  }

  Widget _buildMoviesGrid(BuildContext context,
      AsyncValue<List<Movie>> filteredMoviesAsync, List<String> favoriteIds) {
    return filteredMoviesAsync.when(
      data: (movies) {
        if (movies.isEmpty) {
          return const SizedBox.shrink();
        }
        return AlignedGridView.count(
          shrinkWrap: true,
          crossAxisCount: 2,
          mainAxisSpacing: 15,
          crossAxisSpacing: 15,
          itemCount: movies.length,
          itemBuilder: (context, index) {
            final movie = movies[index];
            final isFavorite = favoriteIds.contains(movie.id);
            return _buildMovieCard(context, movie, isFavorite);
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(
        child: Text('Error: $err'),
      ),
    );
  }

  Widget _buildFavoritesList(BuildContext context, AsyncValue<List<Movie>> allMoviesAsync,
      List<String> favoriteIds) {
    return allMoviesAsync.when(
      data: (allMovies) {
        final movieMap = {for (var movie in allMovies) movie.id: movie};
        
        final favorites = favoriteIds
            .map((id) => movieMap[id])
            .whereType<Movie>()
            .toList();

        if (favorites.isEmpty) {
          return Center(
            child: Text(
              'Add your favorite movies',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          );
        }

        return AlignedGridView.count(
          shrinkWrap: true,
          crossAxisCount: 2,
          mainAxisSpacing: 15,
          crossAxisSpacing: 15,
          itemCount: favorites.length,
          itemBuilder: (context, index) {
            return _buildMovieCard(context, favorites[index], true);
          },
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (err, stack) => const SizedBox.shrink(),
    );
  }

  Widget _buildMovieCard(BuildContext context, Movie movie, bool isFavorite) {
    return Consumer(
      builder: (context, ref, child) {
        final favoritesNotifier = ref.read(favoritesProvider.notifier);

        return Card(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          child: SizedBox(
            height: 280,
            child: Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 200,
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(8)),
                        color: Colors.grey[300],
                      ),
                      child: Image.asset(
                        'assets/movie_poster.jpg',
                        fit: BoxFit.cover,
                      ),
                    ),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          movie.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: () {
                      if (isFavorite) {
                        favoritesNotifier.state = favoritesNotifier.state
                            .where((id) => id != movie.id)
                            .toList();
                      } else {
                        favoritesNotifier.state = [
                          ...favoritesNotifier.state,
                          movie.id
                        ];
                      }
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        shape: BoxShape.circle,
                      ),
                      padding: const EdgeInsets.all(6),
                      child: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: Colors.red,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
