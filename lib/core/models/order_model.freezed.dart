// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'order_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

OrderModel _$OrderModelFromJson(Map<String, dynamic> json) {
  return _OrderModel.fromJson(json);
}

/// @nodoc
mixin _$OrderModel {
  String get id => throw _privateConstructorUsedError;
  String get buyerId => throw _privateConstructorUsedError;
  String get buyerName => throw _privateConstructorUsedError;
  String get buyerPhone => throw _privateConstructorUsedError;
  String get sellerId => throw _privateConstructorUsedError;
  String get sellerName => throw _privateConstructorUsedError;
  List<OrderItem> get items => throw _privateConstructorUsedError;
  double get totalAmount => throw _privateConstructorUsedError;
  String get deliveryAddress => throw _privateConstructorUsedError;
  OrderStatus get status => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;
  DateTime? get acceptedAt => throw _privateConstructorUsedError;
  DateTime? get readyAt => throw _privateConstructorUsedError;
  DateTime? get shippedAt => throw _privateConstructorUsedError;
  DateTime? get deliveredAt => throw _privateConstructorUsedError;
  DateTime? get receivedAt => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;
  String? get rejectionReason => throw _privateConstructorUsedError;

  /// Serializes this OrderModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of OrderModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $OrderModelCopyWith<OrderModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $OrderModelCopyWith<$Res> {
  factory $OrderModelCopyWith(
    OrderModel value,
    $Res Function(OrderModel) then,
  ) = _$OrderModelCopyWithImpl<$Res, OrderModel>;
  @useResult
  $Res call({
    String id,
    String buyerId,
    String buyerName,
    String buyerPhone,
    String sellerId,
    String sellerName,
    List<OrderItem> items,
    double totalAmount,
    String deliveryAddress,
    OrderStatus status,
    DateTime createdAt,
    DateTime updatedAt,
    DateTime? acceptedAt,
    DateTime? readyAt,
    DateTime? shippedAt,
    DateTime? deliveredAt,
    DateTime? receivedAt,
    String? notes,
    String? rejectionReason,
  });
}

