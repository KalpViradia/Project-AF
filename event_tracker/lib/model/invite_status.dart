enum InviteStatus {
  pending,
  accepted,
  declined,
  cancelled,
}

extension InviteStatusExtension on InviteStatus {
  String get value => toString().split('.').last;

  static InviteStatus fromString(String status) {
    final normalized = status.toLowerCase().replaceAll('invittestatus.', '');
    switch (normalized) {
      case 'accepted':
        return InviteStatus.accepted;
      case 'declined':
      case 'rejected': // Support alias
        return InviteStatus.declined;
      case 'cancelled':
        return InviteStatus.cancelled;
      case 'pending':
      default:
        return InviteStatus.pending;
    }
  }
}
