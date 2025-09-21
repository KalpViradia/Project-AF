import '../utils/import_export.dart';
import '../service/contact_picker_service.dart';

class InviteesListPage extends StatefulWidget {
  const InviteesListPage({super.key});

  @override
  State<InviteesListPage> createState() => _InviteesListPageState();
}

class _InviteesListPageState extends State<InviteesListPage> {
  final InviteController _inviteController = Get.find<InviteController>();
  final TextEditingController _phoneController = TextEditingController();
  List<UserModel> _savedInvitees = [];
  bool _loadingSaved = true;
  
  void _applySearch(String raw) {
    final v = raw.trim();
    _inviteController.searchQuery.value = v;
  }

  @override
  void initState() {
    super.initState();
    _loadSavedInvitees();
  }

  Future<void> _loadSavedInvitees() async {
    final currentUser = Get.find<AuthController>().currentUser.value;
    // Try backend first
    if (currentUser != null) {
      try {
        final backendUsers = await Get.find<SavedInviteesService>()
            .getSavedInvitees(currentUser.userId);
        setState(() {
          _savedInvitees = backendUsers.where((u) => u.userId != currentUser.userId).toList();
          _loadingSaved = false;
        });
        return;
      } catch (_) {
        // fallback
      }
    }

    // Local fallback
    final users = await StorageService.getInvitees();
    setState(() {
      if (currentUser != null) {
        _savedInvitees = users.where((u) => u.userId != currentUser.userId).toList();
      } else {
        _savedInvitees = users;
      }
      _loadingSaved = false;
    });
  }

  Future<void> _addToSaved(UserModel user) async {
    final currentUser = Get.find<AuthController>().currentUser.value;
    bool success = false;
    if (currentUser != null) {
      try {
        success = await Get.find<SavedInviteesService>()
            .addSavedInvitee(currentUser.userId, user.userId);
      } catch (_) {}
    }
    if (!success) {
      await StorageService.addInvitee(user);
    }
    await _loadSavedInvitees();
    ModernSnackbar.success(title: 'Added', message: 'Invitee added to your list');
  }

  Future<void> _removeFromSaved(UserModel user) async {
    final currentUser = Get.find<AuthController>().currentUser.value;
    bool success = false;
    if (currentUser != null) {
      try {
        success = await Get.find<SavedInviteesService>()
            .removeSavedInvitee(currentUser.userId, user.userId);
      } catch (_) {}
    }
    if (!success) {
      await StorageService.removeInvitee(user.userId);
    }
    await _loadSavedInvitees();
    ModernSnackbar.success(title: 'Removed', message: 'Invitee removed from your list');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Invitees'),
      ),
      body: Column(
        children: [
          // Search section
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _phoneController,
                    decoration: InputDecoration(
                      labelText: 'Search by Phone Number',
                      hintText: 'Enter phone number to search',
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.phone),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.search),
                        onPressed: () => _applySearch(_phoneController.text.trim()),
                      ),
                    ),
                    keyboardType: TextInputType.phone,
                    onChanged: (v) => _applySearch(v),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: () async {
                    try {
                      final contact = await ContactPickerService.pickContact();
                      if (contact == null) return;
                      final phone = ContactPickerService.getFirstPhoneNumber(contact);
                      if (phone != null) {
                        _phoneController.text = phone;
                        _inviteController.searchQuery.value = phone.trim();
                      }
                    } catch (e) {
                      ModernSnackbar.error(title: 'Contacts', message: e.toString());
                    }
                  },
                  icon: const Icon(Icons.contacts),
                  label: const Text('Contacts'),
                ),
              ],
            ),
          ),

          // Search Results
          Obx(() {
            if (_inviteController.isLoading.value) {
              return const Expanded(child: Center(child: CircularProgressIndicator()));
            }
            if (_inviteController.searchQuery.value.isNotEmpty && _inviteController.searchResults.isEmpty) {
              return const Expanded(child: Center(child: Text('No users found')));
            }
            if (_inviteController.searchQuery.value.isEmpty) {
              return _buildSavedInvitees(theme);
            }
            return Expanded(
              child: ListView.builder(
                itemCount: _inviteController.searchResults.length,
                itemBuilder: (context, index) {
                  final user = _inviteController.searchResults[index];
                  final alreadySaved = _savedInvitees.any((u) => u.userId == user.userId);
                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: theme.colorScheme.primary,
                        child: Text(user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                            style: TextStyle(color: theme.colorScheme.onPrimary)),
                      ),
                      title: Text(user.name),
                      subtitle: Text((user.phone ?? user.email)),
                      trailing: ElevatedButton.icon(
                        onPressed: alreadySaved ? null : () => _addToSaved(user),
                        icon: const Icon(Icons.playlist_add),
                        label: Text(alreadySaved ? 'Added' : 'Add'),
                      ),
                    ),
                  );
                },
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildSavedInvitees(ThemeData theme) {
    if (_loadingSaved) {
      return const Expanded(child: Center(child: CircularProgressIndicator()));
    }
    if (_savedInvitees.isEmpty) {
      return const Expanded(
        child: Center(
          child: Text('Your invitees list is empty. Search by phone or import from contacts.'),
        ),
      );
    }
    return Expanded(
      child: ListView.builder(
        itemCount: _savedInvitees.length,
        itemBuilder: (context, index) {
          final user = _savedInvitees[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: theme.colorScheme.primary,
                child: Text(user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                    style: TextStyle(color: theme.colorScheme.onPrimary)),
              ),
              title: Text(user.name),
              subtitle: Text((user.phone ?? user.email)),
              trailing: IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                onPressed: () => _removeFromSaved(user),
                tooltip: 'Remove',
              ),
            ),
          );
        },
      ),
    );
  }
}
