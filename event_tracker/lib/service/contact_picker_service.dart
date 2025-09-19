import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/foundation.dart';

class ContactPickerService {
  static Future<bool> requestContactsPermission() async {
    if (kIsWeb) {
      // Contacts are not supported on web
      return false;
    }
    
    final status = await Permission.contacts.request();
    return status.isGranted;
  }

  static Future<List<Contact>> getContacts() async {
    if (kIsWeb) {
      // Return empty list for web
      return [];
    }
    
    final hasPermission = await requestContactsPermission();
    if (!hasPermission) {
      throw Exception('Contacts permission denied');
    }

    try {
      final contacts = await FlutterContacts.getContacts(
        withProperties: true,
        withPhoto: false,
      );
      
      // Filter contacts that have phone numbers
      return contacts.where((contact) => 
        contact.phones.isNotEmpty
      ).toList();
    } catch (e) {
      throw Exception('Failed to load contacts: $e');
    }
  }

  static Future<Contact?> pickContact() async {
    if (kIsWeb) {
      // Contact picker not supported on web
      return null;
    }
    
    final hasPermission = await requestContactsPermission();
    if (!hasPermission) {
      throw Exception('Contacts permission denied');
    }

    try {
      final contact = await FlutterContacts.openExternalPick();
      return contact;
    } catch (e) {
      throw Exception('Failed to pick contact: $e');
    }
  }

  static String? getFirstPhoneNumber(Contact contact) {
    if (contact.phones.isNotEmpty) {
      return contact.phones.first.number.replaceAll(RegExp(r'[^\d+]'), '');
    }
    return null;
  }

  static String getDisplayName(Contact contact) {
    return contact.displayName.isNotEmpty ? contact.displayName : 'Unknown Contact';
  }
}
