import 'package:echo/app/router/route_names.dart';
import 'package:echo/features/capture_feed/presentation/pages/capture_feed_module_page.dart';
import 'package:echo/features/curation/presentation/pages/curation_module_page.dart';
import 'package:echo/features/element/presentation/pages/element_module_page.dart';
import 'package:echo/features/notes/presentation/pages/notes_module_page.dart';
import 'package:echo/features/photo_import/presentation/pages/photo_import_module_page.dart';
import 'package:echo/features/project/presentation/pages/project_module_page.dart';
import 'package:echo/features/structure/presentation/pages/structure_module_page.dart';
import 'package:echo/features/timeline/presentation/pages/timeline_module_page.dart';
import 'package:flutter/widgets.dart';

final class AppRouter {
  const AppRouter._();

  static Map<String, WidgetBuilder> routes = {
    RouteNames.projectModule: (_) => const ProjectModulePage(),
    RouteNames.structureModule: (_) => const StructureModulePage(),
    RouteNames.elementModule: (_) => const ElementModulePage(),
    RouteNames.captureFeedModule: (_) => const CaptureFeedModulePage(),
    RouteNames.photoImportModule: (_) => const PhotoImportModulePage(),
    RouteNames.curationModule: (_) => const CurationModulePage(),
    RouteNames.notesModule: (_) => const NotesModulePage(),
    RouteNames.timelineModule: (_) => const TimelineModulePage(),
  };
}
