import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UsersManagementPage extends StatefulWidget {
  const UsersManagementPage({Key? key}) : super(key: key);

  @override
  State<UsersManagementPage> createState() => _UsersManagementPageState();
}

class _UsersManagementPageState extends State<UsersManagementPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  List<UserRecord> _authUsers = [];
  List<UserRecord> _firestoreUsers = [];

  @override
  void initState() {
    super.initState();
    _getAuthUsers();
    _getFirestoreUsers();
  }

  Future<void> _getAuthUsers() async {
    // Authentication users handling logic if applicable
  }

  Future<void> _getFirestoreUsers() async {
    List<UserRecord> users = [];
    try {
      final userCollection = await FirebaseFirestore.instance.collection('users').get();
      for (var doc in userCollection.docs) {
        users.add(UserRecord(
          uid: doc.id,
          email: doc['email'],
          fullname: doc['fullname'],
        ));
      }
      setState(() {
        _firestoreUsers = users;
      });
    } catch (e) {
      print('Error fetching users: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý người dùng', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blueAccent,
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () {
              showSearch(
                context: context,
                delegate: UserSearchDelegate(_searchController, _searchQuery, _updateSearchQuery),
              );
            },
          ),
        ],
      ),
      body: _firestoreUsers.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: _firestoreUsers.length,
        itemBuilder: (context, index) {
          final user = _firestoreUsers[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: ListTile(
              title: Text(user.email, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('Tên đầy đủ: ${user.fullname}'),
              trailing: Wrap(
                spacing: 8,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue),
                    onPressed: () {
                      _editUser(user);
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      _deleteUser(user);
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addUser,
        backgroundColor: Colors.blueAccent,
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _addUser() async {
    String email = '';
    String fullname = '';
    String password = '';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Thêm người dùng mới'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTextField('Email', onChanged: (value) => email = value),
              const SizedBox(height: 10),
              _buildTextField('Tên đầy đủ', onChanged: (value) => fullname = value),
              const SizedBox(height: 10),
              _buildTextField('Mật khẩu', obscureText: true, onChanged: (value) => password = value),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                try {
                  UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
                    email: email,
                    password: password,
                  );
                  await FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).set({
                    'email': email,
                    'fullname': fullname,
                  });
                  Navigator.of(context).pop();
                  _getFirestoreUsers();
                } catch (e) {
                  print('Lỗi khi thêm người dùng: $e');
                }
              },
              child: const Text('Thêm'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Hủy'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _editUser(UserRecord user) async {
    String email = user.email;
    String fullname = user.fullname;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Chỉnh sửa người dùng'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTextField('Email', initialValue: user.email, onChanged: (value) => email = value),
              const SizedBox(height: 10),
              _buildTextField('Tên đầy đủ', initialValue: user.fullname, onChanged: (value) => fullname = value),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                try {
                  await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
                    'email': email,
                    'fullname': fullname,
                  });
                  Navigator.of(context).pop();
                  _getFirestoreUsers();
                } catch (e) {
                  print('Lỗi khi chỉnh sửa người dùng: $e');
                }
              },
              child: const Text('Lưu'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Hủy'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteUser(UserRecord user) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).delete();
      await _auth.currentUser!.delete();
      _getFirestoreUsers();
    } catch (e) {
      print('Lỗi khi xóa người dùng: $e');
    }
  }

  void _updateSearchQuery(String query) {
    setState(() {
      _searchQuery = query;
    });
  }

  Widget _buildTextField(String label,
      {String? initialValue, bool obscureText = false, required ValueChanged<String> onChanged}) {
    return TextField(
      onChanged: onChanged,
      obscureText: obscureText,
      controller: initialValue != null ? TextEditingController(text: initialValue) : null,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
      ),
    );
  }
}

class UserRecord {
  final String uid;
  final String email;
  final String fullname;

  UserRecord({
    required this.uid,
    required this.email,
    required this.fullname,
  });
}

class UserSearchDelegate extends SearchDelegate {
  final TextEditingController searchController;
  final String searchQuery;
  final Function(String) updateSearchQuery;

  UserSearchDelegate(this.searchController, this.searchQuery, this.updateSearchQuery);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          searchController.clear();
          updateSearchQuery('');
          close(context, null);
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return Center(child: Text('Tìm kiếm cho: $searchQuery'));
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return Container();
  }
}
