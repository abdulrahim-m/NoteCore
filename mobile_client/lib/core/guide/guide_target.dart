import 'package:flutter/widgets.dart';

/// Marks a tab's page so [GuideTarget]s inside register under that tab
/// (every tab stays alive in the bottom navigation, so ids must not clash).
class GuideScope extends InheritedWidget {
  const GuideScope({super.key, required this.id, required super.child});

  final String id;

  static String? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<GuideScope>()?.id;

  @override
  bool updateShouldNotify(GuideScope old) => id != old.id;
}

/// Where the guide finds the widgets it highlights.
abstract final class GuideRegistry {
  static final Map<String, GlobalKey> _keys = {};

  static GlobalKey? find(String scope, String id) => _keys['$scope/$id'];
}

/// Wrap any widget in `GuideTarget` and a guide step with `target: 'search'`
/// will highlight it. Costs nothing when no guide runs. Do not put it 
/// directly under an Expanded/Positioned, wrap it inside instead.
class GuideTarget extends StatefulWidget {
  const GuideTarget({super.key, required this.id, required this.child});

  final String id;
  final Widget child;

  @override
  State<GuideTarget> createState() => _GuideTargetState();
}

class _GuideTargetState extends State<GuideTarget> {
  final _key = GlobalKey();
  String? _name;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _unregister();
    final scope = GuideScope.maybeOf(context);
    if (scope != null) {
      _name = '$scope/${widget.id}';
      GuideRegistry._keys[_name!] = _key;
    }
  }

  void _unregister() {
    // A replacement widget may already have taken the name over.
    if (_name != null && GuideRegistry._keys[_name] == _key) {
      GuideRegistry._keys.remove(_name);
    }
  }

  @override
  void dispose() {
    _unregister();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      KeyedSubtree(key: _key, child: widget.child);
}
