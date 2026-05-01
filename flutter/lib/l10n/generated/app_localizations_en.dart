// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Control Hub';

  @override
  String get navigationCategories => 'Categories';

  @override
  String get navHome => 'Home';

  @override
  String get navAudio => 'Audio deck';

  @override
  String get homeTitle => 'Welcome center';

  @override
  String get homeDescription =>
      'Choose a module from the side menu to navigate through the app areas.';

  @override
  String get homePlaceholder => 'Select an area to begin';

  @override
  String get audioPageEyebrow => 'Live panel';

  @override
  String get audioPageTitle => 'Real-time audio';

  @override
  String get audioPageDescription =>
      'Choose an output and follow, in a single screen, which apps are using that audio right now.';

  @override
  String get audioHeroBadge => 'Quick studio';

  @override
  String get audioHeroTitle => 'Control sound without guessing';

  @override
  String get audioHeroDescription =>
      'See the active output, the apps currently playing, and the volume of each session in a clearer control deck.';

  @override
  String get audioHeroDevicesMetric => 'Ready outputs';

  @override
  String get audioHeroAppsMetric => 'Tracked apps';

  @override
  String get audioHeroMutedMetric => 'Muted';

  @override
  String get audioSelectorTitle => 'Sound destination';

  @override
  String get audioSelectorDescription =>
      'Choose where you want to inspect this computer\'s audio.';

  @override
  String get audioSelectorFieldLabel => 'Audio output';

  @override
  String get audioSelectorFieldHint => 'Select an output';

  @override
  String audioSelectorDevicesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count outputs available',
      one: '1 output available',
    );
    return '$_temp0';
  }

  @override
  String get audioSelectorRefresh => 'Refresh outputs';

  @override
  String get audioSelectorReloadSessions => 'Refresh apps';

  @override
  String get audioSelectorDeviceFallback => 'Unnamed output';

  @override
  String get audioOverviewTitle => 'Quick read';

  @override
  String get audioOverviewEmpty =>
      'Choose an output to see a live summary of apps and overall status.';

  @override
  String get audioOverviewDeviceId => 'Identifier';

  @override
  String audioOverviewAppsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count apps',
      one: '1 app',
    );
    return '$_temp0';
  }

  @override
  String get audioOverviewMuted => 'There are muted apps';

  @override
  String get audioOverviewLive => 'Live connection';

  @override
  String get audioSessionsTitle => 'Apps with sound';

  @override
  String get audioSessionsDescription =>
      'Each card shows volume, current activity, and whether the session is muted.';

  @override
  String get audioSessionsLiveChip => 'Live updates';

  @override
  String get audioSessionsEmptyName => 'Unnamed app';

  @override
  String audioSessionsIdLabel(String id) {
    return 'ID $id';
  }

  @override
  String get audioLoadingDevicesTitle => 'Loading outputs';

  @override
  String get audioLoadingDevicesMessage =>
      'Looking for the audio destinations available on this computer.';

  @override
  String get audioDevicesErrorTitle => 'Could not load outputs';

  @override
  String get audioDevicesErrorMessage => 'Try again in a moment.';

  @override
  String get audioDevicesEmptyTitle => 'No outputs found';

  @override
  String get audioDevicesEmptyMessage =>
      'Connect an audio device and refresh the list to continue.';

  @override
  String get audioSelectPromptTitle => 'Choose an output to continue';

  @override
  String get audioSelectPromptMessage =>
      'As soon as you pick an output, the apps with sound will appear here.';

  @override
  String get audioSessionsLoadingTitle => 'Refreshing apps';

  @override
  String get audioSessionsLoadingMessage =>
      'Fetching the audio sessions for the selected output.';

  @override
  String get audioSessionsErrorTitle => 'Could not load apps';

  @override
  String get audioSessionsErrorMessage =>
      'Try another output or refresh the list.';

  @override
  String get audioSessionsEmptyTitle => 'No apps with visible audio';

  @override
  String get audioSessionsEmptyMessage =>
      'When an app starts playing through this output, it will show up in this panel.';

  @override
  String get audioSessionActive => 'Now playing';

  @override
  String get audioSessionInactive => 'Idle';

  @override
  String get audioSessionExpired => 'Closed';

  @override
  String get audioSessionMuted => 'Muted';

  @override
  String get audioSessionUnmuted => 'Audio active';
}
