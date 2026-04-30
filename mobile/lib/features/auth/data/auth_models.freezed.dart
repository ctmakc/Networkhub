// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'auth_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This is only meant to be used by code generators. When creating an instance of the class, use the public constructor instead.');

/// @nodoc
mixin _$User {
  String get id => throw _privateConstructorUsedError;
  String get email => throw _privateConstructorUsedError;
  String? get name => throw _privateConstructorUsedError;
  String? get signature => throw _privateConstructorUsedError;
  bool get onboardingComplete => throw _privateConstructorUsedError;
  String? get defaultTemplateId => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;
  DateTime? get updatedAt => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $UserCopyWith<User> get copyWith => throw _privateConstructorUsedError;
}

abstract class $UserCopyWith<$Res> {
  factory $UserCopyWith(User value, $Res Function(User) then) =
      _$UserCopyWithImpl<$Res, User>;
  @useResult
  $Res call({
    String id,
    String email,
    String? name,
    String? signature,
    bool onboardingComplete,
    String? defaultTemplateId,
    DateTime? createdAt,
    DateTime? updatedAt,
  });
}

class _$UserCopyWithImpl<$Res, $Val extends User>
    implements $UserCopyWith<$Res> {
  _$UserCopyWithImpl(this._value, this._then);

  final $Val _value;
  final $Res Function($Val) _then;

  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? email = null,
    Object? name = freezed,
    Object? signature = freezed,
    Object? onboardingComplete = null,
    Object? defaultTemplateId = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id ? _value.id : id as String,
      email: null == email ? _value.email : email as String,
      name: freezed == name ? _value.name : name as String?,
      signature: freezed == signature ? _value.signature : signature as String?,
      onboardingComplete: null == onboardingComplete
          ? _value.onboardingComplete
          : onboardingComplete as bool,
      defaultTemplateId: freezed == defaultTemplateId
          ? _value.defaultTemplateId
          : defaultTemplateId as String?,
      createdAt:
          freezed == createdAt ? _value.createdAt : createdAt as DateTime?,
      updatedAt:
          freezed == updatedAt ? _value.updatedAt : updatedAt as DateTime?,
    ) as $Val);
  }
}

abstract class _$$UserImplCopyWith<$Res> implements $UserCopyWith<$Res> {
  factory _$$UserImplCopyWith(
          _$UserImpl value, $Res Function(_$UserImpl) then) =
      __$$UserImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String email,
    String? name,
    String? signature,
    bool onboardingComplete,
    String? defaultTemplateId,
    DateTime? createdAt,
    DateTime? updatedAt,
  });
}

class __$$UserImplCopyWithImpl<$Res>
    extends _$UserCopyWithImpl<$Res, _$UserImpl>
    implements _$$UserImplCopyWith<$Res> {
  __$$UserImplCopyWithImpl(_$UserImpl super.value, super.then);

  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? email = null,
    Object? name = freezed,
    Object? signature = freezed,
    Object? onboardingComplete = null,
    Object? defaultTemplateId = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(_$UserImpl(
      id: null == id ? _value.id : id as String,
      email: null == email ? _value.email : email as String,
      name: freezed == name ? _value.name : name as String?,
      signature: freezed == signature ? _value.signature : signature as String?,
      onboardingComplete: null == onboardingComplete
          ? _value.onboardingComplete
          : onboardingComplete as bool,
      defaultTemplateId: freezed == defaultTemplateId
          ? _value.defaultTemplateId
          : defaultTemplateId as String?,
      createdAt:
          freezed == createdAt ? _value.createdAt : createdAt as DateTime?,
      updatedAt:
          freezed == updatedAt ? _value.updatedAt : updatedAt as DateTime?,
    ));
  }
}

@JsonSerializable()
class _$UserImpl implements _User {
  const _$UserImpl({
    required this.id,
    required this.email,
    this.name,
    this.signature,
    this.onboardingComplete = false,
    this.defaultTemplateId,
    this.createdAt,
    this.updatedAt,
  });

  factory _$UserImpl.fromJson(Map<String, dynamic> json) =>
      _$$UserImplFromJson(json);

  @override
  final String id;
  @override
  final String email;
  @override
  final String? name;
  @override
  final String? signature;
  @override
  @JsonKey()
  final bool onboardingComplete;
  @override
  final String? defaultTemplateId;
  @override
  final DateTime? createdAt;
  @override
  final DateTime? updatedAt;

