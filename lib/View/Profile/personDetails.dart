import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class PersonDetails extends StatefulWidget {
  @override
  _PersonDetailsState createState() => _PersonDetailsState();
}

class _PersonDetailsState extends State<PersonDetails> {
  final User? user = FirebaseAuth.instance.currentUser;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 215,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            CircleAvatar(
              radius: 74,
              child: Image.asset('assets/doremon.png'),
            ),
            StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance.collection('users').doc(user?.uid).collection('userInfo').doc(user?.uid).snapshots(),
              builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
                if (snapshot.hasData && snapshot.data?.data() != null) {
                  var userData = snapshot.data!.data() as Map<String, dynamic>;
                  String name = userData['name'] ?? ""; // Giả sử trường tên trong Firestore của bạn là 'Name'

                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Xin chào ',
                        style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        name,
                        style: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold , color: Colors.orange),
                      ),
                    ],
                  );
                }

                return const Text("Loading...");
              },
            ),
            Text(user?.email ?? 'No Email'),
          ],
        ),
      ),
    );
  }
}
