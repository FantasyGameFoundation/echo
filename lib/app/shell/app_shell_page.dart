import 'dart:ui';

import 'package:echo/features/beacon/presentation/pages/beacon_page_prototype.dart';
import 'package:echo/features/curation/presentation/pages/organize_page_prototype.dart';
import 'package:echo/features/project/presentation/pages/project_wizard_page.dart';
import 'package:echo/features/project/presentation/widgets/project_sidebar.dart';
import 'package:echo/features/structure_elements_relations/domain/element_status.dart';
import 'package:echo/features/structure_elements_relations/presentation/pages/structure_page_prototype.dart';
import 'package:echo/features/timeline/presentation/pages/timeline_page_prototype.dart';
import 'package:echo/shared/models/prototype_tab.dart';
import 'package:echo/shared/widgets/quick_record_overlay_prototype.dart';
import 'package:flutter/material.dart';

class AppShellPage extends StatefulWidget {
  const AppShellPage({super.key});

  @override
  State<AppShellPage> createState() => _AppShellPageState();
}

class _AppShellPageState extends State<AppShellPage> {
  PrototypeTab _currentTab = PrototypeTab.structure;
  bool _sidebarOpen = false;
  bool _showAddOverlay = false;
  int _currentTabIndex = 0;

  final List<Map<String, dynamic>> _chapterElements = [
    {
      'chapter': 'C H A P T E R  0 1  /  晨曦之眼',
      'elements': [
        {
          'title': '江边的空酒瓶',
          'desc': '捕捉清晨薄雾中，人造物与自然边界的冲突。',
          'status': ElementStatus.finding,
          'images': const [
            'https://picsum.photos/seed/echo-structure-a/400/400?grayscale',
            'https://picsum.photos/seed/echo-structure-b/400/400?grayscale',
            'https://picsum.photos/seed/echo-structure-c/400/400?grayscale',
            'https://picsum.photos/seed/echo-structure-d/400/400?grayscale',
          ],
        },
        {
          'title': '孤独的电线杆',
          'desc': '黄昏时分，切割天空的几何线条。',
          'status': ElementStatus.finding,
          'images': const <String>[],
        },
      ],
    },
    {
      'chapter': 'C H A P T E R  0 2  /  众神之后',
      'elements': [
        {
          'title': '某种醉态',
          'desc': '体现人物与环境的疏离感，而非酒精的狂热。',
          'status': ElementStatus.ready,
          'images': const [
            'https://picsum.photos/seed/echo-structure-b/400/400?grayscale',
            'https://picsum.photos/seed/echo-structure-d/400/400?grayscale',
            'https://picsum.photos/seed/echo-structure-e/400/400?grayscale',
          ],
        },
        {
          'title': '斑驳的树影',
          'desc': '工业废墟中唯一的生机暗示。',
          'status': ElementStatus.ready,
          'images': const [
            'https://picsum.photos/seed/echo-structure-c/400/400?grayscale',
            'https://picsum.photos/seed/echo-structure-a/400/400?grayscale',
          ],
        },
      ],
    },
    {
      'chapter': 'C H A P T E R  0 3  /  呼吸感',
      'elements': [
        {
          'title': '江边的围网',
          'desc': '被遗弃的秩序感，纠缠的线条暗示束缚。',
          'status': ElementStatus.ready,
          'images': const [
            'https://picsum.photos/seed/echo-structure-d/400/400?grayscale',
          ],
        },
        {
          'title': '留白的天空',
          'desc': '大面积低饱和度冷灰，压抑情绪的释放口。',
          'status': ElementStatus.finding,
          'images': const <String>[],
        },
      ],
    },
  ];

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_showAddOverlay,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && _showAddOverlay) {
          setState(() {
            _showAddOverlay = false;
          });
        }
      },
      child: Scaffold(
        body: Stack(
          children: [
            _buildCurrentPage(),
            if (_showAddOverlay) ...[
              Positioned.fill(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 6.0, sigmaY: 6.0),
                  child: Container(
                    color: Colors.white.withValues(alpha: 0.18),
                  ),
                ),
              ),
              Positioned(
                top: 120,
                left: 20,
                right: 20,
                bottom: 80,
                child: QuickRecordOverlayPrototype(
                  onClose: () => setState(() => _showAddOverlay = false),
                  onBottomTabChanged: (_) {},
                ),
              ),
            ],
            if (_sidebarOpen) ...[
              Positioned.fill(
                child: GestureDetector(
                  onTap: () => setState(() => _sidebarOpen = false),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 6.0, sigmaY: 6.0),
                    child: Container(
                      color: Colors.white.withValues(alpha: 0.18),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 0,
                bottom: 0,
                left: 0,
                child: ProjectSidebar(
                  onNewProject: () async {
                    setState(() {
                      _sidebarOpen = false;
                      _currentTab = PrototypeTab.structure;
                      _currentTabIndex = 0;
                    });
                    await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => ProjectWizardPage(
                          onFinish: () {
                            setState(() {
                              _currentTab = PrototypeTab.structure;
                              _currentTabIndex = 0;
                              _sidebarOpen = false;
                            });
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentPage() {
    switch (_currentTab) {
      case PrototypeTab.structure:
      case PrototypeTab.add:
        return StructurePagePrototype(
          currentTabIndex: _currentTabIndex,
          chapterElements: _chapterElements,
          onOpenSidebar: () => setState(() => _sidebarOpen = true),
          onTabChanged: (index) {
            setState(() {
              _currentTabIndex = index;
            });
          },
          onBottomTabChanged: _changeTab,
        );
      case PrototypeTab.curation:
        return OrganizePagePrototype(
          onOpenSidebar: () => setState(() => _sidebarOpen = true),
          onBottomTabChanged: _changeTab,
        );
      case PrototypeTab.overview:
        return BeaconPagePrototype(
          onOpenSidebar: () => setState(() => _sidebarOpen = true),
          onBottomTabChanged: _changeTab,
        );
      case PrototypeTab.timeline:
        return TimelinePagePrototype(
          onOpenSidebar: () => setState(() => _sidebarOpen = true),
          onBottomTabChanged: _changeTab,
        );
    }
  }

  void _changeTab(PrototypeTab tab) {
    if (tab == PrototypeTab.add) {
      setState(() {
        _showAddOverlay = true;
        _sidebarOpen = false;
      });
      return;
    }

    setState(() {
      _currentTab = tab;
      _sidebarOpen = false;
      _showAddOverlay = false;
    });
  }
}
