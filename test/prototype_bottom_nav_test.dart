import 'package:echo/features/beacon/presentation/pages/beacon_page_prototype.dart';
import 'package:echo/features/structure_elements_relations/presentation/models/structure_chapter_card_data.dart';
import 'package:echo/features/structure_elements_relations/presentation/models/structure_relation_card_data.dart';
import 'package:echo/features/structure_elements_relations/presentation/pages/structure_page_prototype.dart';
import 'package:echo/features/timeline/presentation/pages/timeline_page_prototype.dart';
import 'package:echo/shared/models/prototype_tab.dart';
import 'package:echo/shared/widgets/custom_bottom_nav_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'structure timeline and beacon nav bars stay flush to bottom safe edge',
    (tester) async {
      const screenSize = Size(390, 844);
      const bottomInset = 34.0;

      await tester.binding.setSurfaceSize(screenSize);
      addTearDown(() async {
        await tester.binding.setSurfaceSize(null);
      });

      Future<void> expectBottomNavPinned(Widget page) async {
        await tester.pumpWidget(
          MaterialApp(
            home: MediaQuery(
              data: const MediaQueryData(
                size: screenSize,
                padding: EdgeInsets.only(bottom: bottomInset),
                viewPadding: EdgeInsets.only(bottom: bottomInset),
              ),
              child: page,
            ),
          ),
        );
        await tester.pumpAndSettle();

        final navRect = tester.getRect(find.byType(CustomBottomNavBar));
        expect(navRect.bottom, closeTo(screenSize.height, 0.001));
      }

      await expectBottomNavPinned(
        StructurePagePrototype(
          currentTabIndex: 0,
          chapterCards: const <StructureChapterCardData>[],
          elementGroups: const <Map<String, dynamic>>[],
          relationCards: const <StructureRelationCardData>[],
          onOpenSidebar: _noop,
          onAddChapter: _noop,
          onAddElement: _noop,
          onAddRelation: _noop,
          onTabChanged: _noopTab,
          onBottomTabChanged: _noopPrototypeTab,
        ),
      );

      await expectBottomNavPinned(
        TimelinePagePrototype(
          onOpenSidebar: _noop,
          onBottomTabChanged: _noopPrototypeTab,
        ),
      );

      await expectBottomNavPinned(
        BeaconPagePrototype(
          onOpenSidebar: _noop,
          onBottomTabChanged: _noopPrototypeTab,
        ),
      );
    },
  );
}

void _noop() {}

void _noopTab(int _) {}

void _noopPrototypeTab(PrototypeTab _) {}