/// @nodoc
class _$OrderModelCopyWithImpl<$Res, $Val extends OrderModel>
    implements $OrderModelCopyWith<$Res> {
  _$OrderModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of OrderModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? buyerId = null,
    Object? buyerName = null,
    Object? buyerPhone = null,
    Object? sellerId = null,
    Object? sellerName = null,
    Object? items = null,
    Object? totalAmount = null,
    Object? deliveryAddress = null,
    Object? status = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? acceptedAt = freezed,
    Object? readyAt = freezed,
    Object? shippedAt = freezed,
    Object? deliveredAt = freezed,
    Object? receivedAt = freezed,
    Object? notes = freezed,
    Object? rejectionReason = freezed,
  }) {
    return _then(
      _value.copyWith(
            id:
                null == id
                    ? _value.id
                    : id // ignore: cast_nullable_to_non_nullable
                        as String,
            buyerId:
                null == buyerId
                    ? _value.buyerId
                    : buyerId // ignore: cast_nullable_to_non_nullable
                        as String,
            buyerName:
                null == buyerName
                    ? _value.buyerName
                    : buyerName // ignore: cast_nullable_to_non_nullable
                        as String,
            buyerPhone:
                null == buyerPhone
                    ? _value.buyerPhone
                    : buyerPhone // ignore: cast_nullable_to_non_nullable
                        as String,
            sellerId:
                null == sellerId
                    ? _value.sellerId
                    : sellerId // ignore: cast_nullable_to_non_nullable
                        as String,
            sellerName:
                null == sellerName
                    ? _value.sellerName
                    : sellerName // ignore: cast_nullable_to_non_nullable
                        as String,
            items:
                null == items
                    ? _value.items
                    : items // ignore: cast_nullable_to_non_nullable
                        as List<OrderItem>,
            totalAmount:
                null == totalAmount
                    ? _value.totalAmount
                    : totalAmount // ignore: cast_nullable_to_non_nullable
                        as double,
            deliveryAddress:
                null == deliveryAddress
                    ? _value.deliveryAddress
                    : deliveryAddress // ignore: cast_nullable_to_non_nullable
                        as String,
            status:
                null == status
                    ? _value.status
                    : status // ignore: cast_nullable_to_non_nullable
                        as OrderStatus,
            createdAt:
                null == createdAt
                    ? _value.createdAt
                    : createdAt // ignore: cast_nullable_to_non_nullable
                        as DateTime,
            updatedAt:
                null == updatedAt
                    ? _value.updatedAt
                    : updatedAt // ignore: cast_nullable_to_non_nullable
                        as DateTime,
            acceptedAt:
                freezed == acceptedAt
                    ? _value.acceptedAt
                    : acceptedAt // ignore: cast_nullable_to_non_nullable
                        as DateTime?,
            readyAt:
                freezed == readyAt
                    ? _value.readyAt
                    : readyAt // ignore: cast_nullable_to_non_nullable
                        as DateTime?,
            shippedAt:
                freezed == shippedAt
                    ? _value.shippedAt
                    : shippedAt // ignore: cast_nullable_to_non_nullable
                        as DateTime?,
            deliveredAt:
                freezed == deliveredAt
                    ? _value.deliveredAt
                    : deliveredAt // ignore: cast_nullable_to_non_nullable
                        as DateTime?,
            receivedAt:
                freezed == receivedAt
                    ? _value.receivedAt
                    : receivedAt // ignore: cast_nullable_to_non_nullable
                        as DateTime?,
            notes:
                freezed == notes
                    ? _value.notes
                    : notes // ignore: cast_nullable_to_non_nullable
                        as String?,
            rejectionReason:
                freezed == rejectionReason
                    ? _value.rejectionReason
                    : rejectionReason // ignore: cast_nullable_to_non_nullable
                        as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$OrderModelImplCopyWith<$Res>
    implements $OrderModelCopyWith<$Res> {
  factory _$$OrderModelImplCopyWith(
    _$OrderModelImpl value,
    $Res Function(_$OrderModelImpl) then,
  ) = __$$OrderModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String buyerId,
    String buyerName,
    String buyerPhone,
    String sellerId,
    String sellerName,
    List<OrderItem> items,
    double totalAmount,
    String deliveryAddress,
    OrderStatus status,
    DateTime createdAt,
    DateTime updatedAt,
    DateTime? acceptedAt,
    DateTime? readyAt,
    DateTime? shippedAt,
    DateTime? deliveredAt,
    DateTime? receivedAt,
    String? notes,
    String? rejectionReason,
  });
}

/// @nodoc
class __$$OrderModelImplCopyWithImpl<$Res>
    extends _$OrderModelCopyWithImpl<$Res, _$OrderModelImpl>
    implements _$$OrderModelImplCopyWith<$Res> {
  __$$OrderModelImplCopyWithImpl(
    _$OrderModelImpl _value,
    $Res Function(_$OrderModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of OrderModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? buyerId = null,
    Object? buyerName = null,
    Object? buyerPhone = null,
    Object? sellerId = null,
    Object? sellerName = null,
    Object? items = null,
    Object? totalAmount = null,
    Object? deliveryAddress = null,
    Object? status = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? acceptedAt = freezed,
    Object? readyAt = freezed,
    Object? shippedAt = freezed,
    Object? deliveredAt = freezed,
    Object? receivedAt = freezed,
    Object? notes = freezed,
    Object? rejectionReason = freezed,
  }) {
    return _then(
      _$OrderModelImpl(
        id:
            null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                    as String,
        buyerId:
            null == buyerId
                ? _value.buyerId
                : buyerId // ignore: cast_nullable_to_non_nullable
                    as String,
        buyerName:
            null == buyerName
                ? _value.buyerName
                : buyerName // ignore: cast_nullable_to_non_nullable
                    as String,
        buyerPhone:
            null == buyerPhone
                ? _value.buyerPhone
                : buyerPhone // ignore: cast_nullable_to_non_nullable
                    as String,
        sellerId:
            null == sellerId
                ? _value.sellerId
                : sellerId // ignore: cast_nullable_to_non_nullable
                    as String,
        sellerName:
            null == sellerName
                ? _value.sellerName
                : sellerName // ignore: cast_nullable_to_non_nullable
                    as String,
        items:
            null == items
                ? _value._items
                : items // ignore: cast_nullable_to_non_nullable
                    as List<OrderItem>,
        totalAmount:
            null == totalAmount
                ? _value.totalAmount
                : totalAmount // ignore: cast_nullable_to_non_nullable
                    as double,
        deliveryAddress:
            null == deliveryAddress
                ? _value.deliveryAddress
                : deliveryAddress // ignore: cast_nullable_to_non_nullable
                    as String,
        status:
            null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                    as OrderStatus,
        createdAt:
            null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                    as DateTime,
        updatedAt:
            null == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                    as DateTime,
        acceptedAt:
            freezed == acceptedAt
                ? _value.acceptedAt
                : acceptedAt // ignore: cast_nullable_to_non_nullable
                    as DateTime?,
        readyAt:
            freezed == readyAt
                ? _value.readyAt
                : readyAt // ignore: cast_nullable_to_non_nullable
                    as DateTime?,
        shippedAt:
            freezed == shippedAt
                ? _value.shippedAt
                : shippedAt // ignore: cast_nullable_to_non_nullable
                    as DateTime?,
        deliveredAt:
            freezed == deliveredAt
                ? _value.deliveredAt
                : deliveredAt // ignore: cast_nullable_to_non_nullable
                    as DateTime?,
        receivedAt:
            freezed == receivedAt
                ? _value.receivedAt
                : receivedAt // ignore: cast_nullable_to_non_nullable
                    as DateTime?,
        notes:
            freezed == notes
                ? _value.notes
                : notes // ignore: cast_nullable_to_non_nullable
                    as String?,
        rejectionReason:
            freezed == rejectionReason
                ? _value.rejectionReason
                : rejectionReason // ignore: cast_nullable_to_non_nullable
                    as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$OrderModelImpl implements _OrderModel {
  const _$OrderModelImpl({
    required this.id,
    required this.buyerId,
    required this.buyerName,
    required this.buyerPhone,
    required this.sellerId,
    required this.sellerName,
    required final List<OrderItem> items,
    required this.totalAmount,
    required this.deliveryAddress,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.acceptedAt,
    this.readyAt,
    this.shippedAt,
    this.deliveredAt,
    this.receivedAt,
    this.notes,
    this.rejectionReason,
  }) : _items = items;

  factory _$OrderModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$OrderModelImplFromJson(json);

  @override
  final String id;
  @override
  final String buyerId;
  @override
  final String buyerName;
  @override
  final String buyerPhone;
  @override
  final String sellerId;
  @override
  final String sellerName;
  final List<OrderItem> _items;
  @override
  List<OrderItem> get items {
    if (_items is EqualUnmodifiableListView) return _items;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_items);
  }

  @override
  final double totalAmount;
  @override
  final String deliveryAddress;
  @override
  final OrderStatus status;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;
  @override
  final DateTime? acceptedAt;
  @override
  final DateTime? readyAt;
  @override
  final DateTime? shippedAt;
  @override
  final DateTime? deliveredAt;
  @override
  final DateTime? receivedAt;
  @override
  final String? notes;
  @override
  final String? rejectionReason;

  @override
  String toString() {
    return 'OrderModel(id: $id, buyerId: $buyerId, buyerName: $buyerName, buyerPhone: $buyerPhone, sellerId: $sellerId, sellerName: $sellerName, items: $items, totalAmount: $totalAmount, deliveryAddress: $deliveryAddress, status: $status, createdAt: $createdAt, updatedAt: $updatedAt, acceptedAt: $acceptedAt, readyAt: $readyAt, shippedAt: $shippedAt, deliveredAt: $deliveredAt, receivedAt: $receivedAt, notes: $notes, rejectionReason: $rejectionReason)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$OrderModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.buyerId, buyerId) || other.buyerId == buyerId) &&
            (identical(other.buyerName, buyerName) ||
                other.buyerName == buyerName) &&
            (identical(other.buyerPhone, buyerPhone) ||
                other.buyerPhone == buyerPhone) &&
            (identical(other.sellerId, sellerId) ||
                other.sellerId == sellerId) &&
            (identical(other.sellerName, sellerName) ||
                other.sellerName == sellerName) &&
            const DeepCollectionEquality().equals(other._items, _items) &&
            (identical(other.totalAmount, totalAmount) ||
                other.totalAmount == totalAmount) &&
            (identical(other.deliveryAddress, deliveryAddress) ||
                other.deliveryAddress == deliveryAddress) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.acceptedAt, acceptedAt) ||
                other.acceptedAt == acceptedAt) &&
            (identical(other.readyAt, readyAt) || other.readyAt == readyAt) &&
            (identical(other.shippedAt, shippedAt) ||
                other.shippedAt == shippedAt) &&
            (identical(other.deliveredAt, deliveredAt) ||
                other.deliveredAt == deliveredAt) &&
            (identical(other.receivedAt, receivedAt) ||
                other.receivedAt == receivedAt) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.rejectionReason, rejectionReason) ||
                other.rejectionReason == rejectionReason));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
    runtimeType,
    id,
    buyerId,
    buyerName,
    buyerPhone,
    sellerId,
    sellerName,
    const DeepCollectionEquality().hash(_items),
    totalAmount,
    deliveryAddress,
    status,
    createdAt,
    updatedAt,
    acceptedAt,
    readyAt,
    shippedAt,
    deliveredAt,
    receivedAt,
    notes,
    rejectionReason,
  ]);

  /// Create a copy of OrderModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$OrderModelImplCopyWith<_$OrderModelImpl> get copyWith =>
      __$$OrderModelImplCopyWithImpl<_$OrderModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$OrderModelImplToJson(this);
  }
}

