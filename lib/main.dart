import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'viewmodels/library_view_model.dart';
import 'views/library_screen.dart';

void main() {
  runApp(const UniversityLibraryApp());
}

class UniversityLibraryApp extends StatefulWidget {
  const UniversityLibraryApp({super.key});

  @override
  State<UniversityLibraryApp> createState() => _UniversityLibraryAppState();
}

class _UniversityLibraryAppState extends State<UniversityLibraryApp> {
  late final LibraryViewModel _libraryViewModel;

  @override
  void initState() {
    super.initState();
    _libraryViewModel = LibraryViewModel();
  }

  @override
  void dispose() {
    _libraryViewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'University Library System',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,

      home: LibraryScreen(viewModel: _libraryViewModel),
    );
  }
}