import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Offset of the first character of the line containing [offset].
int lineStartOf(String text, int offset) =>
    offset <= 0 ? 0 : text.lastIndexOf('\n', offset - 1) + 1;

/// Offset just past the last character of the line containing [offset].
int lineEndOf(String text, int offset) {
  final i = text.indexOf('\n', offset);
  return i == -1 ? text.length : i;
}

/// Converts between the markdown that is stored in the database and the
/// "display text" that lives inside the editor.
///
/// The editor shows list markers as real glyphs so the effect is visible while
/// typing, without needing widgets inside the text field:
///
///     markdown            display
///     - item              • item        (◦ / ▪)
///     - [ ] task          ☐ task
///     - [x] task          ☑ task
///       - sub item        ◦ sub item    (1 leading space per level)
///
/// Headers (`#`, `##`, `###`) stay as typed and are only styled.
class MarkdownCodec {
  MarkdownCodec._();

  static const unchecked = '☐';
  static const checked = '☑';

  /// Bullet glyph for a nesting level (= number of leading spaces).
  static String bullet(int level) => level <= 0
      ? '•'
      : level == 1
      ? '◦'
      : '▪';

  /// A list line in display form: indent, glyph, one space, content.
  static final RegExp displayItem = RegExp(r'^( *)(•|◦|▪|☐|☑) (.*)$');

  static final RegExp _mdItem = RegExp(
    r'^([ \t]*)[-*+] (?:\[([ xX])\](?: |$))?(.*)$',
  );

  static String fromMarkdown(String md) {
    final lines = md.replaceAll('\r\n', '\n').split('\n');
    return lines.map(_lineFromMd).join('\n');
  }

  static String _lineFromMd(String line) {
    final m = _mdItem.firstMatch(line);
    if (m == null) return line;
    final level = m.group(1)!.replaceAll('\t', '  ').length ~/ 2;
    final box = m.group(2);
    final glyph = box == null ? bullet(level) : (box == ' ' ? unchecked : checked);
    return '${' ' * level}$glyph ${m.group(3)}';
  }

  static String toMarkdown(String display) =>
      display.split('\n').map(_lineToMd).join('\n');

  static String _lineToMd(String line) {
    final m = displayItem.firstMatch(line);
    if (m == null) return line;
    final glyph = m.group(2)!;
    final marker = glyph == unchecked
        ? '- [ ] '
        : glyph == checked
        ? '- [x] '
        : '- ';
    return '${'  ' * m.group(1)!.length}$marker${m.group(3)}';
  }

  /// Makes sure a bullet line uses the glyph that matches its indentation.
  /// Never changes the length of the line.
  static String normalizeLine(String line) {
    final m = displayItem.firstMatch(line);
    if (m == null) return line;
    final glyph = m.group(2)!;
    if (glyph == unchecked || glyph == checked) return line;
    final want = bullet(m.group(1)!.length);
    return glyph == want ? line : '${m.group(1)}$want ${m.group(3)}';
  }
}

/// A text controller that styles markdown as you type and offers the line
/// operations used by the toolbar. Its [text] is the *display* text, use
/// [markdown] to get what should be stored.
class MarkdownTextController extends TextEditingController {
  MarkdownTextController({super.text});

  static const _maxIndent = 6;
  static final RegExp _head = RegExp(r'^(#{1,3}) (.*)$');

  String get markdown => MarkdownCodec.toMarkdown(text);

  // ------------------------------------------------------------ rendering
  @override
  TextSpan buildTextSpan({
    required BuildContext context,
    TextStyle? style,
    required bool withComposing,
  }) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final base = style ?? theme.textTheme.bodyLarge ?? const TextStyle();
    final fs = base.fontSize ?? 16;
    final dim = cs.onSurface.withValues(alpha: 0.4);

    final lines = text.split('\n');
    final spans = <InlineSpan>[];

