import 'dart:async';
import 'dart:ui';

import 'package:echo/features/structure_elements_relations/presentation/widgets/narrative_thumbnail_provider.dart';
import 'package:echo/shared/models/prototype_tab.dart';
import 'package:echo/shared/widgets/custom_bottom_nav_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

const Object _retainHoverChapterId = Object();
const String globalArrangeLoosePhotoBucketId =
    '__global_arrange_loose_photo_bucket__';

class GlobalArrangeBoardData {
  const GlobalArrangeBoardData({
    required this.chapters,
    this.unassignedElements = const <GlobalArrangeElementData>[],
    this.unassignedPhotos = const <GlobalArrangePhotoData>[],
  });

  final List<GlobalArrangeChapterData> chapters;
  final List<GlobalArrangeElementData> unassignedElements;
  final List<GlobalArrangePhotoData> unassignedPhotos;
}

class GlobalArrangeChapterData {
  const GlobalArrangeChapterData({
    required this.chapterId,
    required this.title,
    required this.elements,
  });

  final String chapterId;
  final String title;
  final List<GlobalArrangeElementData> elements;
}

class GlobalArrangeElementData {
  const GlobalArrangeElementData({
    required this.elementId,
    required this.title,
    required this.relationTags,
    required this.photos,
  });

  final String elementId;
  final String title;
  final List<String> relationTags;
  final List<GlobalArrangePhotoData> photos;
}

class GlobalArrangePhotoData {
  const GlobalArrangePhotoData({
    required this.photoId,
    required this.imageSource,
    required this.relationTags,
    this.sourceRecordId,
  });

  final String photoId;
  final String imageSource;
  final List<String> relationTags;
  final String? sourceRecordId;
}

class GlobalArrangePhotoLandingRequest {
  const GlobalArrangePhotoLandingRequest({
    required this.requestId,
    required this.photoPath,
    this.sourceRecordId,
  });

  final String requestId;
  final String photoPath;
  final String? sourceRecordId;
}

class GlobalArrangePage extends StatefulWidget {
  const GlobalArrangePage({
    super.key,
    required this.projectTitle,
    required this.boardData,
    required this.onOpenSidebar,
    required this.onBottomTabChanged,
    required this.onOpenPendingOrganize,
    required this.onMoveChapter,
    required this.onMoveElement,
    required this.onMovePhoto,
    this.onOpenSettings,
    this.landingRequest,
    this.onLandingRequestConsumed,
    this.onDeletePhoto,
  });

  final String projectTitle;
  final GlobalArrangeBoardData boardData;
  final VoidCallback onOpenSidebar;
  final ValueChanged<PrototypeTab> onBottomTabChanged;
  final Future<void> Function() onOpenPendingOrganize;
  final Future<void> Function({
    required String chapterId,
    required int targetIndex,
  })
  onMoveChapter;
  final Future<void> Function({
    required String elementId,
    required String? targetChapterId,
    required int targetIndex,
  })
  onMoveElement;
  final Future<void> Function({
    required String sourceElementId,
    required int sourcePhotoIndex,
    required String targetElementId,
    required int targetPhotoIndex,
  })
  onMovePhoto;
  final Future<void> Function()? onOpenSettings;
  final GlobalArrangePhotoLandingRequest? landingRequest;
  final ValueChanged<String>? onLandingRequestConsumed;
  final Future<bool> Function(String photoPath)? onDeletePhoto;

  @override
  State<GlobalArrangePage> createState() => _GlobalArrangePageState();
}

enum _ActiveTagSource { element, photo }

enum _DragKind { chapter, element, photo }

