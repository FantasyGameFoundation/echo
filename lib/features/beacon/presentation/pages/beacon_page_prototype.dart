import 'dart:ui';

import 'package:echo/features/beacon/domain/entities/beacon_task.dart';
import 'package:echo/shared/models/prototype_tab.dart';
import 'package:echo/shared/widgets/custom_bottom_nav_bar.dart';
import 'package:echo/shared/widgets/restrained_action_button.dart';
import 'package:echo/features/structure_elements_relations/domain/entities/narrative_element.dart';
import 'package:flutter/material.dart';

class BeaconPagePrototype extends StatefulWidget {
  const BeaconPagePrototype({
    super.key,
    this.projectTitle = '',
    required this.tasks,
    required this.elements,
    required this.chapterTitleById,
    required this.onOpenSidebar,
    required this.onBottomTabChanged,
    this.onOpenSettings,
    required this.onCreateTask,
    required this.onOpenTask,
  });

  final String projectTitle;
  final List<BeaconTask> tasks;
  final List<NarrativeElement> elements;
  final Map<String, String> chapterTitleById;
  final VoidCallback onOpenSidebar;
  final ValueChanged<PrototypeTab> onBottomTabChanged;
  final Future<void> Function()? onOpenSettings;
  final Future<void> Function() onCreateTask;
  final Future<void> Function(BeaconTask task) onOpenTask;

  @override
  State<BeaconPagePrototype> createState() => _BeaconPagePrototypeState();
}

class _BeaconPagePrototypeState extends State<BeaconPagePrototype> {
  String _activeTab = '全部';
  String _searchQuery = '';
  bool _isSearchExpanded = false;
  bool _isExecutionMode = false;
  final Set<String> _selectedTaskIds = <String>{};

  Map<String, NarrativeElement> get _elementById => <String, NarrativeElement>{
    for (final element in widget.elements) element.elementId: element,
  };

  List<BeaconTask> get _filteredTasks {
    final normalizedQuery = _searchQuery.trim().toLowerCase();
    final baseTasks = switch (_activeTab) {
      '待执行' => widget.tasks.where((task) => !task.isArchived),
      '已归档' => widget.tasks.where((task) => task.isArchived),
      _ => widget.tasks,
    };

    final tasks = baseTasks.toList(growable: false);
    if (normalizedQuery.isEmpty) {
      return tasks;
    }

    return tasks
        .where((task) {
          final title = task.title.toLowerCase();
          final description = (task.description ?? '').toLowerCase();
          return title.contains(normalizedQuery) ||
              description.contains(normalizedQuery);
        })
        .toList(growable: false);
  }

  List<BeaconTask> get _executionTasks =>
      widget.tasks.where((task) => !task.isArchived).toList(growable: false);

  List<BeaconTask> get _pendingTasks =>
      _filteredTasks.where((task) => !task.isArchived).toList(growable: false);

  List<BeaconTask> get _archivedTasks =>
      _filteredTasks.where((task) => task.isArchived).toList(growable: false);

  List<BeaconTask> get _selectedExecutionTasks => _executionTasks
      .where((task) => _selectedTaskIds.contains(task.taskId))
      .toList(growable: false);

  List<NarrativeElement> get _executionElements {
    final orderedElements = <NarrativeElement>[];
    final seenIds = <String>{};
    for (final task in _selectedExecutionTasks) {
      for (final elementId in task.linkedElementIds) {
        final element = _elementById[elementId];
        if (element == null || !seenIds.add(element.elementId)) {
          continue;
        }
        orderedElements.add(element);
      }
    }
    return orderedElements;
  }

  int get _countAll => widget.tasks.length;
  int get _countPending =>
      widget.tasks.where((task) => !task.isArchived).length;
  int get _countArchived =>
      widget.tasks.where((task) => task.isArchived).length;

  Future<void> _enterExecutionMode() async {
    final selectedTaskIds = await _showExecutionTaskPickerDialog();
    if (!mounted || selectedTaskIds == null || selectedTaskIds.isEmpty) {
      return;
    }

    setState(() {
      _isExecutionMode = true;
      _selectedTaskIds
        ..clear()
        ..addAll(selectedTaskIds);
    });
  }

  void _exitExecutionMode() {
    setState(() {
      _isExecutionMode = false;
      _selectedTaskIds.clear();
    });
  }

  void _toggleSearch() {
    setState(() {
      _isSearchExpanded = !_isSearchExpanded;
      if (!_isSearchExpanded) {
        _searchQuery = '';
      }
    });
  }