abstract class _OrderModel implements OrderModel {
  const factory _OrderModel({
    required final String id,
    required final String buyerId,
    required final String buyerName,
    required final String buyerPhone,
    required final String sellerId,
    required final String sellerName,
    required final List<OrderItem> items,
    required final double totalAmount,
    required final String deliveryAddress,
    required final OrderStatus status,
    required final DateTime createdAt,
    required final DateTime updatedAt,
    final DateTime? acceptedAt,
    final DateTime? readyAt,
    final DateTime? shippedAt,
    final DateTime? deliveredAt,
    final DateTime? receivedAt,
    final String? notes,
    final String? rejectionReason,
  }) = _$OrderModelImpl;

  factory _OrderModel.fromJson(Map<String, dynamic> json) =
      _$OrderModelImpl.fromJson;

  @override
  String get id;
  @override
  String get buyerId;
  @override
  String get buyerName;
  @override
  String get buyerPhone;
  @override
  String get sellerId;
  @override
  String get sellerName;
  @override
  List<OrderItem> get items;
  @override
  double get totalAmount;
  @override
  String get deliveryAddress;
  @override
  OrderStatus get status;
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt;
  @override
  DateTime? get acceptedAt;
  @override
  DateTime? get readyAt;
  @override
  DateTime? get shippedAt;
  @override
  DateTime? get deliveredAt;
  @override
  DateTime? get receivedAt;
  @override
  String? get notes;
  @override
  String? get rejectionReason;

