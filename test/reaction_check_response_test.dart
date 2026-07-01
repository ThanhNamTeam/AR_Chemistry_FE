import 'package:flutter_test/flutter_test.dart';
import 'package:labedu/core/models/response/reaction_check_response.dart';

void main() {
  test('parses matched reaction response', () {
    final result = ReactionCheckResponse.fromJson(<String, dynamic>{
      'matched': true,
      'reason': 'REACTION_MATCHED',
      'message': 'ok',
      'reactionCode': 'FE_HCL',
      'affectedQrPayloads': <String>[],
      'affectedFormulas': <String>[],
      'reactants': <Map<String, dynamic>>[
        <String, dynamic>{'formula': 'Fe'},
        <String, dynamic>{'formula': 'HCl'},
      ],
    });

    expect(result.matched, isTrue);
    expect(result.reactantFormulas, <String>['Fe', 'HCl']);
  });

  test('rejects malformed response', () {
    expect(
      () => ReactionCheckResponse.fromJson(<String, dynamic>{'matched': true}),
      throwsFormatException,
    );
  });
}
