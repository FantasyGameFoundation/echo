import 'package:echo/features/curation/presentation/pages/global_arrange_page.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'live drag flow keeps placeholders visible and preserves chapter element photo order',
    (tester) async {
      final harnessKey = GlobalKey<_ArrangeHarnessState>();

      await binding.setSurfaceSize(const Size(430, 2400));
      await tester.pumpWidget(
        MaterialApp(home: _ArrangeHarness(key: harnessKey)),
      );
      await tester.pumpAndSettle();
      final chapterOneStart = tester.getCenter(
        find.byKey(const ValueKey('globalArrangeChapterHeader-chapter-1')),
      );
      final chapterGesture = await _startLongPressDrag(
        tester,
        find.byKey(const ValueKey('globalArrangeChapterHeader-chapter-1')),
      );
      final chapterTwoTarget = Offset(
        tester
            .getCenter(
              find.byKey(
                const ValueKey('globalArrangeChapterHeader-chapter-2'),
              ),
            )
            .dx,
        tester
                .getCenter(
                  find.byKey(
                    const ValueKey('globalArrangeChapterHeader-chapter-2'),
                  ),
                )
                .dy +
            52,
      );
      expect(
        find.byKey(const ValueKey('globalArrangeChapterPlaceholder-chapter-1')),
        findsOneWidget,
      );
      await _dragSmoothly(
        tester,
        gesture: chapterGesture,
        start: chapterOneStart,
        end: chapterTwoTarget,
      );
      await chapterGesture.up();
      await tester.pumpAndSettle();

      final elementOneStart = tester.getCenter(
        find.byKey(const ValueKey('globalArrangeElementHeader-element-1')),
      );
      final elementGesture = await _startLongPressDrag(
        tester,
        find.byKey(const ValueKey('globalArrangeElementHeader-element-1')),
      );
      final elementThreeTarget = Offset(
        tester
            .getCenter(
              find.byKey(
                const ValueKey('globalArrangeElementHeader-element-3'),
              ),
            )
            .dx,
        tester
                .getCenter(
                  find.byKey(
                    const ValueKey('globalArrangeElementHeader-element-3'),
                  ),
                )
                .dy +
            44,
      );
      expect(
        find.byKey(const ValueKey('globalArrangeElementPlaceholder-element-1')),
        findsOneWidget,
      );
      await _dragSmoothly(
        tester,
        gesture: elementGesture,
        start: elementOneStart,
        end: elementThreeTarget,
      );
      await elementGesture.up();
      await tester.pumpAndSettle();

      final photoTwoStart = tester.getCenter(
        find.byKey(const ValueKey('globalArrangePhotoCard-photo-2')),
      );
      final photoGesture = await _startLongPressDrag(
        tester,
        find.byKey(const ValueKey('globalArrangePhotoCard-photo-2')),
      );
      final photoFourTarget =
          tester.getCenter(
            find.byKey(const ValueKey('globalArrangePhotoCard-photo-4')),
          ) +
          const Offset(140, 0);
      expect(
        find.byKey(const ValueKey('globalArrangePhotoPlaceholder-photo-2')),
        findsOneWidget,
      );
      await _dragSmoothly(
        tester,
        gesture: photoGesture,
        start: photoTwoStart,
        end: photoFourTarget,
      );
      await photoGesture.up();
      await tester.pumpAndSettle();

      final boardData = harnessKey.currentState!.boardData;
      expect(
        boardData.chapters.map((chapter) => chapter.chapterId).toList(),
        <String>['chapter-2', 'chapter-1'],
      );
      expect(
        boardData.chapters.first.elements
            .map((element) => element.elementId)
            .toList(),
        <String>['element-3', 'element-1'],
      );
      expect(
        boardData.chapters.first.elements.first.photos
            .map((photo) => photo.photoId)
            .toList(),
        <String>['photo-4', 'photo-2'],
      );

      await binding.takeScreenshot('global-arrange-drag-flow');
    },
  );
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
  const _ArrangeHarness({super.key});

  @override
  State<_ArrangeHarness> createState() => _ArrangeHarnessState();
}

class _ArrangeHarnessState extends State<_ArrangeHarness> {
  late GlobalArrangeBoardData boardData = _seedBoardData();

  @override
  Widget build(BuildContext context) {
    return GlobalArrangePage(
      projectTitle: '整理页拖动实测',
      boardData: boardData,
      onOpenSidebar: () {},
      onBottomTabChanged: (_) {},
      onOpenPendingOrganize: () async {},
      onMoveChapter: ({required chapterId, required targetIndex}) async {
        setState(() {
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

  GlobalArrangeElementData? sourceElement;
  GlobalArrangeElementData? targetElement;
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
  if (sourceElement == null ||
      targetElement == null ||
      sourcePhotoIndex < 0 ||
      sourcePhotoIndex >= sourceElement.photos.length) {
    return boardData;
  }

  final movedPhoto = sourceElement.photos.removeAt(sourcePhotoIndex);
  targetElement.photos.insert(
    targetPhotoIndex.clamp(0, targetElement.photos.length),
    movedPhoto,
  );

  return GlobalArrangeBoardData(
    chapters: chapters,
    unassignedElements: unassigned,
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
  );
}