  /// Create a copy of OrderModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$OrderModelImplCopyWith<_$OrderModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

OrderItem _$OrderItemFromJson(Map<String, dynamic> json) {
  return _OrderItem.fromJson(json);
}

/// @nodoc
mixin _$OrderItem {
  String get productId => throw _privateConstructorUsedError;
  String get productName => throw _privateConstructorUsedError;
  String get productImage => throw _privateConstructorUsedError;
  int get quantity => throw _privateConstructorUsedError;
  double get pricePerUnit => throw _privateConstructorUsedError;
  double get totalPrice => throw _privateConstructorUsedError;

  /// Serializes this OrderItem to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of OrderItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $OrderItemCopyWith<OrderItem> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $OrderItemCopyWith<$Res> {
  factory $OrderItemCopyWith(OrderItem value, $Res Function(OrderItem) then) =
      _$OrderItemCopyWithImpl<$Res, OrderItem>;
  @useResult
  $Res call({
    String productId,
    String productName,
    String productImage,
    int quantity,
    double pricePerUnit,
    double totalPrice,
  });
}

/// @nodoc
class _$OrderItemCopyWithImpl<$Res, $Val extends OrderItem>
    implements $OrderItemCopyWith<$Res> {
  _$OrderItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of OrderItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? productId = null,
    Object? productName = null,
    Object? productImage = null,
    Object? quantity = null,
    Object? pricePerUnit = null,
    Object? totalPrice = null,
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
            productImage:
                null == productImage
                    ? _value.productImage
                    : productImage // ignore: cast_nullable_to_non_nullable
                        as String,
            quantity:
                null == quantity
                    ? _value.quantity
                    : quantity // ignore: cast_nullable_to_non_nullable
                        as int,
            pricePerUnit:
                null == pricePerUnit
                    ? _value.pricePerUnit
                    : pricePerUnit // ignore: cast_nullable_to_non_nullable
                        as double,
            totalPrice:
                null == totalPrice
                    ? _value.totalPrice
                    : totalPrice // ignore: cast_nullable_to_non_nullable
                        as double,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$OrderItemImplCopyWith<$Res>
    implements $OrderItemCopyWith<$Res> {
  factory _$$OrderItemImplCopyWith(
    _$OrderItemImpl value,
    $Res Function(_$OrderItemImpl) then,
  ) = __$$OrderItemImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String productId,
    String productName,
    String productImage,
    int quantity,
    double pricePerUnit,
    double totalPrice,
  });
}

