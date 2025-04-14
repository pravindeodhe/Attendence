import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

import 'model/user.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  double screenHeight = 0;
  double screenWidth = 0;
  Color primary = const Color(0xffe444c);
  String birth = "Date of Birth";
  final ImagePicker _picker = ImagePicker();

  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController addressController = TextEditingController();

  Future<void> pickUploadProfilePic() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxHeight: 512,
        maxWidth: 512,
        imageQuality: 90,
      );

      if (image == null) return;

      Reference ref = FirebaseStorage.instance
          .ref()
          .child("${User.employeeId.toLowerCase()}_profilepic.jpg");

      await ref.putFile(File(image.path));

      String downloadURL = await ref.getDownloadURL();

      setState(() {
        User.profilePicLink = downloadURL;
      });

      await FirebaseFirestore.instance
          .collection("Employee")
          .doc(User.id)
          .update({
        'profilePic': User.profilePicLink,
      });
    } catch (e) {
      _showSnackBar("Error uploading image: ${e.toString()}");
    }
  }

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            GestureDetector(
              onTap: pickUploadProfilePic,
              child: Container(
                margin: const EdgeInsets.only(top: 80, bottom: 24),
                height: 120,
                width: 120,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: primary,
                ),
                child: Center(
                  child: User.profilePicLink.isEmpty
                      ? Icon(
                    Icons.person,
                    color: Colors.white,
                    size: 80,
                  )
                      : ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.network(
                      User.profilePicLink,
                      fit: BoxFit.cover,
                      width: 120,
                      height: 120,
                    ),
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.center,
              child: Text(
                "Employee ${User.employeeId}",
                style: const TextStyle(
                  fontFamily: "NexaBold",
                  fontSize: 18,
                ),
              ),
            ),
            const SizedBox(height: 24),
            textField("First Name", "First name", firstNameController),
            textField("Last Name", "Last name", lastNameController),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Date of Birth",
                style: TextStyle(
                  fontFamily: "NexaBold",
                  color: Colors.black87,
                ),
              ),
            ),
            GestureDetector(
              onTap: () async {
                final selectedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(1950),
                  lastDate: DateTime.now(),
                );
                if (selectedDate != null) {
                  setState(() {
                    birth =
                    "${selectedDate.day}/${selectedDate.month}/${selectedDate.year}";
                  });
                }
              },
              child: Container(
                height: kToolbarHeight,
                width: screenWidth,
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.only(left: 11),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: Colors.black54,
                  ),
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    birth,
                    style: const TextStyle(
                      color: Colors.black54,
                      fontFamily: "NexaBold",
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),
            textField("Address", "Address", addressController),
            GestureDetector(
              onTap: () async {
                String firstName = firstNameController.text;
                String lastName = lastNameController.text;
                String birthDate = birth;
                String address = addressController.text;

                if (User.canEdit) {
                  if (firstName.isEmpty) {
                    _showSnackBar("Please enter your first name!");
                  } else if (lastName.isEmpty) {
                    _showSnackBar("Please enter your last name!");
                  } else if (birthDate == "Date of Birth") {
                    _showSnackBar("Please enter your birth date!");
                  } else if (address.isEmpty) {
                    _showSnackBar("Please enter your address!");
                  } else {
                    try {
                      await FirebaseFirestore.instance
                          .collection("Employee")
                          .doc(User.id)
                          .update({
                        'firstName': firstName,
                        'lastName': lastName,
                        'birthDate': birthDate,
                        'address': address,
                        'canEdit': false,
                      });
                      _showSnackBar("Profile updated successfully!");
                    } catch (e) {
                      _showSnackBar("Error updating profile: ${e.toString()}");
                    }
                  }
                } else {
                  _showSnackBar(
                      "You can't edit anymore, please contact support team.");
                }
              },
              child: Container(
                height: kToolbarHeight,
                width: screenWidth,
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  color: primary,
                ),
                child: Center(
                  child: Text(
                    "Save",
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: "NexaBold",
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget textField(
      String title, String hint, TextEditingController controller) {
    return Column(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            title,
            style: TextStyle(
              fontFamily: "NexaBold",
              color: Colors.black87,
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.only(bottom: 12),
          child: TextFormField(
            controller: controller,
            cursorColor: Colors.black54,
            maxLines: 1,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle:
              TextStyle(color: Colors.black54, fontFamily: "NexaBold"),
              enabledBorder: const OutlineInputBorder(
                borderSide: BorderSide(
                  color: Colors.black54,
                ),
              ),
              focusedBorder: const OutlineInputBorder(
                borderSide: BorderSide(
                  color: Colors.black54,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showSnackBar(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text(text),
      ),
    );
  }
}