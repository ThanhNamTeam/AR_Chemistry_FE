import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_flutter/amplify_flutter.dart';

class CognitoService {

  Future<String> loginGoogle() async {

    final result = await Amplify.Auth.signInWithWebUI(
      provider: AuthProvider.google,
    );

    if (!result.isSignedIn) {
      throw Exception();
    }

    final session =
    await Amplify.Auth.fetchAuthSession()
    as CognitoAuthSession;

    return session.userPoolTokensResult
        .value
        .idToken
        .raw;
  }
}