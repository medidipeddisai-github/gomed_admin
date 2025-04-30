import 'package:flutter/material.dart';
import 'package:gomed_admin/widgets/topbar.dart';
import 'package:gomed_admin/models/user_profile_model.dart';
import 'package:gomed_admin/widgets/bottomnavigation.dart';
import 'package:gomed_admin/widgets/custom_button.dart';
import 'package:gomed_admin/models/manage_users_model.dart';

class UserProfileScreen extends StatelessWidget {
  final User user;

  UserProfileScreen({required this.user});

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;
    final double padding = screenWidth * 0.04;
    final double textSize = screenWidth * 0.045;

    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          child: Column(
            children: [
              TopBar(
                title: 'User Profile',
                onBackPressed: () {
                  Navigator.pop(context);
                },
              ),
              SizedBox(height: screenHeight * 0.02), // 2% of screen height
              Container(
                width: double.infinity,
                child: Card(
                  elevation: 4.0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(padding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Profile Information",
                          style: TextStyle(
                            fontSize: textSize * 1.2,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(
                            height: screenHeight * 0.01), // 1% of screen height
                        Text(
                          "Username: ${user.username}",
                          style: TextStyle(
                            fontSize: textSize,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "Email: ${user.email}",
                          style: TextStyle(fontSize: textSize * 0.9),
                        ),
                        Text(
                          "Date: ${user.date}",
                          style: TextStyle(fontSize: textSize * 0.9),
                        ),
                        Text(
                          "Status: ${user.status}",
                          style: TextStyle(
                            fontSize: textSize * 0.9,
                            color: user.status == 'Active'
                                ? Colors.green
                                : Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.02), // 3% of screen height
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Activity Log",
                        style: TextStyle(
                          fontSize: textSize * 1.2,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        "Recent Bookings",
                        style: TextStyle(
                          fontSize: textSize * 1.2,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: screenHeight * 0.01), // 1% of screen height
                  Table(
                    border: TableBorder.all(color: Colors.white),
                    columnWidths: {
                      0: FixedColumnWidth(screenWidth * 0.1),
                      1: FlexColumnWidth(),
                      2: FixedColumnWidth(screenWidth * 0.25),
                      3: FlexColumnWidth(),
                      4: FixedColumnWidth(screenWidth * 0.18),
                    },
                    children: [
                      TableRow(
                        decoration:const BoxDecoration(color: Color(0xFF2A9D8F)),
                        children: [
                          Padding(
                            padding: EdgeInsets.all(screenWidth * 0.02),
                            child: const Text('S.no',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                          Padding(
                            padding: EdgeInsets.all(screenWidth * 0.02),
                            child: const Text('Service',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                          Padding(
                            padding: EdgeInsets.all(screenWidth * 0.02),
                            child: const Text('Date',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                          Padding(
                            padding: EdgeInsets.all(screenWidth * 0.02),
                            child: const Text('Assign',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                          Padding(
                            padding: EdgeInsets.all(screenWidth * 0.02),
                            child: const Text('Status',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                      ...userProfile.activityLog.asMap().entries.map(
                            (entry) => TableRow(
                              children: [
                                Padding(
                                  padding: EdgeInsets.all(screenWidth * 0.02),
                                  child: Text('${entry.key + 1}'),
                                ),
                                Padding(
                                  padding: EdgeInsets.all(screenWidth * 0.02),
                                  child: Text(entry.value.service),
                                ),
                                Padding(
                                  padding: EdgeInsets.all(screenWidth * 0.02),
                                  child: Text(entry.value.date),
                                ),
                                Padding(
                                  padding: EdgeInsets.all(screenWidth * 0.02),
                                  child: Text(entry.value.assignedTo),
                                ),
                                Padding(
                                  padding: EdgeInsets.all(screenWidth * 0.02),
                                  child: Text(
                                    entry.value.status,
                                    style: TextStyle(
                                      color: entry.value.status == 'Completed'
                                          ? Colors.green
                                          : Colors.red,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                    ],
                  ),
                  SizedBox(height: screenHeight * 0.01), // 2% of screen height
                  Text(
                    "Reviews Given",
                    style: TextStyle(
                      fontSize: textSize * 1.2,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  ...userProfile.reviews.map((review) => Padding(
                        padding:
                            EdgeInsets.symmetric(vertical: screenHeight * 0.01),
                        child: Text(
                          'Reviewed ${review.service} with ${review.rating} Stars On ${review.date}',
                          style: TextStyle(fontSize: textSize * 0.9),
                        ),
                      )),
                ],
              ),
              SizedBox(height: screenHeight * 0.06), // 8% of screen height
              CustomButton(
                text: 'Deactivate Account',
                color: Colors.red,
                screenWidth: screenWidth,
                onTap: () {
                  // Add your onTap logic here
                },
              ),
            ],
          ),
        ),
        // bottomNavigationBar: CustomBottomNavigationBar(
        //   currentIndex: 0,
        //   onTap: (index) {
        //     Navigator.pop(context);
        //   },
        // ),
      ),
    );
  }
}
