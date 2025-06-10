// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'delivery_item_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$DeliveryItem {
  String get productId => throw _privateConstructorUsedError;
  String get productName => throw _privateConstructorUsedError;
  int get quantity => throw _privateConstructorUsedError;
  double get price => throw _privateConstructorUsedError;

  /// Create a copy of DeliveryItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DeliveryItemCopyWith<DeliveryItem> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DeliveryItemCopyWith<$Res> {
  factory $DeliveryItemCopyWith(
    DeliveryItem value,
    $Res Function(DeliveryItem) then,
  ) = _$DeliveryItemCopyWithImpl<$Res, DeliveryItem>;
  @useResult
  $Res call({String productId, String productName, int quantity, double price});
}

/// @nodoc
class _$DeliveryItemCopyWithImpl<$Res, $Val extends DeliveryItem>
    implements $DeliveryItemCopyWith<$Res> {
  _$DeliveryItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DeliveryItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? productId = null,
    Object? productName = null,
    Object? quantity = null,
    Object? price = null,
  }) {
    return _then(
      _value.copyWith(
            productId:
                null == productId
                    ? _value.productId
                    : productId // ignore: cast_nullable_to_non_nullable
                        as String,
            productName:
                null == productName
                    ? _value.productName
                    : productName // ignore: cast_nullable_to_non_nullable
                        as String,
            quantity:
                null == quantity
                    ? _value.quantity
                    : quantity // ignore: cast_nullable_to_non_nullable
                        as int,
            price:
                null == price
                    ? _value.price
                    : price // ignore: cast_nullable_to_non_nullable
                        as double,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$DeliveryItemImplCopyWith<$Res>
    implements $DeliveryItemCopyWith<$Res> {
  factory _$$DeliveryItemImplCopyWith(
    _$DeliveryItemImpl value,
    $Res Function(_$DeliveryItemImpl) then,
  ) = __$$DeliveryItemImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String productId, String productName, int quantity, double price});
}

/// @nodoc
class __$$DeliveryItemImplCopyWithImpl<$Res>
    extends _$DeliveryItemCopyWithImpl<$Res, _$DeliveryItemImpl>
    implements _$$DeliveryItemImplCopyWith<$Res> {
  __$$DeliveryItemImplCopyWithImpl(
    _$DeliveryItemImpl _value,
    $Res Function(_$DeliveryItemImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of DeliveryItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? productId = null,
    Object? productName = null,
    Object? quantity = null,
    Object? price = null,
  }) {
    return _then(
      _$DeliveryItemImpl(
        productId:
            null == productId
                ? _value.productId
                : productId // ignore: cast_nullable_to_non_nullable
                    as String,
        productName:
            null == productName
                ? _value.productName
                : productName // ignore: cast_nullable_to_non_nullable
                    as String,
        quantity:
            null == quantity
                ? _value.quantity
                : quantity // ignore: cast_nullable_to_non_nullable
                    as int,
        price:
            null == price
                ? _value.price
                : price // ignore: cast_nullable_to_non_nullable
                    as double,
      ),
    );
  }
}

/// @nodoc

class _$DeliveryItemImpl extends _DeliveryItem {
  _$DeliveryItemImpl({
    this.productId = '',
    this.productName = '',
    this.quantity = 0,
    this.price = 0.0,
  }) : super._();

  @override
  @JsonKey()
  final String productId;
  @override
  @JsonKey()
  final String productName;
  @override
  @JsonKey()
  final int quantity;
  @override
  @JsonKey()
  final double price;

  @override
  String toString() {
    return 'DeliveryItem(productId: $productId, productName: $productName, quantity: $quantity, price: $price)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DeliveryItemImpl &&
            (identical(other.productId, productId) ||
                other.productId == productId) &&
            (identical(other.productName, productName) ||
                other.productName == productName) &&
            (identical(other.quantity, quantity) ||
                other.quantity == quantity) &&
            (identical(other.price, price) || other.price == price));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, productId, productName, quantity, price);

  /// Create a copy of DeliveryItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DeliveryItemImplCopyWith<_$DeliveryItemImpl> get copyWith =>
      __$$DeliveryItemImplCopyWithImpl<_$DeliveryItemImpl>(this, _$identity);
}

abstract class _DeliveryItem extends DeliveryItem {
  factory _DeliveryItem({
    final String productId,
    final String productName,
    final int quantity,
    final double price,
  }) = _$DeliveryItemImpl;
  _DeliveryItem._() : super._();

  @override
  String get productId;
  @override
  String get productName;
  @override
  int get quantity;
  @override
  double get price;

  /// Create a copy of DeliveryItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DeliveryItemImplCopyWith<_$DeliveryItemImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
