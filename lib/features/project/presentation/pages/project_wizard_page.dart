import 'dart:io';

import 'package:flutter/material.dart';
import 'package:echo/features/project/presentation/utils/project_cover_picker.dart';

typedef ProjectWizardFinish =
    Future<void> Function(
      String title,
      String themeStatement,
      String? coverImagePath,
    );

class ProjectWizardPage extends StatefulWidget {
  const ProjectWizardPage({
    super.key,
    required this.onFinish,
    PickProjectCoverImage? onPickCoverImage,
  }) : onPickCoverImage = onPickCoverImage ?? pickProjectCoverImageFromGallery;

  final ProjectWizardFinish onFinish;
  final PickProjectCoverImage onPickCoverImage;

  @override
  State<ProjectWizardPage> createState() => _ProjectWizardPageState();
}

class _ProjectWizardPageState extends State<ProjectWizardPage> {
  int _currentStage = 1;

  final TextEditingController _intentController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final FocusNode _intentFocusNode = FocusNode();
  final FocusNode _nameFocusNode = FocusNode();

  bool _isFlashing = false;
  String? _coverImagePath;

  @override
  void initState() {
    super.initState();
    _scheduleStageFocus();
  }

  void _nextStage() {
    if (_currentStage == 1 && _intentController.text.trim().isEmpty) return;
    if (_currentStage == 2 && _nameController.text.trim().isEmpty) return;

    if (_currentStage < 3) {
      setState(() => _currentStage++);
      _scheduleStageFocus();
    }
  }

  void _prevStage() {
    if (_currentStage > 1) {
      setState(() => _currentStage--);
      _scheduleStageFocus();
    } else {
      Navigator.pop(context);
    }
  }

  void _goToStructurePage() async {
    setState(() => _isFlashing = true);
    await Future.delayed(const Duration(milliseconds: 150));

    if (!mounted) return;
    await widget.onFinish(
      _nameController.text.trim(),
      _intentController.text.trim(),
      _coverImagePath,
    );
    if (!mounted) return;
    Navigator.pop(context);
  }

  Future<void> _pickCoverImage() async {
    final coverImagePath = await widget.onPickCoverImage();
    if (!mounted || coverImagePath == null) {
      return;
    }

    setState(() {
      _coverImagePath = coverImagePath;
    });
  }

  void _scheduleStageFocus() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      switch (_currentStage) {
        case 1:
          _intentFocusNode.requestFocus();
          break;
        case 2:
          _nameFocusNode.requestFocus();
          break;
        case 3:
          FocusScope.of(context).unfocus();
          break;
      }
    });
  }

  @override
  void dispose() {
    _intentController.dispose();
    _nameController.dispose();
    _intentFocusNode.dispose();
    _nameFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Positioned(
              top: 16,
              left: 16,
              child: IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios_new,
                  size: 18,
                  color: Colors.black87,
                ),
                onPressed: _prevStage,
              ),
            ),
            Positioned.fill(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 800),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeInCubic,
                transitionBuilder: (child, animation) {
                  final inOffset = Tween<Offset>(
                    begin: const Offset(0, 0.05),
                    end: Offset.zero,
                  ).animate(animation);
                  return FadeTransition(
                    opacity: animation,
                    child: child.key == ValueKey(_currentStage)
                        ? SlideTransition(position: inOffset, child: child)
                        : child,
                  );
                },
                child: _buildStageContent(),
              ),
            ),
            if (_currentStage < 3)
              Positioned(
                bottom: 40,
                left: 32,
                right: 32,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildNavButton(
                      icon: Icons.arrow_back,
                      onTap: _prevStage,
                      opacity: _currentStage > 1 ? 0.6 : 0.0,
                    ),
                    _buildNavButton(
                      icon: Icons.arrow_forward,
                      onTap: _nextStage,
                      opacity: 1.0,
                      isPrimary: true,
                    ),
                  ],
                ),
              ),
            if (_isFlashing)
              Positioned.fill(child: Container(color: Colors.white)),
          ],
        ),
      ),
    );
  }

  Widget _buildStageContent() {
    switch (_currentStage) {
      case 1:
        return _buildStage1Intention();
      case 2:
        return _buildStage2Naming();
      case 3:
        return _buildStage3Cover();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildStage1Intention() {
    return Center(
      key: const ValueKey(1),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40.0),
        child: TextField(
          key: const ValueKey('projectIntentField'),
          controller: _intentController,
          focusNode: _intentFocusNode,
          maxLines: null,
          textAlign: TextAlign.center,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => _nextStage(),
          style: const TextStyle(
            fontSize: 22,
            color: Colors.black87,
            fontWeight: FontWeight.w300,
            fontStyle: FontStyle.italic,
            height: 1.6,
          ),
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: '输入你的创作意图',
            hintStyle: TextStyle(
              fontSize: 22,
              color: Colors.grey.shade400,
              fontWeight: FontWeight.w300,
              fontStyle: FontStyle.italic,
              height: 1.6,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStage2Naming() {
    return Padding(
      key: const ValueKey(2),
      padding: const EdgeInsets.symmetric(horizontal: 40.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '" ${_intentController.text} "',
            textAlign: TextAlign.center,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.w300,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 64),
          TextField(
            key: const ValueKey('projectNameField'),
            controller: _nameController,
            focusNode: _nameFocusNode,
            maxLines: null,
            textAlign: TextAlign.center,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _nextStage(),
            style: const TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
              letterSpacing: 2.0,
              height: 1.3,
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: '项目名称',
              hintStyle: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade300,
                letterSpacing: 2.0,
              ),
            ),
          ),
          const SizedBox(height: 56),
        ],
      ),
    );
  }

  Widget _buildStage3Cover() {
    return Padding(
      key: const ValueKey(3),
      padding: const EdgeInsets.symmetric(horizontal: 32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 80),
          Text(
            _intentController.text,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade400,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _nameController.text,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
              letterSpacing: 2.0,
            ),
          ),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '是否添加封面图',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w300,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(width: 12),
              InkWell(
                onTap: _pickCoverImage,
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.black26, width: 1),
                  ),
                  child: const Icon(Icons.add, size: 14, color: Colors.black87),
                ),
              ),
            ],
          ),
          if (_coverImagePath != null) ...[
            const SizedBox(height: 20),
            ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Container(
                width: 120,
                height: 148,
                color: Colors.grey.shade200,
                child: Image.file(
                  File(_coverImagePath!),
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Center(
                    child: Icon(
                      Icons.image_outlined,
                      color: Colors.grey.shade500,
                      size: 24,
                    ),
                  ),
                ),
              ),
            ),
          ],
          const Spacer(),
          Padding(
            padding: const EdgeInsets.only(bottom: 40.0),
            child: Center(
              child: InkWell(
                onTap: _goToStructurePage,
                borderRadius: BorderRadius.circular(24),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black12, width: 1.0),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '详 细 编 辑',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.black87,
                          fontWeight: FontWeight.w400,
                          letterSpacing: 2.0,
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(
                        Icons.arrow_forward,
                        size: 14,
                        color: Colors.black54,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavButton({
    required IconData icon,
    required VoidCallback onTap,
    required double opacity,
    bool isPrimary = false,
  }) {
    if (opacity == 0) return const SizedBox(width: 48);

    return Opacity(
      opacity: opacity,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: isPrimary ? Colors.black26 : Colors.black12,
              width: 1.0,
            ),
          ),
          child: Icon(icon, color: Colors.black87, size: isPrimary ? 24 : 20),
        ),
      ),
    );
  }
}
