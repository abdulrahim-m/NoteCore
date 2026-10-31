import 'package:flutter/material.dart';
import 'package:mobile_client/shared/text_direction_utils.dart';

/// Bottom bar to add one-line items. Stays focused after adding so several
/// items can be entered in a row.
class ItemComposer extends StatefulWidget {
  const ItemComposer({
    super.key,
    required this.hint,
    required this.sendTooltip,
    required this.onAdd,
  });

  final String hint;
  final String sendTooltip;
  final Future<void> Function(String text) onAdd;

  @override
  State<ItemComposer> createState() => _ItemComposerState();
}

class _ItemComposerState extends State<ItemComposer> {
  final _text = TextEditingController();
  TextDirection? _dir;

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  Future<void> _add() async {
    final value = _text.text.trim();
    if (value.isEmpty) return;
    _text.clear();
    setState(() => _dir = null);
    await widget.onAdd(value);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Material(
      color: cs.surface,
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.5)),
          ),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 4, 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _text,
                    textDirection: _dir,
                    textInputAction: TextInputAction.send,
                    textCapitalization: TextCapitalization.sentences,
                    // onEditingComplete (not onSubmitted) keeps the keyboard
                    // open so several items can be added in a row.
                    onEditingComplete: _add,
                    onChanged: (t) {
                      final dir = detectTextDirection(t);
                      if (dir != _dir) setState(() => _dir = dir);
                    },
                    decoration: InputDecoration(
                      hintText: widget.hint,
                      isDense: true,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: widget.sendTooltip,
                  onPressed: _add,
                  icon: const Icon(Icons.send),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
