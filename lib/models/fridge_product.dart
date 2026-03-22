class FridgeProduct {
  final String id;
  final String category;
  final String name;
  final String barcode;
  final int quantity;
  final DateTime insertionDate;
  final DateTime expiryDate;

  const FridgeProduct({
    required this.id,
    required this.category,
    required this.name,
    required this.barcode,
    required this.quantity,
    required this.insertionDate,
    required this.expiryDate,
  });

  FridgeProduct copyWith({
    String? id,
    String? category,
    String? name,
    String? barcode,
    int? quantity,
    DateTime? insertionDate,
    DateTime? expiryDate,
  }) {
    return FridgeProduct(
      id: id ?? this.id,
      category: category ?? this.category,
      name: name ?? this.name,
      barcode: barcode ?? this.barcode,
      quantity: quantity ?? this.quantity,
      insertionDate: insertionDate ?? this.insertionDate,
      expiryDate: expiryDate ?? this.expiryDate,
    );
  }
}