  @override
  String toString() {
    return 'User(id: $id, email: $email, name: $name, signature: $signature, onboardingComplete: $onboardingComplete, defaultTemplateId: $defaultTemplateId, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.signature, signature) ||
                other.signature == signature) &&
            (identical(other.onboardingComplete, onboardingComplete) ||
                other.onboardingComplete == onboardingComplete) &&
            (identical(other.defaultTemplateId, defaultTemplateId) ||
                other.defaultTemplateId == defaultTemplateId) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, id, email, name, signature,
      onboardingComplete, defaultTemplateId, createdAt, updatedAt);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$UserImplCopyWith<_$UserImpl> get copyWith =>
      __$$UserImplCopyWithImpl<_$UserImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$UserImplToJson(this);
  }
}

abstract class _User implements User {
  const factory _User({
    required final String id,
    required final String email,
    final String? name,
    final String? signature,
    final bool onboardingComplete,
    final String? defaultTemplateId,
    final DateTime? createdAt,
    final DateTime? updatedAt,
  }) = _$UserImpl;

  factory _User.fromJson(Map<String, dynamic> json) = _$UserImpl.fromJson;

  @override
  String get id;
  @override
  String get email;
  @override
  String? get name;
  @override
  String? get signature;
  @override
  bool get onboardingComplete;
  @override
  String? get defaultTemplateId;
  @override
  DateTime? get createdAt;
  @override
  DateTime? get updatedAt;
  @override
  @JsonKey(ignore: true)
  _$$UserImplCopyWith<_$UserImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$TokenResponse {
  String get token => throw _privateConstructorUsedError;
  String get tokenType => throw _privateConstructorUsedError;
  DateTime? get expiresAt => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $TokenResponseCopyWith<TokenResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

abstract class $TokenResponseCopyWith<$Res> {
  factory $TokenResponseCopyWith(
          TokenResponse value, $Res Function(TokenResponse) then) =
      _$TokenResponseCopyWithImpl<$Res, TokenResponse>;
  @useResult
  $Res call({String token, String tokenType, DateTime? expiresAt});
}

class _$TokenResponseCopyWithImpl<$Res, $Val extends TokenResponse>
    implements $TokenResponseCopyWith<$Res> {
  _$TokenResponseCopyWithImpl(this._value, this._then);

  final $Val _value;
  final $Res Function($Val) _then;

  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? token = null,
    Object? tokenType = null,
    Object? expiresAt = freezed,
  }) {
    return _then(_value.copyWith(
      token: null == token ? _value.token : token as String,
      tokenType: null == tokenType ? _value.tokenType : tokenType as String,
      expiresAt:
          freezed == expiresAt ? _value.expiresAt : expiresAt as DateTime?,
    ) as $Val);
  }
}

abstract class _$$TokenResponseImplCopyWith<$Res>
    implements $TokenResponseCopyWith<$Res> {
  factory _$$TokenResponseImplCopyWith(
          _$TokenResponseImpl value, $Res Function(_$TokenResponseImpl) then) =
      __$$TokenResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String token, String tokenType, DateTime? expiresAt});
}

class __$$TokenResponseImplCopyWithImpl<$Res>
    extends _$TokenResponseCopyWithImpl<$Res, _$TokenResponseImpl>
    implements _$$TokenResponseImplCopyWith<$Res> {
  __$$TokenResponseImplCopyWithImpl(super.value, super.then);

  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? token = null,
    Object? tokenType = null,
    Object? expiresAt = freezed,
  }) {
    return _then(_$TokenResponseImpl(
      token: null == token ? _value.token : token as String,
      tokenType: null == tokenType ? _value.tokenType : tokenType as String,
      expiresAt:
          freezed == expiresAt ? _value.expiresAt : expiresAt as DateTime?,
    ));
  }
}

@JsonSerializable()
class _$TokenResponseImpl implements _TokenResponse {
  const _$TokenResponseImpl({
    required this.token,
    required this.tokenType,
    this.expiresAt,
  });

  factory _$TokenResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$TokenResponseImplFromJson(json);

  @override
  final String token;
  @override
  final String tokenType;
  @override
  final DateTime? expiresAt;

