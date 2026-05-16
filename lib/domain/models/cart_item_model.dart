enum CartItemType { card, bundle }

class CartItem {
  final CartItemType type;
  final String id;

  const CartItem({required this.type, required this.id});

  String get key => '${type.name}:$id';

  Map<String, dynamic> toJson() => {
        'type': type.name,
        'id': id,
      };

  factory CartItem.fromJson(Map<String, dynamic> json) {
    final typeName = json['type'] as String? ?? 'card';
    return CartItem(
      type: CartItemType.values.firstWhere(
        (t) => t.name == typeName,
        orElse: () => CartItemType.card,
      ),
      id: json['id'] as String,
    );
  }
}