class _GlobalArrangePageState extends State<GlobalArrangePage>
    with SingleTickerProviderStateMixin {
  static const double _dragPlaceholderOpacity = 0.34;
  static const Duration _autoScrollTick = Duration(milliseconds: 16);
  static const Duration _gapAnimationDuration = Duration(milliseconds: 220);
  static const Duration _dragFeedbackAnimationDuration = Duration(
    milliseconds: 150,
  );
  static const int _maxLandingAttempts = 5;
  static const Duration _focusModeRestoreDelay = Duration(milliseconds: 780);
  static const Duration _hapticThrottleDuration = Duration(milliseconds: 180);
  static const Curve _dragMotionCurve = Curves.easeOutCubic;
  static const double _autoScrollEdgePadding = 136.0;
  static const double _autoScrollMinStep = 2.0;
  static const double _autoScrollMaxStep = 14.0;
  static const double _chapterDragExtent = 54.0;
  static const double _chapterTailGapExtent = 96.0;
  static const double _elementDragExtent = 42.0;
  static const double _elementAfterThresholdCap = 72.0;
  static const double _elementInactiveGapExtent = 20.0;
  static const double _elementTailGapExtent = 84.0;
  static const double _spotlightInactiveScale = 0.98;
  final Set<String> _expandedChapterIds = <String>{};
  final Set<String> _expandedElementIds = <String>{};
  final Map<String, GlobalKey> _chapterItemKeys = <String, GlobalKey>{};
  final Map<int, GlobalKey> _chapterGapItemKeys = <int, GlobalKey>{};
  final Map<String, GlobalKey> _elementItemKeys = <String, GlobalKey>{};
  final Map<String, GlobalKey> _elementGapItemKeys = <String, GlobalKey>{};
  final Map<String, GlobalKey> _photoItemKeys = <String, GlobalKey>{};
  final List<BoxShadow> _subtleShadow = <BoxShadow>[
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.06),
      blurRadius: 18,
      offset: const Offset(0, 4),
    ),
  ];
  final List<BoxShadow> _dragLiftShadow = <BoxShadow>[
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.14),
      blurRadius: 28,
      offset: const Offset(0, 12),
    ),
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.07),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
  ];
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _scrollViewportKey = GlobalKey(
    debugLabel: 'global-arrange-scroll-viewport',
  );
  final GlobalKey _unassignedPhotoPoolKey = GlobalKey(
    debugLabel: 'global-arrange-unassigned-photo-pool',
  );
  late final Ticker _autoScrollTicker;
  late final ValueNotifier<_ElementDragState?> _elementDragStateListenable;
  late final ValueNotifier<_PhotoDragState?> _photoDragStateListenable;

  late List<_ArrangeChapterVm> _chapters;
  late List<_ArrangeElementVm> _unassignedElements;
  late List<_ArrangePhotoVm> _unassignedPhotos;
  String? _activeTag;
  _ActiveTagSource? _activeTagSource;
  _DragKind? _activeDragKind;
  _ChapterDragState? _chapterDragState;
  Offset? _latestDragGlobalPosition;
  Duration? _lastAutoScrollElapsed;
  Timer? _focusModeRestoreTimer;
  DateTime? _lastHapticAt;
  String? _lastHapticTargetId;
  double _lastScrollOffset = 0.0;
  double _chapterBreathingGap = 0.0;
  bool _chapterDragFinalizing = false;
  bool _elementDragFinalizing = false;
  bool _isFocusMode = false;
  bool _isUnassignedChapterExpanded = true;
  String? _processingLandingRequestId;
  String? _consumedLandingRequestId;

  _ElementDragState? get _elementDragState => _elementDragStateListenable.value;
  set _elementDragState(_ElementDragState? value) {
    _elementDragStateListenable.value = value;
  }

  _PhotoDragState? get _photoDragState => _photoDragStateListenable.value;
  set _photoDragState(_PhotoDragState? value) {
    _photoDragStateListenable.value = value;
  }

  @override
  void initState() {
    super.initState();
    _autoScrollTicker = createTicker(_handleAutoScrollTick);
    _elementDragStateListenable = ValueNotifier<_ElementDragState?>(null);
    _photoDragStateListenable = ValueNotifier<_PhotoDragState?>(null);
    _scrollController.addListener(_handleScrollForFocusMode);
    _syncBoardData();
    _queueLandingRequestIfNeeded();
  }

  @override
  void dispose() {
    _stopAutoScroll();
    _focusModeRestoreTimer?.cancel();
    _scrollController.removeListener(_handleScrollForFocusMode);
    _autoScrollTicker.dispose();
    _elementDragStateListenable.dispose();
    _photoDragStateListenable.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant GlobalArrangePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.boardData != widget.boardData) {
      _syncBoardData();
    }
    final didLandingRequestChange =
        oldWidget.landingRequest?.requestId != widget.landingRequest?.requestId;
    if (oldWidget.boardData != widget.boardData || didLandingRequestChange) {
      _queueLandingRequestIfNeeded();
    }
  }

  void _syncBoardData() {
    final currentExpandedChapters = Set<String>.from(_expandedChapterIds);
    final currentExpandedElements = Set<String>.from(_expandedElementIds);

    _chapters = widget.boardData.chapters
        .map(_ArrangeChapterVm.fromData)
        .toList(growable: true);
    _unassignedElements = widget.boardData.unassignedElements
        .map(_ArrangeElementVm.fromData)
        .toList(growable: true);
    _unassignedPhotos = widget.boardData.unassignedPhotos
        .map(_ArrangePhotoVm.fromData)
        .toList(growable: true);

    _expandedChapterIds
      ..clear()
      ..addAll(
        _chapters
            .map((chapter) => chapter.chapterId)
            .where(
              (chapterId) =>
                  currentExpandedChapters.isEmpty ||
                  currentExpandedChapters.contains(chapterId),
            ),
      );
    for (final chapter in _chapters) {
      for (final element in chapter.elements) {
        if (currentExpandedElements.isEmpty ||
            currentExpandedElements.contains(element.elementId)) {
          _expandedElementIds.add(element.elementId);
        }
      }
    }
    _expandedElementIds.removeWhere(
      (elementId) =>
          !_chapters.any(
            (chapter) => chapter.elements.any(
              (element) => element.elementId == elementId,
            ),
          ) &&
          !_unassignedElements.any((element) => element.elementId == elementId),
    );
    for (final element in _unassignedElements) {
      if (currentExpandedElements.isEmpty ||
          currentExpandedElements.contains(element.elementId)) {
        _expandedElementIds.add(element.elementId);
      }
    }
  }

  void _queueLandingRequestIfNeeded() {
    final request = widget.landingRequest;
    if (request == null ||
        request.requestId == _consumedLandingRequestId ||
        request.requestId == _processingLandingRequestId) {
      return;
    }
    _processingLandingRequestId = request.requestId;
    SchedulerBinding.instance.addPostFrameCallback((_) {
      unawaited(_consumeLandingRequest(request));
    });
  }

  Future<void> _consumeLandingRequest(
    GlobalArrangePhotoLandingRequest request, {
    int attempt = 1,
  }) async {
    if (!mounted || widget.landingRequest?.requestId != request.requestId) {
      _processingLandingRequestId = null;
      return;
    }

    final target = _findLandingTarget(request);
    if (target == null) {
      _finishLandingRequest(request.requestId);
      return;
    }

    var needsAnotherFrame = false;
    if (target.chapterId != null &&
        !_expandedChapterIds.contains(target.chapterId)) {
      _expandedChapterIds.add(target.chapterId!);
      needsAnotherFrame = true;
    }
    if (target.elementId != null &&
        !_expandedElementIds.contains(target.elementId)) {
      _expandedElementIds.add(target.elementId!);
      needsAnotherFrame = true;
    }

    if (needsAnotherFrame) {
      if (mounted) {
        setState(() {});
      }
      _scheduleLandingAttempt(request, attempt + 1);
      return;
    }

    if (attempt == 2) {
      final containerContext = _landingContainerContext(target);
      if (containerContext != null) {
        await Scrollable.ensureVisible(
          containerContext,
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          alignment: 0.10,
        );
      }
      _scheduleLandingAttempt(request, attempt + 1);
      return;
    }

    final targetContext = _photoKey(target.photoId).currentContext;
    if (targetContext == null) {
      if (attempt < _maxLandingAttempts) {
        _scheduleLandingAttempt(request, attempt + 1);
        return;
      }
      _finishLandingRequest(request.requestId);
      return;
    }

    await Scrollable.ensureVisible(
      targetContext,
      duration: const Duration(milliseconds: 360),
      curve: Curves.easeInOutCubic,
      alignment: 0.14,
    );
    _finishLandingRequest(request.requestId);
  }

  void _scheduleLandingAttempt(
    GlobalArrangePhotoLandingRequest request,
    int attempt,
  ) {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      unawaited(_consumeLandingRequest(request, attempt: attempt));
    });
  }

  BuildContext? _landingContainerContext(_PhotoLandingTarget target) {
    final elementId = target.elementId;
    if (elementId != null) {
      return _elementKey(elementId).currentContext;
    }
    final chapterId = target.chapterId;
    if (chapterId != null) {
      return _chapterKey(chapterId).currentContext;
    }
    return _unassignedPhotoPoolKey.currentContext;
  }

  _PhotoLandingTarget? _findLandingTarget(
    GlobalArrangePhotoLandingRequest request,
  ) {
    if (request.sourceRecordId != null) {
      final exactTarget = _findLandingTargetWithMatcher(
        (photo) =>
            photo.imageSource == request.photoPath &&
            photo.sourceRecordId == request.sourceRecordId,
      );
      if (exactTarget != null) {
        return exactTarget;
      }
    }

    return _findLandingTargetWithMatcher(
      (photo) => photo.imageSource == request.photoPath,
    );
  }

  _PhotoLandingTarget? _findLandingTargetWithMatcher(
    bool Function(_ArrangePhotoVm photo) matches,
  ) {
    for (final photo in _unassignedPhotos) {
      if (matches(photo)) {
        return _PhotoLandingTarget(photoId: photo.photoId);
      }
    }

    for (final chapter in _chapters) {
      for (final element in chapter.elements) {
        for (final photo in element.photos) {
          if (matches(photo)) {
            return _PhotoLandingTarget(
              chapterId: chapter.chapterId,
              elementId: element.elementId,
              photoId: photo.photoId,
            );
          }
        }
      }
    }

    for (final element in _unassignedElements) {
      for (final photo in element.photos) {
        if (matches(photo)) {
          return _PhotoLandingTarget(
            elementId: element.elementId,
            photoId: photo.photoId,
          );
        }
      }
    }

    return null;
  }

  void _finishLandingRequest(String requestId) {
    _processingLandingRequestId = null;
    _consumedLandingRequestId = requestId;
    widget.onLandingRequestConsumed?.call(requestId);
  }

  bool _isChapterExpanded(String chapterId) {
    return _expandedChapterIds.contains(chapterId);
  }

  bool _isElementExpanded(String elementId) {
    return _expandedElementIds.contains(elementId);
  }

  void _toggleChapter(String chapterId) {
    setState(() {
      if (_expandedChapterIds.contains(chapterId)) {
        _expandedChapterIds.remove(chapterId);
      } else {
        _expandedChapterIds.add(chapterId);
      }
    });
  }

  void _toggleUnassignedChapter() {
    setState(() {
      _isUnassignedChapterExpanded = !_isUnassignedChapterExpanded;
    });
  }

  void _toggleElement(String elementId) {
    setState(() {
      if (_expandedElementIds.contains(elementId)) {
        _expandedElementIds.remove(elementId);
      } else {
        _expandedElementIds.add(elementId);
      }
    });
  }

  bool _isElementActive(_ArrangeElementVm element) {
    if (_activeTag == null) {
      return true;
    }
    if (element.relationTags.contains(_activeTag)) {
      return true;
    }
    return element.photos.any(
      (photo) => photo.relationTags.contains(_activeTag),
    );
  }

  bool _isChapterActive(_ArrangeChapterVm chapter) {
    if (_activeTag == null) {
      return true;
    }
    return chapter.elements.any(_isElementActive);
  }

  bool _isPhotoActive(_ArrangeElementVm element, _ArrangePhotoVm photo) {
    if (_activeTag == null) {
      return true;
    }
    if (_activeTagSource == _ActiveTagSource.element) {
      return element.relationTags.contains(_activeTag) ||
          photo.relationTags.contains(_activeTag);
    }
    return photo.relationTags.contains(_activeTag);
  }

  void _toggleTag(String tag, _ActiveTagSource source) {
    setState(() {
      if (_activeTag == tag) {
        _activeTag = null;
        _activeTagSource = null;
      } else {
        _activeTag = tag;
        _activeTagSource = source;
      }
    });
  }

  void _clearActiveTag() {
    if (_activeTag == null) {
      return;
    }
    setState(() {
      _activeTag = null;
      _activeTagSource = null;
    });
  }

  GlobalKey _chapterKey(String chapterId) {
    return _chapterItemKeys.putIfAbsent(
      chapterId,
      () => GlobalKey(debugLabel: 'global-arrange-chapter-$chapterId'),
    );
  }

  GlobalKey _elementKey(String elementId) {
    return _elementItemKeys.putIfAbsent(
      elementId,
      () => GlobalKey(debugLabel: 'global-arrange-element-$elementId'),
    );
  }

  GlobalKey _chapterGapKey(int index) {
    return _chapterGapItemKeys.putIfAbsent(
      index,
      () => GlobalKey(debugLabel: 'global-arrange-chapter-gap-$index'),
    );
  }

  GlobalKey _photoKey(String photoId) {
    return _photoItemKeys.putIfAbsent(
      photoId,
      () => GlobalKey(debugLabel: 'global-arrange-photo-$photoId'),
    );
  }

  GlobalKey _elementGapKey(String? chapterId, int index) {
    final bucketKey = '${chapterId ?? 'unassigned'}::$index';
    return _elementGapItemKeys.putIfAbsent(
      bucketKey,
      () => GlobalKey(debugLabel: 'global-arrange-element-gap-$bucketKey'),
    );
  }

  Widget _buildDragPlaceholder({required Key key, required Widget child}) {
    return KeyedSubtree(
      key: key,
      child: IgnorePointer(
        child: Opacity(opacity: _dragPlaceholderOpacity, child: child),
      ),
    );
  }

  void _recordDragPosition(Offset globalPosition) {
    _latestDragGlobalPosition = globalPosition;
    if (_activeDragKind != null) {
      _ensureAutoScrollRunning();
    }
  }

  void _ensureAutoScrollRunning() {
    if (_autoScrollTicker.isTicking) {
      return;
    }
    _lastAutoScrollElapsed = null;
    _autoScrollTicker.start();
  }

  void _stopAutoScroll() {
    if (_autoScrollTicker.isTicking) {
      _autoScrollTicker.stop();
    }
    _lastAutoScrollElapsed = null;
  }

  void _releaseDragMotion() {
    _latestDragGlobalPosition = null;
    _stopAutoScroll();
    _scheduleFocusModeRestore();
  }

  void _triggerHaptic({String? targetId, bool force = false}) {
    final now = DateTime.now();
    if (!force &&
        _lastHapticAt != null &&
        now.difference(_lastHapticAt!) < _hapticThrottleDuration &&
        _lastHapticTargetId == targetId) {
      return;
    }
    _lastHapticAt = now;
    _lastHapticTargetId = targetId;
    unawaited(HapticFeedback.mediumImpact());
  }

  void _scheduleFocusModeRestore() {
    _focusModeRestoreTimer?.cancel();
    if (_activeDragKind != null) {
      return;
    }
    _focusModeRestoreTimer = Timer(_focusModeRestoreDelay, () {
      if (!mounted || _activeDragKind != null) {
        return;
      }
      setState(() {
        _isFocusMode = false;
        _chapterBreathingGap = 0.0;
      });
    });
  }

  void _enterFocusMode({double? breathingGap}) {
    _focusModeRestoreTimer?.cancel();
    final nextBreathingGap = breathingGap ?? _chapterBreathingGap;
    if (!_isFocusMode ||
        (nextBreathingGap - _chapterBreathingGap).abs() > 0.8) {
      setState(() {
        _isFocusMode = true;
        _chapterBreathingGap = nextBreathingGap;
      });
    }
    _scheduleFocusModeRestore();
  }

  bool _handleBoardScrollNotification(ScrollNotification notification) {
    if (notification.depth != 0) {
      return false;
    }
    final shouldEnterFocus =
        notification is ScrollStartNotification ||
        notification is ScrollUpdateNotification ||
        notification is OverscrollNotification ||
        notification is UserScrollNotification;
    if (!shouldEnterFocus) {
      return false;
    }
    final delta = notification is ScrollUpdateNotification
        ? (notification.scrollDelta ?? 0).abs()
        : 1.0;
    _enterFocusMode(breathingGap: (delta * 0.16).clamp(0.0, 8.0));
    return false;
  }

  void _handleScrollForFocusMode() {
    if (!_scrollController.hasClients) {
      return;
    }
    final nextOffset = _scrollController.offset;
    final delta = (nextOffset - _lastScrollOffset).abs();
    _lastScrollOffset = nextOffset;
    if (delta <= 0.2) {
      return;
    }
    final nextBreathingGap = (delta * 0.16).clamp(0.0, 8.0);
    _enterFocusMode(breathingGap: nextBreathingGap);
  }

  void _handleAutoScrollTick(Duration elapsed) {
    final previousElapsed = _lastAutoScrollElapsed;
    _lastAutoScrollElapsed = elapsed;
    final frameScale = previousElapsed == null
        ? 1.0
        : (elapsed - previousElapsed).inMicroseconds /
              _autoScrollTick.inMicroseconds;
    _tickAutoScrollWithFrameScale(frameScale.clamp(0.6, 2.2));
  }

  void _tickAutoScrollWithFrameScale(double frameScale) {
    if (!mounted ||
        _activeDragKind == null ||
        !_scrollController.hasClients ||
        _latestDragGlobalPosition == null) {
      return;
    }

    final viewportContext = _scrollViewportKey.currentContext;
    if (viewportContext == null) {
      return;
    }
    final renderObject = viewportContext.findRenderObject() as RenderBox?;
    if (renderObject == null || !renderObject.hasSize) {
      return;
    }

    final localPosition = renderObject.globalToLocal(
      _latestDragGlobalPosition!,
    );
    final viewportHeight = renderObject.size.height;
    final leadingRatio =
        ((_autoScrollEdgePadding - localPosition.dy) / _autoScrollEdgePadding)
            .clamp(0.0, 1.0);
    final trailingRatio =
        ((localPosition.dy - (viewportHeight - _autoScrollEdgePadding)) /
                _autoScrollEdgePadding)
            .clamp(0.0, 1.0);

    double scrollDelta = 0.0;
    if (leadingRatio > 0) {
      scrollDelta = -_autoScrollStep(leadingRatio) * frameScale;
    } else if (trailingRatio > 0) {
      scrollDelta = _autoScrollStep(trailingRatio) * frameScale;
    }

    if (scrollDelta == 0.0) {
      return;
    }

    final nextOffset = (_scrollController.offset + scrollDelta).clamp(
      _scrollController.position.minScrollExtent,
      _scrollController.position.maxScrollExtent,
    );
    if (nextOffset == _scrollController.offset) {
      return;
    }
    _scrollController.jumpTo(nextOffset);
  }

  double _autoScrollStep(double edgeRatio) {
    final easedRatio = edgeRatio * edgeRatio * edgeRatio;
    return _autoScrollMinStep +
        (_autoScrollMaxStep - _autoScrollMinStep) * easedRatio;
  }

  Widget _buildChapterDragPreview({
    required _ArrangeChapterVm chapter,
    required int chapterIndex,
  }) {
    return SizedBox(
      width: double.infinity,
      height: _chapterDragExtent,
      child: Align(
        alignment: Alignment.topCenter,
        child: _buildChapterHeader(
          chapter: chapter,
          chapterIndex: chapterIndex,
          isExpanded: false,
          onTap: null,
          isDragging: true,
          includeKey: false,
        ),
      ),
    );
  }

  Widget _buildElementDragPreview({required _ArrangeElementVm element}) {
    return SizedBox(
      width: double.infinity,
      height: _elementDragExtent,
      child: Align(
        alignment: Alignment.topCenter,
        child: _buildElementHeader(
          element: element,
          isExpanded: false,
          onTap: null,
          isDragging: true,
          includeKey: false,
        ),
      ),
    );
  }

  Widget _buildDragFeedbackShell({
    required Widget child,
    required double width,
    required double maxScale,
  }) {
    return IgnorePointer(
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 0.0, end: 1.0),
        duration: _dragFeedbackAnimationDuration,
        curve: _dragMotionCurve,
        child: SizedBox(width: width, child: child),
        builder: (context, value, feedbackChild) {
          return Opacity(
            opacity: lerpDouble(0.82, 1.0, value)!,
            child: Transform.rotate(
              angle: lerpDouble(0.0, -0.035, value)!,
              child: Transform.scale(
                scale: lerpDouble(1.0, maxScale, value)!,
                child: DecoratedBox(
                  decoration: BoxDecoration(boxShadow: _dragLiftShadow),
                  child: feedbackChild,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  String _chapterIndexLabel(int chapterIndex) {
    return (chapterIndex + 1).toString().padLeft(2, '0');
  }

  String _chapterShortLabel(int chapterIndex) {
    return 'CH ${_chapterIndexLabel(chapterIndex)}';
  }

  InlineSpan _chapterDisplaySpan(int chapterIndex, String title) {
    return TextSpan(
      children: [
        const TextSpan(text: 'CH', style: TextStyle(letterSpacing: 1.4)),
        TextSpan(
          text: ' ${_chapterIndexLabel(chapterIndex)}',
          style: const TextStyle(letterSpacing: 2.2),
        ),
        const TextSpan(text: ' / ', style: TextStyle(letterSpacing: 1.0)),
        TextSpan(text: title, style: const TextStyle(letterSpacing: 1.2)),
      ],
    );
  }

  int _chapterIndexById(String chapterId) {
    return _chapters.indexWhere((chapter) => chapter.chapterId == chapterId);
  }

  ({_ArrangeElementVm? element, String? chapterId, int elementIndex})
  _findElement(String elementId) {
    for (
      var chapterIndex = 0;
      chapterIndex < _chapters.length;
      chapterIndex++
    ) {
      final elementIndex = _chapters[chapterIndex].elements.indexWhere(
        (element) => element.elementId == elementId,
      );
      if (elementIndex != -1) {
        return (
          element: _chapters[chapterIndex].elements[elementIndex],
          chapterId: _chapters[chapterIndex].chapterId,
          elementIndex: elementIndex,
        );
      }
    }

    final unassignedIndex = _unassignedElements.indexWhere(
      (element) => element.elementId == elementId,
    );
    if (unassignedIndex != -1) {
      return (
        element: _unassignedElements[unassignedIndex],
        chapterId: null,
        elementIndex: unassignedIndex,
      );
    }

    return (element: null, chapterId: null, elementIndex: -1);
  }

  List<_ArrangeElementVm> _elementsForChapter(String? chapterId) {
    if (chapterId == null) {
      return _unassignedElements;
    }
    return _chapters[_chapterIndexById(chapterId)].elements;
  }

  _ArrangeElementVm _unassignedPhotoBucket() {
    return _ArrangeElementVm(
      elementId: globalArrangeLoosePhotoBucketId,
      title: '未关联照片',
      relationTags: const <String>[],
      photos: _unassignedPhotos,
    );
  }

  List<_ArrangePhotoVm>? _photosForContainer(String containerId) {
    if (containerId == globalArrangeLoosePhotoBucketId) {
      return _unassignedPhotos;
    }
    return _findElement(containerId).element?.photos;
  }

  Future<void> _handleChapterDrop(
    _ChapterDragPayload payload,
    int targetIndex,
  ) async {
    final sourceIndex = _chapterIndexById(payload.chapterId);
    if (sourceIndex == -1) {
      return;
    }
    final normalizedTargetIndex = targetIndex.clamp(0, _chapters.length - 1);
    if (normalizedTargetIndex == sourceIndex) {
      return;
    }

    final previousChapters = _chapters
        .map((chapter) => chapter.clone())
        .toList();
    setState(() {
      final chapter = _chapters.removeAt(sourceIndex);
      _chapters.insert(normalizedTargetIndex, chapter);
    });

    try {
      await widget.onMoveChapter(
        chapterId: payload.chapterId,
        targetIndex: normalizedTargetIndex,
      );
    } catch (_) {
      setState(() {
        _chapters = previousChapters;
      });
      rethrow;
    }
  }

  void _startChapterDrag(String chapterId) {
    final sourceIndex = _chapterIndexById(chapterId);
    if (sourceIndex == -1) {
      return;
    }
    _triggerHaptic(targetId: 'chapter-$chapterId', force: true);
    final wasExpanded = _isChapterExpanded(chapterId);
    setState(() {
      _isFocusMode = true;
      _activeDragKind = _DragKind.chapter;
      _chapterDragState = _ChapterDragState(
        sourceChapterId: chapterId,
        hoverIndex: sourceIndex,
        wasExpanded: wasExpanded,
      );
      if (wasExpanded) {
        _expandedChapterIds.remove(chapterId);
      }
    });
    _chapterDragFinalizing = false;
    _ensureAutoScrollRunning();
  }

  void _clearChapterDrag() {
    final dragState = _chapterDragState;
    if (dragState == null && _activeDragKind != _DragKind.chapter) {
      return;
    }
    setState(() {
      if (dragState?.wasExpanded ?? false) {
        _expandedChapterIds.add(dragState!.sourceChapterId);
      }
      _chapterDragState = null;
      if (_activeDragKind == _DragKind.chapter) {
        _activeDragKind = null;
      }
    });
    _chapterDragFinalizing = false;
    _releaseDragMotion();
  }

  Future<void> _finishChapterDrag(_ChapterDragPayload payload) async {
    if (_chapterDragFinalizing) {
      return;
    }
    _chapterDragFinalizing = true;
    final latestDragGlobalPosition = _latestDragGlobalPosition;
    _releaseDragMotion();
    final dragState = _chapterDragState;
    if (dragState != null) {
      final targetIndex = latestDragGlobalPosition == null
          ? dragState.hoverIndex
          : _resolveChapterDropTarget(latestDragGlobalPosition) ??
                dragState.hoverIndex;
      final currentIndex = _chapterIndexById(payload.chapterId);
      if (currentIndex != targetIndex) {
        await _handleChapterDrop(payload, targetIndex);
      }
    }
    if (mounted) {
      _clearChapterDrag();
    }
  }

  void _updateChapterHover({
    required String chapterId,
    required Offset globalPosition,
  }) {
    final dragState = _chapterDragState;
    if (dragState == null) {
      return;
    }
    final renderObject =
        _chapterKey(chapterId).currentContext?.findRenderObject() as RenderBox?;
    if (renderObject == null || !renderObject.hasSize) {
      return;
    }
    final localPosition = renderObject.globalToLocal(globalPosition);
    final chapterIndex = _chapterIndexById(chapterId);
    if (chapterIndex == -1) {
      return;
    }
    final sourceIndex = _chapterIndexById(dragState.sourceChapterId);
    int nextHoverIndex;
    if (sourceIndex < chapterIndex) {
      nextHoverIndex = chapterIndex + 1;
    } else if (sourceIndex > chapterIndex) {
      nextHoverIndex = chapterIndex;
    } else {
      nextHoverIndex = localPosition.dy > renderObject.size.height / 2
          ? chapterIndex + 1
          : chapterIndex;
    }
    if (dragState.hoverIndex == nextHoverIndex) {
      return;
    }
    setState(() {
      _chapterDragState = dragState.copyWith(hoverIndex: nextHoverIndex);
    });
  }

  int? _resolveChapterDropTarget(Offset globalPosition) {
    for (var index = 0; index <= _chapters.length; index++) {
      final gapRenderObject =
          _chapterGapKey(index).currentContext?.findRenderObject()
              as RenderBox?;
      if (gapRenderObject != null && gapRenderObject.hasSize) {
        final gapTopLeft = gapRenderObject.localToGlobal(Offset.zero);
        final gapRect = gapTopLeft & gapRenderObject.size;
        if (gapRect.contains(globalPosition)) {
          return index;
        }
      }

      if (index == _chapters.length) {
        continue;
      }

      final chapterId = _chapters[index].chapterId;
      final renderObject =
          _chapterKey(chapterId).currentContext?.findRenderObject()
              as RenderBox?;
      if (renderObject == null || !renderObject.hasSize) {
        continue;
      }
      final topLeft = renderObject.localToGlobal(Offset.zero);
      final rect = topLeft & renderObject.size;
      if (!rect.contains(globalPosition)) {
        final withinTailLane =
            globalPosition.dx >= rect.left &&
            globalPosition.dx <= rect.right &&
            globalPosition.dy >= rect.bottom &&
            globalPosition.dy <= rect.bottom + _chapterTailGapExtent;
        if (withinTailLane) {
          return index + 1;
        }
        continue;
      }
      final localPosition = renderObject.globalToLocal(globalPosition);
      final sourceIndex = _chapterIndexById(_chapterDragState!.sourceChapterId);
      if (sourceIndex < index) {
        return index + 1;
      }
      if (sourceIndex > index) {
        return index;
      }
      return localPosition.dy > renderObject.size.height / 2
          ? index + 1
          : index;
    }

    return null;
  }

  void _updateChapterHoverFromGlobalPosition(Offset globalPosition) {
    final dragState = _chapterDragState;
    if (dragState == null) {
      return;
    }
    final nextHoverIndex = _resolveChapterDropTarget(globalPosition);
    if (nextHoverIndex == null || dragState.hoverIndex == nextHoverIndex) {
      return;
    }
    setState(() {
      _chapterDragState = dragState.copyWith(hoverIndex: nextHoverIndex);
    });
  }

  Future<void> _handleElementDrop(
    _ElementDragPayload payload,
    String? targetChapterId,
    int targetIndex,
  ) async {
    final locatedElement = _findElement(payload.elementId);
    final element = locatedElement.element;
    if (element == null) {
      return;
    }

    final previousChapters = _chapters
        .map((chapter) => chapter.clone())
        .toList();
    final previousUnassigned = _unassignedElements
        .map((item) => item.clone())
        .toList();

    final sourceChapterId = locatedElement.chapterId;
    final sourceElements = _elementsForChapter(sourceChapterId);
    final sourceIndex = locatedElement.elementIndex;
    final targetElements = _elementsForChapter(targetChapterId);
    var normalizedTargetIndex = targetIndex.clamp(0, targetElements.length);
    if (sourceChapterId == targetChapterId &&
        sourceIndex < normalizedTargetIndex) {
      normalizedTargetIndex -= 1;
    }
    if (sourceChapterId == targetChapterId &&
        normalizedTargetIndex == sourceIndex) {
      return;
    }

    setState(() {
      sourceElements.removeAt(sourceIndex);
      targetElements.insert(normalizedTargetIndex, element);
    });

    try {
      await widget.onMoveElement(
        elementId: payload.elementId,
        targetChapterId: targetChapterId,
        targetIndex: normalizedTargetIndex,
      );
    } catch (_) {
      setState(() {
        _chapters = previousChapters;
        _unassignedElements = previousUnassigned;
      });
      rethrow;
    }
  }

  void _startElementDrag({
    required String elementId,
    required String? sourceChapterId,
  }) {
    final locatedElement = _findElement(elementId);
    if (locatedElement.elementIndex == -1) {
      return;
    }
    _triggerHaptic(targetId: 'element-$elementId', force: true);
    final wasExpanded = _isElementExpanded(elementId);
    setState(() {
      _isFocusMode = true;
      _activeDragKind = _DragKind.element;
      _elementDragState = _ElementDragState(
        sourceElementId: elementId,
        sourceChapterId: sourceChapterId,
        hoverChapterId: sourceChapterId,
        hoverIndex: locatedElement.elementIndex,
        wasExpanded: wasExpanded,
      );
      if (wasExpanded) {
        _expandedElementIds.remove(elementId);
      }
    });
    _elementDragFinalizing = false;
    _ensureAutoScrollRunning();
  }

  void _clearElementDrag() {
    final dragState = _elementDragState;
    if (dragState == null && _activeDragKind != _DragKind.element) {
      return;
    }
    setState(() {
      if (dragState?.wasExpanded ?? false) {
        _expandedElementIds.add(dragState!.sourceElementId);
      }
      _elementDragState = null;
      if (_activeDragKind == _DragKind.element) {
        _activeDragKind = null;
      }
    });
    _elementDragFinalizing = false;
    _releaseDragMotion();
  }

  ({String? chapterId, int index})? _resolveElementDropTarget(
    Offset globalPosition,
  ) {
    final chapterIds = <String?>[
      ..._chapters.map((chapter) => chapter.chapterId),
      null,
    ];

    for (final chapterId in chapterIds) {
      final elements = _elementsForChapter(chapterId);
      for (var index = 0; index <= elements.length; index++) {
        final gapRenderObject =
            _elementGapKey(chapterId, index).currentContext?.findRenderObject()
                as RenderBox?;
        if (gapRenderObject == null || !gapRenderObject.hasSize) {
          continue;
        }
        final gapTopLeft = gapRenderObject.localToGlobal(Offset.zero);
        final gapRect = gapTopLeft & gapRenderObject.size;
        if (gapRect.contains(globalPosition)) {
          return (chapterId: chapterId, index: index);
        }
      }

      for (var index = 0; index < elements.length; index++) {
        final renderObject =
            _elementKey(
                  elements[index].elementId,
                ).currentContext?.findRenderObject()
                as RenderBox?;
        if (renderObject == null || !renderObject.hasSize) {
          continue;
        }
        final topLeft = renderObject.localToGlobal(Offset.zero);
        final rect = topLeft & renderObject.size;
        if (rect.contains(globalPosition)) {
          final localPosition = renderObject.globalToLocal(globalPosition);
          final dropIndex =
              localPosition.dy >
                  renderObject.size.height.clamp(0.0, _elementAfterThresholdCap)
              ? index + 1
              : index;
          return (chapterId: chapterId, index: dropIndex);
        }
      }

      if (elements.isEmpty) {
        continue;
      }
      final lastRenderObject =
          _elementKey(
                elements.last.elementId,
              ).currentContext?.findRenderObject()
              as RenderBox?;
      if (lastRenderObject == null || !lastRenderObject.hasSize) {
        continue;
      }
      final lastTopLeft = lastRenderObject.localToGlobal(Offset.zero);
      final lastRect = lastTopLeft & lastRenderObject.size;
      final withinTailLane =
          globalPosition.dx >= lastRect.left &&
          globalPosition.dx <= lastRect.right &&
          globalPosition.dy >= lastRect.bottom &&
          globalPosition.dy <= lastRect.bottom + _elementTailGapExtent;
      if (withinTailLane) {
        return (chapterId: chapterId, index: elements.length);
      }
    }

    return null;
  }

  Future<void> _finishElementDrag(_ElementDragPayload payload) async {
    if (_elementDragFinalizing) {
      return;
    }
    _elementDragFinalizing = true;
    final latestDragGlobalPosition = _latestDragGlobalPosition;
    _releaseDragMotion();
    final dragState = _elementDragState;
    if (dragState != null) {
      final resolvedTarget = latestDragGlobalPosition == null
          ? null
          : _resolveElementDropTarget(latestDragGlobalPosition);
      final targetChapterId =
          resolvedTarget?.chapterId ?? dragState.hoverChapterId;
      final targetIndex = resolvedTarget?.index ?? dragState.hoverIndex;
      final currentElementIndex = _findElement(payload.elementId).elementIndex;
      final sourceLocationUnchanged =
          dragState.sourceChapterId == targetChapterId &&
          currentElementIndex == targetIndex;
      if (!sourceLocationUnchanged) {
        await _handleElementDrop(payload, targetChapterId, targetIndex);
      }
    }
    if (mounted) {
      _clearElementDrag();
    }
  }

  void _updateElementHover({
    required String elementId,
    required String? targetChapterId,
    required Offset globalPosition,
  }) {
    final dragState = _elementDragState;
    if (dragState == null) {
      return;
    }
    final renderObject =
        _elementKey(elementId).currentContext?.findRenderObject() as RenderBox?;
    if (renderObject == null || !renderObject.hasSize) {
      return;
    }
    final localPosition = renderObject.globalToLocal(globalPosition);
    final targetElements = _elementsForChapter(targetChapterId);
    final itemIndex = targetElements.indexWhere(
      (element) => element.elementId == elementId,
    );
    if (itemIndex == -1) {
      return;
    }
    final nextHoverIndex =
        localPosition.dy >
            renderObject.size.height.clamp(0.0, _elementAfterThresholdCap)
        ? itemIndex + 1
        : itemIndex;
    if (dragState.hoverChapterId == targetChapterId &&
        dragState.hoverIndex == nextHoverIndex) {
      return;
    }
    _elementDragState = dragState.copyWith(
      hoverChapterId: targetChapterId,
      hoverIndex: nextHoverIndex,
    );
  }

  void _updateElementGapHover({
    required String? targetChapterId,
    required int gapIndex,
  }) {
    final dragState = _elementDragState;
    if (dragState == null) {
      return;
    }
    if (dragState.hoverChapterId == targetChapterId &&
        dragState.hoverIndex == gapIndex) {
      return;
    }
    _elementDragState = dragState.copyWith(
      hoverChapterId: targetChapterId,
      hoverIndex: gapIndex,
    );
  }

  void _updateElementHoverFromGlobalPosition(Offset globalPosition) {
    final dragState = _elementDragState;
    if (dragState == null) {
      return;
    }
    final resolvedTarget = _resolveElementDropTarget(globalPosition);
    if (resolvedTarget == null ||
        (dragState.hoverChapterId == resolvedTarget.chapterId &&
            dragState.hoverIndex == resolvedTarget.index)) {
      return;
    }
    _elementDragState = dragState.copyWith(
      hoverChapterId: resolvedTarget.chapterId,
      hoverIndex: resolvedTarget.index,
    );
  }

  ({_ArrangePhotoVm? photo, int photoIndex}) _findPhoto(
    String sourceContainerId,
    int photoIndex,
  ) {
    final photos = _photosForContainer(sourceContainerId);
    if (photos == null || photoIndex < 0 || photoIndex >= photos.length) {
      return (photo: null, photoIndex: -1);
    }
    return (photo: photos[photoIndex], photoIndex: photoIndex);
  }

  Future<void> _handlePhotoDrop(
    _PhotoDragPayload payload,
    String targetElementId,
    int targetPhotoIndex,
  ) async {
    final locatedPhoto = _findPhoto(
      payload.sourceElementId,
      payload.sourcePhotoIndex,
    );
    final photo = locatedPhoto.photo;
    if (photo == null) {
      return;
    }

    final sourcePhotos = _photosForContainer(payload.sourceElementId);
    final targetPhotos = _photosForContainer(targetElementId);
    if (sourcePhotos == null || targetPhotos == null) {
      return;
    }

    final previousChapters = _chapters
        .map((chapter) => chapter.clone())
        .toList();
    final previousUnassigned = _unassignedElements
        .map((item) => item.clone())
        .toList();
    final previousUnassignedPhotos = _unassignedPhotos
        .map((photo) => photo.clone())
        .toList();

    var normalizedTargetIndex = targetPhotoIndex.clamp(0, targetPhotos.length);
    if (payload.sourceElementId == targetElementId &&
        payload.sourcePhotoIndex < normalizedTargetIndex) {
      normalizedTargetIndex -= 1;
    }
    if (payload.sourceElementId == targetElementId &&
        normalizedTargetIndex == payload.sourcePhotoIndex) {
      return;
    }

    setState(() {
      sourcePhotos.removeAt(payload.sourcePhotoIndex);
      targetPhotos.insert(normalizedTargetIndex, photo);
    });

    try {
      await widget.onMovePhoto(
        sourceElementId: payload.sourceElementId,
        sourcePhotoIndex: payload.sourcePhotoIndex,
        targetElementId: targetElementId,
        targetPhotoIndex: normalizedTargetIndex,
      );
    } catch (_) {
      setState(() {
        _chapters = previousChapters;
        _unassignedElements = previousUnassigned;
        _unassignedPhotos = previousUnassignedPhotos;
      });
      rethrow;
    }
  }

  void _startPhotoDrag({
    required String sourceElementId,
    required int sourcePhotoIndex,
  }) {
    _triggerHaptic(
      targetId: 'photo-$sourceElementId-$sourcePhotoIndex',
      force: true,
    );
    setState(() {
      _isFocusMode = true;
      _activeDragKind = _DragKind.photo;
      _photoDragState = _PhotoDragState(
        sourceElementId: sourceElementId,
        sourcePhotoIndex: sourcePhotoIndex,
        hoverElementId: sourceElementId,
        hoverPhotoIndex: sourcePhotoIndex,
      );
    });
    _ensureAutoScrollRunning();
  }

  void _clearPhotoDrag() {
    if (_photoDragState == null && _activeDragKind != _DragKind.photo) {
      return;
    }
    setState(() {
      _photoDragState = null;
      if (_activeDragKind == _DragKind.photo) {
        _activeDragKind = null;
      }
    });
    _releaseDragMotion();
  }

  void _updatePhotoHover({
    required String targetElementId,
    required String photoId,
    required Offset globalPosition,
  }) {
    final dragState = _photoDragState;
    if (dragState == null) {
      return;
    }
    final renderObject =
        _photoKey(photoId).currentContext?.findRenderObject() as RenderBox?;
    if (renderObject == null || !renderObject.hasSize) {
      return;
    }
    final targetPhotos = _photosForContainer(targetElementId);
    if (targetPhotos == null) {
      return;
    }
    final itemIndex = targetPhotos.indexWhere(
      (photo) => photo.photoId == photoId,
    );
    if (itemIndex == -1) {
      return;
    }
    final localPosition = renderObject.globalToLocal(globalPosition);
    final insertAfter =
        localPosition.dy > renderObject.size.height * 0.58 ||
        localPosition.dx > renderObject.size.width * 0.55;
    final nextHoverIndex = insertAfter ? itemIndex + 1 : itemIndex;
    if (dragState.hoverElementId == targetElementId &&
        dragState.hoverPhotoIndex == nextHoverIndex) {
      return;
    }
    if (dragState.hoverElementId != targetElementId) {
      _triggerHaptic(targetId: 'photo-target-$targetElementId');
    }
    _photoDragState = dragState.copyWith(
      hoverElementId: targetElementId,
      hoverPhotoIndex: nextHoverIndex,
    );
  }

  List<({int originalIndex, _ArrangePhotoVm photo})> _projectedPhotosForElement(
    _ArrangeElementVm element,
  ) {
    final dragState = _photoDragState;
    final projected = <({int originalIndex, _ArrangePhotoVm photo})>[];
    for (var index = 0; index < element.photos.length; index++) {
      final isDraggedSource =
          dragState != null &&
          dragState.sourceElementId == element.elementId &&
          dragState.sourcePhotoIndex == index;
      if (isDraggedSource) {
        continue;
      }
      projected.add((originalIndex: index, photo: element.photos[index]));
    }
    return projected;
  }

  int _displayPhotoGapIndexForState(
    _ArrangeElementVm element,
    _PhotoDragState? dragState,
  ) {
    if (dragState == null || dragState.hoverElementId != element.elementId) {
      return -1;
    }
    var displayIndex = dragState.hoverPhotoIndex;
    if (dragState.sourceElementId == element.elementId &&
        dragState.sourcePhotoIndex < displayIndex) {
      displayIndex -= 1;
    }
    return displayIndex.clamp(0, _projectedPhotosForElement(element).length);
  }

  void _openFullScreenViewer({
    required List<_ArrangePhotoVm> photos,
    required int initialIndex,
    required String elementTitle,
    required String chapterLabel,
  }) {
    Navigator.of(context).push(
      PageRouteBuilder<void>(
        opaque: false,
        pageBuilder: (context, animation, secondaryAnimation) {
          return _GlobalArrangeFullScreenViewer(
            photos: photos,
            initialIndex: initialIndex,
            elementTitle: elementTitle,
            chapterLabel: chapterLabel,
            onDeletePhoto: widget.onDeletePhoto,
          );
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCFCFC),
      body: SafeArea(
        child: Listener(
          onPointerMove: (event) {
            if (_activeDragKind != null) {
              _recordDragPosition(event.position);
            }
          },
          child: Stack(
            children: [
              Column(
                children: [
                  _buildTopBar(),
                  Expanded(
                    child: NotificationListener<ScrollNotification>(
                      onNotification: _handleBoardScrollNotification,
                      child: ListView(
                        key: _scrollViewportKey,
                        controller: _scrollController,
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.only(bottom: 140),
                        children: [
                          ..._buildChapterListChildren(),
                          if (_unassignedElements.isNotEmpty ||
                              _unassignedPhotos.isNotEmpty)
                            _buildUnassignedSection(),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              Positioned(
                right: 20,
                bottom: 18,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (_activeTag != null) ...[
                      _buildStickyFilterPill(),
                      const SizedBox(height: 6),
                    ],
                    _PendingOrganizeFab(
                      buttonKey: const ValueKey('globalArrangePendingButton'),
                      onTap: () {
                        widget.onOpenPendingOrganize();
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SizedBox(
        key: const ValueKey('globalArrangeBottomNavShell'),
        height: 80,
        child: OverflowBox(
          minHeight: 80,
          maxHeight: 80,
          alignment: Alignment.topCenter,
          child: CustomBottomNavBar(
            activeTab: PrototypeTab.curation,
            onChangeTab: widget.onBottomTabChanged,
          ),
        ),
      ),
    );
  }

  List<Widget> _buildChapterListChildren() {
    final children = <Widget>[];
    for (var index = 0; index <= _chapters.length; index++) {
      children.add(_buildChapterGap(index));
      if (index == _chapters.length) {
        continue;
      }
      final chapter = _chapters[index];
      children.add(
        _buildChapterDragTarget(chapter: chapter, chapterIndex: index),
      );
      if (_chapterBreathingGap > 0) {
        children.add(
          AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            height: _chapterBreathingGap,
          ),
        );
      }
    }
    return children;
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.menu, color: Colors.black87),
            onPressed: widget.onOpenSidebar,
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Text(
                widget.projectTitle,
                key: const ValueKey('globalArrangePageTitle'),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w300,
                  letterSpacing: 4.0,
                  color: Colors.black87,
                ),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: Colors.black87),
            onPressed: () {
              widget.onOpenSettings?.call();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStickyFilterPill() {
    return _FrostedBoardPill(
      key: const ValueKey('globalArrangeStickyFilterPill'),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Text(
              '透 视 中 : $_activeTag',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 10,
                letterSpacing: 2.0,
                color: Colors.black87,
              ),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            key: const ValueKey('globalArrangeStickyFilterClearButton'),
            onTap: _clearActiveTag,
            child: const Text(
              '×',
              style: TextStyle(fontSize: 16, height: 1, color: Colors.black54),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpotlightDepth({required bool isActive, required Widget child}) {
    final wrapped = ColorFiltered(
      colorFilter: isActive
          ? const ColorFilter.matrix(<double>[
              1,
              0,
              0,
              0,
              0,
              0,
              1,
              0,
              0,
              0,
              0,
              0,
              1,
              0,
              0,
              0,
              0,
              0,
              1,
              0,
            ])
          : const ColorFilter.matrix(<double>[
              0.2126,
              0.7152,
              0.0722,
              0,
              0,
              0.2126,
              0.7152,
              0.0722,
              0,
              0,
              0.2126,
              0.7152,
              0.0722,
              0,
              0,
              0,
              0,
              0,
              1,
              0,
            ]),
      child: child,
    );
    return AnimatedScale(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      scale: isActive ? 1.0 : _spotlightInactiveScale,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 220),
        opacity: isActive ? 1.0 : 0.15,
        child: wrapped,
      ),
    );
  }

  Widget _buildChapterSection(_ArrangeChapterVm chapter, int chapterIndex) {
    final isExpanded = _isChapterExpanded(chapter.chapterId);
    final children = <Widget>[
      _buildSpotlightDepth(
        isActive: _isChapterActive(chapter),
        child: _buildChapterHeader(
          chapter: chapter,
          chapterIndex: chapterIndex,
          isExpanded: isExpanded,
          onTap: () => _toggleChapter(chapter.chapterId),
          isDragging: _chapterDragState?.sourceChapterId == chapter.chapterId,
        ),
      ),
    ];

    if (isExpanded) {
      children.addAll(
        _buildElementListChildren(
          elements: chapter.elements,
          owningChapterId: chapter.chapterId,
          chapterLabel: _chapterShortLabel(chapterIndex),
        ),
      );
    }

    children.add(
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Divider(
          height: 1,
          thickness: 0.5,
          color: Colors.black.withValues(alpha: 0.05),
        ),
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );
  }

  Widget _buildChapterHeader({
    required _ArrangeChapterVm chapter,
    required int chapterIndex,
    required bool isExpanded,
    required VoidCallback? onTap,
    bool isDragging = false,
    bool includeKey = true,
    bool showDragHandle = true,
    InlineSpan? titleOverride,
    Key? keyOverride,
  }) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        key: includeKey
            ? keyOverride ??
                  ValueKey('globalArrangeChapterHeader-${chapter.chapterId}')
            : null,
        width: double.infinity,
        margin: const EdgeInsets.only(top: 12, bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        decoration: BoxDecoration(
          color: isDragging ? Colors.white : Colors.transparent,
          boxShadow: isDragging ? _subtleShadow : null,
        ),
        child: Row(
          children: [
            Icon(
              isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
              color: Colors.black26,
              size: 16,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text.rich(
                titleOverride ??
                    _chapterDisplaySpan(chapterIndex, chapter.title),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: Colors.black45,
                ),
              ),
            ),
            SizedBox(
              width: 18,
              child: showDragHandle
                  ? const Icon(
                      Icons.drag_handle,
                      color: Colors.black26,
                      size: 18,
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChapterDragTarget({
    required _ArrangeChapterVm chapter,
    required int chapterIndex,
  }) {
    return DragTarget<_ChapterDragPayload>(
      onWillAcceptWithDetails: (_) => _chapterDragState != null,
      onMove: (details) {
        _updateChapterHover(
          chapterId: chapter.chapterId,
          globalPosition: details.offset,
        );
      },
      onAcceptWithDetails: (details) async {
        final dragState = _chapterDragState;
        if (dragState == null) {
          return;
        }
        _releaseDragMotion();
        final targetIndex =
            _resolveChapterDropTarget(details.offset) ?? dragState.hoverIndex;
        await _handleChapterDrop(details.data, targetIndex);
      },
      builder: (context, candidateData, rejectedData) {
        return KeyedSubtree(
          key: _chapterKey(chapter.chapterId),
          child: LongPressDraggable<_ChapterDragPayload>(
            data: _ChapterDragPayload(chapterId: chapter.chapterId),
            dragAnchorStrategy: pointerDragAnchorStrategy,
            onDragStarted: () => _startChapterDrag(chapter.chapterId),
            onDragUpdate: (details) {
              _recordDragPosition(details.globalPosition);
              _updateChapterHoverFromGlobalPosition(details.globalPosition);
            },
            onDragCompleted: () {},
            onDraggableCanceled: (velocity, offset) {},
            onDragEnd: (details) async {
              if (details.wasAccepted) {
                _clearChapterDrag();
                return;
              }
              await _finishChapterDrag(
                _ChapterDragPayload(chapterId: chapter.chapterId),
              );
            },
            childWhenDragging: _buildDragPlaceholder(
              key: ValueKey(
                'globalArrangeChapterPlaceholder-${chapter.chapterId}',
              ),
              child: _buildChapterDragPreview(
                chapter: chapter,
                chapterIndex: chapterIndex,
              ),
            ),
            feedback: Material(
              color: Colors.transparent,
              child: _buildDragFeedbackShell(
                width: MediaQuery.sizeOf(context).width,
                maxScale: 1.05,
                child: _buildChapterDragPreview(
                  chapter: chapter,
                  chapterIndex: chapterIndex,
                ),
              ),
            ),
            child: _buildChapterSection(chapter, chapterIndex),
          ),
        );
      },
    );
  }

  Widget _buildChapterGap(int index) {
    final dragState = _chapterDragState;
    final active = dragState != null && dragState.hoverIndex == index;
    final sourceIndex = dragState == null
        ? -1
        : _chapterIndexById(dragState.sourceChapterId);
    final gapHeight = active && index != sourceIndex ? _chapterDragExtent : 0.0;
    return DragTarget<_ChapterDragPayload>(
      onWillAcceptWithDetails: (details) {
        return _chapterDragState != null;
      },
      onMove: (_) {
        final drag = _chapterDragState;
        if (drag == null || drag.hoverIndex == index) {
          return;
        }
        setState(() {
          _chapterDragState = drag.copyWith(hoverIndex: index);
        });
      },
      onAcceptWithDetails: (details) async {
        _releaseDragMotion();
        final targetIndex = _resolveChapterDropTarget(details.offset) ?? index;
        await _handleChapterDrop(details.data, targetIndex);
      },
      builder: (context, candidateData, rejectedData) {
        return KeyedSubtree(
          key: _chapterGapKey(index),
          child: AnimatedContainer(
            duration: _gapAnimationDuration,
            curve: _dragMotionCurve,
            width: double.infinity,
            height: gapHeight,
          ),
        );
      },
    );
  }

  List<Widget> _buildElementListChildren({
    required List<_ArrangeElementVm> elements,
    required String? owningChapterId,
    required String chapterLabel,
  }) {
    final children = <Widget>[];
    for (var index = 0; index <= elements.length; index++) {
      children.add(_buildElementGap(owningChapterId, index));
      if (index == elements.length) {
        continue;
      }
      final element = elements[index];
      children.add(
        _buildElementDragTarget(
          element: element,
          chapterLabel: chapterLabel,
          owningChapterId: owningChapterId,
        ),
      );
    }
    return children;
  }

  Widget _buildUnassignedSection() {
    final chapter = _ArrangeChapterVm(
      chapterId: 'chapter-unassigned',
      title: '未归属章节',
      elements: _unassignedElements,
    );
    final children = <Widget>[
      _buildChapterHeader(
        chapter: chapter,
        chapterIndex: -1,
        isExpanded: _isUnassignedChapterExpanded,
        onTap: _toggleUnassignedChapter,
        showDragHandle: false,
        titleOverride: const TextSpan(
          children: [
            TextSpan(text: 'CH', style: TextStyle(letterSpacing: 1.4)),
            TextSpan(text: ' 未归属章节', style: TextStyle(letterSpacing: 1.2)),
          ],
        ),
        keyOverride: const ValueKey('globalArrangeChapterHeader-unassigned'),
      ),
    ];

    if (_isUnassignedChapterExpanded) {
      children.addAll(
        _buildElementListChildren(
          elements: _unassignedElements,
          owningChapterId: null,
          chapterLabel: 'UNASSIGNED',
        ),
      );
      children.add(_buildUnassignedPhotoPool());
    }

    children.add(
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Divider(
          height: 1,
          thickness: 0.5,
          color: Colors.black.withValues(alpha: 0.05),
        ),
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );
  }

  Widget _buildUnassignedPhotoPool() {
    final photoBucket = _unassignedPhotoBucket();
    final shouldShow =
        photoBucket.photos.isNotEmpty ||
        (_photoDragState?.hoverElementId == globalArrangeLoosePhotoBucketId);
    if (!shouldShow) {
      return const SizedBox.shrink();
    }

    return Padding(
      key: _unassignedPhotoPoolKey,
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 48, right: 24, bottom: 12),
            child: Text(
              '未 关 联 照 片',
              key: const ValueKey('globalArrangeLoosePhotoPoolHeader'),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                letterSpacing: 3.0,
                color: Colors.black38,
              ),
            ),
          ),
          _buildPhotoCollection(
            element: photoBucket,
            chapterLabel: 'UNASSIGNED',
            elementTitleOverride: '未关联照片',
          ),
        ],
      ),
    );
  }

  Widget _buildElementBlock({
    required _ArrangeElementVm element,
    required String chapterLabel,
    required String? owningChapterId,
  }) {
    final isExpanded = _isElementExpanded(element.elementId);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      margin: EdgeInsets.only(bottom: isExpanded ? 24.0 : 8.0),
      decoration: const BoxDecoration(color: Colors.transparent),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSpotlightDepth(
            isActive: _isElementActive(element),
            child: _buildElementHeader(
              element: element,
              isExpanded: isExpanded,
              onTap: () => _toggleElement(element.elementId),
              isDragging:
                  _elementDragState?.sourceElementId == element.elementId,
            ),
          ),
          if (isExpanded && element.relationTags.isNotEmpty)
            _buildSpotlightDepth(
              isActive: _isElementActive(element),
              child: Padding(
                padding: const EdgeInsets.only(left: 48, bottom: 12),
                child: Row(
                  children: [
                    const Text(
                      '└─ ',
                      style: TextStyle(color: Colors.black12, fontSize: 12),
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        child: Row(
                          children: element.relationTags
                              .map(
                                (tag) => _buildGlassTag(
                                  tag: tag,
                                  source: _ActiveTagSource.element,
                                ),
                              )
                              .toList(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 24),
                  ],
                ),
              ),
            ),
          if (isExpanded)
            _buildPhotoCollection(element: element, chapterLabel: chapterLabel),
        ],
      ),
    );
  }

  Widget _buildPhotoCollection({
    required _ArrangeElementVm element,
    required String chapterLabel,
    String? elementTitleOverride,
  }) {
    final shouldShow =
        element.photos.isNotEmpty ||
        (_photoDragState?.hoverElementId == element.elementId);
    if (!shouldShow) {
      return const SizedBox.shrink();
    }

    return ValueListenableBuilder<_PhotoDragState?>(
      valueListenable: _photoDragStateListenable,
      builder: (context, dragState, child) {
        return LayoutBuilder(
          builder: (context, constraints) {
            const horizontalPadding = 24.0;
            const spacing = 16.0;
            final availableWidth =
                constraints.maxWidth - horizontalPadding * 2 - spacing;
            final itemWidth = availableWidth > 0 ? availableWidth / 2 : 0.0;
            final photoHeight = itemWidth > 0 ? itemWidth + 32.0 : 152.0;
            final photoChildren = <Widget>[];
            final projectedPhotos = _projectedPhotosForElement(element);
            final hoverPhotoIndex = _displayPhotoGapIndexForState(
              element,
              dragState,
            );
            final sourcePlaceholderIndex =
                dragState != null &&
                    dragState.sourceElementId == element.elementId
                ? dragState.sourcePhotoIndex.clamp(0, projectedPhotos.length)
                : -1;
            final sourcePlaceholderPhoto =
                sourcePlaceholderIndex == -1 ||
                    dragState == null ||
                    dragState.sourcePhotoIndex >= element.photos.length
                ? null
                : element.photos[dragState.sourcePhotoIndex];
            final actualTargetPhotoIndex =
                dragState?.hoverElementId == element.elementId
                ? dragState!.hoverPhotoIndex
                : 0;
            for (var index = 0; index < projectedPhotos.length; index++) {
              if (sourcePlaceholderIndex == index &&
                  sourcePlaceholderPhoto != null) {
                photoChildren.add(
                  _buildPhotoSourcePlaceholder(
                    photo: sourcePlaceholderPhoto,
                    parentElement: element,
                    itemWidth: itemWidth,
                  ),
                );
              }
              if (hoverPhotoIndex == index) {
                photoChildren.add(
                  _buildPhotoGap(
                    targetElementId: element.elementId,
                    targetPhotoIndex: actualTargetPhotoIndex,
                    itemWidth: itemWidth == 0 ? 120.0 : itemWidth,
                    photoHeight: photoHeight,
                  ),
                );
              }
              final photoEntry = projectedPhotos[index];
              final photo = photoEntry.photo;
              photoChildren.add(
                _buildSpotlightDepth(
                  isActive: _isPhotoActive(element, photo),
                  child: SizedBox(
                    width: itemWidth == 0 ? 120.0 : itemWidth,
                    child: _buildPhotoDragTarget(
                      parentElement: element,
                      photo: photo,
                      photoIndex: photoEntry.originalIndex,
                      chapterLabel: chapterLabel,
                      elementTitleOverride: elementTitleOverride,
                      itemWidth: itemWidth == 0 ? 120.0 : itemWidth,
                    ),
                  ),
                ),
              );
            }
            if (sourcePlaceholderIndex == projectedPhotos.length &&
                sourcePlaceholderPhoto != null) {
              photoChildren.add(
                _buildPhotoSourcePlaceholder(
                  photo: sourcePlaceholderPhoto,
                  parentElement: element,
                  itemWidth: itemWidth == 0 ? 120.0 : itemWidth,
                ),
              );
            }
            if (hoverPhotoIndex == projectedPhotos.length ||
                photoChildren.isEmpty) {
              photoChildren.add(
                _buildPhotoGap(
                  targetElementId: element.elementId,
                  targetPhotoIndex: actualTargetPhotoIndex,
                  itemWidth: itemWidth == 0 ? 120.0 : itemWidth,
                  photoHeight: photoHeight,
                ),
              );
            }

            final isHoveredDropTarget =
                dragState != null &&
                dragState.hoverElementId == element.elementId &&
                dragState.sourceElementId != element.elementId;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              margin: const EdgeInsets.symmetric(horizontal: 18),
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
              decoration: BoxDecoration(
                color: isHoveredDropTarget
                    ? Colors.white.withValues(alpha: 0.62)
                    : Colors.transparent,
                border: isHoveredDropTarget
                    ? Border.all(color: Colors.black.withValues(alpha: 0.08))
                    : null,
                boxShadow: isHoveredDropTarget
                    ? [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 14,
                          offset: const Offset(0, 6),
                        ),
                      ]
                    : null,
              ),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: photoChildren.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: spacing,
                  mainAxisSpacing: 16,
                  childAspectRatio:
                      (itemWidth == 0 ? 120.0 : itemWidth) / photoHeight,
                ),
                itemBuilder: (context, index) {
                  return photoChildren[index];
                },
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildElementHeader({
    required _ArrangeElementVm element,
    required bool isExpanded,
    required VoidCallback? onTap,
    bool isDragging = false,
    bool includeKey = true,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        key: includeKey
            ? ValueKey('globalArrangeElementHeader-${element.elementId}')
            : null,
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        decoration: BoxDecoration(
          color: isDragging ? Colors.white : Colors.transparent,
          boxShadow: isDragging ? _subtleShadow : null,
        ),
        child: Row(
          children: [
            Icon(
              isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
              color: Colors.black26,
              size: 16,
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black12, width: 0.5),
              ),
              child: const Text(
                '元 素',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 8,
                  letterSpacing: 2.0,
                  color: Colors.black45,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                element.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ),
            const SizedBox(
              width: 18,
              child: Align(
                alignment: Alignment.centerRight,
                child: Icon(Icons.drag_handle, color: Colors.black12, size: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildElementDragTarget({
    required _ArrangeElementVm element,
    required String chapterLabel,
    required String? owningChapterId,
  }) {
    return DragTarget<_ElementDragPayload>(
      onWillAcceptWithDetails: (_) => _elementDragState != null,
      onMove: (details) {
        _updateElementHover(
          elementId: element.elementId,
          targetChapterId: owningChapterId,
          globalPosition: details.offset,
        );
      },
      onAcceptWithDetails: (details) async {
        final dragState = _elementDragState;
        if (dragState == null) {
          return;
        }
        _releaseDragMotion();
        await _handleElementDrop(
          details.data,
          dragState.hoverChapterId,
          dragState.hoverIndex,
        );
      },
      builder: (context, candidateData, rejectedData) {
        return KeyedSubtree(
          key: _elementKey(element.elementId),
          child: LongPressDraggable<_ElementDragPayload>(
            data: _ElementDragPayload(
              elementId: element.elementId,
              sourceChapterId: owningChapterId,
            ),
            dragAnchorStrategy: pointerDragAnchorStrategy,
            onDragStarted: () => _startElementDrag(
              elementId: element.elementId,
              sourceChapterId: owningChapterId,
            ),
            onDragUpdate: (details) {
              _recordDragPosition(details.globalPosition);
              _updateElementHoverFromGlobalPosition(details.globalPosition);
            },
            onDragCompleted: () {
              unawaited(
                _finishElementDrag(
                  _ElementDragPayload(
                    elementId: element.elementId,
                    sourceChapterId: owningChapterId,
                  ),
                ),
              );
            },
            onDraggableCanceled: (velocity, offset) {
              unawaited(
                _finishElementDrag(
                  _ElementDragPayload(
                    elementId: element.elementId,
                    sourceChapterId: owningChapterId,
                  ),
                ),
              );
            },
            onDragEnd: (_) {
              unawaited(
                _finishElementDrag(
                  _ElementDragPayload(
                    elementId: element.elementId,
                    sourceChapterId: owningChapterId,
                  ),
                ),
              );
            },
            childWhenDragging: _buildDragPlaceholder(
              key: ValueKey(
                'globalArrangeElementPlaceholder-${element.elementId}',
              ),
              child: _buildElementDragPreview(element: element),
            ),
            feedback: Material(
              color: Colors.transparent,
              child: _buildDragFeedbackShell(
                width: MediaQuery.sizeOf(context).width,
                maxScale: 1.06,
                child: _buildElementDragPreview(element: element),
              ),
            ),
            child: _buildElementBlock(
              element: element,
              chapterLabel: chapterLabel,
              owningChapterId: owningChapterId,
            ),
          ),
        );
      },
    );
  }

  Widget _buildElementGap(String? owningChapterId, int index) {
    final targetLength = _elementsForChapter(owningChapterId).length;
    return DragTarget<_ElementDragPayload>(
      onWillAcceptWithDetails: (_) => _elementDragState != null,
      onMove: (_) => _updateElementGapHover(
        targetChapterId: owningChapterId,
        gapIndex: index,
      ),
      onAcceptWithDetails: (details) async {
        _releaseDragMotion();
        await _handleElementDrop(details.data, owningChapterId, index);
      },
      builder: (context, candidateData, rejectedData) {
        return KeyedSubtree(
          key: _elementGapKey(owningChapterId, index),
          child: ValueListenableBuilder<_ElementDragState?>(
            valueListenable: _elementDragStateListenable,
            builder: (context, dragState, child) {
              final active =
                  dragState != null &&
                  dragState.hoverChapterId == owningChapterId &&
                  dragState.hoverIndex == index;
              final sourceIndex = dragState == null
                  ? -1
                  : _findElement(dragState.sourceElementId).elementIndex;
              final visibleHeight =
                  active &&
                      !(dragState.sourceChapterId == owningChapterId &&
                          sourceIndex == index)
                  ? _elementDragExtent
                  : 0.0;
              final inactiveGapHeight = index == targetLength
                  ? _elementTailGapExtent
                  : _elementInactiveGapExtent;
              final interactiveHeight = dragState == null
                  ? visibleHeight
                  : visibleHeight > 0
                  ? visibleHeight
                  : inactiveGapHeight;
              return Container(
                key: ValueKey(
                  'globalArrangeElementGap-${owningChapterId ?? 'unassigned'}-$index',
                ),
                width: double.infinity,
                height: interactiveHeight,
                color: Colors.transparent,
                alignment: Alignment.topCenter,
                child: AnimatedContainer(
                  duration: _gapAnimationDuration,
                  curve: _dragMotionCurve,
                  width: double.infinity,
                  height: visibleHeight,
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildPhotoDragTarget({
    required _ArrangeElementVm parentElement,
    required _ArrangePhotoVm photo,
    required int photoIndex,
    required String chapterLabel,
    required double itemWidth,
    String? elementTitleOverride,
  }) {
    return DragTarget<_PhotoDragPayload>(
      onWillAcceptWithDetails: (details) {
        return details.data.sourceElementId != parentElement.elementId ||
            details.data.sourcePhotoIndex != photoIndex;
      },
      onMove: (details) {
        _updatePhotoHover(
          targetElementId: parentElement.elementId,
          photoId: photo.photoId,
          globalPosition: details.offset,
        );
      },
      onAcceptWithDetails: (details) async {
        final dragState = _photoDragState;
        if (dragState == null) {
          return;
        }
        await _handlePhotoDrop(
          details.data,
          dragState.hoverElementId,
          dragState.hoverPhotoIndex,
        );
      },
      builder: (context, candidateData, rejectedData) {
        return KeyedSubtree(
          key: _photoKey(photo.photoId),
          child: LongPressDraggable<_PhotoDragPayload>(
            data: _PhotoDragPayload(
              sourceElementId: parentElement.elementId,
              sourcePhotoIndex: photoIndex,
            ),
            dragAnchorStrategy: pointerDragAnchorStrategy,
            onDragStarted: () => _startPhotoDrag(
              sourceElementId: parentElement.elementId,
              sourcePhotoIndex: photoIndex,
            ),
            onDragUpdate: (details) =>
                _recordDragPosition(details.globalPosition),
            onDragCompleted: _clearPhotoDrag,
            onDraggableCanceled: (velocity, offset) => _clearPhotoDrag(),
            onDragEnd: (_) => _clearPhotoDrag(),
            feedback: Material(
              color: Colors.transparent,
              child: _buildDragFeedbackShell(
                width: itemWidth,
                maxScale: 1.08,
                child: _buildPhotoCardFrame(
                  photo: photo,
                  parentElement: parentElement,
                  onOpenViewer: null,
                  includeKeys: false,
                  isDragging: true,
                ),
              ),
            ),
            child: _buildPhotoCardFrame(
              photo: photo,
              parentElement: parentElement,
              onOpenViewer: () => _openFullScreenViewer(
                photos: parentElement.photos,
                initialIndex: photoIndex,
                elementTitle: elementTitleOverride ?? parentElement.title,
                chapterLabel: chapterLabel,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPhotoCardFrame({
    required _ArrangePhotoVm photo,
    required _ArrangeElementVm parentElement,
    required VoidCallback? onOpenViewer,
    bool includeKeys = true,
    bool isDragging = false,
  }) {
    return Container(
      key: includeKeys
          ? ValueKey('globalArrangePhotoCard-${photo.photoId}')
          : null,
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: isDragging ? _dragLiftShadow : _subtleShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AspectRatio(
            aspectRatio: 1,
            child: GestureDetector(
              key: includeKeys
                  ? ValueKey('globalArrangePhotoOpenArea-${photo.photoId}')
                  : null,
              behavior: HitTestBehavior.opaque,
              onTap: onOpenViewer,
              child: Container(
                color: const Color(0xFFF0F0F0),
                child: Image(
                  image: narrativeThumbnailProvider(photo.imageSource),
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const Center(
                      child: Icon(
                        Icons.broken_image_outlined,
                        color: Colors.black26,
                        size: 28,
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
          Padding(
            key: includeKeys
                ? ValueKey('globalArrangePhotoSafeArea-${photo.photoId}')
                : null,
            padding: const EdgeInsets.only(top: 2),
            child: Row(
              children: [
                Expanded(
                  child: photo.relationTags.isEmpty
                      ? const SizedBox(height: 12)
                      : SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          child: Row(
                            children: photo.relationTags
                                .map(
                                  (tag) => _buildGlassTag(
                                    tag: tag,
                                    source: _ActiveTagSource.photo,
                                  ),
                                )
                                .toList(),
                          ),
                        ),
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.drag_indicator,
                  color: Colors.black12,
                  size: 14,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoSourcePlaceholder({
    required _ArrangePhotoVm photo,
    required _ArrangeElementVm parentElement,
    required double itemWidth,
  }) {
    return SizedBox(
      width: itemWidth,
      child: _buildDragPlaceholder(
        key: ValueKey('globalArrangePhotoPlaceholder-${photo.photoId}'),
        child: _buildPhotoCardFrame(
          photo: photo,
          parentElement: parentElement,
          onOpenViewer: null,
          includeKeys: false,
        ),
      ),
    );
  }

  Widget _buildGlassTag({
    required String tag,
    required _ActiveTagSource source,
  }) {
    final isActive = _activeTag == tag;
    return GestureDetector(
      onTap: () => _toggleTag(tag, source),
      child: Container(
        width: 64,
        margin: const EdgeInsets.only(right: 8, top: 1),
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.065),
              blurRadius: 4.5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
              decoration: BoxDecoration(
                color: isActive
                    ? Colors.black87
                    : Colors.white.withValues(alpha: 0.75),
              ),
              child: Text(
                tag,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 8,
                  fontWeight: isActive ? FontWeight.w500 : FontWeight.w400,
                  letterSpacing: 1.5,
                  color: isActive ? Colors.white : Colors.black87,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPhotoGap({
    required String targetElementId,
    required int targetPhotoIndex,
    required double itemWidth,
    required double photoHeight,
  }) {
    final dragState = _photoDragState;
    final active =
        dragState != null &&
        dragState.hoverElementId == targetElementId &&
        dragState.hoverPhotoIndex == targetPhotoIndex;
    return DragTarget<_PhotoDragPayload>(
      onWillAcceptWithDetails: (_) => _photoDragState != null,
      onAcceptWithDetails: (details) async {
        await _handlePhotoDrop(details.data, targetElementId, targetPhotoIndex);
      },
      builder: (context, candidateData, rejectedData) {
        final showGap =
            active &&
            !(dragState.sourceElementId == targetElementId &&
                dragState.sourcePhotoIndex == targetPhotoIndex);
        return AnimatedContainer(
          duration: _gapAnimationDuration,
          curve: _dragMotionCurve,
          key: ValueKey(
            'globalArrangePhotoGap-$targetElementId-$targetPhotoIndex',
          ),
          width: showGap ? itemWidth : 0.0,
          height: showGap ? photoHeight : 0.0,
        );
      },
    );
  }
}

class _ArrangeChapterVm {
  _ArrangeChapterVm({
    required this.chapterId,
    required this.title,
    required this.elements,
  });

  factory _ArrangeChapterVm.fromData(GlobalArrangeChapterData data) {
    return _ArrangeChapterVm(
      chapterId: data.chapterId,
      title: data.title,
      elements: data.elements.map(_ArrangeElementVm.fromData).toList(),
    );
  }

  final String chapterId;
  final String title;
  final List<_ArrangeElementVm> elements;

  _ArrangeChapterVm clone() {
    return _ArrangeChapterVm(
      chapterId: chapterId,
      title: title,
      elements: elements.map((element) => element.clone()).toList(),
    );
  }
}

class _ArrangeElementVm {
  _ArrangeElementVm({
    required this.elementId,
    required this.title,
    required this.relationTags,
    required this.photos,
  });

  factory _ArrangeElementVm.fromData(GlobalArrangeElementData data) {
    return _ArrangeElementVm(
      elementId: data.elementId,
      title: data.title,
      relationTags: List<String>.from(data.relationTags),
      photos: data.photos.map(_ArrangePhotoVm.fromData).toList(),
    );
  }

  final String elementId;
  final String title;
  final List<String> relationTags;
  final List<_ArrangePhotoVm> photos;

  _ArrangeElementVm clone() {
    return _ArrangeElementVm(
      elementId: elementId,
      title: title,
      relationTags: List<String>.from(relationTags),
      photos: photos.map((photo) => photo.clone()).toList(),
    );
  }
}

class _ArrangePhotoVm {
  _ArrangePhotoVm({
    required this.photoId,
    required this.imageSource,
    required this.relationTags,
    this.sourceRecordId,
  });

  factory _ArrangePhotoVm.fromData(GlobalArrangePhotoData data) {
    return _ArrangePhotoVm(
      photoId: data.photoId,
      imageSource: data.imageSource,
      relationTags: List<String>.from(data.relationTags),
      sourceRecordId: data.sourceRecordId,
    );
  }

  final String photoId;
  final String imageSource;
  final List<String> relationTags;
  final String? sourceRecordId;

  _ArrangePhotoVm clone() {
    return _ArrangePhotoVm(
      photoId: photoId,
      imageSource: imageSource,
      relationTags: List<String>.from(relationTags),
      sourceRecordId: sourceRecordId,
    );
  }
}

class _PhotoLandingTarget {
  const _PhotoLandingTarget({
    required this.photoId,
    this.chapterId,
    this.elementId,
  });

  final String photoId;
  final String? chapterId;
  final String? elementId;
}

class _ChapterDragPayload {
  const _ChapterDragPayload({required this.chapterId});

  final String chapterId;
}

class _ElementDragPayload {
  const _ElementDragPayload({
    required this.elementId,
    required this.sourceChapterId,
  });

  final String elementId;
  final String? sourceChapterId;
}

class _PhotoDragPayload {
  const _PhotoDragPayload({
    required this.sourceElementId,
    required this.sourcePhotoIndex,
  });

  final String sourceElementId;
  final int sourcePhotoIndex;
}

class _ChapterDragState {
  const _ChapterDragState({
    required this.sourceChapterId,
    required this.hoverIndex,
    required this.wasExpanded,
  });

  final String sourceChapterId;
  final int hoverIndex;
  final bool wasExpanded;

  _ChapterDragState copyWith({int? hoverIndex}) {
    return _ChapterDragState(
      sourceChapterId: sourceChapterId,
      hoverIndex: hoverIndex ?? this.hoverIndex,
      wasExpanded: wasExpanded,
    );
  }
}

class _ElementDragState {
  const _ElementDragState({
    required this.sourceElementId,
    required this.sourceChapterId,
    required this.hoverChapterId,
    required this.hoverIndex,
    required this.wasExpanded,
  });

  final String sourceElementId;
  final String? sourceChapterId;
  final String? hoverChapterId;
  final int hoverIndex;
  final bool wasExpanded;

  _ElementDragState copyWith({
    Object? hoverChapterId = _retainHoverChapterId,
    int? hoverIndex,
  }) {
    return _ElementDragState(
      sourceElementId: sourceElementId,
      sourceChapterId: sourceChapterId,
      hoverChapterId: hoverChapterId == _retainHoverChapterId
          ? this.hoverChapterId
          : hoverChapterId as String?,
      hoverIndex: hoverIndex ?? this.hoverIndex,
      wasExpanded: wasExpanded,
    );
  }
}

class _PhotoDragState {
  const _PhotoDragState({
    required this.sourceElementId,
    required this.sourcePhotoIndex,
    required this.hoverElementId,
    required this.hoverPhotoIndex,
  });

  final String sourceElementId;
  final int sourcePhotoIndex;
  final String hoverElementId;
  final int hoverPhotoIndex;

  _PhotoDragState copyWith({String? hoverElementId, int? hoverPhotoIndex}) {
    return _PhotoDragState(
      sourceElementId: sourceElementId,
      sourcePhotoIndex: sourcePhotoIndex,
      hoverElementId: hoverElementId ?? this.hoverElementId,
      hoverPhotoIndex: hoverPhotoIndex ?? this.hoverPhotoIndex,
    );
  }
}

class _GlobalArrangeFullScreenViewer extends StatefulWidget {
  const _GlobalArrangeFullScreenViewer({
    required this.photos,
    required this.initialIndex,
    required this.elementTitle,
    required this.chapterLabel,
    this.onDeletePhoto,
  });

  final List<_ArrangePhotoVm> photos;
  final int initialIndex;
  final String elementTitle;
  final String chapterLabel;
  final Future<bool> Function(String photoPath)? onDeletePhoto;

  @override
  State<_GlobalArrangeFullScreenViewer> createState() =>
      _GlobalArrangeFullScreenViewerState();
}

class _GlobalArrangeFullScreenViewerState
    extends State<_GlobalArrangeFullScreenViewer> {
  static const Duration _dismissSpringDuration = Duration(milliseconds: 240);

  late final PageController _pageController;
  late final TransformationController _transformationController;
  late int _currentIndex;
  bool _showUI = true;
  bool _isDismissingBack = false;
  bool _isDeleting = false;
  Offset _dismissOffset = Offset.zero;
  double _viewerScale = 1.0;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
    _transformationController = TransformationController()
      ..addListener(_handleTransformationChanged);
  }

  @override
  void dispose() {
    _transformationController.removeListener(_handleTransformationChanged);
    _transformationController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _handleTransformationChanged() {
    _viewerScale = _transformationController.value.getMaxScaleOnAxis();
  }

  void _toggleUI() {
    if (_dismissOffset != Offset.zero) {
      return;
    }
    setState(() {
      _showUI = !_showUI;
    });
  }

  bool get _canDismissByDrag => _viewerScale <= 1.02;

  void _handleVerticalDismissUpdate(DragUpdateDetails details) {
    if (!_canDismissByDrag || details.primaryDelta == null) {
      return;
    }
    final nextDy = (_dismissOffset.dy + details.primaryDelta!).clamp(
      0.0,
      360.0,
    );
    if (nextDy == _dismissOffset.dy) {
      return;
    }
    setState(() {
      _showUI = false;
      _isDismissingBack = false;
      _dismissOffset = Offset(0, nextDy);
    });
  }

  void _handleVerticalDismissEnd(DragEndDetails details) {
    if (_dismissOffset == Offset.zero) {
      return;
    }
    final shouldDismiss =
        _dismissOffset.dy > 132 || (details.primaryVelocity ?? 0) > 850;
    if (shouldDismiss) {
      Navigator.of(context).pop();
      return;
    }
    setState(() {
      _isDismissingBack = true;
      _dismissOffset = Offset.zero;
      _showUI = true;
    });
  }

  void _resetVerticalDismiss() {
    if (_dismissOffset == Offset.zero) {
      return;
    }
    setState(() {
      _isDismissingBack = true;
      _dismissOffset = Offset.zero;
      _showUI = true;
    });
  }

  Future<void> _deleteCurrentPhoto() async {
    final onDeletePhoto = widget.onDeletePhoto;
    if (onDeletePhoto == null ||
        _isDeleting ||
        _currentIndex < 0 ||
        _currentIndex >= widget.photos.length) {
      return;
    }
    setState(() {
      _isDeleting = true;
    });
    final deleted = await onDeletePhoto(
      widget.photos[_currentIndex].imageSource,
    );
    if (!mounted) {
      return;
    }
    if (deleted) {
      Navigator.of(context).pop();
      return;
    }
    setState(() {
      _isDeleting = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final dismissAnimationDuration = _isDismissingBack
        ? _dismissSpringDuration
        : Duration.zero;
    final dismissScale = 1.0 - (_dismissOffset.dy / 1200.0).clamp(0.0, 0.18);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: GestureDetector(
        onTap: _toggleUI,
        onVerticalDragUpdate: _handleVerticalDismissUpdate,
        onVerticalDragEnd: _handleVerticalDismissEnd,
        onVerticalDragCancel: _resetVerticalDismiss,
        child: Stack(
          children: [
            Positioned.fill(
              child: AnimatedContainer(
                duration: dismissAnimationDuration,
                curve: Curves.easeOutCubic,
                color: Colors.black.withValues(
                  alpha: 1.0 - (_dismissOffset.dy / 420.0).clamp(0.0, 0.58),
                ),
              ),
            ),
            AnimatedContainer(
              duration: dismissAnimationDuration,
              curve: Curves.easeOutCubic,
              transform: Matrix4.identity()
                ..translateByDouble(0.0, _dismissOffset.dy, 0.0, 1.0)
                ..scaleByDouble(dismissScale, dismissScale, 1.0, 1.0),
              transformAlignment: Alignment.center,
              onEnd: () {
                if (!mounted || !_isDismissingBack) {
                  return;
                }
                setState(() {
                  _isDismissingBack = false;
                });
              },
              child: PageView.builder(
                controller: _pageController,
                physics: const BouncingScrollPhysics(),
                itemCount: widget.photos.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentIndex = index;
                    _isDismissingBack = false;
                    _dismissOffset = Offset.zero;
                    _viewerScale = 1.0;
                  });
                  _transformationController.value = Matrix4.identity();
                },
                itemBuilder: (context, index) {
                  final photo = widget.photos[index];
                  return InteractiveViewer(
                    transformationController: index == _currentIndex
                        ? _transformationController
                        : null,
                    minScale: 1,
                    maxScale: 4,
                    child: Center(
                      child: Image(
                        image: narrativeThumbnailProvider(photo.imageSource),
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return _buildPlaceholder(
                            icon: Icons.broken_image_outlined,
                            label: 'IMAGE UNAVAILABLE',
                          );
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
            AnimatedOpacity(
              duration: const Duration(milliseconds: 200),
              opacity: _showUI ? 1 : 0,
              child: IgnorePointer(
                ignoring: !_showUI,
                child: Container(
                  padding: EdgeInsets.only(
                    top: MediaQuery.of(context).padding.top + 16,
                    left: 16,
                    right: 16,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.6),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 24,
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      const Spacer(),
                      Expanded(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          reverse: true,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: widget.photos[_currentIndex].relationTags
                                .map(
                                  (tag) => Container(
                                    width: 64,
                                    margin: const EdgeInsets.only(
                                      left: 8,
                                      bottom: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withValues(
                                            alpha: 0.3,
                                          ),
                                          blurRadius: 6,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: ClipRect(
                                      child: BackdropFilter(
                                        filter: ImageFilter.blur(
                                          sigmaX: 10,
                                          sigmaY: 10,
                                        ),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 4,
                                            vertical: 4,
                                          ),
                                          color: Colors.white.withValues(
                                            alpha: 0.15,
                                          ),
                                          child: Text(
                                            tag,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            textAlign: TextAlign.center,
                                            style: const TextStyle(
                                              fontSize: 8,
                                              color: Colors.white70,
                                              letterSpacing: 1.5,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            AnimatedOpacity(
              duration: const Duration(milliseconds: 200),
              opacity: _showUI ? 1 : 0,
              child: IgnorePointer(
                ignoring: !_showUI,
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.fromLTRB(
                      24,
                      40,
                      24,
                      MediaQuery.of(context).padding.bottom + 24,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.8),
                          Colors.transparent,
                        ],
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Colors.white38,
                                  width: 0.5,
                                ),
                              ),
                              child: Text(
                                widget.chapterLabel,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: Colors.white,
                                  letterSpacing: 1,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                widget.elementTitle,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                  letterSpacing: 1,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Center(
                          child: Text(
                            '${_currentIndex + 1} / ${widget.photos.length}',
                            style: TextStyle(
                              fontSize: 12,
                              letterSpacing: 2,
                              color: Colors.white.withValues(alpha: 0.6),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            if (widget.onDeletePhoto != null)
              Positioned(
                right: 18,
                bottom: MediaQuery.of(context).padding.bottom + 18,
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 200),
                  opacity: _showUI ? 1 : 0,
                  child: IgnorePointer(
                    ignoring: !_showUI,
                    child: GestureDetector(
                      key: const ValueKey('globalArrangePhotoDeleteButton'),
                      behavior: HitTestBehavior.opaque,
                      onTap: _deleteCurrentPhoto,
                      child: ClipRect(
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: Container(
                            width: 38,
                            height: 38,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.28),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.16),
                                width: 0.6,
                              ),
                            ),
                            child: _isDeleting
                                ? SizedBox(
                                    width: 13,
                                    height: 13,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 1.3,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white.withValues(alpha: 0.78),
                                      ),
                                    ),
                                  )
                                : Icon(
                                    Icons.delete_outline,
                                    size: 17,
                                    color: Colors.white.withValues(alpha: 0.78),
                                  ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder({required IconData icon, required String label}) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        border: Border.all(color: Colors.white24, width: 1),
      ),
      child: AspectRatio(
        aspectRatio: 3 / 4,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white24, size: 48),
              const SizedBox(height: 24),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 10,
                  color: Colors.white38,
                  letterSpacing: 3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PendingOrganizeFab extends StatelessWidget {
  const _PendingOrganizeFab({required this.buttonKey, required this.onTap});

  final Key buttonKey;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: _FrostedBoardPill(
        key: buttonKey,
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.inbox_outlined, color: Colors.black87, size: 13),
            SizedBox(width: 8),
            Text(
              '待 整 理',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.black87,
                fontSize: 10,
                fontWeight: FontWeight.w400,
                letterSpacing: 2.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FrostedBoardPill extends StatelessWidget {
  const _FrostedBoardPill({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.74),
        border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.065),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.025),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: child,
          ),
        ),
      ),
    );
  }
}
