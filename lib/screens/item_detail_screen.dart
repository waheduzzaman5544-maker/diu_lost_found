import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';

class ItemDetailScreen extends StatefulWidget {
  final String docId;
  final Map<String, dynamic> data;

  const ItemDetailScreen({
    super.key,
    required this.docId,
    required this.data,
  });

  @override
  State<ItemDetailScreen> createState() => _ItemDetailScreenState();
}

class _ItemDetailScreenState extends State<ItemDetailScreen> {
  final commentController = TextEditingController();

  CollectionReference<Map<String, dynamic>> get commentCol =>
      FirebaseFirestore.instance
          .collection("items")
          .doc(widget.docId)
          .collection("comments");

  Future<void> callNumber(String phone) async {
    final uri = Uri.parse("tel:$phone");
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> addComment() async {
    final text = commentController.text.trim();
    if (text.isEmpty) return;

    final currentUid = FirebaseAuth.instance.currentUser!.uid;
    final ownerUid = widget.data["createdBy"];

  
    await commentCol.add({
      "text": text,
      "uid": currentUid,
      "createdAt": DateTime.now().millisecondsSinceEpoch,
    });

    
    if (ownerUid != currentUid) {
      await FirebaseFirestore.instance
          .collection("users")
          .doc(ownerUid)
          .collection("notifications")
          .add({
        "title": "New comment on your post",
        "message": text,
        "postId": widget.docId,
        "createdAt": DateTime.now().millisecondsSinceEpoch,
        "read": false,
      });
    }

    commentController.clear();
  }

  @override
  void dispose() {
    commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final d = widget.data;

    final title = (d["title"] ?? "").toString();
    final location = (d["location"] ?? "").toString();
    final type = (d["type"] ?? "LOST").toString();
    final status = (d["status"] ?? "ACTIVE").toString();
    final phone = (d["phone"] ?? "").toString();
    final desc = (d["description"] ?? "").toString();

    final isResolved = status == "RESOLVED";

    return Scaffold(
      appBar: AppBar(title: const Text("Post Details")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            height: 160,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: Colors.black.withOpacity(.05),
            ),
            child: const Center(
              child: Icon(Icons.image, size: 60),
            ),
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: isResolved
                      ? Colors.green.withOpacity(.15)
                      : Colors.orange.withOpacity(.15),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  isResolved ? "RESOLVED" : type,
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    color: isResolved ? Colors.green : Colors.orange,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.location_on_outlined, size: 18),
              const SizedBox(width: 6),
              Expanded(child: Text(location)),
            ],
          ),

          
          if (phone.isNotEmpty) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.phone_outlined, size: 18),
                const SizedBox(width: 6),
                Expanded(child: Text(phone)),
                ElevatedButton.icon(
                  onPressed: () => callNumber(phone),
                  icon: const Icon(Icons.call),
                  label: const Text("Call"),
                ),
              ],
            ),
          ],

          if (desc.isNotEmpty) ...[
            const SizedBox(height: 14),
            const Text(
              "Description",
              style: TextStyle(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 6),
            Text(desc),
          ],

          const SizedBox(height: 18),
          const Divider(),
          const SizedBox(height: 10),

          const Text(
            "Comments",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 10),

          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: commentController,
                  decoration: InputDecoration(
                    hintText: "Write a comment...",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: commentController,
                  decoration: InputDecoration(
                    hintText: "Ages",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: addComment,
                child: const Text("Post"),
              ),
            ],
          ),

          const SizedBox(height: 12),

          StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream:
                commentCol.orderBy("createdAt", descending: true).snapshots(),
            builder: (context, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (!snap.hasData || snap.data!.docs.isEmpty) {
                return const Text("No comments yet.");
              }

              final comments = snap.data!.docs;

              return Column(
                children: comments.map((c) {
                  final cd = c.data();
                  return Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border:
                          Border.all(color: Colors.black.withOpacity(.08)),
                    ),
                    child: Text(cd["text"] ?? ""),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}
