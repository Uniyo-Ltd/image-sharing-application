// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

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
    // Create a mock repository
    final mockRepository = MockImgurRepository();
    
    // Build our app and trigger a frame
    await tester.pumpWidget(MyApp(repository: mockRepository));

    // Basic verification - the app should contain the title
    expect(find.text('Imgur Gallery'), findsOneWidget);
  });
}
