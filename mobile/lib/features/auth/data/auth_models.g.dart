// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UserImpl _$$UserImplFromJson(Map<String, dynamic> json) => _$UserImpl(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String?,
      signature: json['signature'] as String?,
      onboardingComplete: json['onboarding_complete'] as bool? ?? false,
      defaultTemplateId: json['default_template_id'] as String?,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$$UserImplToJson(_$UserImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'email': instance.email,
      'name': instance.name,
      'signature': instance.signature,
      'onboarding_complete': instance.onboardingComplete,
      'default_template_id': instance.defaultTemplateId,
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
    };

_$TokenResponseImpl _$$TokenResponseImplFromJson(Map<String, dynamic> json) =>
    _$TokenResponseImpl(
      token: json['token'] as String,
      tokenType: json['token_type'] as String,
      expiresAt: json['expires_at'] == null
          ? null
          : DateTime.parse(json['expires_at'] as String),
    );

Map<String, dynamic> _$$TokenResponseImplToJson(
        _$TokenResponseImpl instance) =>
    <String, dynamic>{
      'token': instance.token,
      'token_type': instance.tokenType,
      'expires_at': instance.expiresAt?.toIso8601String(),
    };

_$MagicLinkRequestImpl _$$MagicLinkRequestImplFromJson(
        Map<String, dynamic> json) =>
    _$MagicLinkRequestImpl(
      email: json['email'] as String,
    );

Map<String, dynamic> _$$MagicLinkRequestImplToJson(
        _$MagicLinkRequestImpl instance) =>
    <String, dynamic>{
      'email': instance.email,
    };

_$VerifyMagicLinkRequestImpl _$$VerifyMagicLinkRequestImplFromJson(
        Map<String, dynamic> json) =>
    _$VerifyMagicLinkRequestImpl(
      email: json['email'] as String,
      code: json['code'] as String,
    );

Map<String, dynamic> _$$VerifyMagicLinkRequestImplToJson(
        _$VerifyMagicLinkRequestImpl instance) =>
    <String, dynamic>{
      'email': instance.email,
      'code': instance.code,
    };