  @override
  String toString() {
    return 'TokenResponse(token: $token, tokenType: $tokenType, expiresAt: $expiresAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TokenResponseImpl &&
            (identical(other.token, token) || other.token == token) &&
            (identical(other.tokenType, tokenType) ||
                other.tokenType == tokenType) &&
            (identical(other.expiresAt, expiresAt) ||
                other.expiresAt == expiresAt));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, token, tokenType, expiresAt);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$TokenResponseImplCopyWith<_$TokenResponseImpl> get copyWith =>
      __$$TokenResponseImplCopyWithImpl<_$TokenResponseImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TokenResponseImplToJson(this);
  }
}

abstract class _TokenResponse implements TokenResponse {
  const factory _TokenResponse({
    required final String token,
    required final String tokenType,
    final DateTime? expiresAt,
  }) = _$TokenResponseImpl;

  factory _TokenResponse.fromJson(Map<String, dynamic> json) =
      _$TokenResponseImpl.fromJson;

  @override
  String get token;
  @override
  String get tokenType;
  @override
  DateTime? get expiresAt;
  @override
  @JsonKey(ignore: true)
  _$$TokenResponseImplCopyWith<_$TokenResponseImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$MagicLinkRequest {
  String get email => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $MagicLinkRequestCopyWith<MagicLinkRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

abstract class $MagicLinkRequestCopyWith<$Res> {
  factory $MagicLinkRequestCopyWith(
          MagicLinkRequest value, $Res Function(MagicLinkRequest) then) =
      _$MagicLinkRequestCopyWithImpl<$Res, MagicLinkRequest>;
  @useResult
  $Res call({String email});
}

class _$MagicLinkRequestCopyWithImpl<$Res, $Val extends MagicLinkRequest>
    implements $MagicLinkRequestCopyWith<$Res> {
  _$MagicLinkRequestCopyWithImpl(this._value, this._then);

  final $Val _value;
  final $Res Function($Val) _then;

  @override
  @pragma('vm:prefer-inline')
  $Res call({Object? email = null}) {
    return _then(_value.copyWith(
      email: null == email ? _value.email : email as String,
    ) as $Val);
  }
}

abstract class _$$MagicLinkRequestImplCopyWith<$Res>
    implements $MagicLinkRequestCopyWith<$Res> {
  factory _$$MagicLinkRequestImplCopyWith(_$MagicLinkRequestImpl value,
          $Res Function(_$MagicLinkRequestImpl) then) =
      __$$MagicLinkRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String email});
}

class __$$MagicLinkRequestImplCopyWithImpl<$Res>
    extends _$MagicLinkRequestCopyWithImpl<$Res, _$MagicLinkRequestImpl>
    implements _$$MagicLinkRequestImplCopyWith<$Res> {
  __$$MagicLinkRequestImplCopyWithImpl(super.value, super.then);

  @override
  @pragma('vm:prefer-inline')
  $Res call({Object? email = null}) {
    return _then(_$MagicLinkRequestImpl(
      email: null == email ? _value.email : email as String,
    ));
  }
}

@JsonSerializable()
class _$MagicLinkRequestImpl implements _MagicLinkRequest {
  const _$MagicLinkRequestImpl({required this.email});

  factory _$MagicLinkRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$MagicLinkRequestImplFromJson(json);

  @override
  final String email;

  @override
  String toString() {
    return 'MagicLinkRequest(email: $email)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MagicLinkRequestImpl &&
            (identical(other.email, email) || other.email == email));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, email);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$MagicLinkRequestImplCopyWith<_$MagicLinkRequestImpl> get copyWith =>
      __$$MagicLinkRequestImplCopyWithImpl<_$MagicLinkRequestImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MagicLinkRequestImplToJson(this);
  }
}

abstract class _MagicLinkRequest implements MagicLinkRequest {
  const factory _MagicLinkRequest({required final String email}) =
      _$MagicLinkRequestImpl;

  factory _MagicLinkRequest.fromJson(Map<String, dynamic> json) =
      _$MagicLinkRequestImpl.fromJson;

