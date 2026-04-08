import 'package:flutter/material.dart';
import '../models/payment_method.dart';

class PaymentMethodsScreen extends StatefulWidget {
  const PaymentMethodsScreen({super.key});

  @override
  State<PaymentMethodsScreen> createState() => _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends State<PaymentMethodsScreen> {
  static const Color primaryTeal = Color(0xFF26A9B1);
  static const Color backgroundGray = Color(0xFFF8F9FA);

  List<PaymentMethod> _mockPayments = [
    PaymentMethod(
      id: '1',
      type: PaymentMethodType.bank,
      title: 'HDFC Bank',
      subtitle: '**** 1234',
      iconPath: 'assets/Frame 8.png', 
    ),
    PaymentMethod(
      id: '2',
      type: PaymentMethodType.upi,
      title: 'Google Pay',
      subtitle: 'user@okaxis',
      iconPath: 'assets/Frame 7.png',
    ),
  ];

  bool _isLoading = false;

  Future<void> _fetchPaymentMethods() async {
    setState(() => _isLoading = true);
    // TODO: Integrate real API here
    await Future.delayed(const Duration(seconds: 1));
    setState(() => _isLoading = false);
  }

  void _deleteMethod(String id) {
    setState(() {
      _mockPayments.removeWhere((item) => item.id == id);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Payment method deleted')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundGray,
      appBar: _buildAppBar(),
      body: RefreshIndicator(
        onRefresh: _fetchPaymentMethods,
        color: primaryTeal,
        child: _mockPayments.isEmpty ? _buildEmptyState() : _buildMethodsList(),
      ),
      bottomNavigationBar: _buildAddButton(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 20),
        onPressed: () => Navigator.pop(context),
      ),
      title: const Text(
        'Payment Methods',
        style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
      ),
      centerTitle: true,
    );
  }

  Widget _buildMethodsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: _mockPayments.length,
      itemBuilder: (context, index) {
        final method = _mockPayments[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04), // Restored to withOpacity
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: primaryTeal.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                method.type == PaymentMethodType.card 
                    ? Icons.credit_card 
                    : method.type == PaymentMethodType.upi 
                        ? Icons.qr_code_2 
                        : Icons.account_balance,
                color: primaryTeal,
              ),
            ),
            title: Text(
              method.title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            subtitle: Text(
              method.subtitle,
              style: TextStyle(color: Colors.grey[600], fontSize: 13),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit_outlined, color: Colors.grey),
                  onPressed: () => _showPaymentMethodForm(method.type, existing: method),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                  onPressed: () => _deleteMethod(method.id),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              color: primaryTeal.withOpacity(0.05),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.payment, size: 80, color: primaryTeal),
          ),
          const SizedBox(height: 24),
          const Text(
            'No payment methods added yet',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 8),
          Text(
            'Add a payment method for easier bookings',
            style: TextStyle(color: Colors.grey[600], fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildAddButton() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: ElevatedButton(
          onPressed: _showAddMethodBS,
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryTeal,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 56),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 0,
          ),
          child: const Text('Add New Method', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        ),
      ),
    );
  }

  void _showAddMethodBS() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Add New Method',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            _buildBSOption(Icons.account_balance, 'Bank Account', 'Add your savings or current account', () {
              Navigator.pop(context);
              _showPaymentMethodForm(PaymentMethodType.bank);
            }),
            _buildBSOption(Icons.qr_code_2, 'UPI ID', 'Link your GPay, PhonePe, or BHIM', () {
              Navigator.pop(context);
              _showPaymentMethodForm(PaymentMethodType.upi);
            }),
            _buildBSOption(Icons.credit_card, 'Debit/Credit Card', 'Add your Visa, Master, or Rupay', () {
              Navigator.pop(context);
              _showPaymentMethodForm(PaymentMethodType.card);
            }),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildBSOption(IconData icon, String title, String subtitle, VoidCallback onTap) {
    return ListTile(
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: primaryTeal.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: primaryTeal),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
      trailing: const Icon(Icons.chevron_right, size: 20),
    );
  }

  void _showPaymentMethodForm(PaymentMethodType type, {PaymentMethod? existing}) {
    // Define controllers and pre-fill if editing
    final TextEditingController controller1 = TextEditingController(text: existing?.title);
    final TextEditingController controller2 = TextEditingController(text: existing?.subtitle);
    final TextEditingController controller3 = TextEditingController();

    // If it's a card subtype, subtitle is usually the masked number, 
    // but for editing simplicity we'll just pre-fill what we have.
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) {
          return Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        existing == null ? 'Add ${type.name.toUpperCase()} Info' : 'Edit ${existing.title}',
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close, color: Colors.grey),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (type == PaymentMethodType.bank) ...[
                    _buildTextField('Bank Name', controller1, TextInputType.text),
                    const SizedBox(height: 16),
                    _buildTextField('Account Number', controller2, TextInputType.number),
                    const SizedBox(height: 16),
                    _buildTextField('IFSC Code', controller3, TextInputType.text),
                  ] else if (type == PaymentMethodType.upi) ...[
                    _buildTextField('Service Name (e.g. GPay)', controller1, TextInputType.text),
                    const SizedBox(height: 16),
                    _buildTextField('UPI ID', controller2, TextInputType.emailAddress),
                  ] else ...[
                    _buildTextField('Card Brand', controller1, TextInputType.text),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(child: _buildTextField('Card Number / Mask', controller2, TextInputType.number)),
                        const SizedBox(width: 16),
                        Expanded(child: _buildTextField('CVV', controller3, TextInputType.number)),
                      ],
                    ),
                  ],
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      if (controller1.text.isEmpty || controller2.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Please fill in required fields')),
                        );
                        return;
                      }

                      String subtitleText = controller2.text;
                      if (type == PaymentMethodType.bank) {
                        // Mask account number for display e.g. **** 1234
                        String acc = controller2.text;
                        String masked = acc.length > 4 ? '**** ${acc.substring(acc.length - 4)}' : acc;
                        subtitleText = masked;
                      }
                      
                      setState(() {
                        if (existing != null) {
                          // Update existing
                          int index = _mockPayments.indexWhere((m) => m.id == existing.id);
                          if (index != -1) {
                            _mockPayments[index] = PaymentMethod(
                              id: existing.id,
                              type: existing.type,
                              title: controller1.text,
                              subtitle: subtitleText,
                              iconPath: existing.iconPath,
                            );
                          }
                        } else {
                          // Add new
                          _mockPayments.add(PaymentMethod(
                            id: DateTime.now().millisecondsSinceEpoch.toString(),
                            type: type,
                            title: controller1.text,
                            subtitle: subtitleText,
                            iconPath: type == PaymentMethodType.bank ? 'assets/Frame 8.png' : 'assets/Frame 7.png',
                          ));
                        }
                      });

                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(existing == null ? 'Method added successfully' : 'Method updated successfully'),
                          backgroundColor: primaryTeal,
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryTeal,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 56),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                    child: Text(existing == null ? 'Confirm' : 'Save Changes', style: const TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          );
        }
      ),
    ).then((_) {
      controller1.dispose();
      controller2.dispose();
      controller3.dispose();
    });
  }

  Widget _buildTextField(String label, TextEditingController controller, TextInputType type) {
    return TextField(
      controller: controller,
      keyboardType: type,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.grey, fontSize: 14),
        filled: true,
        fillColor: backgroundGray,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryTeal, width: 1),
        ),
      ),
    );
  }
}
