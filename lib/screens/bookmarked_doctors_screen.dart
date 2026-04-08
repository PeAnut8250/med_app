import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'doctor_profile_screen.dart';

class BookmarkedDoctorsScreen extends StatefulWidget {
  const BookmarkedDoctorsScreen({super.key});

  @override
  State<BookmarkedDoctorsScreen> createState() => _BookmarkedDoctorsScreenState();
}

class _BookmarkedDoctorsScreenState extends State<BookmarkedDoctorsScreen> {
  static const Color primaryTeal = Color(0xFF26A9B1);
  List<Map<String, String>> _bookmarkedDoctors = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBookmarks();
  }

  Future<void> _loadBookmarks() async {
    final prefs = await SharedPreferences.getInstance();
    final bookmarks = prefs.getStringList('bookmarked_doctors') ?? [];
    
    setState(() {
      _bookmarkedDoctors = bookmarks.map((item) {
        final Map<String, dynamic> decoded = json.decode(item);
        return decoded.map((key, value) => MapEntry(key, value.toString()));
      }).toList();
      _isLoading = false;
    });
  }

  Future<void> _removeBookmark(int index) async {
    final prefs = await SharedPreferences.getInstance();
    final bookmarks = prefs.getStringList('bookmarked_doctors') ?? [];
    
    final removedName = _bookmarkedDoctors[index]['name'];
    bookmarks.removeWhere((item) => json.decode(item)['name'] == removedName);
    await prefs.setStringList('bookmarked_doctors', bookmarks);
    
    setState(() {
      _bookmarkedDoctors.removeAt(index);
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Doctor removed from bookmarks')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'My Bookmarked Doctors',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: primaryTeal))
          : _bookmarkedDoctors.isEmpty
              ? _buildEmptyState()
              : _buildBookmarksList(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: primaryTeal.withOpacity(0.05),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.bookmark_border, size: 80, color: primaryTeal),
          ),
          const SizedBox(height: 24),
          const Text(
            'No bookmarks yet',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
          const SizedBox(height: 12),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 48),
            child: Text(
              'Save your favorite doctors here to access them quickly whenever you need care.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookmarksList() {
    return ListView.separated(
      padding: const EdgeInsets.all(24),
      itemCount: _bookmarkedDoctors.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final doctor = _bookmarkedDoctors[index];
        return _buildDoctorBookmarkCard(doctor, index);
      },
    );
  }

  Widget _buildDoctorBookmarkCard(Map<String, String> doctor, int index) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DoctorProfileView(doctor: doctor),
          ),
        ).then((_) => _loadBookmarks()); // Refresh on return
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Hero(
              tag: 'doctor_img_${doctor['name']}',
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  image: doctor['image'] != null
                      ? DecorationImage(
                          image: AssetImage(doctor['image']!),
                          fit: BoxFit.cover,
                        )
                      : null,
                  color: primaryTeal.withOpacity(0.1),
                ),
                child: doctor['image'] == null
                    ? const Icon(Icons.person, color: primaryTeal)
                    : null,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    doctor['name'] ?? 'Medical Specialist',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    doctor['specialty'] ?? 'Cardiologist',
                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 14),
                      const SizedBox(width: 4),
                      const Text(
                        '4.8',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                      const SizedBox(width: 12),
                      const Icon(Icons.work_outline, color: Colors.grey, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        doctor['experience'] ?? '10 yrs',
                        style: const TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.bookmark, color: Colors.amber),
              onPressed: () => _removeBookmark(index),
            ),
          ],
        ),
      ),
    );
  }
}
