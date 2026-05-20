const amplifyconfig = '''{
  "UserAgent": "aws-amplify-cli/2.0",
  "Version": "1.0",
  "auth": {
    "plugins": {
      "awsCognitoAuthPlugin": {
        "UserAgent": "aws-amplify-cli/0.1.0",
        "Version": "0.1.0",
        "IdentityManager": {
          "Default": {}
        },
        "CognitoUserPool": {
          "Default": {
            "PoolId": "ap-southeast-2_wuMjdreND",
            "AppClientId": "3kqov0jhckfrhtm0j64tin4r4p",
            "Region": "ap-southeast-2"
          }
        },
        "Auth": {
          "Default": {
            "OAuth": {
              "WebDomain": "chemistryauth2026.auth.ap-southeast-2.amazoncognito.com",
              "AppClientId": "3kqov0jhckfrhtm0j64tin4r4p",
              "SignInRedirectURI": "chemistry://oauth",
              "SignOutRedirectURI": "chemistry://logout",
              "Scopes": [
                "openid",
                "email",
                "profile"
              ]
            }
          }
        }
      }
    }
  }
}''';
