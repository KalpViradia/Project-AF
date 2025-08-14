import '../utils/import_export.dart';

enum InviteStatus {
  pending,
  accepted,
  declined,
  cancelled,
}

extension InviteStatusExtension on InviteStatus {
  String get value {
    switch (this) {
      case InviteStatus.pending:
        return InviteStatus.pending.name;
      case InviteStatus.accepted:
        return InviteStatus.accepted.name;
      case InviteStatus.declined:
        return InviteStatus.declined.name;
      case InviteStatus.cancelled:
        return InviteStatus.cancelled.name;
    }
  }

  static InviteStatus fromString(String status) {
    switch (status) {
      case 'accepted':
        return InviteStatus.accepted;
      case 'declined':
        return InviteStatus.declined;
      case 'cancelled':
        return InviteStatus.cancelled;
      case 'pending':
      default:
        return InviteStatus.pending;
    }
  }
}
