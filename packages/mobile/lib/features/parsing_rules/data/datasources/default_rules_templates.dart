import '../../domain/entities/parsing_rule.dart';

class DefaultRuleTemplate {
  final String name;
  final String description;
  final List<String> triggerWords;
  final String amountPattern;
  final String? datePattern;
  final SourceType sourceType;
  final int priority;

  const DefaultRuleTemplate({
    required this.name,
    required this.description,
    required this.triggerWords,
    required this.amountPattern,
    this.datePattern,
    required this.sourceType,
    this.priority = 0,
  });

  ParsingRule toParsingRule() {
    final now = DateTime.now();
    return ParsingRule(
      id: 'template_${now.millisecondsSinceEpoch}_$name',
      name: name,
      triggerWords: triggerWords,
      amountPattern: amountPattern,
      datePattern: datePattern,
      categoryId: null,
      sourceType: sourceType,
      isEnabled: true,
      priority: priority,
      createdAt: now,
      updatedAt: now,
    );
  }
}

class DefaultRulesTemplates {
  static const List<DefaultRuleTemplate> templates = [
    DefaultRuleTemplate(
      name: 'HDFC Bank SMS',
      description: 'Parses debit notifications from HDFC Bank',
      triggerWords: ['HDFC', 'debit', 'account'],
      amountPattern: r'(?:Rs\.?|INR)\s*([\d,]+\.?\d*)',
      datePattern: r'(\d{2}-\w{3}-\d{4})',
      sourceType: SourceType.sms,
      priority: 10,
    ),
    DefaultRuleTemplate(
      name: 'ICICI Bank SMS',
      description: 'Parses debit notifications from ICICI Bank',
      triggerWords: ['ICICI', 'debit', 'account'],
      amountPattern: r'(?:Rs\.?|INR)\s*([\d,]+\.?\d*)',
      datePattern: r'(\d{2}/\d{2}/\d{4})',
      sourceType: SourceType.sms,
      priority: 10,
    ),
    DefaultRuleTemplate(
      name: 'SBI SMS',
      description: 'Parses debit notifications from State Bank of India',
      triggerWords: ['SBI', 'debit', 'INDB'],
      amountPattern: r'INR\s*([\d,]+\.?\d*)',
      datePattern: r'(\d{2}-\w{3}-\d{2})',
      sourceType: SourceType.sms,
      priority: 10,
    ),
    DefaultRuleTemplate(
      name: 'UPI Payment SMS',
      description:
          'Parses UPI payment notifications (PhonePe, Google Pay, Paytm)',
      triggerWords: ['UPI', 'debited', 'credited', 'paid'],
      amountPattern: r'Rs\.?\s*([\d,]+\.?\d*)',
      datePattern: r'on\s+(\d{2}/\d{2}/\d{4})',
      sourceType: SourceType.sms,
      priority: 8,
    ),
    DefaultRuleTemplate(
      name: 'Amazon Order SMS',
      description: 'Parses Amazon order confirmation and delivery SMS',
      triggerWords: ['Amazon', 'order', 'delivered', 'dispatched'],
      amountPattern: r'(?:Rs\.?|INR)\s*([\d,]+\.?\d*)',
      sourceType: SourceType.sms,
      priority: 5,
    ),

    DefaultRuleTemplate(
      name: 'Amazon Order Email',
      description: 'Parses Amazon order emails',
      triggerWords: ['Amazon', 'order', 'has been dispatched'],
      amountPattern: r'Order\s+Total:\s*[\D]*([\d,]+\.?\d*)',
      sourceType: SourceType.email,
      priority: 7,
    ),
    DefaultRuleTemplate(
      name: 'Swiggy Order Email',
      description: 'Parses Swiggy order confirmation emails',
      triggerWords: ['Swiggy', 'order', 'confirmed'],
      amountPattern: r'Rs\.?\s*([\d,]+\.?\d*)',
      sourceType: SourceType.email,
      priority: 5,
    ),
    DefaultRuleTemplate(
      name: 'Zomato Order Email',
      description: 'Parses Zomato order confirmation emails',
      triggerWords: ['Zomato', 'order', 'confirmed'],
      amountPattern: r'Rs\.?\s*([\d,]+\.?\d*)',
      sourceType: SourceType.email,
      priority: 5,
    ),
    DefaultRuleTemplate(
      name: 'Flipkart Order Email',
      description: 'Parses Flipkart order emails',
      triggerWords: ['Flipkart', 'order', 'confirmed'],
      amountPattern: r'Rs\.?\s*([\d,]+\.?\d*)',
      sourceType: SourceType.email,
      priority: 5,
    ),
    DefaultRuleTemplate(
      name: 'Generic Payment Email',
      description: 'Parses generic payment confirmation emails',
      triggerWords: ['payment', 'confirmed', 'received'],
      amountPattern: r'[\D]*([\d,]+\.?\d*)',
      sourceType: SourceType.email,
      priority: 3,
    ),
  ];
}
