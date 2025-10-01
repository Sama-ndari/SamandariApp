import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:azlistview/azlistview.dart';
import 'package:samapp/models/contact.dart';
import 'package:samapp/services/contact_service.dart';
import 'package:samapp/screens/add_edit_contact_screen.dart';
import 'package:samapp/screens/import_contacts_screen.dart';

class ContactsScreen extends StatefulWidget {
  const ContactsScreen({Key? key}) : super(key: key);

  @override
  _ContactsScreenState createState() => _ContactsScreenState();
}

class _ContactsScreenState extends State<ContactsScreen> {
  final ContactService _contactService = ContactService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contacts'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: ContactSearchDelegate(_contactService),
              );
            },
          ),
          // IconButton(
          //   icon: const Icon(Icons.import_export),
          //   onPressed: () {
          //     Navigator.of(context).push(
          //       MaterialPageRoute(
          //         builder: (context) => const ImportContactsScreen(),
          //       ),
          //     );
          //   },
          // ),
        ],
      ),
      body: ValueListenableBuilder(
        valueListenable: Hive.box<Contact>('contacts').listenable(),
        builder: (context, Box<Contact> box, _) {
          final allContacts = box.values.toList();

          if (allContacts.isEmpty) {
            return const Center(
              child: Text('No contacts yet!'),
            );
          }

          // Prepare contacts for AzListView
          for (var contact in allContacts) {
            if (contact.name.isNotEmpty) {
              contact.tag = contact.name[0].toUpperCase();
            } else {
              contact.tag = '#';
            }
          }
          SuspensionUtil.sortListBySuspensionTag(allContacts);

          return Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                color: Theme.of(context).colorScheme.surfaceVariant,
                child: Row(
                  children: [
                    Text(
                      '${allContacts.length} Contact${allContacts.length != 1 ? 's' : ''}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: AzListView(
                  data: allContacts,
                  itemCount: allContacts.length,
                  itemBuilder: (context, index) {
                    final contact = allContacts[index];
                    return _buildContactItem(contact);
                  },
                  indexBarData: SuspensionUtil.getTagIndexList(allContacts),
                  indexHintBuilder: (context, hint) {
                    return Container(
                      alignment: Alignment.center,
                      width: 60,
                      height: 60,
                      decoration: const BoxDecoration(
                        color: Colors.blue,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        hint,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 30,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'contacts_fab',
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const AddEditContactScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildContactItem(Contact contact) {
    return Dismissible(
      key: Key(contact.id),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) {
        _contactService.deleteContact(contact.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${contact.name} deleted')),
        );
      },
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      child: Material(
        color: Theme.of(context).colorScheme.surface,
        child: InkWell(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => AddEditContactScreen(contact: contact),
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: _getAvatarColor(contact.name.isNotEmpty ? contact.name[0] : '#'),
                  child: Text(
                    contact.name.isNotEmpty ? contact.name[0].toUpperCase() : '#',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        contact.name,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      if (contact.phoneNumber.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Text(
                            contact.phoneNumber,
                            style: TextStyle(
                              fontSize: 14,
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getAvatarColor(String letter) {
    final colors = [
      const Color(0xFF1A73E8),
      const Color(0xFFE37400),
      const Color(0xFF0D652D),
      const Color(0xFFAB47BC),
      const Color(0xFFD93025),
      const Color(0xFFF9AB00),
      const Color(0xFF00897B),
      const Color(0xFF8E24AA),
    ];
    final index = letter.toUpperCase().codeUnitAt(0) % colors.length;
    return colors[index];
  }
}

// Search delegate for contacts
class ContactSearchDelegate extends SearchDelegate<Contact?> {
  final ContactService contactService;

  ContactSearchDelegate(this.contactService);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchResults(context);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildSearchResults(context);
  }

  Widget _buildSearchResults(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: Hive.box<Contact>('contacts').listenable(),
      builder: (context, Box<Contact> box, _) {
        final allContacts = box.values.toList().cast<Contact>();
        
        final filteredContacts = query.isEmpty
            ? allContacts
            : allContacts.where((contact) {
                final nameLower = contact.name.toLowerCase();
                final phoneLower = contact.phoneNumber.toLowerCase();
                final emailLower = contact.email.toLowerCase();
                final searchLower = query.toLowerCase();
                
                return nameLower.contains(searchLower) ||
                    phoneLower.contains(searchLower) ||
                    emailLower.contains(searchLower);
              }).toList();

        filteredContacts.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

        if (filteredContacts.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  query.isEmpty ? 'No contacts yet' : 'No contacts found',
                  style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          itemCount: filteredContacts.length,
          itemBuilder: (context, index) {
            final contact = filteredContacts[index];
            return Material(
              color: Theme.of(context).colorScheme.surface,
              child: InkWell(
                onTap: () {
                  close(context, contact);
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => AddEditContactScreen(contact: contact),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: _getAvatarColorStatic(contact.name.isNotEmpty ? contact.name[0] : '#'),
                        child: Text(
                          contact.name.isNotEmpty ? contact.name[0].toUpperCase() : '#',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              contact.name,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                            if (contact.phoneNumber.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 2),
                                child: Text(
                                  contact.phoneNumber,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
  
  static Color _getAvatarColorStatic(String letter) {
    final colors = [
      const Color(0xFF1A73E8),
      const Color(0xFFE37400),
      const Color(0xFF0D652D),
      const Color(0xFFAB47BC),
      const Color(0xFFD93025),
      const Color(0xFFF9AB00),
      const Color(0xFF00897B),
      const Color(0xFF8E24AA),
    ];
    final index = letter.toUpperCase().codeUnitAt(0) % colors.length;
    return colors[index];
  }
}