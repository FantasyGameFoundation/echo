import 'package:echo/app/app.dart';
import 'package:echo/features/beacon/presentation/pages/beacon_page_prototype.dart';
import 'package:echo/features/curation/presentation/pages/organize_page_prototype.dart';
import 'package:echo/features/structure_elements_relations/presentation/pages/structure_page_prototype.dart';
import 'package:echo/features/timeline/presentation/pages/timeline_page_prototype.dart';
import 'package:echo/shared/models/prototype_tab.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('app renders structure page by default', (tester) async {
    await tester.pumpWidget(const EchoApp());

    expect(find.text('赤水河沿岸寻访'), findsOneWidget);
    expect(find.text('结构'), findsWidgets);
    expect(find.text('整理'), findsWidgets);
    expect(find.text('历程'), findsWidgets);
    expect(find.text('章节骨架'), findsOneWidget);
  });

  testWidgets('add button opens overlay and close button dismisses it', (
    tester,
  ) async {
    await tester.pumpWidget(const EchoApp());

    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    expect(find.text('保 存 记 录'), findsOneWidget);
    expect(find.text('在此输入文字速记...'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.close));
    await tester.pumpAndSettle();

    expect(find.text('保 存 记 录'), findsNothing);
  });

  testWidgets('sidebar opens and new project entry launches wizard', (
    tester,
  ) async {
    await tester.pumpWidget(const EchoApp());

    await tester.tap(find.byIcon(Icons.menu).first);
    await tester.pumpAndSettle();

    expect(find.text('项目中心'), findsOneWidget);
    expect(find.text('新建项目'), findsOneWidget);

    await tester.tap(find.text('新建项目'));
    await tester.pumpAndSettle();

    expect(find.text('输入你的创作意图'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
  });

  testWidgets('structure page chapter preview fits narrow mobile widths', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(360, 800));

    addTearDown(() async {
      await tester.binding.setSurfaceSize(null);
    });

    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(size: Size(360, 800)),
          child: StructurePagePrototype(
            currentTabIndex: 0,
            chapterElements: const [],
            onOpenSidebar: _noop,
            onTabChanged: _noopTab,
            onBottomTabChanged: _noopPrototypeTab,
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('+12'), findsOneWidget);
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is Scrollable &&
            (widget.axisDirection == AxisDirection.left ||
                widget.axisDirection == AxisDirection.right),
      ),
      findsNothing,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('organize page keeps core curation markers after extraction', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: OrganizePagePrototype(
          onOpenSidebar: _noop,
          onBottomTabChanged: _noopPrototypeTab,
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.textContaining('关联关系'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('关联章节'), findsOneWidget);
    expect(find.textContaining('关联元素'), findsOneWidget);
    expect(find.textContaining('关联关系'), findsOneWidget);
  });

  testWidgets('timeline page keeps core markers after extraction', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: TimelinePagePrototype(
          onOpenSidebar: _noop,
          onBottomTabChanged: _noopPrototypeTab,
        ),
      ),
    );

    expect(find.text('全部'), findsOneWidget);
    expect(find.text('照片'), findsOneWidget);
    expect(find.text('手记'), findsOneWidget);
  });

  testWidgets('beacon page keeps core markers after extraction', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: BeaconPagePrototype(
          onOpenSidebar: _noop,
          onBottomTabChanged: _noopPrototypeTab,
        ),
      ),
    );

    expect(find.text('待执行'), findsOneWidget);
    expect(find.text('已归档'), findsOneWidget);
    expect(find.text('执 行 模 式'), findsOneWidget);
  });
}

void _noop() {}

void _noopTab(int _) {}

void _noopPrototypeTab(PrototypeTab _) {}
