// ignore_for_file: deprecated_member_use

import 'package:echo/core/platform/project_bundle_file_transfer.dart';
import 'package:echo/features/settings/domain/entities/app_settings.dart';
import 'package:echo/features/settings/domain/services/import_project_bundle.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SettingsPlaceholderPage extends StatefulWidget {
  const SettingsPlaceholderPage({
    super.key,
    required this.initialSettings,
    required this.onUpdateCompressionLevel,
    required this.onUpdateExportIncludesSettings,
    this.canExportCurrentProject = false,
    this.onExportProject,
    this.onPickImportBundle,
    this.onInspectImportBundle,
    this.onImportProject,
  });

  final AppSettings initialSettings;
  final bool canExportCurrentProject;
  final Future<AppSettings> Function(AppMediaCompressionLevel compressionLevel)
  onUpdateCompressionLevel;
  final Future<AppSettings> Function(bool include)
  onUpdateExportIncludesSettings;
  final Future<ProjectBundleExportReceipt?> Function(bool includeSettings)?
  onExportProject;
  final Future<ProjectBundleImportSelection?> Function()? onPickImportBundle;
  final Future<ImportProjectBundleInspection> Function(
    ProjectBundleImportSelection selection,
  )?
  onInspectImportBundle;
  final Future<AppSettings> Function(
    ProjectBundleImportSelection selection,
    bool applySettingsPayload,
  )?
  onImportProject;

  @override
  State<SettingsPlaceholderPage> createState() =>
      _SettingsPlaceholderPageState();
}

class _SettingsPlaceholderPageState extends State<SettingsPlaceholderPage> {
  late AppSettings _settings;
  bool _isUpdatingCompression = false;
  bool _isUpdatingExportOption = false;
  bool _isExporting = false;
  bool _isSelectingImportBundle = false;
  bool _isImporting = false;
  ProjectBundleExportReceipt? _lastExportReceipt;
  ProjectBundleImportSelection? _selectedImportBundle;
  String? _lastImportedDisplayPath;

  bool get _importExportDisabled => kIsWeb;
  bool get _isTransferFlowActive =>
      _isExporting || _isSelectingImportBundle || _isImporting;

  @override
  void initState() {
    super.initState();
    _settings = widget.initialSettings;
  }

  @override
  void dispose() {
    if (!_isImporting) {
      _selectedImportBundle?.dispose();
    }
    super.dispose();
  }

  Future<void> _updateCompression(AppMediaCompressionLevel level) async {
    if (_isUpdatingCompression || _settings.compressionLevel == level) {
      return;
    }

    setState(() => _isUpdatingCompression = true);
    try {
      final updatedSettings = await widget.onUpdateCompressionLevel(level);
      if (!mounted) {
        return;
      }
      setState(() => _settings = updatedSettings);
    } finally {
      if (mounted) {
        setState(() => _isUpdatingCompression = false);
      }
    }
  }

  Future<void> _updateExportOption(bool include) async {
    if (_isUpdatingExportOption) {
      return;
    }

    setState(() => _isUpdatingExportOption = true);
    try {
      final updatedSettings = await widget.onUpdateExportIncludesSettings(
        include,
      );
      if (!mounted) {
        return;
      }
      setState(() => _settings = updatedSettings);
    } finally {
      if (mounted) {
        setState(() => _isUpdatingExportOption = false);
      }
    }
  }

  Future<void> _exportProject() async {
    if (_isExporting ||
        widget.onExportProject == null ||
        !widget.canExportCurrentProject) {
      return;
    }

    setState(() => _isExporting = true);
    try {
      final exportReceipt = await widget.onExportProject!(
        _settings.includeSettingsInExportsByDefault,
      );
      if (!mounted) {
        return;
      }
      setState(() => _lastExportReceipt = exportReceipt);
      if (exportReceipt != null) {
        _showPassiveHint('导出完成');
      }
    } catch (error) {
      _handleTransferFailure(
        debugContext: 'Export failed',
        fallbackPrefix: '导出失败',
        error: error,
      );
    } finally {
      if (mounted) {
        setState(() => _isExporting = false);
      }
    }
  }

