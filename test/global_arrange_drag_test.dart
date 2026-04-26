import 'package:echo/features/curation/presentation/pages/global_arrange_page.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('chapter drag start invokes medium haptic feedback', (
    tester,
  ) async {
    final hapticCalls = <MethodCall>[];
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        if (call.method == 'HapticFeedback.vibrate') {
          hapticCalls.add(call);
        }
        return null;
      },
    );
    addTearDown(() {
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        null,
      );
    });
    _setLargeSurface(tester);

    await tester.pumpWidget(const MaterialApp(home: _ArrangeHarness()));
    await tester.pumpAndSettle();

    final dragGesture = await _startLongPressDrag(
      tester,
      find.byKey(const ValueKey('globalArrangeChapterHeader-chapter-1')),
    );
    await tester.pump();

    expect(
      hapticCalls.map((call) => call.arguments),
      contains('HapticFeedbackType.mediumImpact'),
    );

    await dragGesture.up();
    await tester.pumpAndSettle();
  });

  testWidgets(
    'chapter drag keeps the source placeholder and impacted chapter visible',
    (tester) async {
      _setLargeSurface(tester);

      await tester.pumpWidget(const MaterialApp(home: _ArrangeHarness()));
      await tester.pumpAndSettle();

      final chapterHeaderHeight = tester
          .getSize(
            find.byKey(const ValueKey('globalArrangeChapterHeader-chapter-1')),
          )
          .height;
      final chapterOneStart = tester.getCenter(
        find.byKey(const ValueKey('globalArrangeChapterHeader-chapter-1')),
      );
      final chapterTwoTarget =
          tester.getCenter(
            find.byKey(const ValueKey('globalArrangeChapterHeader-chapter-2')),
          ) +
          const Offset(0, 52);

      final dragGesture = await _startLongPressDrag(
        tester,
        find.byKey(const ValueKey('globalArrangeChapterHeader-chapter-1')),
      );

      expect(
        find.byKey(const ValueKey('globalArrangeChapterPlaceholder-chapter-1')),
        findsOneWidget,
      );
      expect(
        tester
            .getSize(
              find.byKey(
                const ValueKey('globalArrangeChapterPlaceholder-chapter-1'),
              ),
            )
            .height,
        closeTo(chapterHeaderHeight, 0.1),
      );

      await _dragSmoothly(
        tester,
        gesture: dragGesture,
        start: chapterOneStart,
        end: chapterTwoTarget,
      );

      expect(
        find.byKey(const ValueKey('globalArrangeChapterHeader-chapter-2')),
        findsOneWidget,
      );

      await dragGesture.up();
      await tester.pumpAndSettle();
    },
  );

  testWidgets(
    'expanded chapter collapses during drag and restores after release',
    (tester) async {
      _setLargeSurface(tester);

      await tester.pumpWidget(const MaterialApp(home: _ArrangeHarness()));
      await tester.pumpAndSettle();

      expect(
        find.byKey(const ValueKey('globalArrangeElementHeader-element-1')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('globalArrangeElementHeader-element-2')),
        findsOneWidget,
      );

      final dragGesture = await _startLongPressDrag(
        tester,
        find.byKey(const ValueKey('globalArrangeChapterHeader-chapter-1')),
      );

      expect(
        find.byKey(const ValueKey('globalArrangeElementHeader-element-1')),
        findsNothing,
      );
      expect(
        find.byKey(const ValueKey('globalArrangeElementHeader-element-2')),
        findsNothing,
      );

      await dragGesture.up();
      await tester.pumpAndSettle();

      expect(
        find.byKey(const ValueKey('globalArrangeElementHeader-element-1')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('globalArrangeElementHeader-element-2')),
        findsOneWidget,
      );
    },
  );

  testWidgets('chapter drag can reverse direction after moving downward', (
    tester,
  ) async {
    _setLargeSurface(tester);

    await tester.pumpWidget(const MaterialApp(home: _ArrangeHarness()));
    await tester.pumpAndSettle();

    final dragGesture = await _startLongPressDrag(
      tester,
      find.byKey(const ValueKey('globalArrangeChapterHeader-chapter-1')),
    );

    final chapterTwoLowerHalf =
        tester.getCenter(
          find.byKey(const ValueKey('globalArrangeChapterHeader-chapter-2')),
        ) +
        const Offset(0, 20);
    await dragGesture.moveTo(chapterTwoLowerHalf);
    await tester.pump(const Duration(milliseconds: 32));

    final chapterOneUpperHalf =
        tester.getCenter(
          find.byKey(
            const ValueKey('globalArrangeChapterPlaceholder-chapter-1'),
          ),
        ) -
        const Offset(0, 12);
    await dragGesture.moveTo(chapterOneUpperHalf);
    await tester.pump(const Duration(milliseconds: 32));

    await dragGesture.up();
    await tester.pumpAndSettle();

    final chapterOneY = tester
        .getTopLeft(
          find.byKey(const ValueKey('globalArrangeChapterHeader-chapter-1')),
        )
        .dy;
    final chapterTwoY = tester
        .getTopLeft(
          find.byKey(const ValueKey('globalArrangeChapterHeader-chapter-2')),
        )
        .dy;
    expect(chapterOneY, lessThan(chapterTwoY));
  });

  testWidgets(
    'chapter drag downward can move the first chapter after the next chapter',
    (tester) async {
      _setLargeSurface(tester);

      final harnessKey = GlobalKey<_ArrangeHarnessState>();
      await tester.pumpWidget(
        MaterialApp(home: _ArrangeHarness(key: harnessKey)),
      );
      await tester.pumpAndSettle();

      final chapterOneStart = tester.getCenter(
        find.byKey(const ValueKey('globalArrangeChapterHeader-chapter-1')),
      );
      final chapterTwoRect = tester.getRect(
        find.byKey(const ValueKey('globalArrangeChapterHeader-chapter-2')),
      );
      final dragGesture = await _startLongPressDrag(
        tester,
        find.byKey(const ValueKey('globalArrangeChapterHeader-chapter-1')),
      );

      await _dragSmoothly(
        tester,
        gesture: dragGesture,
        start: chapterOneStart,
        end: Offset(chapterTwoRect.center.dx, chapterTwoRect.bottom + 72),
      );
      await dragGesture.up();
      await tester.pumpAndSettle();

      expect(harnessKey.currentState!.lastMovedChapterId, 'chapter-1');
      expect(harnessKey.currentState!.lastChapterTargetIndex, isNotNull);
      expect(
        harnessKey.currentState!.boardData.chapters
            .map((chapter) => chapter.chapterId)
            .toList(),
        <String>['chapter-2', 'chapter-1'],
      );
    },
  );

  testWidgets(
    'element drag keeps the source placeholder and impacted element visible',
    (tester) async {
      _setLargeSurface(tester);

      await tester.pumpWidget(const MaterialApp(home: _ArrangeHarness()));
      await tester.pumpAndSettle();

      final elementHeaderHeight = tester
          .getSize(
            find.byKey(const ValueKey('globalArrangeElementHeader-element-1')),
          )
          .height;
      final elementOneStart = tester.getCenter(
        find.byKey(const ValueKey('globalArrangeElementHeader-element-1')),
      );
      final elementThreeTarget =
          tester.getCenter(
            find.byKey(const ValueKey('globalArrangeElementHeader-element-3')),
          ) +
          const Offset(0, 44);

      final dragGesture = await _startLongPressDrag(
        tester,
        find.byKey(const ValueKey('globalArrangeElementHeader-element-1')),
      );

      expect(
        find.byKey(const ValueKey('globalArrangeElementPlaceholder-element-1')),
        findsOneWidget,
      );
      expect(
        tester
            .getSize(
              find.byKey(
                const ValueKey('globalArrangeElementPlaceholder-element-1'),
              ),
            )
            .height,
        greaterThan(elementHeaderHeight),
      );
      expect(
        tester
            .getSize(
              find.byKey(
                const ValueKey('globalArrangeElementPlaceholder-element-1'),
              ),
            )
            .height,
        lessThan(56),
      );

      await _dragSmoothly(
        tester,
        gesture: dragGesture,
        start: elementOneStart,
        end: elementThreeTarget,
      );

      expect(
        find.byKey(const ValueKey('globalArrangeElementHeader-element-3')),
        findsOneWidget,
      );

      await dragGesture.up();
      await tester.pumpAndSettle();
    },
  );

  testWidgets(
    'expanded element collapses during drag and restores after release',
    (tester) async {
      _setLargeSurface(tester);

      await tester.pumpWidget(const MaterialApp(home: _ArrangeHarness()));
      await tester.pumpAndSettle();

      expect(
        find.byKey(const ValueKey('globalArrangePhotoCard-photo-1')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('globalArrangePhotoCard-photo-2')),
        findsOneWidget,
      );

      final dragGesture = await _startLongPressDrag(
        tester,
        find.byKey(const ValueKey('globalArrangeElementHeader-element-1')),
      );

      expect(
        find.byKey(const ValueKey('globalArrangePhotoCard-photo-1')),
        findsNothing,
      );
      expect(
        find.byKey(const ValueKey('globalArrangePhotoCard-photo-2')),
        findsNothing,
      );

      await dragGesture.up();
      await tester.pumpAndSettle();

      expect(
        find.byKey(const ValueKey('globalArrangePhotoCard-photo-1')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('globalArrangePhotoCard-photo-2')),
        findsOneWidget,
      );
    },
  );

  testWidgets('element drag can reverse direction after moving downward', (
    tester,
  ) async {
    _setLargeSurface(tester);

    await tester.pumpWidget(const MaterialApp(home: _ArrangeHarness()));
    await tester.pumpAndSettle();

    final dragGesture = await _startLongPressDrag(
      tester,
      find.byKey(const ValueKey('globalArrangeElementHeader-element-1')),
    );

    final elementThreeLowerHalf =
        tester.getCenter(
          find.byKey(const ValueKey('globalArrangeElementHeader-element-3')),
        ) +
        const Offset(0, 16);
    await dragGesture.moveTo(elementThreeLowerHalf);
    await tester.pump(const Duration(milliseconds: 32));

    final elementOneUpperHalf =
        tester.getCenter(
          find.byKey(
            const ValueKey('globalArrangeElementPlaceholder-element-1'),
          ),
        ) -
        const Offset(0, 10);
    await dragGesture.moveTo(elementOneUpperHalf);
    await tester.pump(const Duration(milliseconds: 32));

    await dragGesture.up();
    await tester.pumpAndSettle();

    final elementOneY = tester
        .getTopLeft(
          find.byKey(const ValueKey('globalArrangeElementHeader-element-1')),
        )
        .dy;
    final elementTwoY = tester
        .getTopLeft(
          find.byKey(const ValueKey('globalArrangeElementHeader-element-2')),
        )
        .dy;
    expect(elementOneY, lessThan(elementTwoY));
  });

  testWidgets(
    'collapsed chapter and element stay collapsed after drag release',
    (tester) async {
      _setLargeSurface(tester);

      await tester.pumpWidget(const MaterialApp(home: _ArrangeHarness()));
      await tester.pumpAndSettle();

      await tester.tap(
        find.byKey(const ValueKey('globalArrangeElementHeader-element-1')),
      );
      await tester.pumpAndSettle();
      expect(
        find.byKey(const ValueKey('globalArrangePhotoCard-photo-1')),
        findsNothing,
      );

      final elementDragGesture = await _startLongPressDrag(
        tester,
        find.byKey(const ValueKey('globalArrangeElementHeader-element-1')),
      );
      await elementDragGesture.up();
      await tester.pumpAndSettle();

      expect(
        find.byKey(const ValueKey('globalArrangePhotoCard-photo-1')),
        findsNothing,
      );

      await tester.tap(
        find.byKey(const ValueKey('globalArrangeChapterHeader-chapter-1')),
      );
      await tester.pumpAndSettle();
      expect(
        find.byKey(const ValueKey('globalArrangeElementHeader-element-1')),
        findsNothing,
      );

      final chapterDragGesture = await _startLongPressDrag(
        tester,
        find.byKey(const ValueKey('globalArrangeChapterHeader-chapter-1')),
      );
      await chapterDragGesture.up();
      await tester.pumpAndSettle();

      expect(
        find.byKey(const ValueKey('globalArrangeElementHeader-element-1')),
        findsNothing,
      );
    },
  );

  testWidgets(
    'photo drag keeps a source placeholder while projecting destination gap',
    (tester) async {
      _setLargeSurface(tester);

      await tester.pumpWidget(const MaterialApp(home: _ArrangeHarness()));
      await tester.pumpAndSettle();

      final photoTwoStart = tester.getCenter(
        find.byKey(const ValueKey('globalArrangePhotoCard-photo-2')),
      );

      final dragGesture = await _startLongPressDrag(
        tester,
        find.byKey(const ValueKey('globalArrangePhotoCard-photo-2')),
      );
      final photoFourTarget =
          tester.getBottomRight(
            find.byKey(const ValueKey('globalArrangePhotoCard-photo-4')),
          ) -
          const Offset(12, 12);

      expect(
        find.byKey(const ValueKey('globalArrangePhotoCard-photo-2')),
        findsNothing,
      );

      await _dragSmoothly(
        tester,
        gesture: dragGesture,
        start: photoTwoStart,
        end: photoFourTarget,
      );

      expect(
        find.byKey(const ValueKey('globalArrangePhotoCard-photo-4')),
        findsOneWidget,
      );
      expect(
        find.byWidgetPredicate((widget) {
          final key = widget.key;
          return key is ValueKey<String> &&
              key.value.startsWith('globalArrangePhotoGap-element-3-');
        }),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('globalArrangePhotoPlaceholder-photo-2')),
        findsOneWidget,
      );

      await dragGesture.up();
      await tester.pumpAndSettle();
    },
  );

  testWidgets(
    'releasing element drag stops auto scroll before async drop settles',
    (tester) async {
      _setCompactSurface(tester);

      await tester.pumpWidget(
        MaterialApp(
          home: _ArrangeHarness(
            initialBoardData: _seedLargeBoardData(),
            elementMoveDelay: const Duration(milliseconds: 300),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final listViewFinder = find.byType(ListView).first;
      final scrollable = tester.state<ScrollableState>(
        find
            .descendant(of: listViewFinder, matching: find.byType(Scrollable))
            .first,
      );
      final dragGesture = await _startLongPressDrag(
        tester,
        find.byKey(const ValueKey('globalArrangeElementHeader-element-1')),
      );

      final bottomEdgeTarget =
          tester.getRect(listViewFinder).bottomCenter - const Offset(0, 12);
      await dragGesture.moveTo(bottomEdgeTarget);
      await tester.pump(const Duration(milliseconds: 240));

      final offsetBeforeRelease = scrollable.position.pixels;
      expect(offsetBeforeRelease, greaterThan(0));

      await dragGesture.up();
      await tester.pump(const Duration(milliseconds: 16));
      final offsetAfterRelease = scrollable.position.pixels;

      await tester.pump(const Duration(milliseconds: 160));
      final offsetLater = scrollable.position.pixels;

      expect(offsetLater, closeTo(offsetAfterRelease, 0.1));

      await tester.pump(const Duration(milliseconds: 200));
      await tester.pumpAndSettle();
    },
  );

  testWidgets('photo drag edge auto scroll reverses during one drag', (
    tester,
  ) async {
    _setCompactSurface(tester);

    await tester.pumpWidget(
      MaterialApp(
        home: _ArrangeHarness(initialBoardData: _seedLargeBoardData()),
      ),
    );
    await tester.pumpAndSettle();

    final listViewFinder = find.byType(ListView).first;
    final scrollable = tester.state<ScrollableState>(
      find
          .descendant(of: listViewFinder, matching: find.byType(Scrollable))
          .first,
    );
    final dragGesture = await _startLongPressDrag(
      tester,
      find.byKey(const ValueKey('globalArrangePhotoCard-photo-1')),
    );

    final bottomEdgeTarget =
        tester.getRect(listViewFinder).bottomCenter - const Offset(0, 10);
    await dragGesture.moveTo(bottomEdgeTarget);
    await tester.pump(const Duration(milliseconds: 260));
    final offsetAfterDownScroll = scrollable.position.pixels;
    expect(offsetAfterDownScroll, greaterThan(0));

    final topEdgeTarget =
        tester.getRect(listViewFinder).topCenter + const Offset(0, 10);
    await dragGesture.moveTo(topEdgeTarget);
    await tester.pump(const Duration(milliseconds: 260));
    expect(scrollable.position.pixels, lessThan(offsetAfterDownScroll));

    await dragGesture.up();
    await tester.pumpAndSettle();
  });

  testWidgets('element can move from chapter into unassigned lane', (
    tester,
  ) async {
    _setLargeSurface(tester);

    await tester.pumpWidget(
      MaterialApp(
        home: _ArrangeHarness(initialBoardData: _seedBoardDataWithUnassigned()),
      ),
    );
    await tester.pumpAndSettle();

    final dragGesture = await _startLongPressDrag(
      tester,
      find.byKey(const ValueKey('globalArrangeElementHeader-element-2')),
    );

    final unassignedGapCenter = tester.getCenter(
      find.byKey(const ValueKey('globalArrangeElementGap-unassigned-1')),
    );
    await dragGesture.moveTo(unassignedGapCenter);
    await tester.pump(const Duration(milliseconds: 32));

    await dragGesture.up();
    await tester.pumpAndSettle();

    final unassignedElementY = tester
        .getTopLeft(
          find.byKey(
            const ValueKey('globalArrangeElementHeader-element-unassigned'),
          ),
        )
        .dy;
    final movedElementY = tester
        .getTopLeft(
          find.byKey(const ValueKey('globalArrangeElementHeader-element-2')),
        )
        .dy;

    expect(movedElementY, greaterThan(unassignedElementY));
  });

  testWidgets('unassigned chapter keeps chapter styling but is not draggable', (
    tester,
  ) async {
    _setLargeSurface(tester);

    await tester.pumpWidget(
      MaterialApp(
        home: _ArrangeHarness(initialBoardData: _seedBoardDataWithUnassigned()),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('globalArrangeChapterHeader-unassigned')),
      findsOneWidget,
    );

    final dragGesture = await _startLongPressDrag(
      tester,
      find.byKey(const ValueKey('globalArrangeChapterHeader-unassigned')),
    );
    await tester.pump(const Duration(milliseconds: 32));
    await dragGesture.up();
    await tester.pumpAndSettle();

    expect(
      find.byKey(
        const ValueKey('globalArrangeChapterPlaceholder-chapter-unassigned'),
      ),
      findsNothing,
    );
  });

  testWidgets('photo can move from element into loose photo pool', (
    tester,
  ) async {
    _setLargeSurface(tester);
    final harnessKey = GlobalKey<_ArrangeHarnessState>();

    await tester.pumpWidget(
      MaterialApp(
        home: _ArrangeHarness(
          key: harnessKey,
          initialBoardData: _seedBoardDataWithUnassigned(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('globalArrangePhotoCard-loose-photo-1')),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    final sourcePhoto = tester.getCenter(
      find.byKey(const ValueKey('globalArrangePhotoCard-photo-3')),
    );
    final dragGesture = await _startLongPressDrag(
      tester,
      find.byKey(const ValueKey('globalArrangePhotoCard-photo-3')),
    );
    final loosePoolTarget = tester.getCenter(
      find.byKey(const ValueKey('globalArrangePhotoCard-loose-photo-1')),
    );
    await _dragSmoothly(
      tester,
      gesture: dragGesture,
      start: sourcePhoto,
      end: loosePoolTarget + const Offset(0, 40),
    );
    await dragGesture.up();
    await tester.pumpAndSettle();

    expect(
      harnessKey.currentState!.boardData.unassignedPhotos.map(
        (photo) => photo.photoId,
      ),
      contains('photo-3'),
    );
  });

  test('loose photo model move can place a pool photo under an element', () {
    final updated = _movePhoto(
      boardData: _seedBoardDataWithUnassigned(),
      sourceElementId: globalArrangeLoosePhotoBucketId,
      sourcePhotoIndex: 0,
      targetElementId: 'element-unassigned',
      targetPhotoIndex: 1,
    );

    expect(
      updated.unassignedPhotos.map((photo) => photo.photoId),
      isNot(contains('loose-photo-1')),
    );
    expect(
      updated.unassignedElements.first.photos.map((photo) => photo.photoId),
      contains('loose-photo-1'),
    );
  });
}

void _setLargeSurface(WidgetTester tester) {
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });
  tester.view.devicePixelRatio = 1.0;
  tester.view.physicalSize = const Size(430, 2400);
}

void _setCompactSurface(WidgetTester tester) {
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });
  tester.view.devicePixelRatio = 1.0;
  tester.view.physicalSize = const Size(430, 780);
}

Future<TestGesture> _startLongPressDrag(
  WidgetTester tester,
  Finder finder,
) async {
  final gesture = await tester.startGesture(
    tester.getCenter(finder),
    kind: PointerDeviceKind.touch,
  );
  await tester.pump(const Duration(milliseconds: 700));
  await tester.pump();
  return gesture;
}

Future<void> _dragSmoothly(
  WidgetTester tester, {
  required TestGesture gesture,
  required Offset start,
  required Offset end,
  int steps = 8,
}) async {
  for (var step = 1; step <= steps; step++) {
    final t = step / steps;
    final nextOffset = Offset.lerp(start, end, t)!;
    await gesture.moveTo(nextOffset);
    await tester.pump(const Duration(milliseconds: 16));
  }
}

class _ArrangeHarness extends StatefulWidget {
  const _ArrangeHarness({
    super.key,
    this.initialBoardData,
    this.elementMoveDelay = Duration.zero,
  });

  final GlobalArrangeBoardData? initialBoardData;
  final Duration elementMoveDelay;

  @override
  State<_ArrangeHarness> createState() => _ArrangeHarnessState();
}

class _ArrangeHarnessState extends State<_ArrangeHarness> {
  late GlobalArrangeBoardData boardData =
      widget.initialBoardData ?? _seedBoardData();
  int? lastChapterTargetIndex;
  String? lastMovedChapterId;

  @override
  Widget build(BuildContext context) {
    return GlobalArrangePage(
      projectTitle: '拖动测试项目',
      boardData: boardData,
      onOpenSidebar: () {},
      onBottomTabChanged: (_) {},
      onOpenPendingOrganize: () async {},
      onMoveChapter: ({required chapterId, required targetIndex}) async {
        setState(() {
          lastMovedChapterId = chapterId;
          lastChapterTargetIndex = targetIndex;
          boardData = _moveChapter(
            boardData: boardData,
            chapterId: chapterId,
            targetIndex: targetIndex,
          );
        });
      },
      onMoveElement:
          ({
            required elementId,
            required targetChapterId,
            required targetIndex,
          }) async {
            if (widget.elementMoveDelay > Duration.zero) {
              await Future<void>.delayed(widget.elementMoveDelay);
            }
            setState(() {
              boardData = _moveElement(
                boardData: boardData,
                elementId: elementId,
                targetChapterId: targetChapterId,
                targetIndex: targetIndex,
              );
            });
          },
      onMovePhoto:
          ({
            required sourceElementId,
            required sourcePhotoIndex,
            required targetElementId,
            required targetPhotoIndex,
          }) async {
            setState(() {
              boardData = _movePhoto(
                boardData: boardData,
                sourceElementId: sourceElementId,
                sourcePhotoIndex: sourcePhotoIndex,
                targetElementId: targetElementId,
                targetPhotoIndex: targetPhotoIndex,
              );
            });
          },
    );
  }
}

GlobalArrangeBoardData _seedBoardData() {
  return const GlobalArrangeBoardData(
    chapters: <GlobalArrangeChapterData>[
      GlobalArrangeChapterData(
        chapterId: 'chapter-1',
        title: '第一章',
        elements: <GlobalArrangeElementData>[
          GlobalArrangeElementData(
            elementId: 'element-1',
            title: '元素一',
            relationTags: <String>['呼应'],
            photos: <GlobalArrangePhotoData>[
              GlobalArrangePhotoData(
                photoId: 'photo-1',
                imageSource: '/tmp/photo-1.jpg',
                relationTags: <String>['呼应'],
              ),
              GlobalArrangePhotoData(
                photoId: 'photo-2',
                imageSource: '/tmp/photo-2.jpg',
                relationTags: <String>['重复'],
              ),
            ],
          ),
          GlobalArrangeElementData(
            elementId: 'element-2',
            title: '元素二',
            relationTags: <String>[],
            photos: <GlobalArrangePhotoData>[
              GlobalArrangePhotoData(
                photoId: 'photo-3',
                imageSource: '/tmp/photo-3.jpg',
                relationTags: <String>[],
              ),
            ],
          ),
        ],
      ),
      GlobalArrangeChapterData(
        chapterId: 'chapter-2',
        title: '第二章',
        elements: <GlobalArrangeElementData>[
          GlobalArrangeElementData(
            elementId: 'element-3',
            title: '元素三',
            relationTags: <String>['对比'],
            photos: <GlobalArrangePhotoData>[
              GlobalArrangePhotoData(
                photoId: 'photo-4',
                imageSource: '/tmp/photo-4.jpg',
                relationTags: <String>['对比'],
              ),
            ],
          ),
        ],
      ),
    ],
  );
}

GlobalArrangeBoardData _seedLargeBoardData() {
  return GlobalArrangeBoardData(
    chapters: List<GlobalArrangeChapterData>.generate(8, (chapterIndex) {
      return GlobalArrangeChapterData(
        chapterId: 'chapter-${chapterIndex + 1}',
        title: '章节 ${chapterIndex + 1}',
        elements: List<GlobalArrangeElementData>.generate(3, (elementIndex) {
          final globalElementIndex = chapterIndex * 3 + elementIndex + 1;
          return GlobalArrangeElementData(
            elementId: 'element-$globalElementIndex',
            title: '元素 $globalElementIndex',
            relationTags: const <String>[],
            photos: <GlobalArrangePhotoData>[
              GlobalArrangePhotoData(
                photoId: 'photo-$globalElementIndex',
                imageSource: '/tmp/photo-$globalElementIndex.jpg',
                relationTags: const <String>[],
              ),
            ],
          );
        }),
      );
    }),
  );
}

GlobalArrangeBoardData _seedBoardDataWithUnassigned() {
  return GlobalArrangeBoardData(
    chapters: _seedBoardData().chapters.map(_copyChapter).toList(),
    unassignedElements: <GlobalArrangeElementData>[
      const GlobalArrangeElementData(
        elementId: 'element-unassigned',
        title: '未归属元素',
        relationTags: <String>[],
        photos: <GlobalArrangePhotoData>[
          GlobalArrangePhotoData(
            photoId: 'photo-unassigned',
            imageSource: '/tmp/photo-unassigned.jpg',
            relationTags: <String>[],
          ),
        ],
      ),
    ],
    unassignedPhotos: const <GlobalArrangePhotoData>[
      GlobalArrangePhotoData(
        photoId: 'loose-photo-1',
        imageSource: '/tmp/loose-photo-1.jpg',
        relationTags: <String>[],
        sourceRecordId: 'record-1',
      ),
    ],
  );
}

GlobalArrangeBoardData _moveChapter({
  required GlobalArrangeBoardData boardData,
  required String chapterId,
  required int targetIndex,
}) {
  final chapters = boardData.chapters.map(_copyChapter).toList(growable: true);
  final sourceIndex = chapters.indexWhere(
    (chapter) => chapter.chapterId == chapterId,
  );
  if (sourceIndex == -1) {
    return boardData;
  }
  final chapter = chapters.removeAt(sourceIndex);
  chapters.insert(targetIndex.clamp(0, chapters.length), chapter);
  return GlobalArrangeBoardData(
    chapters: chapters,
    unassignedElements: boardData.unassignedElements.map(_copyElement).toList(),
    unassignedPhotos: boardData.unassignedPhotos.map(_copyPhoto).toList(),
  );
}

GlobalArrangeBoardData _moveElement({
  required GlobalArrangeBoardData boardData,
  required String elementId,
  required String? targetChapterId,
  required int targetIndex,
}) {
  final chapters = boardData.chapters.map(_copyChapter).toList(growable: true);
  final unassigned = boardData.unassignedElements
      .map(_copyElement)
      .toList(growable: true);

  GlobalArrangeElementData? movedElement;
  for (final chapter in chapters) {
    final sourceIndex = chapter.elements.indexWhere(
      (element) => element.elementId == elementId,
    );
    if (sourceIndex == -1) {
      continue;
    }
    movedElement = chapter.elements.removeAt(sourceIndex);
    break;
  }
  if (movedElement == null) {
    final sourceIndex = unassigned.indexWhere(
      (element) => element.elementId == elementId,
    );
    if (sourceIndex != -1) {
      movedElement = unassigned.removeAt(sourceIndex);
    }
  }
  if (movedElement == null) {
    return boardData;
  }

  final targetBucket = targetChapterId == null
      ? unassigned
      : chapters
            .firstWhere((chapter) => chapter.chapterId == targetChapterId)
            .elements;
  targetBucket.insert(targetIndex.clamp(0, targetBucket.length), movedElement);

  return GlobalArrangeBoardData(
    chapters: chapters,
    unassignedElements: unassigned,
    unassignedPhotos: boardData.unassignedPhotos.map(_copyPhoto).toList(),
  );
}

GlobalArrangeBoardData _movePhoto({
  required GlobalArrangeBoardData boardData,
  required String sourceElementId,
  required int sourcePhotoIndex,
  required String targetElementId,
  required int targetPhotoIndex,
}) {
  final chapters = boardData.chapters.map(_copyChapter).toList(growable: true);
  final unassigned = boardData.unassignedElements
      .map(_copyElement)
      .toList(growable: true);
  final loosePhotos = boardData.unassignedPhotos
      .map(_copyPhoto)
      .toList(growable: true);

  GlobalArrangeElementData? sourceElement;
  GlobalArrangeElementData? targetElement;
  List<GlobalArrangePhotoData>? sourceBucket;
  List<GlobalArrangePhotoData>? targetBucket;
  if (sourceElementId == globalArrangeLoosePhotoBucketId) {
    sourceBucket = loosePhotos;
  }
  if (targetElementId == globalArrangeLoosePhotoBucketId) {
    targetBucket = loosePhotos;
  }
  for (final chapter in chapters) {
    for (final element in chapter.elements) {
      if (element.elementId == sourceElementId) {
        sourceElement = element;
      }
      if (element.elementId == targetElementId) {
        targetElement = element;
      }
    }
  }
  for (final element in unassigned) {
    if (element.elementId == sourceElementId) {
      sourceElement = element;
    }
    if (element.elementId == targetElementId) {
      targetElement = element;
    }
  }
  if (sourceBucket == null && sourceElement == null) {
    return boardData;
  }
  if (targetBucket == null && targetElement == null) {
    return boardData;
  }

  GlobalArrangePhotoData? movedPhoto;
  if (sourceBucket != null) {
    if (sourcePhotoIndex < 0 || sourcePhotoIndex >= sourceBucket.length) {
      return boardData;
    }
    movedPhoto = sourceBucket.removeAt(sourcePhotoIndex);
  } else {
    if (sourcePhotoIndex < 0 ||
        sourcePhotoIndex >= sourceElement!.photos.length) {
      return boardData;
    }
    movedPhoto = sourceElement.photos.removeAt(sourcePhotoIndex);
  }

  final targetPhotos = targetBucket ?? targetElement!.photos;
  targetPhotos.insert(
    targetPhotoIndex.clamp(0, targetPhotos.length),
    movedPhoto,
  );

  return GlobalArrangeBoardData(
    chapters: chapters,
    unassignedElements: unassigned,
    unassignedPhotos: loosePhotos,
  );
}

GlobalArrangeChapterData _copyChapter(GlobalArrangeChapterData chapter) {
  return GlobalArrangeChapterData(
    chapterId: chapter.chapterId,
    title: chapter.title,
    elements: chapter.elements.map(_copyElement).toList(),
  );
}

GlobalArrangeElementData _copyElement(GlobalArrangeElementData element) {
  return GlobalArrangeElementData(
    elementId: element.elementId,
    title: element.title,
    relationTags: List<String>.from(element.relationTags),
    photos: element.photos.map(_copyPhoto).toList(),
  );
}

GlobalArrangePhotoData _copyPhoto(GlobalArrangePhotoData photo) {
  return GlobalArrangePhotoData(
    photoId: photo.photoId,
    imageSource: photo.imageSource,
    relationTags: List<String>.from(photo.relationTags),
    sourceRecordId: photo.sourceRecordId,
  );
}
