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
    try {
      // Lấy danh sách người dùng từ Firebase Authentication
      final List<UserRecord> users = [];
      final userList = await _auth.fetchSignInMethodsForEmail(''); // Phương thức này không có tác dụng trong trường hợp này
      setState(() {
        _authUsers = users; // Lưu danh sách người dùng
      });
    } catch (e) {
      print('Lỗi khi lấy danh sách người dùng từ Authentication: $e');
    }
  }

  Future<void> _getFirestoreUsers() async {
    List<UserRecord> users = [];
    try {
      // Lấy danh sách người dùng từ Firestore
      final userCollection = await FirebaseFirestore.instance.collection('users').get();
      for (var doc in userCollection.docs) {
        users.add(UserRecord(
          uid: doc.id,
          email: doc['email'],
          fullname: doc['fullname'],
        ));
      }
      setState(() {
        _firestoreUsers = users; // Lưu danh sách người dùng từ Firestore
      });
    } catch (e) {
      print('Lỗi khi lấy danh sách người dùng: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý người dùng'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
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
          return ListTile(
            title: Text(user.email),
            subtitle: Text('Tên đầy đủ: ${user.fullname}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    _editUser(user);
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () {
                    _deleteUser(user);
                  },
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addUser,
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
              TextField(
                onChanged: (value) {
                  email = value;
                },
                decoration: const InputDecoration(labelText: 'Email'),
              ),
              TextField(
                onChanged: (value) {
                  fullname = value;
                },
                decoration: const InputDecoration(labelText: 'Tên đầy đủ'),
              ),
              TextField(
                onChanged: (value) {
                  password = value;
                },
                decoration: const InputDecoration(labelText: 'Mật khẩu'),
                obscureText: true,
              ),
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
                  _getFirestoreUsers(); // Cập nhật danh sách người dùng
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
              TextField(
                onChanged: (value) {
                  email = value;
                },
                controller: TextEditingController(text: user.email),
                decoration: const InputDecoration(labelText: 'Email'),
              ),
              TextField(
                onChanged: (value) {
                  fullname = value;
                },
                controller: TextEditingController(text: user.fullname),
                decoration: const InputDecoration(labelText: 'Tên đầy đủ'),
              ),
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
                  _getFirestoreUsers(); // Cập nhật danh sách người dùng
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
      await _auth.currentUser!.delete(); // Xóa người dùng từ Firebase Authentication
      _getFirestoreUsers(); // Cập nhật danh sách người dùng
    } catch (e) {
      print('Lỗi khi xóa người dùng: $e');
    }
  }

  void _updateSearchQuery(String query) {
    setState(() {
      _searchQuery = query;
    });
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
