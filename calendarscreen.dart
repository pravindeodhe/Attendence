import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:month_year_picker/month_year_picker.dart';

import 'model/user.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  double screenHeight = 0;
  double screenWidth = 0;

  Color primary = Colors.red;

  String _month = DateFormat('MMMM').format(DateTime.now());

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
                  "My Attendance",
                  style: TextStyle(
                    fontFamily: "NexaBold",
                    fontSize: screenWidth / 18,
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: 20),
                padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      spreadRadius: 2,
                      offset: Offset(0, 4),
                    )
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                      decoration: BoxDecoration(
                        color: primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _month,
                        style: TextStyle(
                          fontFamily: "NexaBold",
                          fontSize: screenWidth / 18,
                          color: primary,
                        ),
                      ),
                    ),
                    MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        onTap: () async {
                          final month = await showMonthYearPicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(2025),
                              lastDate: DateTime(2099),
                              builder: (context, child) {
                                return Theme(
                                  data: Theme.of(context).copyWith(
                                    colorScheme: ColorScheme.light(
                                      primary: primary,
                                      secondary: primary,
                                      onSecondary: Colors.white,
                                    ),
                                    textButtonTheme: TextButtonThemeData(
                                      style: TextButton.styleFrom(
                                        foregroundColor: primary,
                                      ),
                                    ),
                                    textTheme: TextTheme(
                                      headlineMedium: TextStyle(
                                        fontFamily: "NexaBold",
                                      ),
                                      labelSmall: TextStyle(
                                        fontFamily: "NexaBold",
                                      ),
                                      labelLarge: TextStyle(
                                          fontFamily: "NexaBold"
                                      ),
                                    ),
                                  ),
                                  child: child!,
                                );
                              }
                          );

                          if (month != null) {
                            setState(() {
                              _month = DateFormat('MMMM').format(month);
                            });
                          }
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                          decoration: BoxDecoration(
                            color: primary,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: primary.withOpacity(0.3),
                                blurRadius: 4,
                                offset: Offset(0, 2),
                              )
                            ],
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.calendar_today,
                                  size: 18,
                                  color: Colors.white),
                              SizedBox(width: 8),
                              Text(
                                "Pick a Month",
                                style: TextStyle(
                                  fontFamily: "NexaBold",
                                  fontSize: screenWidth / 22,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: screenHeight / 1.45,
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection("Employee")
                      .doc(User.id)
                      .collection("Record")
                      .snapshots(),
                  builder: (BuildContext context,
                      AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (snapshot.hasData) {
                      final snap = snapshot.data!.docs;
                      final filteredDocs = snap.where((doc) {
                        try {
                          final date = DateFormat('dd MMMM yyyy').parse(doc.id);
                          return DateFormat('MMMM').format(date) == _month;
                        } catch (e) {
                          return false;
                        }
                      }).toList();

                      return ListView.builder(
                          itemCount: filteredDocs.length,
                          itemBuilder: (context, index) {
                            String dateString = filteredDocs[index].id;
                            DateTime recordDate;

                            try {
                              recordDate = DateFormat('dd MMMM yyyy').parse(dateString);
                            } catch (e) {
                              recordDate = DateTime.now();
                            }

                            return Container(
                              margin: EdgeInsets.only(top: index > 0 ? 12 : 0, left: 6, right: 6),
                              height: 160,
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
                              child: Row(
                                children: [
                                  Container(
                                    width: screenWidth / 8,
                                    margin: EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: primary,
                                      borderRadius:
                                      BorderRadius.all(Radius.circular(10)),
                                    ),
                                    child: Center(
                                      child: Text(
                                        DateFormat('EE\ndd').format(recordDate),
                                        style: TextStyle(
                                          fontFamily: "NexaBold",
                                          fontSize: screenWidth / 18,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Expanded(
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
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
                                              SizedBox(height: 4),
                                              Text(
                                                  filteredDocs[index]['checkIn'] ?? "--/--",
                                                  style: TextStyle(
                                                    fontFamily: "NexaBold",
                                                    fontSize: screenWidth / 18,
                                                  )),
                                            ],
                                          ),
                                        ),
                                        Expanded(
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
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
                                              SizedBox(height: 4),
                                              Text(
                                                filteredDocs[index]['checkOut'] ?? "--/--",
                                                style: TextStyle(
                                                  fontFamily: "NexaBold",
                                                  fontSize: screenWidth / 18,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          });
                    } else {
                      return const SizedBox();
                    }
                  },
                ),
              )
            ],
          ),
        ));
  }
}