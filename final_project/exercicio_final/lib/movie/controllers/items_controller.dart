import 'package:exercicio_final/movie/repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/model.dart';

class MoviesController extends StateNotifier<AsyncValue<List<Movie>>> {
  final MoviesRepository repository = MoviesRepository();

  MoviesController() : super(const AsyncValue.loading()) {
    fetchMovies();
  }

  Future<void> fetchMovies() async {
    try {
      state = const AsyncValue.loading();
      final movies = await repository.fetchMovies();
      state = AsyncValue.data(movies);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  List<Movie> filterMovies(List<Movie> movies, String query) {
    if (query.isEmpty) return movies;
    final q = query.toLowerCase();
    final filtered = movies
        .where((m) =>
            m.title.toLowerCase().contains(q))
        .toList();
    return filtered;
  }

  Movie? getMovieById(String id, List<Movie> movies) {
    try {
      return movies.firstWhere((movie) => movie.id == id);
    } catch (e) {
      return null;
    }
  }
}

final moviesProvider = StateNotifierProvider<MoviesController, AsyncValue<List<Movie>>>((ref) {
  return MoviesController();
});

final searchQueryProvider = StateProvider<String>((ref) => '');

final filteredMoviesProvider = Provider<AsyncValue<List<Movie>>>((ref) {
  final moviesAsync = ref.watch(moviesProvider);
  final query = ref.watch(searchQueryProvider);
  final controller = ref.watch(moviesProvider.notifier);

  return moviesAsync.when(
    data: (movies) {
      final filtered = controller.filterMovies(movies, query);
      return AsyncValue.data(filtered);
    },
    loading: () => const AsyncValue.loading(),
    error: (err, stack) => AsyncValue.error(err, stack),
  );
});

final favoritesProvider = StateProvider<List<String>>((ref) => []);
