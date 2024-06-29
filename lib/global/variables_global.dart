import 'package:firebase_auth/firebase_auth.dart';

String userFirstName = "";
String userLastName = "";
String userPhone = "";
String userPhoto = "";
String userMail = "";
String userStatus = "";
String userID = FirebaseAuth.instance.currentUser!.uid;