enum PropertyType { apartment, office, shop, other }

class Property {
  const Property({
    required this.id,
    required this.name,
    required this.address,
    required this.type,
    this.photoPath,
  });

  final String id;
  final String name;
  final String address;
  final PropertyType type;
  final String? photoPath;

  String get typeLabel {
    switch (type) {
      case PropertyType.apartment:
        return 'Daire';
      case PropertyType.office:
        return 'Ofis';
      case PropertyType.shop:
        return 'Dükkan';
      case PropertyType.other:
        return 'Diğer';
    }
  }

  Property copyWith({
    String? name,
    String? address,
    PropertyType? type,
    String? photoPath,
  }) {
    return Property(
      id: id,
      name: name ?? this.name,
      address: address ?? this.address,
      type: type ?? this.type,
      photoPath: photoPath ?? this.photoPath,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'address': address,
        'type': type.name,
        'photoPath': photoPath,
      };

  factory Property.fromJson(Map<String, dynamic> json) => Property(
        id: json['id'] as String,
        name: json['name'] as String,
        address: json['address'] as String,
        type: PropertyType.values.byName(json['type'] as String),
        photoPath: json['photoPath'] as String?,
      );
}
