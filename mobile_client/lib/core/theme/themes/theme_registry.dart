import 'package:mobile_client/core/theme/themes/aqua.dart';
import 'package:mobile_client/core/theme/themes/base.dart';
import 'package:mobile_client/core/theme/themes/forest.dart';
import 'package:mobile_client/core/theme/themes/neutral.dart';
import 'package:mobile_client/core/theme/themes/rust.dart';

/// A theme the user can pick: a stable [id] (from settings), a
/// display [name] and its colors.
class AppThemeOption {
  AppThemeOption(this.id, this.name, this.colors);

  final String id;
  final String name;
  final AppColors colors;
}

const defaultThemeId = 'rust';

/// Every theme of the app. To add one: write a class implementing
/// [AppColors] (copy `forest.dart`) and add a line here. The settings page
/// shows it automatically.
final List<AppThemeOption> appThemeOptions = [
  AppThemeOption('rust', 'Rust', RustThemeColors()),
  AppThemeOption('aqua', 'Aqua', AquaThemeColors()),
  AppThemeOption('forest', 'Forest', ForestThemeColors()),
  AppThemeOption('neutral', 'Neutral', NeutralThemeColors()),
];

AppThemeOption themeById(String id) => appThemeOptions.firstWhere(
  (t) => t.id == id,
  orElse: () => appThemeOptions.firstWhere((t) => t.id == defaultThemeId),
);
