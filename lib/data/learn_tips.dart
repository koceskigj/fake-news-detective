import 'package:flutter/widgets.dart';

import '../l10n/app_localizations.dart';


List<String> learnTips(BuildContext context) {
  final l10n = AppLocalizations.of(context)!;
  return [
    l10n.tip0,
    l10n.tip1,
    l10n.tip2,
    l10n.tip3,
    l10n.tip4,
    l10n.tip5,
    l10n.tip6,
    l10n.tip7,
  ];
}
