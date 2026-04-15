import 'package:echo/features/project/domain/entities/project.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

typedef ProjectActionCallback = Future<void> Function(Project project);

class ProjectSidebar extends StatefulWidget {
  const ProjectSidebar({
    super.key,
    required this.onNewProject,
    required this.projects,
    required this.currentProjectId,
    required this.onSelectProject,
    required this.onEditProject,
    required this.onArchiveProject,
    required this.onDeleteProject,
  });

  final VoidCallback onNewProject;
  final List<Project> projects;
  final String? currentProjectId;
  final ValueChanged<String> onSelectProject;
  final ProjectActionCallback onEditProject;
  final ProjectActionCallback onArchiveProject;
  final ProjectActionCallback onDeleteProject;

  @override
  State<ProjectSidebar> createState() => _ProjectSidebarState();
}

class _ProjectSidebarState extends State<ProjectSidebar> {
  String? _pressedProjectId;
  String? _menuProjectId;

  @override
  Widget build(BuildContext context) {
    final activeProjects = widget.projects
        .where((project) => project.stage != 'completed')
        .toList();
    final archivedProjects = widget.projects
        .where((project) => project.stage == 'completed')
        .toList();

    return SizedBox(
      width: 280,
      child: Container(
        color: const Color(0xFFF8F9FA),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(left: 24, top: 64, bottom: 48),
              child: Text(
                '项目中心',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 2.0,
                  color: Colors.black87,
                ),
              ),
            ),
            _buildSectionTitle('活 跃 项 目'),
            if (activeProjects.isEmpty)
              _buildEmptyState(label: '暂无项目')
            else
              for (final project in activeProjects)
                _buildProjectTile(
                  project: project,
                  isSelected: project.projectId == widget.currentProjectId,
                ),
            const SizedBox(height: 32),
            _buildSectionTitle('归档项目'),
            if (archivedProjects.isEmpty)
              _buildEmptyState(label: '暂无项目')
            else
              for (final project in archivedProjects)
                _buildProjectTile(
                  project: project,
                  isSelected: project.projectId == widget.currentProjectId,
                ),
            const Spacer(),
            Container(
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: Colors.grey.shade300, width: 0.5),
                ),
              ),
              padding: const EdgeInsets.all(24.0),
              child: InkWell(
                onTap: widget.onNewProject,
                child: Container(
                  height: 56,
                  decoration: const BoxDecoration(color: Color(0xFF111111)),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_circle, color: Colors.white, size: 20),
                      SizedBox(width: 12),
                      Text(
                        '新建项目',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2.0,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 24, bottom: 16),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 12,
          color: Colors.black54,
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  Widget _buildEmptyState({required String label}) {
    return Container(
      height: 72,
      alignment: Alignment.center,
      child: Text(
        label,
        style: TextStyle(
          fontSize: 13,
          color: Colors.grey.shade400,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.6,
        ),
      ),
    );
  }

  Widget _buildProjectTile({
    required Project project,
    required bool isSelected,
  }) {
    final isPressed = _pressedProjectId == project.projectId;
    final baseColor = isSelected ? const Color(0xFFDEE3E5) : Colors.transparent;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        key: ValueKey('projectNavItem-${project.projectId}'),
        onTapDown: (_) {
          if (!mounted) {
            return;
          }
          setState(() {
            _pressedProjectId = project.projectId;
          });
        },
        onTapCancel: () {
          if (!mounted || _menuProjectId == project.projectId) {
            return;
          }
          setState(() {
            _pressedProjectId = null;
          });
        },
        onTap: () {
          if (mounted) {
            setState(() {
              _pressedProjectId = null;
            });
          }
          widget.onSelectProject(project.projectId);
        },
        onLongPress: () async {
          if (!mounted) {
            return;
          }
          setState(() {
            _pressedProjectId = project.projectId;
            _menuProjectId = project.projectId;
          });
          try {
            await HapticFeedback.mediumImpact();
          } catch (_) {
            // Some test and desktop environments do not provide haptics.
          }
          await _openProjectActions(project);
          if (!mounted) {
            return;
          }
          setState(() {
            if (_menuProjectId == project.projectId) {
              _menuProjectId = null;
            }
            if (_pressedProjectId == project.projectId) {
              _pressedProjectId = null;
            }
          });
        },
        splashFactory: NoSplash.splashFactory,
        highlightColor: Colors.transparent,
        splashColor: Colors.transparent,
        overlayColor: WidgetStateProperty.all<Color>(Colors.transparent),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          width: double.infinity,
          height: 54,
          padding: const EdgeInsets.only(left: 24, right: 16),
          alignment: Alignment.centerLeft,
          decoration: BoxDecoration(
            color: baseColor,
            border: Border(
              left: BorderSide(
                color: (isSelected || isPressed)
                    ? const Color(0xFF4A4A4A)
                    : Colors.transparent,
                width: 3,
              ),
            ),
            boxShadow: isPressed
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : null,
          ),
          child: Text(
            project.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 16,
              color: Colors.black87,
              fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
              letterSpacing: 1.0,
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _openProjectActions(Project project) async {
    final isArchivedProject = project.stage == 'completed';

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      elevation: 0,
      builder: (sheetContext) {
        return Container(
          margin: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.black12, width: 1),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildMenuAction(
                title: '编 辑',
                onTap: () async {
                  Navigator.of(sheetContext).pop();
                  await widget.onEditProject(project);
                },
              ),
              const Divider(height: 1, color: Color(0xFFEEEEEE)),
              _buildMenuAction(
                title: isArchivedProject ? '恢 复' : '归 档',
                onTap: () async {
                  Navigator.of(sheetContext).pop();
                  final shouldArchive = await _showConfirmationDialog(
                    context: context,
                    title: isArchivedProject ? '确 认 恢 复' : '确 认 归 档',
                    content: isArchivedProject
                        ? '是否将项目 "${project.title}" 恢复到活跃项目？'
                        : '是否将项目 "${project.title}" 移至归档库？',
                    actionText: isArchivedProject ? '恢 复' : '归 档',
                  );
                  if (!shouldArchive) {
                    return;
                  }
                  await widget.onArchiveProject(project);
                },
              ),
              const Divider(height: 1, color: Color(0xFFEEEEEE)),
              _buildMenuAction(
                title: '删 除',
                onTap: () async {
                  Navigator.of(sheetContext).pop();
                  final shouldDelete = await _showConfirmationDialog(
                    context: context,
                    title: '确 认 删 除',
                    content: '档案 "${project.title}" 将被永久移除。此操作不可撤销。',
                    actionText: '删 除',
                  );
                  if (!shouldDelete) {
                    return;
                  }
                  await widget.onDeleteProject(project);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMenuAction({
    required String title,
    required Future<void> Function() onTap,
    bool enabled = true,
  }) {
    return InkWell(
      onTap: enabled ? () => onTap() : null,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 22),
        alignment: Alignment.center,
        child: Text(
          title,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w400,
            letterSpacing: 4.0,
            color: enabled ? Colors.black87 : Colors.black26,
          ),
        ),
      ),
    );
  }

  Future<bool> _showConfirmationDialog({
    required BuildContext context,
    required String title,
    required String content,
    required String actionText,
  }) async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.4),
      builder: (dialogContext) {
        return Dialog(
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          elevation: 0,
          child: Container(
            padding: const EdgeInsets.fromLTRB(32, 40, 32, 32),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.black12, width: 1),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 2.0,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  content,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 48),
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () => Navigator.of(dialogContext).pop(true),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: const BoxDecoration(color: Colors.black),
                          alignment: Alignment.center,
                          child: Text(
                            actionText,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              letterSpacing: 2.0,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: InkWell(
                        onTap: () => Navigator.of(dialogContext).pop(false),
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
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );

    return confirmed ?? false;
  }
}
