enum PaymentMethodType { upi, bank, card }

class PaymentMethod {
  final String id;
  final PaymentMethodType type;
  final String title;
  final String subtitle;
  final String iconPath;

  PaymentMethod({
    required this.id,
    required this.type,
    required this.title,
    required this.subtitle,
    required this.iconPath,
  });
}