  List<String> _chapterTitlesForTask(BeaconTask task) {
    final titles = <String>[];
    final seenTitles = <String>{};
    for (final elementId in task.linkedElementIds) {
      final element = _elementById[elementId];
      final chapterId = element?.owningChapterId;
      if (chapterId == null) {
        continue;
      }
      final title = widget.chapterTitleById[chapterId];
      if (title == null || title.trim().isEmpty || !seenTitles.add(title)) {
        continue;
      }
      titles.add(title);
    }
    return titles;
  }

  List<String> _elementTitlesForTask(BeaconTask task) {
    final titles = <String>[];
    final seenTitles = <String>{};
    for (final elementId in task.linkedElementIds) {
      final title = _elementById[elementId]?.title.trim();
      if (title == null || title.isEmpty || !seenTitles.add(title)) {
        continue;
      }
      titles.add(title);
    }
    return titles;
  }

  Future<Set<String>?> _showExecutionTaskPickerDialog() async {
    final initialSelection = Set<String>.from(_selectedTaskIds);
    return showDialog<Set<String>>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.36),
      builder: (dialogContext) {
        final draftSelection = Set<String>.from(initialSelection);
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              key: const ValueKey('beaconExecutionTaskPickerDialog'),
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.zero,
              ),
              elevation: 0,
              child: Container(
                padding: const EdgeInsets.fromLTRB(28, 30, 28, 24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.black12, width: 1),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '选 择 任 务',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 2.0,
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      '勾选本次外拍要探索的进行中任务，再进入探索。',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 20),
                    for (final task in _executionTasks)
                      _buildExecutionTaskPickerRow(
                        task: task,
                        selected: draftSelection.contains(task.taskId),
                        onTap: () {
                          setDialogState(() {
                            if (draftSelection.contains(task.taskId)) {
                              draftSelection.remove(task.taskId);
                            } else {
                              draftSelection.add(task.taskId);
                            }
                          });
                        },
                      ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () => Navigator.of(dialogContext).pop(),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.black12),
                              ),
                              alignment: Alignment.center,
                              child: const Text(
                                '取 消',
                                style: TextStyle(
                                  color: Colors.black54,
                                  fontSize: 13,
                                  letterSpacing: 2.0,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: IgnorePointer(
                            ignoring: draftSelection.isEmpty,
                            child: Opacity(
                              opacity: draftSelection.isEmpty ? 0.35 : 1,
                              child: InkWell(
                                key: const ValueKey(
                                  'beaconExecutionTaskPickerConfirmButton',
                                ),
                                onTap: () => Navigator.of(
                                  dialogContext,
                                ).pop(Set<String>.from(draftSelection)),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                  decoration: const BoxDecoration(
                                    color: Colors.black,
                                  ),
                                  alignment: Alignment.center,
                                  child: const Text(
                                    '开 始 执 行',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 13,
                                      letterSpacing: 2.0,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildExecutionTaskPickerRow({
    required BeaconTask task,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              key: ValueKey('beaconExecutionTaskPickerRow-${task.taskId}'),
              onTap: onTap,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOutCubic,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: selected
                      ? const Color(0xFFF3F4F4).withValues(alpha: 0.92)
                      : Colors.white.withValues(alpha: 0.72),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.018),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    _buildExecutionTaskPickerMarker(selected),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        task.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: selected
                              ? FontWeight.w500
                              : FontWeight.w400,
                          color: selected
                              ? const Color(0xFF3A3A3A)
                              : const Color(0xFF7B7B7B),
                          letterSpacing: 0.4,
                          height: 1.2,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildExecutionTaskPickerMarker(bool selected) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOutCubic,
      width: 16,
      height: 16,
      decoration: BoxDecoration(
        color: selected
            ? const Color(0xFF2E3438)
            : Colors.white.withValues(alpha: 0.6),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: selected
          ? const Icon(Icons.check, size: 11, color: Colors.white)
          : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 420),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      transitionBuilder: (child, animation) {
        final isExecutionChild =
            child.key == const ValueKey('beaconExecutionScaffold');
        final offsetAnimation = Tween<Offset>(
          begin: isExecutionChild
              ? const Offset(0, 0.035)
              : const Offset(0, -0.02),
          end: Offset.zero,
        ).animate(animation);
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(position: offsetAnimation, child: child),
        );
      },
      child: _isExecutionMode
          ? _buildExecutionScaffold()
          : _buildNormalScaffold(),
    );
  }

  Widget _buildNormalScaffold() {
    return Scaffold(
      key: const ValueKey('beaconNormalScaffold'),
      body: SafeArea(
        child: KeyedSubtree(
          key: const ValueKey('beaconNormalModeRoot'),
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTopBar(),
                  const SizedBox(height: 24),
                  _buildTabsAndSearch(),
                  Expanded(child: _buildTaskList()),
                ],
              ),
              Positioned(
                bottom: 16,
                right: 16,
                child: _buildExecutionEntryButton(),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        activeTab: PrototypeTab.overview,
        onChangeTab: widget.onBottomTabChanged,
      ),
    );
  }

  Widget _buildExecutionScaffold() {
    return Scaffold(
      key: const ValueKey('beaconExecutionScaffold'),
      body: SafeArea(
        child: KeyedSubtree(
          key: const ValueKey('beaconExecutionModeRoot'),
          child: _buildExecutionMode(),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.menu, color: Colors.black87),
            onPressed: widget.onOpenSidebar,
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                widget.projectTitle,
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

  Widget _buildTabsAndSearch() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildSingleTab('全部', _countAll),
              const SizedBox(width: 32),
              _buildSingleTab('待执行', _countPending),
              const SizedBox(width: 32),
              _buildSingleTab('已归档', _countArchived),
              const Spacer(),
              IconButton(
                key: const ValueKey('beaconSearchToggleButton'),
                onPressed: _toggleSearch,
                tooltip: '搜索任务',
                padding: const EdgeInsets.all(8),
                icon: const Icon(
                  Icons.search,
                  size: 16,
                  color: Color(0xFF8E8E8E),
                ),
              ),
            ],
          ),
          if (_isSearchExpanded) ...[
            const SizedBox(height: 14),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF7F7F7),
                border: Border.all(color: const Color(0xFFE6E6E6)),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: TextField(
                key: const ValueKey('beaconSearchField'),
                onChanged: (value) => setState(() => _searchQuery = value),
                decoration: const InputDecoration(
                  hintText: '搜索任务',
                  hintStyle: TextStyle(color: Color(0xFF9A9A9A), fontSize: 13),
                  border: InputBorder.none,
                ),
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 14,
                  height: 1.3,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSingleTab(String title, int count) {
    final isActive = _activeTab == title;
    return GestureDetector(
      onTap: () => setState(() => _activeTab = title),
      child: Container(
        padding: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isActive ? Colors.black87 : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Row(
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 15,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                color: isActive ? Colors.black87 : Colors.grey.shade500,
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              '$count',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: isActive ? Colors.grey.shade600 : Colors.grey.shade400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskList() {
    if (_activeTab == '全部') {
      return ListView(
        padding: const EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: 140,
        ),
        children: [
          _buildTaskSectionHeader(
            key: const ValueKey('beaconPendingSectionHeader'),
            label: '进 行 中',
          ),
          const SizedBox(height: 10),
          if (_pendingTasks.isEmpty)
            _buildEmptySectionHint('当前没有进行中的任务')
          else
            for (final task in _pendingTasks) _buildTaskCard(task),
          const SizedBox(height: 12),
          _buildTaskSectionHeader(
            key: const ValueKey('beaconArchivedSectionHeader'),
            label: '已 归 档',
          ),
          const SizedBox(height: 10),
          if (_archivedTasks.isEmpty)
            _buildEmptySectionHint('当前没有已归档任务')
          else
            for (final task in _archivedTasks) _buildTaskCard(task),
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: _buildAddTaskButton(),
          ),
        ],
      );
    }

    final tasks = _filteredTasks;
    return ListView(
      padding: const EdgeInsets.only(left: 24, right: 24, top: 24, bottom: 140),
      children: [
        for (final task in tasks) _buildTaskCard(task),
        Padding(
          padding: const EdgeInsets.only(top: 4),
          child: _buildAddTaskButton(),
        ),
      ],
    );
  }

  Widget _buildTaskSectionHeader({required Key key, required String label}) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        label,
        key: key,
        style: const TextStyle(
          fontSize: 10,
          color: Color(0xFFA6A6A6),
          letterSpacing: 4.4,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildEmptySectionHint(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          color: Color(0xFFB3B3B3),
          letterSpacing: 1.0,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }

  Widget _buildTaskCard(BeaconTask task) {
    final chapterTitles = _chapterTitlesForTask(task);
    final elementTitles = _elementTitlesForTask(task);
    final hasAssociations =
        chapterTitles.isNotEmpty || elementTitles.isNotEmpty;

    return InkWell(
      key: ValueKey('beaconTaskCard-${task.taskId}'),
      onTap: () {
        widget.onOpenTask(task);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 24),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      task.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: Colors.black54),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                task.description ?? '',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                  height: 1.6,
                ),
              ),
              if (hasAssociations) ...[
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.only(top: 12),
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(color: Colors.grey.shade100),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (chapterTitles.isNotEmpty)
                        _buildAssociationText(
                          key: ValueKey('beaconTaskChapterLine-${task.taskId}'),
                          label: '章节',
                          content: chapterTitles.join('，'),
                        ),
                      if (chapterTitles.isNotEmpty && elementTitles.isNotEmpty)
                        const SizedBox(height: 4),
                      if (elementTitles.isNotEmpty)
                        _buildAssociationText(
                          key: ValueKey('beaconTaskElementLine-${task.taskId}'),
                          label: '元素',
                          content: elementTitles.join('，'),
                        ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAssociationText({
    required Key key,
    required String label,
    required String content,
  }) {
    return Text(
      '[$label]  $content',
      key: key,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontSize: 11,
        color: Colors.grey.shade500,
        fontStyle: FontStyle.italic,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildExecutionEntryButton() {
    return GestureDetector(
      onTap: () {
        _enterExecutionMode();
      },
      child: Container(
        key: const ValueKey('beaconExecutionEntryButton'),
        padding: const EdgeInsets.fromLTRB(14, 10, 10, 10),
        decoration: BoxDecoration(
          color: const Color(0xFFF7F7F9),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.playlist_add_check_rounded,
              color: Colors.black87,
              size: 14,
            ),
            SizedBox(width: 8),
            Text(
              '探索',
              style: TextStyle(
                color: Colors.black87,
                fontSize: 11,
                fontWeight: FontWeight.w300,
                letterSpacing: 2.8,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddTaskButton() {
    return RestrainedActionButton(
      key: const ValueKey('beaconAddTaskButton'),
      label: '添加任务',
      onTap: () {
        widget.onCreateTask();
      },
    );
  }

  Widget _buildExecutionMode() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 12),
            child: Row(
              children: [
                IconButton(
                  key: const ValueKey('beaconExecutionExitButton'),
                  icon: const Icon(
                    Icons.arrow_back_ios_new,
                    color: Colors.black87,
                    size: 18,
                  ),
                  onPressed: _exitExecutionMode,
                ),
                const Expanded(
                  child: Text(
                    '寻 找 中',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 4.0,
                      color: Colors.black87,
                    ),
                  ),
                ),
                const SizedBox(width: 48),
              ],
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 7,
                  child: Container(
                    key: const ValueKey('beaconExecutionElementSection'),
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: SingleChildScrollView(
                            child: Wrap(
                              spacing: 12,
                              runSpacing: 12,
                              children: [
                                if (_executionElements.isEmpty)
                                  const Text(
                                    '当前所选任务没有关联元素。',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Color(0xFF9A9A9A),
                                      height: 1.6,
                                    ),
                                  ),
                                for (final element in _executionElements)
                                  _ExecutionDisplayText(
                                    key: ValueKey(
                                      'beaconExecutionElementRow-${element.elementId}',
                                    ),
                                    label: element.title,
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  flex: 4,
                  child: Container(
                    key: const ValueKey('beaconExecutionTaskSection'),
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
                    decoration: const BoxDecoration(
                      border: Border(top: BorderSide(color: Color(0xFFEAEAEA))),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '任务介绍',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w300,
                            letterSpacing: 3.2,
                            color: Color(0xFF666666),
                          ),
                        ),
                        const SizedBox(height: 14),
                        Expanded(
                          child: _selectedExecutionTasks.isEmpty
                              ? const Text(
                                  '选择任务后，这里只保留当前外拍需要记住的提示。',
                                  style: TextStyle(
                                    fontSize: 12,
                                    height: 1.6,
                                    color: Color(0xFF9A9A9A),
                                  ),
                                )
                              : ListView.separated(
                                  itemCount: _selectedExecutionTasks.length,
                                  separatorBuilder: (_, _) =>
                                      const SizedBox(height: 14),
                                  itemBuilder: (context, index) {
                                    final task = _selectedExecutionTasks[index];
                                    return Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 8,
                                      ),
                                      decoration: const BoxDecoration(
                                        color: Color(0xFFF3F3F0),
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            task.title,
                                            style: const TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w600,
                                              letterSpacing: 1.2,
                                              color: Color(0xFF2F2F2F),
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            task.description ?? '',
                                            style: const TextStyle(
                                              fontSize: 12,
                                              height: 1.6,
                                              color: Color(0xFF626262),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ExecutionDisplayText extends StatelessWidget {
  const _ExecutionDisplayText({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w500,
          letterSpacing: 1.2,
          height: 1.15,
          color: Colors.black87,
        ),
      ),
    );
  }
}
