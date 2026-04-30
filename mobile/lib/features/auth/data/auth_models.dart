import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_models.freezed.dart';
part 'auth_models.g.dart';

@freezed
class User with _$User {
  const factory User({
    required String id,
    required String email,
    String? name,
    String? signature,
    @Default(false) bool onboardingComplete,
    String? defaultTemplateId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _User;

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
}

@freezed
class TokenResponse with _$TokenResponse {
  const factory TokenResponse({
    required String token,
    required String tokenType,
    DateTime? expiresAt,
  }) = _TokenResponse;

  factory TokenResponse.fromJson(Map<String, dynamic> json) =>
      _$TokenResponseFromJson(json);
}

@freezed
class MagicLinkRequest with _$MagicLinkRequest {
  const factory MagicLinkRequest({
    required String email,
  }) = _MagicLinkRequest;

  factory MagicLinkRequest.fromJson(Map<String, dynamic> json) =>
      _$MagicLinkRequestFromJson(json);
}

@freezed
class VerifyMagicLinkRequest with _$VerifyMagicLinkRequest {
  const factory VerifyMagicLinkRequest({
    required String email,
    required String code,
  }) = _VerifyMagicLinkRequest;

  factory VerifyMagicLinkRequest.fromJson(Map<String, dynamic> json) =>
      _$VerifyMagicLinkRequestFromJson(json);
}
