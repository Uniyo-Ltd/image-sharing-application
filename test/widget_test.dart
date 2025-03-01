






import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_sharing_application/repositories/imgur_repository.dart';
import 'package:image_sharing_application/api/imgur_api_client.dart';

import 'package:image_sharing_application/main.dart';

class MockImgurRepository extends Mock implements ImgurRepository {}

void main() {
  testWidgets('Verify app renders without errors', (WidgetTester tester) async {
    
    final mockRepository = MockImgurRepository();
    
    
    await tester.pumpWidget(MyApp(repository: mockRepository));

    
    expect(find.text('Imgur Gallery'), findsOneWidget);
  });
}
