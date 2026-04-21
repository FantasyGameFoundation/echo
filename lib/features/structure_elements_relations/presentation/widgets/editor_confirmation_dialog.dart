import 'package:flutter/material.dart';

Future<bool> showEditorConfirmationDialog({
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

Future<bool> showDiscardUnsavedChangesDialog({required BuildContext context}) {
  return showEditorConfirmationDialog(
    context: context,
    title: '放 弃 更 改',
    content: '当前页面仍有未保存改动，返回后这些更改将丢失。',
    actionText: '放 弃',
  );
}