  Future<void> _pickImportBundle() async {
    if (_isSelectingImportBundle || widget.onPickImportBundle == null) {
      return;
    }

    setState(() => _isSelectingImportBundle = true);
    try {
      final selection = await widget.onPickImportBundle!.call();
      if (!mounted || selection == null) {
        return;
      }
      final previousSelection = _selectedImportBundle;
      setState(() => _selectedImportBundle = selection);
      await previousSelection?.dispose();
    } catch (error) {
      _handleTransferFailure(
        debugContext: 'Import pick failed',
        fallbackPrefix: '导入失败',
        error: error,
      );
    } finally {
      if (mounted) {
        setState(() => _isSelectingImportBundle = false);
      }
    }
  }

  Future<void> _importProject() async {
    final selection = _selectedImportBundle;
    if (_isImporting || widget.onImportProject == null || selection == null) {
      return;
    }

    var inspection =
        await widget.onInspectImportBundle?.call(selection) ??
        const ImportProjectBundleInspection(
          hasSettingsPayload: false,
          oversizedMediaCount: 0,
        );

    if (inspection.oversizedMediaCount > 0) {
      final shouldContinue = await _confirmOversizedImport(
        bundleLabel: selection.displayPath,
        initialInspection: inspection,
      );
      if (!shouldContinue) {
        return;
      }
      inspection =
          await widget.onInspectImportBundle?.call(selection) ?? inspection;
    }

    final applyImportedSettings = inspection.hasSettingsPayload
        ? await _confirmApplyImportedSettings()
        : false;
    if (inspection.hasSettingsPayload && applyImportedSettings == null) {
      return;
    }
    final shouldApplyImportedSettings = applyImportedSettings ?? false;

    setState(() => _isImporting = true);
    try {
      final updatedSettings = await widget.onImportProject!(
        selection,
        shouldApplyImportedSettings,
      );
      await selection.dispose();
      if (!mounted) {
        return;
      }
      setState(() {
        _settings = updatedSettings;
        _lastImportedDisplayPath = selection.displayPath;
        _selectedImportBundle = null;
      });
      _showPassiveHint('已导入为新项目');
    } catch (error) {
      _handleTransferFailure(
        debugContext: 'Import execution failed',
        fallbackPrefix: '导入失败',
        error: error,
      );
    } finally {
      if (mounted) {
        setState(() => _isImporting = false);
      }
    }
  }

  Future<bool> _confirmOversizedImport({
    required String bundleLabel,
    required ImportProjectBundleInspection initialInspection,
  }) async {
    var currentSettings = _settings;
    var currentInspection = initialInspection;
    var isUpdating = false;

    final decision = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.4),
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            Future<void> updateCompression(
              AppMediaCompressionLevel level,
            ) async {
              if (isUpdating || currentSettings.compressionLevel == level) {
                return;
              }
              setDialogState(() => isUpdating = true);
              final updatedSettings = await widget.onUpdateCompressionLevel(
                level,
              );
              final selectedImportBundle = _selectedImportBundle;
              final updatedInspection = selectedImportBundle == null
                  ? currentInspection
                  : await widget.onInspectImportBundle?.call(
                          selectedImportBundle,
                        ) ??
                        currentInspection;
              if (!mounted) {
                return;
              }
              setState(() => _settings = updatedSettings);
              setDialogState(() {
                currentSettings = updatedSettings;
                currentInspection = updatedInspection;
                isUpdating = false;
              });
            }

            final isStillOversized = currentInspection.oversizedMediaCount > 0;
            final primaryLabel = isStillOversized ? '压 缩 导 入' : '继 续 导 入';
            final description = isStillOversized
                ? '当前有 ${currentInspection.oversizedMediaCount} 张图片超出当前压缩规格。你可以调整压缩档位重新检查，或按当前档位压缩导入。'
                : '当前待导入图片已符合所选压缩规格，可以直接继续导入。';

