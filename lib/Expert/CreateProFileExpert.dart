import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:weather/Expert/ProfileController.dart';

class CreateProfilesPage extends StatefulWidget {
  const CreateProfilesPage({super.key});

  @override
  State<CreateProfilesPage> createState() => _CreateProfilesPageState();
}

class _CreateProfilesPageState extends State<CreateProfilesPage> {
  final TextEditingController _fullnameController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _degreeController = TextEditingController();
  XFile? _profilePic;

  final _formKey = GlobalKey<FormState>();
  final ProfilesController _profilesController = Get.put(ProfilesController()); // Sử dụng ProfileController

  // Chọn ảnh từ bộ sưu tập hoặc máy ảnh
  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    setState(() {
      _profilePic = image;
    });
  }

  // Lưu hoặc cập nhật hồ sơ
  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      try {
        // Gọi ProfileController để lưu hồ sơ
        await _profilesController.saveOrUpdateProfile(
          _fullnameController.text.trim(),
          _bioController.text.trim(),
          _degreeController.text.trim(),
          _profilePic,
        );

        // Hiển thị thông báo và quay lại trang trước
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile saved successfully!')),
        );
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving profile: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Profile')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _fullnameController,
                decoration: const InputDecoration(labelText: 'Full Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your full name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _bioController,
                decoration: const InputDecoration(labelText: 'Bio'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a bio';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _degreeController,
                decoration: const InputDecoration(labelText: 'Degree'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your degree';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: _pickImage,
                child: const Text('Pick Avatar'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveProfile,
                child: const Text('Save Profile'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