  @override
  String get email;
  @override
  @JsonKey(ignore: true)
  _$$MagicLinkRequestImplCopyWith<_$MagicLinkRequestImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$VerifyMagicLinkRequest {
  String get email => throw _privateConstructorUsedError;
  String get code => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $VerifyMagicLinkRequestCopyWith<VerifyMagicLinkRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

abstract class $VerifyMagicLinkRequestCopyWith<$Res> {
  factory $VerifyMagicLinkRequestCopyWith(VerifyMagicLinkRequest value,
          $Res Function(VerifyMagicLinkRequest) then) =
      _$VerifyMagicLinkRequestCopyWithImpl<$Res, VerifyMagicLinkRequest>;
  @useResult
  $Res call({String email, String code});
}

class _$VerifyMagicLinkRequestCopyWithImpl<$Res,
        $Val extends VerifyMagicLinkRequest>
    implements $VerifyMagicLinkRequestCopyWith<$Res> {
  _$VerifyMagicLinkRequestCopyWithImpl(this._value, this._then);

  final $Val _value;
  final $Res Function($Val) _then;

  @override
  @pragma('vm:prefer-inline')
  $Res call({Object? email = null, Object? code = null}) {
    return _then(_value.copyWith(
      email: null == email ? _value.email : email as String,
      code: null == code ? _value.code : code as String,
    ) as $Val);
  }
}

abstract class _$$VerifyMagicLinkRequestImplCopyWith<$Res>
    implements $VerifyMagicLinkRequestCopyWith<$Res> {
  factory _$$VerifyMagicLinkRequestImplCopyWith(
          _$VerifyMagicLinkRequestImpl value,
          $Res Function(_$VerifyMagicLinkRequestImpl) then) =
      __$$VerifyMagicLinkRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String email, String code});
}

class __$$VerifyMagicLinkRequestImplCopyWithImpl<$Res>
    extends _$VerifyMagicLinkRequestCopyWithImpl<$Res,
        _$VerifyMagicLinkRequestImpl>
    implements _$$VerifyMagicLinkRequestImplCopyWith<$Res> {
  __$$VerifyMagicLinkRequestImplCopyWithImpl(super.value, super.then);

  @override
  @pragma('vm:prefer-inline')
  $Res call({Object? email = null, Object? code = null}) {
    return _then(_$VerifyMagicLinkRequestImpl(
      email: null == email ? _value.email : email as String,
      code: null == code ? _value.code : code as String,
    ));
  }
}

@JsonSerializable()
class _$VerifyMagicLinkRequestImpl implements _VerifyMagicLinkRequest {
  const _$VerifyMagicLinkRequestImpl(
      {required this.email, required this.code});

  factory _$VerifyMagicLinkRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$VerifyMagicLinkRequestImplFromJson(json);

  @override
  final String email;
  @override
  final String code;

  @override
  String toString() {
    return 'VerifyMagicLinkRequest(email: $email, code: $code)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$VerifyMagicLinkRequestImpl &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.code, code) || other.code == code));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, email, code);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$VerifyMagicLinkRequestImplCopyWith<_$VerifyMagicLinkRequestImpl>
      get copyWith =>
          __$$VerifyMagicLinkRequestImplCopyWithImpl<
              _$VerifyMagicLinkRequestImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$VerifyMagicLinkRequestImplToJson(this);
  }
}

abstract class _VerifyMagicLinkRequest implements VerifyMagicLinkRequest {
  const factory _VerifyMagicLinkRequest(
      {required final String email,
      required final String code}) = _$VerifyMagicLinkRequestImpl;

  factory _VerifyMagicLinkRequest.fromJson(Map<String, dynamic> json) =
      _$VerifyMagicLinkRequestImpl.fromJson;

  @override
  String get email;
  @override
  String get code;
  @override
  @JsonKey(ignore: true)
  _$$VerifyMagicLinkRequestImplCopyWith<_$VerifyMagicLinkRequestImpl>
      get copyWith => throw _privateConstructorUsedError;
}

// JSON helpers redirecting to generated implementations
User _$UserFromJson(Map<String, dynamic> json) => _$$UserImplFromJson(json);
TokenResponse _$TokenResponseFromJson(Map<String, dynamic> json) => _$$TokenResponseImplFromJson(json);
MagicLinkRequest _$MagicLinkRequestFromJson(Map<String, dynamic> json) => _$$MagicLinkRequestImplFromJson(json);
VerifyMagicLinkRequest _$VerifyMagicLinkRequestFromJson(Map<String, dynamic> json) => _$$VerifyMagicLinkRequestImplFromJson(json);
