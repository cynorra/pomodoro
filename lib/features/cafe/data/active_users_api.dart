import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/data/services/remote_config_service.dart';

/// How many people are in a focus session right now: the "focusing now"
/// status documents that have not expired. Only people who turned on the
/// focus status are counted, and the count stops at [maxCounted] because the
/// Firestore rules cap list queries.
abstract class ActiveUsersApi {
  static const maxCounted = 30;

  Future<int> focusingNow();
}

class FirebaseActiveUsersApi implements ActiveUsersApi {
  @override
  Future<int> focusingNow() async {
    final snap = await FirebaseFirestore.instance
        .collection('presence')
        .where('endsAt', isGreaterThan: Timestamp.fromDate(DateTime.now()))
        .orderBy('endsAt')
        .limit(ActiveUsersApi.maxCounted)
        .count()
        .get();
    return snap.count ?? 0;
  }
}

final activeUsersApiProvider =
    Provider<ActiveUsersApi>((ref) => FirebaseActiveUsersApi());

/// The count to show in the cafe, or null when it should stay hidden: the
/// feature flag is off (the default), nobody is signed in, there is nobody to
/// count, or the query failed.
final activeUsersProvider = FutureProvider.autoDispose<int?>((ref) async {
  if (!RemoteConfigService.showActiveUsers) return null;
  if (FirebaseAuth.instance.currentUser == null) return null;
  try {
    final count = await ref.read(activeUsersApiProvider).focusingNow();
    return count > 0 ? count : null;
  } catch (_) {
    return null;
  }
});
