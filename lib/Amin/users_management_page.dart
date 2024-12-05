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
      if (userCollection.docs.isNotEmpty) {
        for (var doc in userCollection.docs) {
          // Kiểm tra xem trường 'role' có tồn tại hay không
          String role = doc.data().containsKey('role') ? doc['role'] : 'Chưa có';

          users.add(UserRecord(
            uid: doc.id,
            email: doc['email'],
            fullname: doc['fullname'],
            role: role, // Sử dụng giá trị 'role' nếu có, nếu không sẽ là 'Chưa có'
          ));
        }
      } else {
        print('Không có người dùng nào trong Firestore.');
      }
      setState(() {
        _firestoreUsers = users;
      });
    } catch (e) {
      print('Lỗi khi lấy người dùng từ Firestore: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Quản lý người dùng',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.blueAccent,
        elevation: 5,
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () {
              showSearch(
                context: context,
                delegate: UserSearchDelegate(
                    _searchController, _searchQuery, _updateSearchQuery),
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
            margin: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
            elevation: 10,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                tileColor: Colors.grey[50],
                title: Text(
                  user.email,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.blueAccent,
                  ),
                ),
                subtitle: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      'Tên: ${user.fullname}',
                      style: const TextStyle(fontSize: 14, color: Colors.black54),
                    ),
                    Text(
                      'Vai trò: ${user.role}',
                      style: const TextStyle(fontSize: 14, color: Colors.black54),
                    ),
                  ],
                ),
                trailing: Wrap(
                  spacing: 12,
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
    String re_password = '';
    String role = 'User'; // Mặc định là 'User'

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
              const SizedBox(height: 10),
              _buildTextField('Nhập lại mật khẩu', obscureText: true, onChanged: (value) => re_password = value),
              const SizedBox(height: 10),
              // DropdownButton để chọn vai trò
              DropdownButton<String>(
                value: role,
                onChanged: (String? newValue) {
                  setState(() {
                    role = newValue!;
                  });
                },
                items: <String>['User', 'Expert']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                hint: const Text('Chọn vai trò'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                if (password != re_password) {
                  // Xử lý nếu mật khẩu và mật khẩu nhập lại không khớp
                  print('Mật khẩu không khớp');
                  return;
                }

                try {
                  UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
                    email: email,
                    password: password,
                  );
                  await FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).set({
                    'email': email,
                    'fullname': fullname,
                    'role': role, // Lưu vai trò vào Firestore
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
      // Xóa người dùng từ Firestore
      await FirebaseFirestore.instance.collection('users').doc(user.uid).delete();

      // Xóa người dùng từ Firebase Authentication
      if (_auth.currentUser != null) {
        await _auth.currentUser!.delete();
      }

      // Cập nhật lại danh sách người dùng Firestore
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
  final String role;


  UserRecord({
    required this.uid,
    required this.email,
    required this.fullname,
    required this.role,
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
