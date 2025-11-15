
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RatingFeedbackScreen extends StatefulWidget {
  const RatingFeedbackScreen({super.key});

  @override
  State<RatingFeedbackScreen> createState() => _RatingFeedbackScreenState();
}

class _RatingFeedbackScreenState extends State<RatingFeedbackScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? userRole;
  String? organizationName;
  String? userEmail;
  String? selectedOrganization;

  @override
  void initState() {
    super.initState();
    _fetchUserRole();
  }

  Future<void> _fetchUserRole() async {
    final user = _auth.currentUser;
    if (user == null) return;
    userEmail = user.email;

    try {
      // 🔹 Check if admin (organization document)
      final orgSnapshot = await _firestore
          .collection('organizations')
          .where('email', isEqualTo: user.email)
          .limit(1)
          .get();

      if (orgSnapshot.docs.isNotEmpty) {
        setState(() {
          userRole = 'admin';
          organizationName =
              orgSnapshot.docs.first['organizationName'].toString().toLowerCase();
        });
        return;
      }

      // 🔹 Check if HR or normal user (users collection)
      final userSnapshot = await _firestore
          .collection('users')
          .where('email', isEqualTo: user.email)
          .limit(1)
          .get();

      if (userSnapshot.docs.isNotEmpty) {
        final data = userSnapshot.docs.first.data();
        setState(() {
          userRole = data['role'] ?? 'user';
          organizationName =
              data['organizationName']?.toString().toLowerCase();
        });
      }
    } catch (e) {
      print('❌ Error fetching role: $e');
    }
  }

  /// 🔹 Review submission dialog
  void _openReviewDialog() {
    double selectedRating = 0;
    TextEditingController reviewController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text("Write a Review"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FutureBuilder<QuerySnapshot>(
                  future: _firestore.collection('organizations').get(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const CircularProgressIndicator();
                    }
                    final orgs = snapshot.data!.docs;
                    return DropdownButtonFormField<String>(
                      value: selectedOrganization,
                      decoration: const InputDecoration(
                        labelText: "Select Organization",
                        border: OutlineInputBorder(),
                      ),
                      items: orgs.map((doc) {
                        final orgName = doc['organizationName'];
                        return DropdownMenuItem(
                          value: orgName.toString().toLowerCase(),
                          child: Text(orgName),
                        );
                      }).toList(),
                      onChanged: (val) {
                        setState(() {
                          selectedOrganization = val;
                        });
                      },
                    );
                  },
                ),
                const SizedBox(height: 16),
                const Text(
                  "Rate the service",
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Color(0xFF154688)),
                ),
                const SizedBox(height: 20),
                StatefulBuilder(
                  builder: (context, setStateSB) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) {
                        return IconButton(
                          icon: Icon(
                            index < selectedRating
                                ? Icons.star
                                : Icons.star_border,
                            color: Colors.amber,
                            size: 35,
                          ),
                          onPressed: () {
                            setStateSB(() {
                              selectedRating = index + 1.0;
                            });
                          },
                        );
                      }),
                    );
                  },
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: reviewController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: "Write your review...",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF154688),
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                final user = _auth.currentUser;
                if (user == null || selectedOrganization == null) return;

                if (selectedRating > 0 && reviewController.text.isNotEmpty) {
                  await _firestore.collection('reviews').add({
                    "uid": user.uid,
                    "name": user.displayName ?? "Anonymous",
                    "email": user.email,
                    "rating": selectedRating.toInt(),
                    "comment": reviewController.text,
                    "institutionName": selectedOrganization,
                    "date": DateTime.now(),
                  });
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Review submitted successfully")),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text("Please select organization and give rating")),
                  );
                }
              },
              child: const Text("Submit"),
            ),
          ],
        );
      },
    );
  }

  /// 🔹 Rating Breakdown
  Widget _buildRatingBreakdown(List<QueryDocumentSnapshot> docs) {
    if (docs.isEmpty) return const SizedBox.shrink();

    int total = docs.length;
    Map<int, int> counts = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0};

    for (var doc in docs) {
      int r = doc["rating"];
      counts[r] = (counts[r] ?? 0) + 1;
    }

    return Column(
      children: counts.entries.map((entry) {
        double percentage = entry.value / total;
        return Row(
          children: [
            Text("${entry.key} ★", style: const TextStyle(fontWeight: FontWeight.w500)),
            const SizedBox(width: 8),
            Expanded(
              child: LinearProgressIndicator(
                value: percentage,
                backgroundColor: Colors.grey.shade300,
                color: const Color(0xFF154688),
                minHeight: 8,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 8),
            Text("${entry.value}"),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildReviewCard(Map<String, dynamic> review) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: const CircleAvatar(
          backgroundColor: Color(0xFF154688),
          child: Icon(Icons.person, color: Colors.white),
        ),
        title: Text(
          review["name"] ?? "Anonymous",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: List.generate(5, (index) {
                return Icon(
                  index < review["rating"] ? Icons.star : Icons.star_border,
                  size: 16,
                  color: Colors.amber,
                );
              }),
            ),
            const SizedBox(height: 4),
            Text(review["comment"] ?? ""),
          ],
        ),
        trailing: Text(
          (review["date"] as Timestamp).toDate().toString().split(" ")[0],
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (userRole == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    Stream<QuerySnapshot> feedbackStream;

    // 🔹 Admin and HR see only their own organization’s reviews
    if ((userRole == 'admin' || userRole == 'HR') &&
        organizationName != null &&
        organizationName!.isNotEmpty) {
      feedbackStream = _firestore
          .collection('reviews')
          .where('institutionName', isEqualTo: organizationName)
          .orderBy('date', descending: true)
          .snapshots();
    } else {
      // 🔹 Normal users see all reviews
      feedbackStream = _firestore
          .collection('reviews')
          .orderBy('date', descending: true)
          .snapshots();
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Rating & Feedback"),
        backgroundColor: const Color(0xFF154688),
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: feedbackStream,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;
          if (docs.isEmpty) {
            return const Center(child: Text("No reviews yet."));
          }

          double avg =
              docs.map((d) => d["rating"]).reduce((a, b) => a + b) / docs.length;

          return Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF154688), Color(0xFF164889)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Row(
                  children: [
                    Text(
                      avg.toStringAsFixed(1),
                      style: const TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: List.generate(5, (index) {
                            return Icon(
                              index < avg.round()
                                  ? Icons.star
                                  : Icons.star_border,
                              color: Colors.amber,
                              size: 18,
                            );
                          }),
                        ),
                        Text(
                          "${docs.length} Reviews",
                          style: const TextStyle(color: Colors.white70),
                        ),
                      ],
                    )
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: _buildRatingBreakdown(docs),
              ),
              const Divider(),
              Expanded(
                child: ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, index) =>
                      _buildReviewCard(docs[index].data() as Map<String, dynamic>),
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: (userRole == 'admin' || userRole == 'HR')
          ? null
          : FloatingActionButton.extended(
        onPressed: _openReviewDialog,
        label: const Text("Write Review"),
        icon: const Icon(Icons.edit),
        backgroundColor: const Color(0xFF154688),
        foregroundColor: Colors.white,
      ),
    );
  }
}
