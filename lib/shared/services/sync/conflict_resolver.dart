import 'package:equatable/equatable.dart';

class ConflictResolver {
  T resolve<T extends Equatable>(T local, T remote) {
    final localUpdatedAt = _getUpdatedAt(local);
    final remoteUpdatedAt = _getUpdatedAt(remote);

    if (remoteUpdatedAt.isAfter(localUpdatedAt)) {
      return remote;
    }
    return local;
  }

  DateTime _getUpdatedAt(Equatable entity) {
    final props = entity.props;
    for (final prop in props) {
      if (prop is DateTime) {
        return prop;
      }
    }
    return DateTime.now();
  }
}
