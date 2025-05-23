import '../../../extensions.dart';

/// {@template chatview_connect.FirestoreChatDatabasePathConfig}
/// Configuration class for defining database paths for chat-related data.
///
/// This class allows customization of Firestore database paths for
/// storing user data, ensuring efficient organization of collections.
///
/// ### Example Usage:
/// ```dart
/// ChatViewConnect.initialize(
///     ChatViewCloudService.firebase,
///     cloudServiceConfig: FirebaseCloudConfig(
///       databasePathConfig: FirestoreChatDatabasePathConfig(
///         userCollectionPath: 'organizations/simform',
///       ),
///     ),
/// );
/// ```
/// If [userCollectionPath] is not specified,
/// the default top-level `users` collection is used.
/// {@endtemplate}
final class FirestoreChatDatabasePathConfig {
  /// Creates a new instance of [FirestoreChatDatabasePathConfig].
  ///
  /// **Parameters:**
  /// - (optional) [userCollectionPath] The Firestore collection path for
  /// retrieving user data.
  ///   If omitted, defaults to the top-level `users` collection.
  ///
  /// {@macro chatview_connect.FirestoreChatDatabasePathConfig.userCollectionPath}
  FirestoreChatDatabasePathConfig({this.userCollectionPath})
      : assert(
          userCollectionPath == null ||
              userCollectionPath.isValidFirestoreDocumentName,
          'Chat Collection Path should not have the nested collection',
        );

  /// {@template chatview_connect.FirestoreChatDatabasePathConfig.userCollectionPath}
  /// The collection path where user data is stored.
  ///
  /// If the 'users' collection is nested within other collections, specify
  /// the parent path excluding 'users'. For example, if the user collection
  /// is located at:
  ///
  /// **Firestore structure:**
  /// `organizations/org123/users`
  ///
  /// Then specify:
  ///
  /// ```dart
  /// userCollectionPath: 'organizations/org123'
  /// ```
  /// {@endtemplate}
  final String? userCollectionPath;
}