            return Dialog(
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.zero,
              ),
              elevation: 0,
              child: Container(
                padding: const EdgeInsets.fromLTRB(32, 36, 32, 32),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.black12),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '导 入 图 片',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 2.0,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      bundleLabel,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black38,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      description,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 18),
                    for (final option in AppMediaCompressionLevel.values)
                      RadioListTile<Object?>(
                        value: option,
                        groupValue: currentSettings.compressionLevel,
                        onChanged: isUpdating
                            ? null
                            : (value) {
                                if (value is AppMediaCompressionLevel) {
                                  updateCompression(value);
                                }
                              },
                        title: Text(option.label),
                        activeColor: Colors.black87,
                        contentPadding: EdgeInsets.zero,
                        visualDensity: const VisualDensity(
                          horizontal: -4,
                          vertical: -4,
                        ),
                      ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: isUpdating
                                ? null
                                : () => Navigator.of(dialogContext).pop(true),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              decoration: const BoxDecoration(
                                color: Colors.black,
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                primaryLabel,
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
                            onTap: isUpdating
                                ? null
                                : () => Navigator.of(dialogContext).pop(false),
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
      },
    );
    return decision ?? false;
  }

  Future<bool?> _confirmApplyImportedSettings() async {
    final apply = await showDialog<bool>(
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
              border: Border.all(color: Colors.black12),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '导 入 设 置',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 2.0,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  '如果导入包内包含设置，可以选择是否同步应用到当前设备。无论是否应用，项目都会作为新项目导入。',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 32),
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () => Navigator.of(dialogContext).pop(true),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: const BoxDecoration(color: Colors.black),
                          alignment: Alignment.center,
                          child: const Text(
                            '一 并 应 用',
                            style: TextStyle(
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
                            '仅 导 入 项 目',
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
                const SizedBox(height: 12),
                InkWell(
                  onTap: () => Navigator.of(dialogContext).pop(null),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    alignment: Alignment.center,
                    child: const Text(
                      '取 消',
                      style: TextStyle(
                        color: Colors.black38,
                        fontSize: 13,
                        letterSpacing: 2.0,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
    return apply;
  }

  void _showPassiveHint(String message) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: Text(message, textAlign: TextAlign.center),
        duration: const Duration(milliseconds: 1400),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope<void>(
      canPop: !_isTransferFlowActive,
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F7F5),
        body: SafeArea(
          child: Column(
            children: [
              _buildTopBar(),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
                  children: [
                    _buildCompressionSection(),
                    const SizedBox(height: 40),
                    _buildImportExportSection(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          IconButton(
            onPressed: _isTransferFlowActive
                ? null
                : () => Navigator.of(context).pop(),
            icon: const Icon(
              Icons.arrow_back_ios_new,
              size: 18,
              color: Colors.black87,
            ),
          ),
          const Expanded(
            child: Center(
              child: Text(
                '设 置',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 4.0,
                  color: Colors.black87,
                ),
              ),
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildCompressionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '图片压缩',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          '控制后续写入图片时采用的压缩规格，不需要额外保存。',
          style: TextStyle(fontSize: 13, color: Color(0xFF8F8F8F), height: 1.6),
        ),
        const SizedBox(height: 18),
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.88),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.035),
                blurRadius: 18,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            children: [
              for (final option in AppMediaCompressionLevel.values)
                RadioListTile<Object?>(
                  value: option,
                  groupValue: _settings.compressionLevel,
                  onChanged: _isUpdatingCompression
                      ? null
                      : (value) {
                          if (value is AppMediaCompressionLevel) {
                            _updateCompression(value);
                          }
                        },
                  title: Text(
                    option.label,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                      letterSpacing: 0.2,
                    ),
                  ),
                  activeColor: Colors.black87,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                  visualDensity: const VisualDensity(
                    horizontal: -2,
                    vertical: -2,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildImportExportSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '项目数据导出 / 导入',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _importExportDisabled
              ? '当前平台暂不提供文件型导出 / 导入。'
              : '导出当前项目数据到系统文件位置，或从已保存的 bundle 目录导入为新项目。',
          style: const TextStyle(
            fontSize: 13,
            color: Color(0xFF8F8F8F),
            height: 1.6,
          ),
        ),
        const SizedBox(height: 18),
        Container(
          padding: const EdgeInsets.fromLTRB(18, 10, 18, 18),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.88),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.035),
                blurRadius: 18,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            children: [
              SwitchListTile(
                value: _settings.includeSettingsInExportsByDefault,
                onChanged: _importExportDisabled || _isUpdatingExportOption
                    ? null
                    : _updateExportOption,
                title: const Text(
                  '导出时包含设置',
                  style: TextStyle(fontSize: 14, color: Colors.black87),
                ),
                activeColor: Colors.black87,
                contentPadding: EdgeInsets.zero,
              ),
              const SizedBox(height: 6),
              _buildActionButton(
                label: _isExporting ? '导出中…' : '导出当前项目',
                onTap:
                    _importExportDisabled ||
                        !widget.canExportCurrentProject ||
                        _isExporting
                    ? null
                    : _exportProject,
              ),
              if (_lastExportReceipt != null) ...[
                const SizedBox(height: 12),
                _buildExportReceiptCard(_lastExportReceipt!),
              ],
              const SizedBox(height: 22),
              _buildActionButton(
                label: _isSelectingImportBundle ? '选择中…' : '选择导入包',
                onTap: _importExportDisabled || _isSelectingImportBundle
                    ? null
                    : _pickImportBundle,
                isPrimary: false,
              ),
              const SizedBox(height: 14),
              _buildActionButton(
                label: _isImporting ? '导入中…' : '导入为新项目',
                onTap:
                    _importExportDisabled ||
                        _isImporting ||
                        _selectedImportBundle == null
                    ? null
                    : _importProject,
              ),
              if (_selectedImportBundle != null) ...[
                const SizedBox(height: 12),
                _buildMetaText('待导入：${_selectedImportBundle!.displayPath}'),
              ],
              if (_lastImportedDisplayPath != null) ...[
                const SizedBox(height: 8),
                _buildMetaText('最近导入：$_lastImportedDisplayPath'),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required String label,
    required VoidCallback? onTap,
    bool isPrimary = true,
  }) {
    final enabled = onTap != null;
    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isPrimary
              ? (enabled ? Colors.black87 : Colors.black12)
              : Colors.transparent,
          border: isPrimary
              ? null
              : Border.all(
                  color: enabled
                      ? const Color(0xFF1F1F1F).withValues(alpha: 0.12)
                      : const Color(0xFF1F1F1F).withValues(alpha: 0.08),
                ),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            color: isPrimary
                ? (enabled ? Colors.white : Colors.black38)
                : (enabled ? Colors.black87 : Colors.black38),
            fontSize: 13,
            letterSpacing: 2.0,
          ),
        ),
      ),
    );
  }

  Widget _buildMetaText(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 12,
        color: Color(0xFF9C9C9C),
        height: 1.6,
      ),
    );
  }

  Widget _buildExportReceiptCard(ProjectBundleExportReceipt receipt) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 12, 12, 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F2EE),
        border: Border.all(
          color: const Color(0xFF1F1F1F).withValues(alpha: 0.08),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '导出地址',
                  style: TextStyle(
                    fontSize: 11,
                    color: Color(0xFF7C7A73),
                    letterSpacing: 1.4,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  receipt.displayPath,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.black87,
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          _buildCopyButton(receipt.copyablePath),
        ],
      ),
    );
  }

  Widget _buildCopyButton(String value) {
    return InkWell(
      onTap: () => _copyExportPath(value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.72),
          border: Border.all(
            color: const Color(0xFF1F1F1F).withValues(alpha: 0.10),
          ),
        ),
        child: const Text(
          '复制',
          style: TextStyle(
            fontSize: 11,
            color: Colors.black87,
            letterSpacing: 1.0,
          ),
        ),
      ),
    );
  }

  Future<void> _copyExportPath(String value) async {
    await Clipboard.setData(ClipboardData(text: value));
    if (!mounted) {
      return;
    }
    _showPassiveHint('已复制导出地址');
  }

  void _handleTransferFailure({
    required String debugContext,
    required String fallbackPrefix,
    required Object error,
  }) {
    if (error is ProjectBundleFileTransferException) {
      debugPrint('$debugContext: $error');
      if (mounted) {
        _showPassiveHint(_buildTransferFailureMessage(fallbackPrefix, error));
      }
      return;
    }

    debugPrint('$debugContext with unexpected error: $error');
    if (mounted) {
      _showPassiveHint(fallbackPrefix);
    }
  }

  String _buildTransferFailureMessage(
    String fallbackPrefix,
    ProjectBundleFileTransferException error,
  ) {
    if (error.isPermissionDenied) {
      return '$fallbackPrefix，需要文件存储权限';
    }
    final message = error.message?.trim();
    if (message == null || message.isEmpty) {
      return fallbackPrefix;
    }
    return '$fallbackPrefix：$message';
  }
}
