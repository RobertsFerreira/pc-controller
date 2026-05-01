import 'package:flutter/widgets.dart';
import 'package:pc_remote_control/l10n/generated/app_localizations.dart';

extension L10nContextX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this)!;
}
