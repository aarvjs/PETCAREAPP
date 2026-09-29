import 'package:flutter_test/flutter_test.dart';
import 'package:pet_care/app.dart';

void main() {
  testWidgets('PetCare app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const PetCareApp());
    expect(find.text('PETCARE'), findsOneWidget);
  });
}
