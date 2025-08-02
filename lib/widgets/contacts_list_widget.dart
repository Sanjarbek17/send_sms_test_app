import 'package:flutter/material.dart';
import '../models/contact.dart';

class ContactsListWidget extends StatelessWidget {
  final List<Contact> sentContacts;

  const ContactsListWidget({
    Key? key,
    required this.sentContacts,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (sentContacts.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            'Sent Messages (${sentContacts.length}):',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
        ...sentContacts.asMap().entries.map((entry) {
          int index = entry.key;
          Contact contact = entry.value;
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 2.0),
            child: Row(
              children: [
                Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text("${index + 1}. ${contact.name}"),
              ],
            ),
          );
        }),
      ],
    );
  }
}
