import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/product.dart';

class ProductTile extends StatelessWidget {
  final Product product;
  const ProductTile({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final expiry = product.expirationDate != null
        ? DateFormat('yyyy-MM-dd').format(product.expirationDate!)
        : '—';
    final isExpired = product.expirationDate != null &&
        product.expirationDate!.isBefore(DateTime.now());
    return ListTile(
      title: Text(product.name),
      subtitle: Text('${product.category} • $expiry'),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text('qty: ${product.quantity}'),
          if (isExpired)
            const Text('EXPIRED', style: TextStyle(color: Colors.red, fontSize: 10)),
        ],
      ),
    );
  }
}
