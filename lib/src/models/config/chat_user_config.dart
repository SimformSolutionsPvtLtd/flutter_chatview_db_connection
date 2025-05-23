import 'package:chatview_utils/chatview_utils.dart';

/// A configurable implementation of [ChatUserConfig] that allows
/// dynamic mapping of user properties when serializing and deserializing JSON.
///
/// By default, user data is stored and retrieved using standard keys such as
/// `id`, `name`, and `profilePhoto`.
/// However, different data sources may use custom key names
/// (e.g., `username` instead of `name`).
/// This class provides flexibility to define custom key mappings
/// to correctly interpret user data from various sources.
final class ChatUserConfig implements ChatUserConfigBase {
  /// Creates a [ChatUserConfig] instance with optional key mappings.
  ///
  /// If a data source uses different keys (e.g., `username` instead of `name`),
  /// those keys can be specified here to ensure correct JSON parsing.
  const ChatUserConfig({
    this.idKey,
    this.nameKey,
    this.profilePhotoKey,
  });

  /// The JSON key used for uniquely identifying a user. Default: `"id"`.
  @override
  final String? idKey;

  /// The JSON key used for storing the user's display name. Default: `"name"`.
  @override
  final String? nameKey;

  /// The JSON key used for the user's profile photo. Default: `"profilePhoto"`.
  @override
  final String? profilePhotoKey;
}
