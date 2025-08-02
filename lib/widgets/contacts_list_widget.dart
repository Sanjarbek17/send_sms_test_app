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
    return Expanded(
      child: ListView.builder(
        itemCount: sentContacts.length,
        itemBuilder: (context, index) {
          if (sentContacts.isNotEmpty) {
            return Text(
              "${('${index + 1}:').padRight(4)} ${sentContacts[index].name}",
            );
          }
          return null;
        },
      ),
    );
  }
}
