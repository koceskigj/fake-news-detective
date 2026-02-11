import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../state/app_state_scope.dart';
import '../widgets/branded_app_bar.dart';

class StudentSettingsScreen extends StatelessWidget {
  const StudentSettingsScreen({super.key});

  Future<void> _showLanguageSheet(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final appState = AppStateScope.of(context);
    final current = appState.studentLocaleCode; // "en" | "mk"

    final selected = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (sheetContext) {
        String temp = current;

        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      l10n.selectLanguage,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                    ),
                  ),
                  const SizedBox(height: 12),

                  RadioListTile<String>(
                    value: 'en',
                    groupValue: temp,
                    onChanged: (v) => setSheetState(() => temp = v ?? 'en'),
                    title: Text(l10n.english),
                  ),
                  RadioListTile<String>(
                    value: 'mk',
                    groupValue: temp,
                    onChanged: (v) => setSheetState(() => temp = v ?? 'mk'),
                    title: Text(l10n.macedonian),
                  ),

                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () => Navigator.pop(sheetContext),
                          child: Text(l10n.cancel),
                        ),
                      ),
                      Expanded(
                        child: FilledButton(
                          onPressed: () => Navigator.pop(sheetContext, temp),
                          child: Text(l10n.confirm),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );

    if (selected == null) return;
    await appState.setStudentLocale(selected);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: BrandedAppBar(),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              child: ListTile(
                leading: const Icon(Icons.language),
                title: Text(l10n.language),
                subtitle: Text('${l10n.english} / ${l10n.macedonian}'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _showLanguageSheet(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
