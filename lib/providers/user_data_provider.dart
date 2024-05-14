import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:guidely/repositories/user_repository.dart';

final userRepositoryProvider = Provider((ref) => UserRepository());

final userDataProvider = FutureProvider.autoDispose(
  (ref) async {
    final repository = ref.read(userRepositoryProvider);
    return await repository.getUserData();
  },
);
