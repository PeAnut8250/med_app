import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

class BookingFlowScreen extends StatefulWidget {
  final Map<String, String> doctor;

  const BookingFlowScreen({super.key, required this.doctor});

  @override
  State<BookingFlowScreen> createState() => _BookingFlowScreenState();
}

class _BookingFlowScreenState extends State<BookingFlowScreen> {
  // --- TOP-LEVEL STATE PERSISTENCE ---
  int _currentStep = 1;
  String _consultationFor = 'For Myself';
  String _consultationType = 'Video Call';
  String _paymentMethod = 'Credit/Debit Card';
  bool _isSummaryExpanded = false;
  
  // DYNAMIC FILE MANAGEMENT
  List<PlatformFile> _medicalRecords = [];
  
  late TextEditingController _reasonController;

  static const Color primaryTeal = Color(0xFF26A9B1);

  @override
  void initState() {
    super.initState();
    _reasonController = TextEditingController();
    _reasonController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  // --- LOGIC METHODS ---

  Future<void> _pickFiles() async {
    try {
      FilePickerResult? result = await FilePicker.pickFiles(
        allowMultiple: true,
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'png', 'jpeg'],
      );

      if (result != null) {
        setState(() {
          _medicalRecords.addAll(result.files);
        });
      }
    } catch (e) {
      debugPrint('Error picking files: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open file picker. Please check permissions.')),
        );
      }
    }
  }

  void _removeFile(int index) {
    setState(() {
      _medicalRecords.removeAt(index);
    });
  }

  bool _isStep1Valid() => _reasonController.text.trim().isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBFBFB),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: _buildCircularIcon(
            icon: Icons.chevron_left,
            onPressed: () {
              if (_currentStep > 1) {
                FocusScope.of(context).unfocus();
                setState(() => _currentStep--);
              } else {
                Navigator.pop(context);
              }
            },
          ),
        ),
        title: Text(
          _getStepTitle(),
          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
      ),
      bottomNavigationBar: _buildBottomBar(),
      body: Column(
        children: [
          const SizedBox(height: 20),
          _buildStepper(),
          const SizedBox(height: 30),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _buildCurrentStepView(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getStepTitle() {
    switch (_currentStep) {
      case 1: return 'Details';
      case 2: return 'Order Summary';
      case 3: return 'Payment';
      default: return 'Booking';
    }
  }

  Widget _buildCurrentStepView() {
    switch (_currentStep) {
      case 1: return _buildDetailsStep();
      case 2: return _buildSummaryStep();
      case 3: return _buildPaymentStep();
      default: return const SizedBox();
    }
  }

  Widget _buildStepper() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildStepCircle(1, 'DETAILS'),
          _buildStepLine(1),
          _buildStepCircle(2, 'ORDER SUMMARY'),
          _buildStepLine(2),
          _buildStepCircle(3, 'PAYMENT'),
        ],
      ),
    );
  }

  Widget _buildStepCircle(int step, String label) {
    bool isActive = _currentStep >= step;
    return Column(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: isActive ? primaryTeal : const Color(0xFFEEEEEE),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              '$step',
              style: TextStyle(
                color: isActive ? Colors.white : Colors.grey[600],
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            color: isActive ? primaryTeal : Colors.grey[400],
            fontSize: 9,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildStepLine(int startStep) {
    bool isActive = _currentStep > startStep;
    return Expanded(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
        height: 2,
        margin: const EdgeInsets.only(bottom: 20),
        color: isActive ? primaryTeal : const Color(0xFFEEEEEE),
      ),
    );
  }

  // --- STEP 1: DETAILS ---
  Widget _buildDetailsStep() {
    return Column(
      key: const ValueKey(1),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Consultation For', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildSelectableCard(
                'For Myself',
                Icons.person,
                _consultationFor == 'For Myself',
                () => setState(() => _consultationFor = 'For Myself'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildSelectableCard(
                'Family Member',
                Icons.group,
                _consultationFor == 'Family Member',
                () => setState(() => _consultationFor = 'Family Member'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 32),
        const Text('Reason for Visit', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        TextField(
          controller: _reasonController,
          maxLines: 5,
          decoration: InputDecoration(
            hintText: 'Describe your symptoms, how long you\'ve had them, or any specific concerns you\'d like to discuss...',
            hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13, height: 1.5),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: Colors.grey[300]!)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: Colors.grey[200]!)),
            filled: true,
            fillColor: Colors.white,
          ),
        ),
        const SizedBox(height: 32),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Upload Medical Records', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            TextButton(
              onPressed: _pickFiles, // Functional Add More
              child: const Text('Add More', style: TextStyle(color: primaryTeal, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        const SizedBox(height: 8),
        
        // DYNAMIC FILE LIST
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _medicalRecords.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) => _buildFileTile(_medicalRecords[index], index),
        ),
        
        if (_medicalRecords.isNotEmpty) const SizedBox(height: 16),
        
        GestureDetector(
          onTap: _pickFiles, // Functional Drop Files
          child: _buildDashedUploadBox(),
        ),
        
        const SizedBox(height: 32),
        _buildInfoCard(),
        const SizedBox(height: 20),
      ],
    );
  }

  // --- STEP 2: SUMMARY ---
  Widget _buildSummaryStep() {
    return Column(
      key: const ValueKey(2),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Consultation Summary', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        _buildSummaryTile('Selected Date', 'Tuesday, Oct 24, 2023', Icons.calendar_today, Colors.blue[100]!, Colors.blue),
        const SizedBox(height: 12),
        _buildSummaryTile('Time Slot', '09:30 AM — 10:00 AM', Icons.access_time, Colors.green[100]!, Colors.green),
        const SizedBox(height: 32),
        const Text('Consultation Type', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        _buildSelectableTile('Video Call', 'Secure face-to-face call', Icons.videocam_outlined, _consultationType == 'Video Call', () => setState(() => _consultationType = 'Video Call')),
        const SizedBox(height: 12),
        _buildSelectableTile('Audio Call', 'Voice only consultation', Icons.phone_outlined, _consultationType == 'Audio Call', () => setState(() => _consultationType = 'Audio Call')),
        const SizedBox(height: 12),
        _buildSelectableTile('Clinic Visit', 'In-person at Central Clinic', Icons.medical_services_outlined, _consultationType == 'Clinic Visit', () => setState(() => _consultationType = 'Clinic Visit')),
        const SizedBox(height: 32),
        const Text('Payment Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        _buildPaymentBreakdown(),
        const SizedBox(height: 40),
      ],
    );
  }

  // --- STEP 3: PAYMENT ---
  Widget _buildPaymentStep() {
    return Column(
      key: const ValueKey(3),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildExpandableHeader(),
        const SizedBox(height: 40),
        const Text('Payment Method', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 20),
        _buildPaymentMethodTile('Credit/Debit Card', 'Visa, Mastercard, AMEX', Icons.credit_card, _paymentMethod == 'Credit/Debit Card'),
        const SizedBox(height: 16),
        _buildPaymentMethodTile('PayPal', 'Secure checkout with PayPal', Icons.account_balance_wallet_outlined, _paymentMethod == 'PayPal'),
        const SizedBox(height: 16),
        _buildPaymentMethodTile('Insurance', 'Link your medical provider', Icons.security_outlined, _paymentMethod == 'Insurance'),
      ],
    );
  }

  // --- WIDGET BUILDERS ---

  Widget _buildFileTile(PlatformFile file, int index) {
    String extension = file.extension?.toUpperCase() ?? 'FILE';
    String size = '${(file.size / 1024 / 1024).toStringAsFixed(2)} MB';
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.grey[100]!)),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: extension == 'PDF' ? Colors.red[50] : Colors.blue[50], 
              borderRadius: BorderRadius.circular(10)
            ),
            child: Icon(
              extension == 'PDF' ? Icons.picture_as_pdf : Icons.image_outlined, 
              color: extension == 'PDF' ? Colors.red : Colors.blue, 
              size: 24
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(file.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14), overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Text('$size • Uploaded today', style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
          IconButton(
            onPressed: () => _removeFile(index),
            icon: const Icon(Icons.delete_outline, color: Colors.black54),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectableCard(String title, IconData icon, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: 100,
        decoration: BoxDecoration(
          color: isSelected ? primaryTeal.withValues(alpha: 0.05) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? primaryTeal : Colors.grey[200]!, width: isSelected ? 2 : 1),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: isSelected ? primaryTeal : Colors.grey[500], size: 28),
            const SizedBox(height: 8),
            Text(title, style: TextStyle(color: isSelected ? Colors.black : Colors.grey[600], fontWeight: FontWeight.bold, fontSize: 14)),
          ],
        ),
      ),
    );
  }

  Widget _buildDashedUploadBox() {
    return CustomPaint(
      painter: DashRectPainter(color: primaryTeal.withValues(alpha: 0.4)),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 30),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(15)),
        child: Column(
          children: [
            const Icon(Icons.cloud_upload_outlined, color: primaryTeal, size: 32),
            const SizedBox(height: 8),
            const Text('Drop files here or browse', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 4),
            Text('PDF, JPG, PNG (Max 10MB)', style: TextStyle(color: Colors.grey[500], fontSize: 11)),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: primaryTeal.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(25)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.info_outline, color: primaryTeal),
              const SizedBox(width: 10),
              const Text('WHY THIS MATTERS', style: TextStyle(color: primaryTeal, fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 0.5)),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Sharing detailed symptoms and records helps your physician prepare for the call, ensuring a more accurate diagnosis and effective treatment plan.',
            style: TextStyle(color: primaryTeal.withValues(alpha: 0.8), fontSize: 13, height: 1.5, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryTile(String label, String value, IconData icon, Color bg, Color iconColor) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.grey[100]!)),
      child: Row(
        children: [
          Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: iconColor)),
          const SizedBox(width: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(color: Colors.grey[500], fontSize: 13, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSelectableTile(String title, String desc, IconData icon, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: isSelected ? primaryTeal.withValues(alpha: 0.05) : Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: isSelected ? primaryTeal : Colors.grey[100]!, width: isSelected ? 2 : 1)),
        child: Row(
          children: [
            Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: isSelected ? primaryTeal : Colors.grey[100]!, borderRadius: BorderRadius.circular(10)), child: Icon(icon, color: isSelected ? Colors.white : Colors.grey[600])),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 4),
                  Text(desc, style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                ],
              ),
            ),
            if (isSelected) const Icon(Icons.check_circle, color: primaryTeal),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentBreakdown() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(25), border: Border.all(color: Colors.grey[100]!)),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(color: const Color(0xFFF5F5F5), borderRadius: BorderRadius.circular(15)),
            child: Row(
              children: [
                const SizedBox(width: 16),
                const Expanded(child: TextField(decoration: InputDecoration(hintText: 'Promo code', border: InputBorder.none, hintStyle: TextStyle(fontSize: 14)))),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: primaryTeal, elevation: 0, padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  child: const Text('Apply', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
          _buildPriceRow('Consultation Fee', '₹120.00'),
          const SizedBox(height: 12),
          _buildPriceRow('Service Fee', '₹12.50'),
          const SizedBox(height: 12),
          _buildPriceRow('Discount (PROMO20)', '-₹20.00', isDiscount: true),
          const Padding(padding: EdgeInsets.symmetric(vertical: 20), child: Divider()),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total Amount', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const Text('₹112.50', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: primaryTeal)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(String label, String val, {bool isDiscount = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: isDiscount ? Colors.green : Colors.grey[600], fontWeight: isDiscount ? FontWeight.bold : FontWeight.normal)),
        Text(val, style: TextStyle(fontWeight: FontWeight.bold, color: isDiscount ? Colors.green : Colors.black87)),
      ],
    );
  }

  Widget _buildExpandableHeader() {
    return GestureDetector(
      onTap: () => setState(() => _isSummaryExpanded = !_isSummaryExpanded),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        decoration: BoxDecoration(color: primaryTeal.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(15)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Text('Total Amount', style: TextStyle(color: primaryTeal, fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(width: 8),
                AnimatedRotation(turns: _isSummaryExpanded ? 0.5 : 0.0, duration: const Duration(milliseconds: 200), child: const Icon(Icons.keyboard_arrow_down, color: primaryTeal)),
              ],
            ),
            const Text('₹112.50', style: TextStyle(color: primaryTeal, fontWeight: FontWeight.w900, fontSize: 18)),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethodTile(String title, String desc, IconData icon, bool isSelected) {
    return GestureDetector(
      onTap: () => setState(() => _paymentMethod = title),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: isSelected ? primaryTeal : Colors.grey[100]!, width: isSelected ? 2 : 1)),
        child: Row(
          children: [
            Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: const Color(0xFFF5F5F5), borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: Colors.black87)),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 4),
                  Text(desc, style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                ],
              ),
            ),
            Container(width: 24, height: 24, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: isSelected ? primaryTeal : Colors.grey[300]!, width: isSelected ? 6 : 2))),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    bool isStep1 = _currentStep == 1;
    bool isValid = !isStep1 || _isStep1Valid();
    String btnText = _currentStep == 3 ? 'Confirm & Pay' : (_currentStep == 2 ? 'Continue to Payment' : 'Continue');
    
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
      decoration: const BoxDecoration(color: Colors.white),
      child: ElevatedButton(
        onPressed: isValid ? () {
          FocusScope.of(context).unfocus();
          if (_currentStep < 3) {
            setState(() => _currentStep++);
          } else {
            _showSuccessDialog();
          }
        } : null,
        style: ElevatedButton.styleFrom(backgroundColor: primaryTeal, disabledBackgroundColor: Colors.grey[300], foregroundColor: Colors.white, minimumSize: const Size(double.infinity, 60), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)), elevation: 0),
        child: Text(btnText, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ),
    );
  }

  void _showSuccessDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
        child: Column(
          children: [
            const SizedBox(height: 60),
            const Icon(Icons.check_circle, color: primaryTeal, size: 100),
            const SizedBox(height: 30),
            const Text('Booking Successful!', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            const Text('Your appointment has been confirmed.', style: TextStyle(color: Colors.grey)),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
                style: ElevatedButton.styleFrom(backgroundColor: primaryTeal, foregroundColor: Colors.white, minimumSize: const Size(double.infinity, 60), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
                child: const Text('Back to Home', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCircularIcon({required IconData icon, required VoidCallback onPressed}) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(50),
      child: Container(
        width: 44, height: 44,
        decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 4, offset: const Offset(0, 2))]),
        child: Icon(icon, color: Colors.black87, size: 26),
      ),
    );
  }
}

class DashRectPainter extends CustomPainter {
  final Color color;
  DashRectPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    double dashWidth = 8, dashSpace = 4;
    final paint = Paint()..color = color..strokeWidth = 1.5..style = PaintingStyle.stroke;
    double startX = 0;
    while (startX < size.width) {
      canvas.drawLine(Offset(startX, 0), Offset(startX + dashWidth, 0), paint);
      startX += dashWidth + dashSpace;
    }
    double startY = 0;
    while (startY < size.height) {
      canvas.drawLine(Offset(size.width, startY), Offset(size.width, startY + dashWidth), paint);
      startY += dashWidth + dashSpace;
    }
    startX = size.width;
    while (startX > 0) {
      canvas.drawLine(Offset(startX, size.height), Offset(startX - dashWidth, size.height), paint);
      startX -= dashWidth + dashSpace;
    }
    startY = size.height;
    while (startY > 0) {
      canvas.drawLine(Offset(0, startY), Offset(0, startY - dashWidth), paint);
      startY -= dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
