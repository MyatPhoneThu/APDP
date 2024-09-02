import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutterfirebasecrudapp/widgets/password_text_form_field.dart';

void main() {
  testWidgets('PasswordTextFormField hides/shows password', (WidgetTester tester) async {
    TextEditingController controller = TextEditingController();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PasswordTextFormField(
            labelText: 'Password',
            passwordEditingController: controller,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Password cannot be empty';
              }
              return null;
            },
          ),
        ),
      ),
    );

    // Initially, the password should be hidden
    expect(find.byIcon(Icons.visibility_off), findsOneWidget);
    expect(find.byIcon(Icons.visibility), findsNothing);

    // Tap on the suffix icon to show the password
    await tester.tap(find.byIcon(Icons.visibility_off));
    await tester.pump();

    // Now, the password should be visible
    expect(find.byIcon(Icons.visibility_off), findsNothing);
    expect(find.byIcon(Icons.visibility), findsOneWidget);
  });



}
