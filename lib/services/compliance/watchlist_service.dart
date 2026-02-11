import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../utils/logger.dart';

/// Manages internal watchlists for compliance monitoring.
class WatchlistService {
  static const _tag = 'Watchlist';
  final AppLogger _log = AppLogger(_tag);
  final Set<String> _watchedUsers = {};
  final Set<String> _watchedAddresses = {};

  void addUser(String userId) {
    _watchedUsers.add(userId);
    _log.debug('User added to watchlist: $userId');
  }

  void addAddress(String address) {
    _watchedAddresses.add(address);
  }

  bool isUserWatched(String userId) => _watchedUsers.contains(userId);
  bool isAddressWatched(String address) => _watchedAddresses.contains(address);

  void removeUser(String userId) => _watchedUsers.remove(userId);
  void removeAddress(String address) => _watchedAddresses.remove(address);

  int get watchedUserCount => _watchedUsers.length;
  int get watchedAddressCount => _watchedAddresses.length;
}

final watchlistServiceProvider = Provider<WatchlistService>((ref) {
  return WatchlistService();
});
