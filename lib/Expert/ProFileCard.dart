import 'package:flutter/material.dart';
import 'package:weather/Expert/ShowInformationPage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:weather/UI/Chat/ChatPage.dart';
import 'package:weather/Expert/ProfileController.dart';

class ProfileCard extends StatelessWidget {
  final ExpertData expertData;

  const ProfileCard({
    Key? key,
    required this.expertData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      ShowInformationPage(expertData: expertData),
                ),
              );
            },
            child: ListTile(
              leading: CircleAvatar(
                radius: 50,
                backgroundImage: expertData.profilePictureUrl.isNotEmpty
                    ? NetworkImage(expertData.profilePictureUrl)
                    : null,
                child: expertData.profilePictureUrl.isEmpty
                    ? const Icon(Icons.person, size: 30, color: Colors.white)
                    : null,
              ),
              title: Text(
                expertData.degree,
                style: const TextStyle(
                  fontStyle: FontStyle.italic,
                  color: Colors.black54,
                ),
              ),
              subtitle: Text(
                expertData.fullName,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.black87,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Container(
            color: Colors.blue[100],
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton.icon(
                  onPressed: () async {
                    final currentUserId = FirebaseAuth.instance.currentUser!.email!;
                    final expertId = expertData.id;
                    final conversationId = "${currentUserId}_$expertId";
                    final conversationRef = FirebaseFirestore.instance
                        .collection('conversations')
                        .doc(conversationId);
                    final conversationDoc = await conversationRef.get();

                    if (!conversationDoc.exists) {
                      await conversationRef.set({
                        'conversationId': conversationId,
                        'userId': currentUserId,
                        'expertId': expertId,
                        'lastMessage': '',
                        'lastTimestamp': FieldValue.serverTimestamp(),
                      });
                    }
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatPage(
                          conversationId: conversationId,
                          currentUserId: currentUserId,
                        ),
                      ),
                    );
                  },
                  icon:
                  const Icon(Icons.wechat_outlined, color: Colors.indigoAccent),
                  label: const Text('Tư vấn', style: TextStyle(fontSize: 14)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.indigoAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    side: const BorderSide(color: Colors.indigoAccent),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.add_call, color: Colors.white),
                  label: const Text('Liên hệ', style: TextStyle(fontSize: 14)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[500],
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    side: const BorderSide(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
