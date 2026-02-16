import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/item_service.dart';

class AddItemScreen extends StatefulWidget {
  const AddItemScreen({super.key});

  @override
  State<AddItemScreen> createState() => _AddItemScreenState();
}

class _AddItemScreenState extends State<AddItemScreen> {
  final _formKey = GlobalKey<FormState>();

  final titleController = TextEditingController();
  final descController = TextEditingController();
  final locationController = TextEditingController();
  final phoneController = TextEditingController();

  String type = "LOST";
  bool loading = false;

  final service = ItemService();

  Future<void> submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => loading = true);

    await service.addItem({
      "type": type,
      "title": titleController.text.trim(),
      "description": descController.text.trim(),
      "location": locationController.text.trim(),
      "phone": phoneController.text.trim(), // ✅ NEW
      "imageUrl": "", // ✅ demo only
      "createdBy": FirebaseAuth.instance.currentUser!.uid,
      "createdAt": DateTime.now().millisecondsSinceEpoch,
      "status": "ACTIVE",
    });

    if (mounted) Navigator.pop(context);
  }

  @override
  void dispose() {
    titleController.dispose();
    descController.dispose();
    locationController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text("Create Post")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: cs.outlineVariant.withOpacity(.6)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Post Type",
                        style: TextStyle(fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        initialValue: type,
                        items: const [
                          DropdownMenuItem(value: "LOST", child: Text("hide")),
                          DropdownMenuItem(value: "FOUND", child: Text("Found")),
                        ],
                        onChanged: (v) => setState(() => type = v!),
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: cs.outlineVariant.withOpacity(.6)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    children: [
                      TextFormField(
                        controller: titleController,
                        decoration: const InputDecoration(
                          labelText: "Item title",
                          hintText: "e.g. iPhone 12 (black)",
                          border: OutlineInputBorder(),
                        ),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return "Title required";
                          }
                          if (v.trim().length < 3) return "Minimum 3 characters";
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: locationController,
                        decoration: const InputDecoration(
                          labelText: "Location",
                          hintText: "e.g. Ashulia, DIU Gate-1",
                          border: OutlineInputBorder(),
                        ),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return "Location required";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),

                      // ✅ Phone Field
                      TextFormField(
                        controller: phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(
                          labelText: "Mobile number",
                          hintText: "01XXXXXXXXX",
                          border: OutlineInputBorder(),
                        ),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return "Mobile number required";
                          }
                          if (v.trim().length < 11) return "Enter valid number";
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      

                      TextFormField(
                        controller: descController,
                        maxLines: 4,
                        decoration: const InputDecoration(
                          labelText: "Description",
                          hintText: "Write details (color, time, contact info...)",
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: loading ? null : submit,
                  icon: loading
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.check),
                  label: Text(loading ? "Posting..." : "Publish"),
                ),
              
              ),
              
              
            ],
          ),
        ),
      ),
    );
  }
}
