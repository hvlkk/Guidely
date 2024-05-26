import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:guidely/models/entities/session.dart';
import 'package:guidely/repositories/session_repository.dart';

final sessionRepositoryProvider = Provider((ref) => SessionRepository());

final sessionsStreamProvider = StreamProvider.autoDispose<List<Session>>(
  (ref) {
    final repository = ref.read(sessionRepositoryProvider);
    return repository.getSessionsStream();
  },
);