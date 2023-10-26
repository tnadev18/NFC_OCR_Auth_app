import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';

class UserDetails extends StatelessWidget {
  final data;

  const UserDetails({Key? key, required this.data}) : super(key: key);

  Future<void> saveContact() async {
    final result = await UserDetails.saveContact(
      firstName: data['Name'] ?? 'N/A',
      lastName: data['Company Name'] ?? 'N/A',
      phoneNumber: data['Phone'] ?? 'N/A',
      email: data['Email'] ?? '',
    );

    if (result.isSuccess) {
      print('Contact saved successfully');
    } else {
      print('Failed to save contact: ${result.error}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Details'),
      ),
      body: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          border: Border.all(width: 2.0, color: Colors.white),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade500,
              offset: const Offset(4.0, 4.0),
              blurRadius: 15.0,
              spreadRadius: 1.0,
            ),
            const BoxShadow(
              color: Colors.white,
              offset: Offset(-4.0, -4.0),
              blurRadius: 15.0,
              spreadRadius: 1.0,
            ),
          ],
          image: const DecorationImage(
            image: AssetImage(
                'lib/images/background.jpg'), // Replace with your image asset
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ... Your existing UI code ...

            Align(
              alignment: Alignment.bottomRight,
              child: Container(
                height: 35,
                width: 60,
                decoration: BoxDecoration(
                  color: Colors.orange,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: ElevatedButton(
                  onPressed: saveContact,
                  child: Icon(Icons.contacts),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Future<OperationResult> saveContact({
    required String firstName,
    required String lastName,
    required String phoneNumber,
    String email = '',
  }) async {
    final newContact = Contact()
      ..name.first = firstName
      ..name.last = lastName
      ..phones = [Phone(phoneNumber, PhoneLabel.mobile)]
      ..emails = [Email(email, EmailLabel.work)];

    final result = await newContact.insert();
    return result;
  }
}
