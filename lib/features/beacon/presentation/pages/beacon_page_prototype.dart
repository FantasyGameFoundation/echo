import 'package:echo/shared/models/prototype_tab.dart';
import 'package:echo/shared/widgets/custom_bottom_nav_bar.dart';
import 'package:flutter/material.dart';

const ColorFilter _beaconGreyscaleFilter = ColorFilter.matrix(<double>[
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
]);

class BeaconPagePrototype extends StatefulWidget {
  const BeaconPagePrototype({
    super.key,
    required this.onOpenSidebar,
    required this.onBottomTabChanged,
  });

  final VoidCallback onOpenSidebar;
  final ValueChanged<PrototypeTab> onBottomTabChanged;

  @override
  State<BeaconPagePrototype> createState() => _BeaconPagePrototypeState();
}

class _BeaconPagePrototypeState extends State<BeaconPagePrototype> {
  String _activeTab = '全部';

  final List<BeaconTask> _allTasks = [
    BeaconTask(
      title: '赤水河中游航拍全景',
      description: '使用无人机接片拍摄河道大拐弯，注意避开正午顶光，寻找河水与两岸红土的清晰交界线。',
      imageUrl:
          'https://images.unsplash.com/photo-1506744626753-1fa44df14c89?w=800',
      status: TaskStatus.pending,
      chapters: [
        '01 / 晨曦之眼',
        '02 / 众神之后',
        '04 / 阴影的重量',
        '05 / 最后的凝视：记忆中的地标',
        '06 / 光影的旋律',
      ],
      elements: ['江边的空酒瓶', '水面的漂浮物', '赤红的泥土', '斑驳的树影', '孤独的电线杆', '江边的围网'],
    ),
    BeaconTask(
      title: '废弃糖厂内部钢铁结构',
      description: '寻找对称的几何构图，使用超广角夸张透视，展现工业巨兽的压迫感。',
      imageUrl:
          'https://images.unsplash.com/photo-1486406146926-c627a92ad1ab?w=800',
      status: TaskStatus.pending,
      chapters: [],
      elements: [
        '某种醉态',
        '江边的空酒瓶',
        '水面的漂浮物',
        '迷茫的眼神',
        '赤红的泥土',
        '斑驳的树影',
        '孤独的电线杆',
      ],
    ),
    BeaconTask(
      title: '寻访废弃的盐道码头',
      description: '重点关注水面反光与铁锈的质感对比，尽量使用广角压低视角。',
      imageUrl:
          'https://images.unsplash.com/photo-1496307653780-42ee777d4833?w=800',
      status: TaskStatus.pending,
      chapters: ['02 / 众神之后'],
      elements: [],
    ),
    BeaconTask(
      title: '老街坊的清晨茶馆',
      description: '抓拍老人们的面部特写，利用茶馆木窗投射进来的自然光，压暗背景。',
      imageUrl:
          'https://images.unsplash.com/photo-1494438639946-1ebd1d20bf85?w=800',
      status: TaskStatus.pending,
      chapters: ['03 / 呼吸感', '06 / 光影的旋律：结构与节奏', '附录 / 遗失的对话'],
      elements: [],
    ),
    BeaconTask(
      title: '旧林区林道伐木痕迹',
      description: '记录树桩上的年轮细节，侧逆光下寻找年轮间隙的青苔深度。',
      imageUrl:
          'https://images.unsplash.com/photo-1518131341018-095034639e44?w=800',
      status: TaskStatus.pending,
      chapters: [],
      elements: ['迷茫的眼神', '斑驳的树影'],
    ),
    BeaconTask(
      title: '县城剧院废弃放映厅',
      description: '极低照度拍摄，捕捉放映机投射孔透出的微光，注意空气中的尘埃。',
      imageUrl:
          'https://images.unsplash.com/photo-1444418776041-9c7e33cc5a9c?w=800',
      status: TaskStatus.archived,
      chapters: ['01 / 晨曦之眼', '03 / 呼吸感'],
      elements: ['某种醉态'],
    ),
    BeaconTask(
      title: '河滩边的采砂船残骸',
      description: '沿着枯水期的河床线寻找，注意工业遗迹与自然河流的切割线。',
      imageUrl:
          'https://images.unsplash.com/photo-1517581177682-a085bb7ffb15?w=800',
      status: TaskStatus.archived,
      chapters: [],
      elements: [],
    ),
  ];

