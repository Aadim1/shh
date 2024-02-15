import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shh/supabase.dart';

part 'home_provider.g.dart';

@riverpod
class GetRecentMemoriesRange extends _$GetRecentMemoriesRange {
  @override
  List<int> build() {
    return [0, 20];
  }

  void reset() {
    state = [0, 20];
  }

  void add() {
    state = [state[0] + 20, state[1] + 20];
  }
}

@riverpod
Future<List<Map<String, dynamic>>> getRecentService(
    GetRecentServiceRef ref) async {
  final rangeProvider = ref.watch(getRecentMemoriesRangeProvider);
  final first = rangeProvider[0];
  final second = rangeProvider[1];

  return await supabase
      .from("memory")
      .select(
          "id, memory_name,date_, description, is_favorite, memory_pictures(storage_path), memory_people(memory_id, people_id)")
      .range(first, second);
}
