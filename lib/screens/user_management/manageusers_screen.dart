import 'package:flutter/material.dart';
import 'package:gomed_admin/provider/usersdataprovider.dart';
import 'package:gomed_admin/screens/user_management/user_profile.dart';
import 'package:gomed_admin/widgets/bottomnavigation.dart';
import 'package:gomed_admin/widgets/topbar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gomed_admin/models/users.dart' as user_model;
import 'package:intl/intl.dart';

class ManageUsersScreen extends ConsumerStatefulWidget {
  const ManageUsersScreen({super.key});
  @override
  ConsumerState<ManageUsersScreen> createState() => _ManageUsersScreenState();
}

class _ManageUsersScreenState extends ConsumerState<ManageUsersScreen> {
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(usersProvider.notifier).getUsers());
  }

  @override
  Widget build(BuildContext context) {
    final usersState = ref.watch(usersProvider);
    final usersData = usersState.data ?? [];

    final filteredUsers = usersData.where((user) {
      final name = user.name?.toLowerCase() ?? '';
      final email = user.email?.toLowerCase() ?? '';
      return name.contains(searchQuery.toLowerCase()) ||
          email.contains(searchQuery.toLowerCase());
    }).toList();

    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    final double paddingHorizontal = screenWidth * 0.04;
    final double searchBarHeight = screenHeight * 0.06;

    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F4F9),
        body: Column(
          children: [
            TopBar(
              title: 'Manage Users',
              onBackPressed: () {
                Navigator.pop(context);
              },
            ),
            SizedBox(height: screenHeight * 0.01),
            _buildSearchBar(paddingHorizontal, searchBarHeight),
            SizedBox(height: screenHeight * 0.01),
            _buildUserListRow(paddingHorizontal),
           Expanded(
              child: filteredUsers.isEmpty && searchQuery.isNotEmpty
                  ? const Center(
                      child: Text(
                        'No users found',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    )
                  : _buildUserList(filteredUsers),
            ),

          ],
        ),
        
      ),
    );
  }

  Widget _buildUserListRow(double paddingHorizontal) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: paddingHorizontal),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(
            'Users List',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(double paddingHorizontal, double searchBarHeight) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: paddingHorizontal),
      child: SizedBox(
        height: searchBarHeight,
        child: TextField(
          onChanged: (query) {
            setState(() {
              searchQuery = query;
            });
          },
          decoration: InputDecoration(
            hintText: 'Search by username or email',
            prefixIcon: const Icon(Icons.search),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUserList(List<user_model.Data> users) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      itemCount: users.length,
      itemBuilder: (context, index) {
        final user = users[index];
        final userStatus = (user.role == 'admin' || user.role == 'user')
            ? 'Active'
            : 'Inactive'; // You can customize this logic if you have a status field

        return Card(
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          elevation: 3,
          margin: const EdgeInsets.symmetric(vertical: 6),
          child: ListTile(
            contentPadding:
                const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            title: Text(
              user.name ?? "No Name",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(user.email ?? "No Email"),
                // Text(
                //   user.createdAt != null
                //       ? DateFormat('dd/MM/yyyy').format(DateTime.parse(user.createdAt))
                //       : 'No Date',
                //   style: const TextStyle(fontWeight: FontWeight.bold),
                // ),
                Text(DateFormat('dd/MM/yyyy').format(DateTime.parse(user.createdAt ?? 'No Date'))),
              ],
            ),
            trailing: Text(
              userStatus,
              style: TextStyle(
                color: userStatus == 'Active' ? Colors.green : Colors.red,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            onTap: () {
              // Navigator.push(
              //   context,
              //   MaterialPageRoute(
              //     builder: (context) => UserProfileScreen(user: user),
              //   ),
              // );
            },
          ),
        );
      },
    );
  }
}
