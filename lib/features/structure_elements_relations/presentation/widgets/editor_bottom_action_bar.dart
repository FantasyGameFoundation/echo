import 'package:flutter/material.dart';

enum EditorBottomActionTone { primary, destructive }

class EditorBottomActionBar extends StatelessWidget {
  const EditorBottomActionBar({
    super.key,
    required this.leftLabel,
    required this.leftKey,
    required this.leftTone,
    required this.leftEnabled,
    this.onLeftTap,
    this.rightLabel,
    this.rightKey,
    this.rightTone = EditorBottomActionTone.destructive,
    this.rightEnabled = true,
    this.onRightTap,
  });

  final String leftLabel;
  final Key leftKey;
  final EditorBottomActionTone leftTone;
  final bool leftEnabled;
  final VoidCallback? onLeftTap;
  final String? rightLabel;
  final Key? rightKey;
  final EditorBottomActionTone rightTone;
  final bool rightEnabled;
  final VoidCallback? onRightTap;

  bool get _hasRightAction => rightLabel != null && rightKey != null;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _ActionButton(
          label: leftLabel,
          buttonKey: leftKey,
          tone: leftTone,
          enabled: leftEnabled,
          width: _hasRightAction ? 140 : 160,
          onTap: onLeftTap,
        ),
        if (_hasRightAction) ...[
          const SizedBox(width: 24),
          _ActionButton(
            label: rightLabel!,
            buttonKey: rightKey!,
            tone: rightTone,
            enabled: rightEnabled,
            width: 140,
            onTap: onRightTap,
          ),
        ],
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.buttonKey,
    required this.tone,
    required this.enabled,
    required this.width,
    this.onTap,
  });

  final String label;
  final Key buttonKey;
  final EditorBottomActionTone tone;
  final bool enabled;
  final double width;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final palette = _paletteForTone(tone: tone, enabled: enabled);

    return Material(
      color: palette.backgroundColor,
      borderRadius: BorderRadius.circular(2),
      child: InkWell(
        key: buttonKey,
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(2),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          width: width,
          height: 50,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(2),
            border: Border.all(color: palette.borderColor),
            boxShadow: enabled
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ]
                : const <BoxShadow>[],
          ),
          child: Text(
            label,
            style: TextStyle(
              color: palette.foregroundColor,
              fontSize: 12,
              fontWeight: FontWeight.w500,
              letterSpacing: 4.6,
            ),
          ),
        ),
      ),
    );
  }

  _ActionPalette _paletteForTone({
    required EditorBottomActionTone tone,
    required bool enabled,
  }) {
    switch (tone) {
      case EditorBottomActionTone.primary:
        if (!enabled) {
          return const _ActionPalette(
            backgroundColor: Color(0xFFE7E7EB),
            foregroundColor: Color(0xFF9F9FA6),
            borderColor: Color(0xFFE0E0E5),
          );
        }
        return const _ActionPalette(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          borderColor: Colors.black,
        );
      case EditorBottomActionTone.destructive:
        if (!enabled) {
          return const _ActionPalette(
            backgroundColor: Color(0xFFF7F7F7),
            foregroundColor: Color(0xFFA4A4A4),
            borderColor: Color(0xFFE2E2E2),
          );
        }
        return const _ActionPalette(
          backgroundColor: Colors.white,
          foregroundColor: Color(0xFF2E2E2E),
          borderColor: Color(0xFFD9D9D9),
        );
    }
  }
}

class _ActionPalette {
  const _ActionPalette({
    required this.backgroundColor,
    required this.foregroundColor,
    required this.borderColor,
  });

  final Color backgroundColor;
  final Color foregroundColor;
  final Color borderColor;
}
