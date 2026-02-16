import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../services/item_service.dart';
import 'add_item_screen.dart';
import 'item_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final service = ItemService();

  String query = "";
  int tabIndex = 0; // 0=All, 1=Lost, 2=Found

  String? get typeFilter {
    if (tabIndex == 1) return "LOST";
    if (tabIndex == 2) return "FOUND";
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final uid = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0B4DA2),
              Color(0xFFF6F7FB),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(.18),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.white.withOpacity(.25)),
                      ),
                      child: Image.asset(
                        "assets/diu_logo.png",
                        height: 26,
                        errorBuilder: (_, __, ___) =>
                            const Icon(Icons.school, color: Colors.white),
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        "DIU Lost & Found",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      tooltip: "Logout",
                      icon: const Icon(Icons.logout, color: Colors.white),
                      onPressed: () => FirebaseAuth.instance.signOut(),
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                child: Card(
                  elevation: 0,
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      children: [
                        TextField(
                          onChanged: (v) =>
                              setState(() => query = v.trim().toLowerCase()),
                          decoration: InputDecoration(
                            hintText: "Search by title or location...",
                            prefixIcon: const Icon(Icons.search),
                            filled: true,
                            fillColor: cs.surfaceContainerHighest.withOpacity(.6),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        SegmentedButton<int>(
                          segments: const [
                            ButtonSegment(value: 0, label: Text("All")),
                            ButtonSegment(value: 1, label: Text("Lost")),
                            ButtonSegment(value: 2, label: Text("Found")),
                          ],
                          selected: {tabIndex},
                          onSelectionChanged: (s) =>
                              setState(() => tabIndex = s.first),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Color(0xFFF6F7FB),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(22),
                      topRight: Radius.circular(22),
                    ),
                  ),
                  child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                    stream: service.getItems(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (!snapshot.hasData) {
                        return const Center(child: Text("No data"));
                      }

                      var docs = snapshot.data!.docs;

                      if (typeFilter != null) {
                        docs = docs
                            .where((d) =>
                                (d.data()["type"] ?? "").toString() == typeFilter)
                            .toList();
                      }

                      if (query.isNotEmpty) {
                        docs = docs.where((d) {
                          final data = d.data();
                          final title =
                              (data["title"] ?? "").toString().toLowerCase();
                          final location =
                              (data["location"] ?? "").toString().toLowerCase();
                          return title.contains(query) || location.contains(query);
                        }).toList();
                      }

                      if (docs.isEmpty) {
                        return const Center(
                          child: Text(
                            "No posts found",
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                        );
                      }

                      return ListView.builder(
                        padding: const EdgeInsets.fromLTRB(12, 12, 12, 90),
                        itemCount: docs.length,
                        itemBuilder: (context, i) {
                          final doc = docs[i];
                          final d = doc.data();

                          final type = (d["type"] ?? "LOST").toString();
                          final title = (d["title"] ?? "").toString();
                          final location = (d["location"] ?? "").toString();
                          final status = (d["status"] ?? "ACTIVE").toString();
                          final isResolved = status == "RESOLVED";

                          final createdBy = (d["createdBy"] ?? "").toString();
                          final isOwner = uid != null && uid == createdBy;

                          final isLost = type == "LOST";

                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  blurRadius: 18,
                                  spreadRadius: 0,
                                  color: Colors.black.withOpacity(.06),
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: ListTile(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ItemDetailScreen(
                                      docId: doc.id,
                                      data: d,
                                    ),
                                  ),
                                );
                              },
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 8),
                              leading: Container(
                                height: 42,
                                width: 42,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isLost
                                      ? Colors.orange.withOpacity(.15)
                                      : Colors.green.withOpacity(.15),
                                ),
                                child: Icon(
                                  isLost
                                      ? Icons.report_problem_rounded
                                      : Icons.check_circle_rounded,
                                  color: isLost ? Colors.orange : Colors.green,
                                ),
                              ),
                              title: Text(
                                title,
                                style: const TextStyle(fontWeight: FontWeight.w900),
                              ),
                              subtitle: Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Row(
                                  children: [
                                    Icon(Icons.location_on_outlined,
                                        size: 16, color: Colors.grey.shade600),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        location,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      isResolved ? "RESOLVED" : type,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w900,
                                        color: isResolved
                                            ? Colors.green
                                            : (isLost ? Colors.orange : Colors.green),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              trailing: isOwner
                                  ? PopupMenuButton<String>(
                                      onSelected: (v) async {
                                        if (v == "resolve") {
                                          await service.markResolved(doc.id);
                                        } else if (v == "delete") {
                                          await service.deleteItem(doc.id);
                                        }
                                      },
                                      itemBuilder: (_) => [
                                        if (!isResolved)
                                          const PopupMenuItem(
                                            value: "resolve",
                                            child: Text("Mark as Returned"),
                                          ),
                                        const PopupMenuItem(
                                          value: "delete",
                                          child: Text("Delete"),
                                        ),
                                      ],
                                    )
                                  : null,
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddItemScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
