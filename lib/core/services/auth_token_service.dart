import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';

class AuthTokenService {
  static Future<String?> getValidAccessToken({bool forceRefresh = false}) async {
    try {
      final session = await Amplify.Auth.fetchAuthSession(
        options: FetchAuthSessionOptions(forceRefresh: forceRefresh),
      );

      if (session is CognitoAuthSession) {
        final tokens = session.userPoolTokensResult.value;
        final accessToken = tokens.accessToken;

        safePrint('Access token exp: ${accessToken.claims.expiration}');
        safePrint('Now: ${DateTime.now()}');

        return accessToken.raw;
      }

      return null;
    } catch (e) {
      safePrint('Get valid access token error: $e');
      return null;
    }
  }
}