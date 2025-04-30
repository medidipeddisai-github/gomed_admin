class User {
  final String id;
  final String? profilePic;
  final String? username;
  final String? email;
  final String? date;
  final String? status;

  User({
    required this.id,
    this.profilePic,
    this.username,
    this.email,
    this.date,
    this.status,
  });
}

final List<User> usersData = [
  User(
      id: '1',
      profilePic: 'assets/images/avatar1.png',
      username: 'John Doe',
      email: 'john@example.com',
      date: '24/02/2024',
      status: 'Active'),
  User(
      id: '2',
      profilePic: 'assets/images/avatar2.png',
      username: 'Jane Smith',
      email: 'jane@example.com',
      date: '19/02/2024',
      status: 'Deactive'),
  User(
      id: '3',
      profilePic: 'assets/images/avatar1.png',
      username: 'John Doe',
      email: 'john@example.com',
      date: '24/02/2024',
      status: 'Active'),
  User(
      id: '4',
      profilePic: 'assets/images/avatar2.png',
      username: 'Jane Smith',
      email: 'jane@example.com',
      date: '19/02/2024',
      status: 'Deactive'),
  User(
      id: '5',
      profilePic: 'assets/images/avatar1.png',
      username: 'John Doe',
      email: 'john@example.com',
      date: '24/02/2024',
      status: 'Active'),
  User(
      id: '6',
      profilePic: 'assets/images/avatar2.png',
      username: 'Jane Smith',
      email: 'jane@example.com',
      date: '19/02/2024',
      status: 'Deactive'),
  User(
      id: '7',
      profilePic: 'assets/images/avatar2.png',
      username: 'Jane Smith',
      email: 'jane@example.com',
      date: '19/02/2024',
      status: 'Deactive'),
  User(
      id: '8',
      profilePic: 'assets/images/avatar2.png',
      username: 'Last edhe',
      email: 'jane@example.com',
      date: '19/02/2024',
      status: 'Deactive'),
];