    for (var i = 0; i < lines.length; i++) {
      final line = lines[i];
      final nl = i < lines.length - 1 ? '\n' : '';

      final head = _head.firstMatch(line);
      if (head != null) {
        final level = head.group(1)!.length;
        final size = fs * (level == 1 ? 1.6 : (level == 2 ? 1.35 : 1.15));
        final hs = base.copyWith(fontSize: size, fontWeight: FontWeight.w700);
        spans.add(
          TextSpan(text: '${head.group(1)} ', style: hs.copyWith(color: dim)),
        );
        spans.add(TextSpan(text: '${head.group(2)}$nl', style: hs));
        continue;
      }

      final item = MarkdownCodec.displayItem.firstMatch(line);
      if (item != null) {
        final indent = item.group(1)!;
        final glyph = item.group(2)!;
        final isBox =
            glyph == MarkdownCodec.unchecked || glyph == MarkdownCodec.checked;
        final done = glyph == MarkdownCodec.checked;
        if (indent.isNotEmpty) {
          spans.add(
            TextSpan(
              text: indent,
              style: base.copyWith(letterSpacing: fs * 0.9),
            ),
          );
        }
        spans.add(
          TextSpan(
            text: glyph,
            style: base.copyWith(
              color: cs.primary,
              fontWeight: FontWeight.w700,
              fontSize: isBox ? fs * 1.25 : fs,
            ),
          ),
        );
        spans.add(TextSpan(text: ' ', style: base));
        spans.add(
          TextSpan(
            text: '${item.group(3)}$nl',
            style: done
                ? base.copyWith(
                    decoration: TextDecoration.lineThrough,
                    color: dim,
                  )
                : base,
          ),
        );
        continue;
      }

      spans.add(TextSpan(text: '$line$nl', style: base));
    }