/// @nodoc
class __$$OrderItemImplCopyWithImpl<$Res>
    extends _$OrderItemCopyWithImpl<$Res, _$OrderItemImpl>
    implements _$$OrderItemImplCopyWith<$Res> {
  __$$OrderItemImplCopyWithImpl(
    _$OrderItemImpl _value,
    $Res Function(_$OrderItemImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of OrderItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? productId = null,
    Object? productName = null,
    Object? productImage = null,
    Object? quantity = null,
    Object? pricePerUnit = null,
    Object? totalPrice = null,
  }) {
    return _then(
      _$OrderItemImpl(
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
        productImage:
            null == productImage
                ? _value.productImage
                : productImage // ignore: cast_nullable_to_non_nullable
                    as String,
        quantity:
            null == quantity
                ? _value.quantity
                : quantity // ignore: cast_nullable_to_non_nullable
                    as int,
        pricePerUnit:
            null == pricePerUnit
                ? _value.pricePerUnit
                : pricePerUnit // ignore: cast_nullable_to_non_nullable
                    as double,
        totalPrice:
            null == totalPrice
                ? _value.totalPrice
                : totalPrice // ignore: cast_nullable_to_non_nullable
                    as double,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$OrderItemImpl implements _OrderItem {
  const _$OrderItemImpl({
    required this.productId,
    required this.productName,
    required this.productImage,
    required this.quantity,
    required this.pricePerUnit,
    required this.totalPrice,
  });

  factory _$OrderItemImpl.fromJson(Map<String, dynamic> json) =>
      _$$OrderItemImplFromJson(json);

  @override
  final String productId;
  @override
  final String productName;
  @override
  final String productImage;
  @override
  final int quantity;
  @override
  final double pricePerUnit;
  @override
  final double totalPrice;

  @override
  String toString() {
    return 'OrderItem(productId: $productId, productName: $productName, productImage: $productImage, quantity: $quantity, pricePerUnit: $pricePerUnit, totalPrice: $totalPrice)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$OrderItemImpl &&
            (identical(other.productId, productId) ||
                other.productId == productId) &&
            (identical(other.productName, productName) ||
                other.productName == productName) &&
            (identical(other.productImage, productImage) ||
                other.productImage == productImage) &&
            (identical(other.quantity, quantity) ||
                other.quantity == quantity) &&
            (identical(other.pricePerUnit, pricePerUnit) ||
                other.pricePerUnit == pricePerUnit) &&
            (identical(other.totalPrice, totalPrice) ||
                other.totalPrice == totalPrice));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    productId,
    productName,
    productImage,
    quantity,
    pricePerUnit,
    totalPrice,
  );

  /// Create a copy of OrderItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$OrderItemImplCopyWith<_$OrderItemImpl> get copyWith =>
      __$$OrderItemImplCopyWithImpl<_$OrderItemImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$OrderItemImplToJson(this);
  }
}

abstract class _OrderItem implements OrderItem {
  const factory _OrderItem({
    required final String productId,
    required final String productName,
    required final String productImage,
    required final int quantity,
    required final double pricePerUnit,
    required final double totalPrice,
  }) = _$OrderItemImpl;

  factory _OrderItem.fromJson(Map<String, dynamic> json) =
      _$OrderItemImpl.fromJson;

  @override
  String get productId;
  @override
  String get productName;
  @override
  String get productImage;
  @override
  int get quantity;
  @override
  double get pricePerUnit;
  @override
  double get totalPrice;

  /// Create a copy of OrderItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$OrderItemImplCopyWith<_$OrderItemImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
