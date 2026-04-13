import 'package:echo/app/app.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('app renders primary navigation labels', (tester) async {
    await tester.pumpWidget(const EchoApp());

    expect(find.text('项目'), findsWidgets);
    expect(find.text('结构'), findsWidgets);
    expect(find.text('整理'), findsWidgets);
    expect(find.text('历程'), findsWidgets);
    expect(find.text('业务原型中'), findsWidgets);
  });
}