    return TextSpan(style: base, children: spans);
  }

  // ------------------------------------------------------- toolbar actions
  /// Cycles the line(s) through `#` → `##` → `###` → plain.
  void toggleHeading() => _editSelectedLines((line) {
    if (MarkdownCodec.displayItem.hasMatch(line)) return line;
    final m = _head.firstMatch(line);
    if (m == null) return '# $line';
    final n = m.group(1)!.length;
    return n >= 3 ? m.group(2)! : '${'#' * (n + 1)} ${m.group(2)}';
  });

  void toggleBullet() => _toggleList(checklist: false);

  void toggleChecklist() => _toggleList(checklist: true);

  void _toggleList({required bool checklist}) => _editSelectedLines((line) {
    final m = MarkdownCodec.displayItem.firstMatch(line);
    if (m != null) {
      final glyph = m.group(2)!;
      final isBox =
          glyph == MarkdownCodec.unchecked || glyph == MarkdownCodec.checked;
      if (isBox == checklist) return m.group(3)!; // same kind: remove marker
      final indent = m.group(1)!;
      final g = checklist
          ? MarkdownCodec.unchecked
          : MarkdownCodec.bullet(indent.length);
      return '$indent$g ${m.group(3)}';
    }
    var body = line;
    final h = _head.firstMatch(line);
    if (h != null) body = h.group(2)!;
    final lead = RegExp(r'^ *').stringMatch(body)!;
    final rest = body.substring(lead.length);
    final g = checklist
        ? MarkdownCodec.unchecked
        : MarkdownCodec.bullet(lead.length);
    return '$lead$g $rest';
  });

  void indent() => _editSelectedLines((line) {
    final m = MarkdownCodec.displayItem.firstMatch(line);
    if (m == null || m.group(1)!.length >= _maxIndent) return line;
    return MarkdownCodec.normalizeLine(' $line');
  });

  void outdent() => _editSelectedLines((line) {
    final m = MarkdownCodec.displayItem.firstMatch(line);
    if (m == null || m.group(1)!.isEmpty) return line;
    return MarkdownCodec.normalizeLine(line.substring(1));
  });

  /// If the caret sits right next to a ☐/☑ glyph (i.e. the user tapped it),
  /// flips it and returns true.
  bool toggleCheckboxAtCaret() {
    final sel = selection;
    if (!sel.isValid || !sel.isCollapsed) return false;
    final t = text;
    final off = sel.baseOffset;
    final ls = lineStartOf(t, off);
    final le = lineEndOf(t, off);
    final m = MarkdownCodec.displayItem.firstMatch(t.substring(ls, le));
    if (m == null) return false;
    final glyph = m.group(2)!;
    if (glyph != MarkdownCodec.unchecked && glyph != MarkdownCodec.checked) {
      return false;
    }
    final gs = ls + m.group(1)!.length;
    if (off != gs && off != gs + 1) return false;
    final flipped = glyph == MarkdownCodec.unchecked
        ? MarkdownCodec.checked
        : MarkdownCodec.unchecked;
    value = value.copyWith(
      text: t.replaceRange(gs, gs + 1, flipped),
      composing: TextRange.empty,
    );
    return true;
  }

  /// Applies [transform] to every line touched by the selection and keeps the
  /// selection on the same content.
  void _editSelectedLines(String Function(String line) transform) {
    final t = text;
    final sel = selection.isValid
        ? selection
        : TextSelection.collapsed(offset: t.length);
    final lines = t.split('\n');
    final starts = <int>[];
    var p = 0;
    for (final l in lines) {
      starts.add(p);
      p += l.length + 1;
    }
    int lineOf(int off) {
      var i = 0;
      while (i + 1 < lines.length && starts[i + 1] <= off) {
        i++;
      }
      return i;
    }

    final first = lineOf(sel.start);
    final last = lineOf(sel.end);
    final out = <String>[];
    var base = sel.baseOffset;
    var extent = sel.extentOffset;

    for (var i = 0; i < lines.length; i++) {
      final old = lines[i];
      final neu = (i >= first && i <= last) ? transform(old) : old;
      out.add(neu);
      final delta = neu.length - old.length;
      if (delta == 0) continue;
      base += _shift(sel.baseOffset, starts[i], delta);
      extent += _shift(sel.extentOffset, starts[i], delta);
    }

    value = value.copyWith(
      text: out.join('\n'),
      selection: TextSelection(baseOffset: base, extentOffset: extent),
      composing: TextRange.empty,
    );
  }

  /// How far an offset moves when the line starting at [lineStart] changes
  /// length by [delta], never moves it in front of the line start.
  static int _shift(int offset, int lineStart, int delta) {
    if (offset < lineStart) return 0;
    if (delta >= 0) return delta;
    final floor = lineStart - offset;
    return floor > delta ? floor : delta;
  }
}

