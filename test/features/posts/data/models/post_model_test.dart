import 'package:flutter_test/flutter_test.dart';
import 'package:showcase_list_test/features/posts/data/models/post_model.dart';

void main() {
  group('PostModel', () {
    const model = PostModel(userId: 1, id: 2, title: 'A title', body: 'A body');

    test('creates a model from json', () {
      expect(
        PostModel.fromJson(const {
          'userId': 1,
          'id': 2,
          'title': 'A title',
          'body': 'A body',
        }),
        model,
      );
    });

    test('converts a model to json', () {
      expect(model.toJson(), const {
        'userId': 1,
        'id': 2,
        'title': 'A title',
        'body': 'A body',
      });
    });
  });
}
