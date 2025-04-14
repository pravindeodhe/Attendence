import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:intl/intl.dart';
import 'package:slide_to_act/slide_to_act.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:task_iii/model/user.dart';
import 'package:task_iii/services/location_service.dart';

class TodayScreen extends StatefulWidget {
  const TodayScreen({super.key});

  @override
  State<TodayScreen> createState() => _TodayScreenState();
}

class _TodayScreenState extends State<TodayScreen> {
  double screenHeight = 0;
  double screenWidth = 0;
  String checkIn = "--/--";
  String checkOut = "--/--";
  String location = " ";
  Color primary = Colors.redAccent;
  bool _isGettingLocation = false;
  final LocationService _locationService = LocationService();
  final GlobalKey<SlideActionState> _slideKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _getRecord();
    _initializeLocation();
  }

  @override
  void dispose() {
    _slideKey.currentState?.dispose();
    super.dispose();
  }

  Future<void> _initializeLocation() async {
    try {
      await _locationService.initialize();
    } catch (e) {
      print("Location initialization error: $e");
    }
  }

  Future<void> _getLocation() async {
    if (_isGettingLocation) return;

    setState(() => _isGettingLocation = true);

    try {
      final lat = await _locationService.getLatitude();
      final long = await _locationService.getLongitude();

      if (lat == null || long == null) {
        setState(() => location = "Location unavailable");
        throw Exception("Location services returned null values");
      }

      User.lat = lat;
      User.long = long;

      try {
        List<Placemark> placemark = await placemarkFromCoordinates(lat, long);
        if (placemark.isNotEmpty) {
          setState(() {
            location = "${placemark[0].street ?? 'Unknown Street'}, "
                "${placemark[0].administrativeArea ?? 'Unknown Area'}, "
                "${placemark[0].postalCode ?? 'Unknown Postal Code'}, "
                "${placemark[0].country ?? 'Unknown Country'}";
          });
        } else {
          setState(() => location = "Coordinates: $lat, $long");
        }
      } catch (e) {
        setState(() => location = "Coordinates: $lat, $long");
        print("Reverse geocoding failed: $e");
      }

    } catch (e) {
      setState(() => location = "Location unavailable");
      print("Location error: $e");

      _slideKey.currentState?.reset();

      if (kIsWeb) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Please enable location permissions in browser settings"))
        );
      }
      rethrow;
    } finally {
      setState(() => _isGettingLocation = false);
    }
  }

  void _getRecord() async {
    try {
      if (User.employeeId.isEmpty) {
        setState(() {
          checkIn = "--/--";
          checkOut = "--/--";
        });
        return;
      }

      QuerySnapshot snap = await FirebaseFirestore.instance
          .collection("Employee")
          .where('id', isEqualTo: User.employeeId.trim())
          .get();

      if (snap.docs.isEmpty) {
        throw Exception("Employee record not found");
      }

      DocumentSnapshot snap2 = await FirebaseFirestore.instance
          .collection("Employee")
          .doc(snap.docs[0].id)
          .collection("Record")
          .doc(DateFormat('dd MMMM yyyy').format(DateTime.now()))
          .get();

      setState(() {
        checkIn = snap2.exists ? snap2['checkIn'] : "--/--";
        checkOut = snap2.exists ? snap2['checkOut'] : "--/--";
      });
    } catch (e) {
      setState(() {
        checkIn = "--/--";
        checkOut = "--/--";
      });
      print("Error getting record: $e");
    }
  }

  Future<void> _updateAttendance(bool isCheckIn) async {
    try {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 20),
                Text("Getting location..."),
              ],
            ),
            duration: Duration(seconds: 5),
          )
      );

      await _getLocation();

      if (location == "Location unavailable") {
        _slideKey.currentState?.reset();
        throw Exception("Location required for attendance");
      }

      QuerySnapshot snap = await FirebaseFirestore.instance
          .collection("Employee")
          .where('id', isEqualTo: User.employeeId.trim())
          .get();

      if (snap.docs.isEmpty) {
        _slideKey.currentState?.reset();
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Employee not found!")));
        return;
      }

      final docRef = FirebaseFirestore.instance
          .collection("Employee")
          .doc(snap.docs[0].id)
          .collection("Record")
          .doc(DateFormat('dd MMMM yyyy').format(DateTime.now()));

      if (isCheckIn) {
        await docRef.set({
          'date': Timestamp.now(),
          'checkIn': DateFormat('hh:mm a').format(DateTime.now()),
          'checkOut': "--/--",
          'location': location,
          'coordinates': GeoPoint(User.lat, User.long),
        });
      } else {
        await docRef.update({
          'date': Timestamp.now(),
          'checkOut': DateFormat('hh:mm a').format(DateTime.now()),
          'location': location,
          'coordinates': GeoPoint(User.lat, User.long),
        });
      }

      _getRecord();
    } catch (e) {
      _slideKey.currentState?.reset();
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: ${e.toString()}")));
    }
  }


  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              alignment: Alignment.centerLeft,
              margin: EdgeInsets.only(top: 32),
              child: Text(
                "Welcome,",
                style: TextStyle(
                  color: Colors.black54,
                  fontFamily: "nexa-regular",
                  fontSize: screenWidth / 20,
                ),
              ),
            ),
            Container(
              alignment: Alignment.centerLeft,
              child: Text(
                "Employee" + User.employeeId,
                style: TextStyle(
                  fontFamily: "NexaBold",
                  fontSize: screenWidth / 18,
                ),
              ),
            ),
            Container(
              alignment: Alignment.centerLeft,
              margin: EdgeInsets.only(top: 32),
              child: Text(
                "Today's Status",
                style: TextStyle(
                  fontFamily: "NexaBold",
                  fontSize: screenWidth / 18,
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.only(top: 12, bottom: 32),
              height: 150,
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    offset: Offset(2, 2),
                  )
                ],
                borderRadius: BorderRadius.all(Radius.circular(20)),
              ),
              child: SingleChildScrollView(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                "Check In",
                                style: TextStyle(
                                    fontFamily: "nexa-regular",
                                    fontSize: screenWidth / 20,
                                    color: Colors.black54),
                              ),
                              Text(checkIn,
                                  style: TextStyle(
                                    fontFamily: "NexaBold",
                                    fontSize: screenWidth / 18,
                                  )),
                            ])),
                    Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              "Check Out",
                              style: TextStyle(
                                  fontFamily: "nexa-regular",
                                  fontSize: screenWidth / 20,
                                  color: Colors.black54),
                            ),
                            Text(
                              checkOut,
                              style: TextStyle(
                                fontFamily: "NexaBold",
                                fontSize: screenWidth / 18,
                              ),
                            ),
                          ],
                        ))
                  ],
                ),
              ),
            ),
            Container(
                alignment: Alignment.centerLeft,
                child: RichText(
                  text: TextSpan(
                      text: DateTime.now().day.toString(),
                      style: TextStyle(
                          color: primary,
                          fontSize: screenWidth / 20,
                          fontFamily: "NexaBold"),
                      children: [
                        TextSpan(
                            text:
                            DateFormat(' MMMM yyyy').format(DateTime.now()),
                            style: TextStyle(
                                color: primary,
                                fontSize: screenWidth / 20,
                                fontFamily: "nexa-regular"))
                      ]),
                )),
            StreamBuilder(
                stream: Stream.periodic(const Duration(seconds: 1)),
                builder: (context, snapshot) {
                  return Container(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      DateFormat('hh:mm:ss a').format(DateTime.now()),
                      style: TextStyle(
                          fontFamily: "nexa-regular",
                          fontSize: screenWidth / 20,
                          color: Colors.black54),
                    ),
                  );
                }),
            checkOut == "--/--"
                ? Container(
              margin: EdgeInsets.only(top: 25, bottom: 12),
              child: Builder(builder: (context) {
                return SlideAction(
                  text: checkIn == "--/--"
                      ? "Slide to Check In"
                      : "Slide to Check Out",
                  textStyle: TextStyle(
                    color: Colors.black54,
                    fontSize: screenWidth / 20,
                    fontFamily: "nexa_regular",
                  ),
                  outerColor: Colors.white,
                  innerColor: primary,
                  key: _slideKey,
                  onSubmit: () async {
                    try {
                      await _updateAttendance(checkIn == "--/--");
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Failed to update attendance: $e"))
                      );
                    }
                  },
                );
              }),
            )
                : Container(
              margin: EdgeInsets.only(top: 32, bottom: 32),
              child: Text(
                "You have Completed this Day!",
                style: TextStyle(
                  fontFamily: "nexa-regular",
                  fontSize: screenWidth / 20,
                  color: Colors.black54,
                ),
              ),
            ),
            location != " "
                ? Container(
              margin: EdgeInsets.only(top: 12),
              alignment: Alignment.centerLeft,
              child: Text(
                "Location: $location",
                style: TextStyle(
                  fontFamily: "nexa-regular",
                  fontSize: screenWidth / 22,
                  color: Colors.black54,
                ),
              ),
            )
                : const SizedBox(),
          ],
        ),
      ),
    );
  }
}