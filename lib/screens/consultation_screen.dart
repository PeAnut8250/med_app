import 'package:flutter/material.dart';
import 'chat_detail_screen.dart';
import 'notifications_screen.dart';
import '../widgets/notification_bell.dart';
import '../models/appointment_model.dart';
import 'pre_appointment_form_screen.dart';

class ConsultationScreen extends StatefulWidget {
  final VoidCallback? onBackTap;
  const ConsultationScreen({super.key, this.onBackTap});

  @override
  State<ConsultationScreen> createState() => _ConsultationScreenState();
}

class _ConsultationScreenState extends State<ConsultationScreen> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  int _selectedTabIndex = 0;
  static const Color primaryTeal = Color(0xFF26A9B1);
  static const Color backgroundGray = Color(0xFFF8F9FA);

  // DATA STATE
  late List<Appointment> _allAppointments;

  @override
  void initState() {
    super.initState();
    // Initialize mock data
    _allAppointments = [
      Appointment(
        id: '1',
        doctorName: 'Dr. Rajesh Verma',
        doctorType: 'Orthopedist',
        doctorImage: 'assets/image 18.png',
        date: DateTime(2026, 10, 23),
        time: const TimeOfDay(hour: 12, minute: 0),
        status: 'Upcoming',
      ),
      Appointment(
        id: '2',
        doctorName: 'Dr. Sarita Singh',
        doctorType: 'Gynecology',
        doctorImage: 'assets/image 18.png',
        date: DateTime(2026, 10, 25),
        time: const TimeOfDay(hour: 10, minute: 30),
        status: 'Upcoming',
      ),
      Appointment(
        id: '3',
        doctorName: 'Dr. Rajesh Verma',
        doctorType: 'Orthopedist',
        doctorImage: 'assets/image 18.png',
        date: DateTime(2026, 10, 15),
        time: const TimeOfDay(hour: 15, minute: 0),
        status: 'Completed',
      ),
      Appointment(
        id: '4',
        doctorName: 'Dr. Sarita Singh',
        doctorType: 'Gynecology',
        doctorImage: 'assets/image 18.png',
        date: DateTime(2026, 10, 10),
        time: const TimeOfDay(hour: 11, minute: 0),
        status: 'Cancelled',
      ),
    ];
  }

  List<Appointment> _getFilteredAppointments() {
    final statusMap = {0: 'Upcoming', 1: 'Completed', 2: 'Cancelled'};
    final targetStatus = statusMap[_selectedTabIndex];
    return _allAppointments.where((a) => a.status == targetStatus).toList();
  }

  Future<void> _handleReschedule(Appointment appointment) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: appointment.date,
      firstDate: DateTime.now(),
      lastDate: DateTime(2027),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: primaryTeal),
        ),
        child: child!,
      ),
    );

    if (pickedDate != null) {
      if (!mounted) return;
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: appointment.time,
        builder: (context, child) => Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: primaryTeal),
          ),
          child: child!,
        ),
      );

      if (pickedTime != null) {
        setState(() {
          appointment.date = pickedDate;
          appointment.time = pickedTime;
        });
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: primaryTeal,
            content: Text('Rescheduled to ${appointment.formattedDate} at ${appointment.formattedTime}'),
          ),
        );
      }
    }
  }

  void _handleCancel(Appointment appointment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Appointment'),
        content: const Text('Are you sure you want to cancel this appointment? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('NO', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                appointment.status = 'Cancelled';
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Appointment cancelled')),
              );
            },
            child: const Text('YES, CANCEL', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: backgroundGray,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    _buildInsightBanner(),
                    const SizedBox(height: 25),
                    _buildTabSelector(),
                    const SizedBox(height: 25),
                    _buildAppointmentList(),
                    const SizedBox(height: 120), 
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildCircularButton(
            icon: Icons.chevron_left,
            onPressed: widget.onBackTap ?? () => Navigator.pop(context),
          ),
          const Text(
            'My Consultation',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          NotificationBell(
            hasNotification: true,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsScreen())),
          ),
        ],
      ),
    );
  }

  Widget _buildCircularButton({required IconData icon, required VoidCallback onPressed}) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        width: 45,
        height: 45,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 5, // Optimization: Lighter GPU load
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(icon, color: Colors.black, size: 28),
      ),
    );
  }

  Widget _buildInsightBanner() {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PreAppointmentFormScreen())),
      child: Container(
        height: 180,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF2EBCC4),
              Color(0xFF1E8D93),
            ],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              right: -20,
              bottom: 0,
              top: 0,
              child: Opacity(
                opacity: 0.3,
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                  child: Image.asset(
                    'assets/image 18.png', 
                    fit: BoxFit.cover,
                    width: 200,
                    cacheWidth: 400, // Optimization: Avoid full size decode
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'PERSONALIZED INSIGHT',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Ready for your visit?',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: 200,
                    child: Text(
                      'Complete your pre-appointment questionnaire to save time.',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              right: 24,
              bottom: 0,
              top: 0,
              child: Center(
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.arrow_forward, color: primaryTeal),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabSelector() {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(35),
      ),
      child: Row(
        children: [
          _buildTabItem('Upcoming', 0),
          _buildTabItem('Completed', 1),
          _buildTabItem('Cancelled', 2),
        ],
      ),
    );
  }

  Widget _buildTabItem(String title, int index) {
    final bool isSelected = _selectedTabIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTabIndex = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? primaryTeal : Colors.transparent,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Center(
            child: Text(
              title,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey[600],
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAppointmentList() {
    final filteredAppointments = _getFilteredAppointments();

    if (filteredAppointments.isEmpty) {
      return Container(
        height: 200,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_note, size: 60, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text('No appointments found', style: TextStyle(color: Colors.grey[400])),
          ],
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: filteredAppointments.length,
      separatorBuilder: (context, index) => const SizedBox(height: 20),
      itemBuilder: (context, index) {
        return _buildAppointmentCard(filteredAppointments[index]);
      },
    );
  }

  Widget _buildAppointmentCard(Appointment appointment) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5, // Optimization: Lighter GPU load
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  appointment.doctorImage,
                  width: 50,
                  height: 50,
                  cacheWidth: 150, // Optimization: Forced small decode size
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      appointment.doctorName,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    Text(
                      appointment.doctorType,
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: (appointment.status == 'Upcoming' ? primaryTeal : (appointment.status == 'Completed' ? Colors.blueAccent : Colors.grey)).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  appointment.status,
                  style: TextStyle(
                    color: appointment.status == 'Upcoming' ? primaryTeal : (appointment.status == 'Completed' ? Colors.blueAccent : Colors.grey),
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Divider(height: 1, color: Color(0xFFF1F1F1)),
          ),
          Row(
            children: [
              _buildInfoItem(Icons.calendar_month, 'Date', appointment.formattedDate),
              const Spacer(),
              _buildInfoItem(Icons.access_time, 'Time', appointment.formattedTime),
            ],
          ),
          if (appointment.status == 'Upcoming') ...[
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _buildActionButton(
                    'Reschedule',
                    primaryTeal,
                    Colors.white,
                    onTap: () => _handleReschedule(appointment),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildActionButton(
                    'Cancel',
                    const Color(0xFFF1F1F1),
                    Colors.redAccent,
                    onTap: () => _handleCancel(appointment),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: primaryTeal.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: primaryTeal, size: 20),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
            Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton(String title, Color bgColor, Color textColor, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Center(
          child: Text(
            title,
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }
}
