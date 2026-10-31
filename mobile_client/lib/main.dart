import 'package:flutter/material.dart';
import 'package:mobile_client/app/app.dart';
import 'package:mobile_client/core/di/injection.dart';
import 'package:mobile_client/core/rust/api.dart';
import 'package:mobile_client/core/rust/api/notes.dart';
import 'package:mobile_client/core/rust/api/short_notes.dart';
import 'package:mobile_client/core/rust/api/short_tasks.dart';
import 'package:mobile_client/core/rust/frb_generated.dart';
import 'package:mobile_client/shared/widgets/search_filters.dart';
import 'package:path_provider/path_provider.dart';

void main() async {
  // Guarantees Flutter bindings are ready before async/native calls
  WidgetsFlutterBinding.ensureInitialized();

  await RustLib.init();
  final appDocDir = await getApplicationSupportDirectory();
  final core = await NoteCore.open(basePath: appDocDir.path);
  getIt.registerSingleton<NoteCore>(core);

  getIt.registerSingleton<ShortNotesApi>(core.shortNotes());
  getIt.registerSingleton<NotesApi>(core.notes());
  getIt.registerSingleton<SearchFilters>(SearchFilters(core.tags()));
  getIt.registerSingleton<ShortTasksApi>(core.shortTasks());

  setupLocator();
  runApp(const MyApp());
}
