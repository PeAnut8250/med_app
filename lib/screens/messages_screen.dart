import 'package:flutter/material.dart';
import 'chat_detail_screen.dart';

class MessagesScreen extends StatefulWidget {
  final VoidCallback? onBackTap;
  const MessagesScreen({super.key, this.onBackTap});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true; // Preserve scroll position and tab state

  final TextEditingController _searchController = TextEditingController();
  String _activeFilter = 'All Chats';

  static const Color primaryTeal = Color(0xFF26A9B1);
  static const Color backgroundGray = Color(0xFFF8F9FA);

  final List<String> _filters = ['All Chats', 'Unread', 'Doctors', 'Support'];

  final List<Map<String, dynamic>> _chats = [
    {
      'name': 'Dr. Aris Thoroe',
      'title': 'SENIOR CARDIOLOGIST',
      'lastMsg': 'Your blood test results are...',
      'time': '10:42 AM',
      'isOnline': true,
      'unread': true,
      'image': 'assets/doctor_aris.png',
    },
    {
      'name': 'Dr. Sophia Bennett',
      'title': 'NEUROLOGIST',
      'lastMsg': 'The medication interval should be...',
      'time': '09:15 AM',
      'isOnline': true,
      'unread': true,
      'image': 'assets/doctor_sophia.png',
    },
    {
      'name': 'Dr. Rajesh Verma',
      'title': 'ORTHOPEDIST',
      'lastMsg': 'Exercise twice daily for 20 mins.',
      'time': 'Yesterday',
      'isOnline': false,
      'unread': false,
      'image': 'assets/image 18.png',
    },
  ];

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: backgroundGray,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    _buildPromoBanner(),
                    const SizedBox(height: 24),
                    _buildSearchBar(),
                    const SizedBox(height: 24),
                    _buildFilters(),
                    const SizedBox(height: 16),
                    _buildChatList(),
                    const SizedBox(height: 120), // Bottom nav allowance
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildCircularBtn(Icons.chevron_left, () {
            if (widget.onBackTap != null) {
              widget.onBackTap!();
            } else {
              Navigator.pop(context);
            }
          }),
          const Text(
            'Messages',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          Stack(
            children: [
              _buildCircularBtn(Icons.notifications_none_outlined, () {}),
              Positioned(
                right: 12,
                top: 12,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Colors.orange,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPromoBanner() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      height: 220, // Increased height to prevent overflow
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF4DB6AC), Color(0xFF26A9B1)],
        ),
        boxShadow: [
          BoxShadow(
            color: primaryTeal.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Watermark
          Positioned(
            right: -20,
            bottom: -20,
            child: Icon(
              Icons.videocam,
              size: 180,
              color: Colors.white.withValues(alpha: 0.1),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24), // Reduced padding for more space
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Consult a\ndoctor in 5\nminutes',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22, // Slightly reduced font size
                    fontWeight: FontWeight.bold,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Instant video call with top\ncertified specialists.',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 12, // Slightly reduced
                  ),
                ),
                const SizedBox(height: 16), // Replaced Spacer with fixed gap
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: primaryTeal,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                  ),
                  child: const Text(
                    'Start Now',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Search Doctors by name or department',
            hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
            prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 15),
          ),
        ),
      ),
    );
  }

  Widget _buildFilters() {
    return SizedBox(
      height: 50,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        scrollDirection: Axis.horizontal,
        itemCount: _filters.length,
        itemBuilder: (context, index) {
          final filter = _filters[index];
          final bool isActive = _activeFilter == filter;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: ChoiceChip(
              label: Text(filter),
              selected: isActive,
              onSelected: (val) {
                if (val) setState(() => _activeFilter = filter);
              },
              selectedColor: primaryTeal,
              backgroundColor: Colors.white,
              labelStyle: TextStyle(
                color: isActive ? Colors.white : Colors.grey[500],
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isActive ? Colors.transparent : Colors.grey[100]!,
                ),
              ),
              elevation: isActive ? 4 : 0,
              pressElevation: 0,
            ),
          );
        },
      ),
    );
  }

  Widget _buildChatList() {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _chats.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        return ChatTile(chat: _chats[index]);
      },
    );
  }

  Widget _buildCircularBtn(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(50),
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(icon, color: Colors.black87, size: 24),
      ),
    );
  }
}

class ChatTile extends StatelessWidget {
  final Map<String, dynamic> chat;
  const ChatTile({super.key, required this.chat});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatDetailScreen(doctor: chat),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundImage: AssetImage(chat['image']),
                ),
                if (chat['isOnline'])
                  Positioned(
                    right: 0,
                    bottom: 2,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        chat['name'],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        chat['time'],
                        style: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    chat['title'],
                    style: const TextStyle(
                      color: Color(0xFF26A9B1),
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          chat['lastMsg'],
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 13,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (chat['unread'])
                        Container(
                          width: 10,
                          height: 10,
                          decoration: const BoxDecoration(
                            color: Color(0xFF26A9B1),
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
