import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/cart_provider.dart';

/// Payment screen with simulated payment form
class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _cardNumberController = TextEditingController();
  final _cardHolderController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();
  bool _isProcessing = false;

  @override
  void dispose() {
    _cardNumberController.dispose();
    _cardHolderController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = context.watch<CartProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Payment',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Order Summary Card
              _buildOrderSummary(cartProvider),
              const SizedBox(height: 24),

              // Payment Form Title
              Text(
                'Payment Information',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              // Card Number
              _buildCardNumberField(),
              const SizedBox(height: 16),

              // Card Holder Name
              _buildCardHolderField(),
              const SizedBox(height: 16),

              // Expiry and CVV
              Row(
                children: [
                  Expanded(child: _buildExpiryField()),
                  const SizedBox(width: 16),
                  Expanded(child: _buildCVVField()),
                ],
              ),
              const SizedBox(height: 32),

              // Pay Now Button
              _buildPayButton(cartProvider),
              const SizedBox(height: 16),

              // Disclaimer
              _buildDisclaimer(),
            ],
          ),
        ),
      ),
    );
  }

  /// Order summary card
  Widget _buildOrderSummary(CartProvider cartProvider) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Order Summary',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Items (${cartProvider.itemCount})',
                  style: GoogleFonts.poppins(color: Colors.grey[600]),
                ),
                Text(
                  '\$${cartProvider.totalAmount.toStringAsFixed(2)}',
                  style: GoogleFonts.poppins(color: Colors.grey[600]),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Shipping',
                  style: GoogleFonts.poppins(color: Colors.grey[600]),
                ),
                Text(
                  'FREE',
                  style: GoogleFonts.poppins(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '\$${cartProvider.totalAmount.toStringAsFixed(2)}',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Card number field
  Widget _buildCardNumberField() {
    return TextFormField(
      controller: _cardNumberController,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: 'Card Number',
        hintText: '1234 5678 9012 3456',
        prefixIcon: const Icon(Icons.credit_card),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.grey[50],
      ),
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(16),
        _CardNumberFormatter(),
      ],
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter card number';
        }
        if (value.replaceAll(' ', '').length != 16) {
          return 'Card number must be 16 digits';
        }
        return null;
      },
    );
  }

  /// Card holder field
  Widget _buildCardHolderField() {
    return TextFormField(
      controller: _cardHolderController,
      textCapitalization: TextCapitalization.words,
      decoration: InputDecoration(
        labelText: 'Card Holder Name',
        hintText: 'John Doe',
        prefixIcon: const Icon(Icons.person),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.grey[50],
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter card holder name';
        }
        return null;
      },
    );
  }

  /// Expiry field
  Widget _buildExpiryField() {
    return TextFormField(
      controller: _expiryController,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: 'Expiry Date',
        hintText: 'MM/YY',
        prefixIcon: const Icon(Icons.calendar_today),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.grey[50],
      ),
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(4),
        _ExpiryDateFormatter(),
      ],
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Enter expiry';
        }
        if (value.length != 5) {
          return 'Invalid format';
        }
        return null;
      },
    );
  }

  /// CVV field
  Widget _buildCVVField() {
    return TextFormField(
      controller: _cvvController,
      keyboardType: TextInputType.number,
      obscureText: true,
      decoration: InputDecoration(
        labelText: 'CVV',
        hintText: '123',
        prefixIcon: const Icon(Icons.lock),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.grey[50],
      ),
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(3),
      ],
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Enter CVV';
        }
        if (value.length != 3) {
          return 'Invalid CVV';
        }
        return null;
      },
    );
  }

  /// Pay now button
  Widget _buildPayButton(CartProvider cartProvider) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isProcessing ? null : () => _processPayment(cartProvider),
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Theme.of(context).colorScheme.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: _isProcessing
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Text(
                'Pay Now - \$${cartProvider.totalAmount.toStringAsFixed(2)}',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }

  /// Disclaimer
  Widget _buildDisclaimer() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.amber[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.amber[200]!),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: Colors.amber[700], size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'This is a simulated payment. No real transaction will occur.',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Colors.amber[900],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Process payment (simulated)
  Future<void> _processPayment(CartProvider cartProvider) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    // Simulate payment processing
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    setState(() {
      _isProcessing = false;
    });

    // Clear cart after successful payment
    await cartProvider.clearCart();

    if (!mounted) return;

    // Show success dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green[50],
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_circle,
                color: Colors.green[600],
                size: 64,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Payment Successful!',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your order has been placed successfully.',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600]),
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () {
                // Pop dialog and payment screen
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text('Continue Shopping'),
            ),
          ),
        ],
      ),
    );
  }
}

/// Card number formatter (adds space every 4 digits)
class _CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.replaceAll(' ', '');
    final buffer = StringBuffer();

    for (int i = 0; i < text.length; i++) {
      buffer.write(text[i]);
      if ((i + 1) % 4 == 0 && i + 1 != text.length) {
        buffer.write(' ');
      }
    }

    final string = buffer.toString();
    return TextEditingValue(
      text: string,
      selection: TextSelection.collapsed(offset: string.length),
    );
  }
}

/// Expiry date formatter (MM/YY)
class _ExpiryDateFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text;

    if (text.length >= 2) {
      final month = text.substring(0, 2);
      final year = text.length > 2 ? text.substring(2) : '';
      final formatted = month + (year.isNotEmpty ? '/$year' : '');

      return TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
    }

    return newValue;
  }
}
