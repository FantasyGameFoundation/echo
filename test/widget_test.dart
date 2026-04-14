import 'package:echo/app/app.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('app renders merged prototype shell', (tester) async {
    await tester.pumpWidget(const EchoApp());

    expect(find.text('赤水河沿岸寻访'), findsOneWidget);
    expect(find.text('结构'), findsWidgets);
    expect(find.text('整理'), findsWidgets);
    expect(find.text('历程'), findsWidgets);
    expect(find.text('章节骨架'), findsOneWidget);
  });
}
