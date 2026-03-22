import 'package:freezed_annotation/freezed_annotation.dart';

part 'product_name.freezed.dart';
part 'product_name.g.dart';

@freezed
class ProductName with _$ProductName {
  const factory ProductName({
    required String name,
    required String category,
  }) = _ProductName;

  factory ProductName.fromJson(Map<String, dynamic> json) =>
      _$ProductNameFromJson(json);
}