/// Makes typing behave like a list-aware editor.
class MarkdownInputFormatter extends TextInputFormatter {
  static final RegExp _dash = RegExp(r'^( *)- ');
  static final RegExp _dashBox = RegExp(r'^( *)(?:•|◦|▪) \[([ xX]?)\] ');

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (!newValue.selection.isValid || !newValue.selection.isCollapsed) {
      return newValue;
    }
    // Never rewrite text while the IME is composing a word.
    if (newValue.composing.isValid && !newValue.composing.isCollapsed) {
      return newValue;
    }
    final grew = newValue.text.length - oldValue.text.length;
    if (grew == 1) {
      return _enter(oldValue, newValue) ?? _typed(newValue);
    }
    if (grew == -1) return _backspace(oldValue, newValue) ?? newValue;
    if (grew > 1) return _pasted(oldValue, newValue) ?? newValue;
    return newValue;
  }

  TextEditingValue? _enter(TextEditingValue old, TextEditingValue neu) {
    final p = neu.selection.baseOffset - 1;
    if (p < 0 || neu.text[p] != '\n') return null;
    if (!old.selection.isValid ||
        !old.selection.isCollapsed ||
        old.selection.baseOffset != p) {
      return null;
    }
    if (neu.text.replaceRange(p, p + 1, '') != old.text) return null;

    final t = old.text;
    final ls = lineStartOf(t, p);
    final le = lineEndOf(t, p);
    final m = MarkdownCodec.displayItem.firstMatch(t.substring(ls, le));
    if (m == null) return null;
    final indent = m.group(1)!;
    if (p - ls < indent.length + 2) return null; // caret is before the marker

    if (m.group(3)!.isEmpty) {
      // Empty item: step out one level, or end the list.
      final newLine = indent.isNotEmpty
          ? MarkdownCodec.normalizeLine(t.substring(ls + 1, le))
          : '';
      return TextEditingValue(
        text: t.replaceRange(ls, le, newLine),
        selection: TextSelection.collapsed(offset: ls + newLine.length),
      );
    }

    final glyph = m.group(2)!;
    final marker =
        '$indent${glyph == MarkdownCodec.checked ? MarkdownCodec.unchecked : glyph} ';
    return TextEditingValue(
      text: neu.text.replaceRange(p + 1, p + 1, marker),
      selection: TextSelection.collapsed(offset: p + 1 + marker.length),
    );
  }

  TextEditingValue? _backspace(TextEditingValue old, TextEditingValue neu) {
    if (!old.selection.isValid || !old.selection.isCollapsed) return null;
    final d = neu.selection.baseOffset;
    if (d < 0 || d != old.selection.baseOffset - 1) return null;
    if (old.text.replaceRange(d, d + 1, '') != neu.text) return null;

    final t = old.text;
    if (t[d] != ' ') return null;
    final ls = lineStartOf(t, d);
    final le = lineEndOf(t, d);
    final m = MarkdownCodec.displayItem.firstMatch(t.substring(ls, le));
    if (m == null) return null;
    final indent = m.group(1)!.length;
    if (d != ls + indent + 1) return null; // not the space after the glyph

    return TextEditingValue(
      text: t.replaceRange(ls + indent, ls + indent + 2, ''),
      selection: TextSelection.collapsed(offset: ls + indent),
    );
  }

  TextEditingValue _typed(TextEditingValue neu) {
    final c = neu.selection.baseOffset;
    final t = neu.text;
    final ls = lineStartOf(t, c);
    final le = lineEndOf(t, c);
    final line = t.substring(ls, le);

    final dash = _dash.firstMatch(line);
    if (dash != null && c == ls + dash.end) {
      final indent = dash.group(1)!;
      final repl = '$indent${MarkdownCodec.bullet(indent.length)} ';
      return neu.copyWith(text: t.replaceRange(ls, ls + dash.end, repl));
    }

    final box = _dashBox.firstMatch(line);
    if (box != null && c == ls + box.end) {
      final mark = box.group(2)!.trim().isEmpty
          ? MarkdownCodec.unchecked
          : MarkdownCodec.checked;
      final repl = '${box.group(1)}$mark ';
      return TextEditingValue(
        text: t.replaceRange(ls, ls + box.end, repl),
        selection: TextSelection.collapsed(offset: ls + repl.length),
      );
    }

    final norm = MarkdownCodec.normalizeLine(line);
    if (norm != line) {
      return neu.copyWith(text: t.replaceRange(ls, le, norm));
    }
    return neu;
  }

  TextEditingValue? _pasted(TextEditingValue old, TextEditingValue neu) {
    if (!old.selection.isValid) return null;
    final start = old.selection.start;
    final end = neu.selection.baseOffset;
    final tail = old.text.substring(old.selection.end);
    if (end < start ||
        !neu.text.endsWith(tail) ||
        neu.text.length - tail.length != end ||
        neu.text.substring(0, start) != old.text.substring(0, start)) {
      return null;
    }

    final inserted = neu.text.substring(start, end);
    final atLineStart = start == 0 || neu.text[start - 1] == '\n';
    String converted;
    if (atLineStart) {
      converted = MarkdownCodec.fromMarkdown(inserted);
    } else {
      final i = inserted.indexOf('\n');
      converted = i == -1
          ? inserted
          : inserted.substring(0, i + 1) +
                MarkdownCodec.fromMarkdown(inserted.substring(i + 1));
    }
    if (converted == inserted) return null;
    return TextEditingValue(
      text: neu.text.replaceRange(start, end, converted),
      selection: TextSelection.collapsed(offset: start + converted.length),
    );
  }
}
