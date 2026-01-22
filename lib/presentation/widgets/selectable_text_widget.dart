import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Reusable selectable text widget with copy functionality
class SelectableTextWidget extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final bool showCopyButton;
  final String? copyMessage;

  const SelectableTextWidget({
    super.key,
    required this.text,
    this.style,
    this.textAlign,
    this.maxLines,
    this.showCopyButton = false,
    this.copyMessage,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: SelectableText(
            text,
            style: style,
            textAlign: textAlign,
            maxLines: maxLines,
            toolbarOptions: const ToolbarOptions(
              copy: true,
              selectAll: true,
              cut: false,
              paste: false,
            ),
          ),
        ),
        if (showCopyButton)
          IconButton(
            icon: const Icon(Icons.copy, size: 18),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: text));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(copyMessage ?? 'Copied to clipboard'),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            tooltip: 'Copy',
          ),
      ],
    );
  }
}

/// Selectable text field (read-only, selectable)
class SelectableTextField extends StatelessWidget {
  final String? label;
  final String? value;
  final IconData? prefixIcon;
  final bool showCopyButton;
  final String? copyMessage;

  const SelectableTextField({
    super.key,
    this.label,
    this.value,
    this.prefixIcon,
    this.showCopyButton = true,
    this.copyMessage,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: value,
      readOnly: true,
      enableInteractiveSelection: true,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
        suffixIcon: showCopyButton && value != null
            ? IconButton(
                icon: const Icon(Icons.copy, size: 18),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: value!));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(copyMessage ?? 'Copied to clipboard'),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
                tooltip: 'Copy',
              )
            : null,
      ),
    );
  }
}

