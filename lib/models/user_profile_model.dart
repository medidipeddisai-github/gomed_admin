class UserProfile {
  final String username;
  final String email;
  final String date;
  final String status;
  final List<ActivityLog> activityLog;
  final List<Review> reviews;

  UserProfile({
    required this.username,
    required this.email,
    required this.date,
    required this.status,
    required this.activityLog,
    required this.reviews,
  });
}

class ActivityLog {
  final String service;
  final String date;
  final String assignedTo;
  final String status;

  ActivityLog({
    required this.service,
    required this.date,
    required this.assignedTo,
    required this.status,
  });
}

class Review {
  final String service;
  final int rating;
  final String date;

  Review({
    required this.service,
    required this.rating,
    required this.date,
  });
}

UserProfile userProfile = UserProfile(
  username: 'Orthopedic Surgery',
  email: 'johndoe@example.com',
  date: '01/01/2023',
  status: 'Active',
  activityLog: [
    ActivityLog(
      service: 'Pediatric Care:',
      date: '01/09/2024',
      assignedTo: 'John Doe',
      status: 'Completed',
    ),
    ActivityLog(
      service: 'Dermatology',
      date: '02/09/2024',
      assignedTo: 'Jane Smith',
      status: 'Pending',
    ),
  ],
  reviews: [
    Review(
      service: 'Orthopedic Surgery',
      rating: 5,
      date: '01/09/2024',
    ),
  ],
);
