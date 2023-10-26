import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';

class UserDetails extends StatelessWidget {
  final data;

  const UserDetails({Key? key, required this.data}) : super(key: key);

  // Future<void> saveContact() async {
  //   final result = await UserDetails.saveContact(
  //     firstName: data['Name'] ?? 'N/A',
  //     lastName: data['Company Name'] ?? 'N/A',
  //     phoneNumber: data['Phone'] ?? 'N/A',
  //     email: data['Email'] ?? '',
  //   );

  //   if (result.isSuccess) {
  //     print('Contact saved successfully');
  //   } else {
  //     print('Failed to save contact: ${result.error}');
  //   }
  // }

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
            image: AssetImage('lib/images/background.jpg'), // Replace with your image asset
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Center(
              child: CircleAvatar(
                radius: 50,
                backgroundImage: NetworkImage(data['photo_url'] ?? ''),
                backgroundColor: Colors.grey,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              data['Name'] ?? 'N/A',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
            ),
            Text(
              data['Company Name'] ?? 'N/A',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Icon(Icons.call, size: 20),
                Text(
                  data['Phone'] ?? 'N/A',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(Icons.email_outlined, size: 20),
                Text(
                  data['Email'] ?? 'N/A',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(Icons.location_on_outlined, size: 20),
                Flexible(
                  child: Text(
                    data['Address'] ?? 'N/A',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Align(
              alignment: Alignment.bottomRight,
              child: Container(
                height: 35,
                width: 80,
                decoration: BoxDecoration(
                  color: Colors.orange,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: ElevatedButton(
                  onPressed: () {
                    // Handle the "Edit" button tap here
                  },
                  child: Text('Edit', style: TextStyle(fontSize: 14)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