  List<BeaconTask> get _filteredTasks {
    if (_activeTab == '待执行') {
      return _allTasks.where((t) => t.status == TaskStatus.pending).toList();
    } else if (_activeTab == '已归档') {
      return _allTasks.where((t) => t.status == TaskStatus.archived).toList();
    }
    return _allTasks;
  }

  int get _countAll => _allTasks.length;
  int get _countPending =>
      _allTasks.where((t) => t.status == TaskStatus.pending).length;
  int get _countArchived =>
      _allTasks.where((t) => t.status == TaskStatus.archived).length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTopBar(),
                const SizedBox(height: 24),
                _buildTabsWithSearch(),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.only(
                      left: 24,
                      right: 24,
                      top: 24,
                      bottom: 100,
                    ),
                    itemCount: _filteredTasks.length,
                    itemBuilder: (context, index) =>
                        _buildTaskCard(_filteredTasks[index]),
                  ),
                ),
              ],
            ),
            Positioned(
              bottom: 96,
              left: 0,
              right: 0,
              child: Center(child: _buildFloatingActionBtn()),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: CustomBottomNavBar(
                activeTab: PrototypeTab.overview,
                onChangeTab: widget.onBottomTabChanged,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.menu, color: Colors.black87),
            onPressed: widget.onOpenSidebar,
          ),
          const Text(
            '赤水河沿岸寻访',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w300,
              letterSpacing: 4.0,
              color: Colors.black87,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.black87),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildTabsWithSearch() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildSingleTab('全部', _countAll),
          const SizedBox(width: 32),
          _buildSingleTab('待执行', _countPending),
          const SizedBox(width: 32),
          _buildSingleTab('已归档', _countArchived),
          const Spacer(),
          GestureDetector(
            onTap: () {},
            child: const Padding(
              padding: EdgeInsets.only(bottom: 6.0),
              child: Icon(Icons.search, color: Colors.black87, size: 18),
            ),
          ),
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
              width: 2.0,
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

  Widget _buildTaskCard(BeaconTask task) {
    final hasAssociations =
        task.chapters.isNotEmpty || task.elements.isNotEmpty;

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
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
              task.description,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade600,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 16),
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Container(
                color: Colors.grey.shade200,
                child: ColorFiltered(
                  colorFilter: _beaconGreyscaleFilter,
                  child: Image.network(
                    task.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (c, e, s) =>
                        const Icon(Icons.image, color: Colors.grey),
                  ),
                ),
              ),
            ),
            if (hasAssociations) ...[
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.only(top: 12),
                decoration: BoxDecoration(
                  border: Border(top: BorderSide(color: Colors.grey.shade100)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (task.chapters.isNotEmpty)
                      _buildAssociationText('章节', task.chapters.join('，')),
                    if (task.chapters.isNotEmpty && task.elements.isNotEmpty)
                      const SizedBox(height: 4),
                    if (task.elements.isNotEmpty)
                      _buildAssociationText('元素', task.elements.join('，')),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAssociationText(String label, String content) {
    return Text(
      '[$label]  $content',
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

  Widget _buildFloatingActionBtn() {
    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '执 行 模 式',
              style: TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.bold,
                letterSpacing: 2.0,
              ),
            ),
            SizedBox(width: 8),
            Icon(Icons.arrow_forward, color: Colors.white, size: 16),
          ],
        ),
      ),
    );
  }
}

enum TaskStatus { pending, archived }

class BeaconTask {
  BeaconTask({
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.status,
    this.chapters = const [],
    this.elements = const [],
  });

  final String title;
  final String description;
  final String imageUrl;
  final TaskStatus status;
  final List<String> chapters;
  final List<String> elements;
}
