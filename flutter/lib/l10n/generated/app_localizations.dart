import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_pt.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('pt'),
  ];

  /// Application title
  ///
  /// In en, this message translates to:
  /// **'Control Hub'**
  String get appTitle;

  /// Side menu section title
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get navigationCategories;

  /// Home module title
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// Audio module title
  ///
  /// In en, this message translates to:
  /// **'Audio deck'**
  String get navAudio;

  /// Home page title
  ///
  /// In en, this message translates to:
  /// **'Welcome center'**
  String get homeTitle;

  /// Home page description
  ///
  /// In en, this message translates to:
  /// **'Choose a module from the side menu to navigate through the app areas.'**
  String get homeDescription;

  /// Home page placeholder text
  ///
  /// In en, this message translates to:
  /// **'Select an area to begin'**
  String get homePlaceholder;

  /// Audio page eyebrow
  ///
  /// In en, this message translates to:
  /// **'Live panel'**
  String get audioPageEyebrow;

  /// Audio page title
  ///
  /// In en, this message translates to:
  /// **'Real-time audio'**
  String get audioPageTitle;

  /// Audio page description
  ///
  /// In en, this message translates to:
  /// **'Choose an output and follow, in a single screen, which apps are using that audio right now.'**
  String get audioPageDescription;

  /// Audio hero badge
  ///
  /// In en, this message translates to:
  /// **'Quick studio'**
  String get audioHeroBadge;

  /// Audio hero title
  ///
  /// In en, this message translates to:
  /// **'Control sound without guessing'**
  String get audioHeroTitle;

  /// Audio hero description
  ///
  /// In en, this message translates to:
  /// **'See the active output, the apps currently playing, and the volume of each session in a clearer control deck.'**
  String get audioHeroDescription;

  /// Metric label for devices
  ///
  /// In en, this message translates to:
  /// **'Ready outputs'**
  String get audioHeroDevicesMetric;

  /// Metric label for apps
  ///
  /// In en, this message translates to:
  /// **'Tracked apps'**
  String get audioHeroAppsMetric;

  /// Metric label for muted sessions
  ///
  /// In en, this message translates to:
  /// **'Muted'**
  String get audioHeroMutedMetric;

  /// Audio selector card title
  ///
  /// In en, this message translates to:
  /// **'Sound destination'**
  String get audioSelectorTitle;

  /// Audio selector card description
  ///
  /// In en, this message translates to:
  /// **'Choose where you want to inspect this computer\'s audio.'**
  String get audioSelectorDescription;

  /// Audio selector field label
  ///
  /// In en, this message translates to:
  /// **'Audio output'**
  String get audioSelectorFieldLabel;

  /// Audio selector field hint
  ///
  /// In en, this message translates to:
  /// **'Select an output'**
  String get audioSelectorFieldHint;

  /// Number of outputs available
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 output available} other{{count} outputs available}}'**
  String audioSelectorDevicesCount(int count);

  /// Refresh outputs button
  ///
  /// In en, this message translates to:
  /// **'Refresh outputs'**
  String get audioSelectorRefresh;

  /// Reload sessions button
  ///
  /// In en, this message translates to:
  /// **'Refresh apps'**
  String get audioSelectorReloadSessions;

  /// Fallback text for unnamed output device
  ///
  /// In en, this message translates to:
  /// **'Unnamed output'**
  String get audioSelectorDeviceFallback;

  /// Overview card title
  ///
  /// In en, this message translates to:
  /// **'Quick read'**
  String get audioOverviewTitle;

  /// Overview empty state
  ///
  /// In en, this message translates to:
  /// **'Choose an output to see a live summary of apps and overall status.'**
  String get audioOverviewEmpty;

  /// Label for device id
  ///
  /// In en, this message translates to:
  /// **'Identifier'**
  String get audioOverviewDeviceId;

  /// Apps count in overview
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 app} other{{count} apps}}'**
  String audioOverviewAppsCount(int count);

  /// Muted apps indicator
  ///
  /// In en, this message translates to:
  /// **'There are muted apps'**
  String get audioOverviewMuted;

  /// Overview live indicator
  ///
  /// In en, this message translates to:
  /// **'Live connection'**
  String get audioOverviewLive;

  /// Sessions panel title
  ///
  /// In en, this message translates to:
  /// **'Apps with sound'**
  String get audioSessionsTitle;

  /// Sessions panel description
  ///
  /// In en, this message translates to:
  /// **'Each card shows volume, current activity, and whether the session is muted.'**
  String get audioSessionsDescription;

  /// Sessions panel live chip
  ///
  /// In en, this message translates to:
  /// **'Live updates'**
  String get audioSessionsLiveChip;

  /// Fallback text for unnamed app
  ///
  /// In en, this message translates to:
  /// **'Unnamed app'**
  String get audioSessionsEmptyName;

  /// Session id label
  ///
  /// In en, this message translates to:
  /// **'ID {id}'**
  String audioSessionsIdLabel(String id);

  /// Loading title for outputs
  ///
  /// In en, this message translates to:
  /// **'Loading outputs'**
  String get audioLoadingDevicesTitle;

  /// Loading message for outputs
  ///
  /// In en, this message translates to:
  /// **'Looking for the audio destinations available on this computer.'**
  String get audioLoadingDevicesMessage;

  /// Error title for outputs
  ///
  /// In en, this message translates to:
  /// **'Could not load outputs'**
  String get audioDevicesErrorTitle;

  /// Error message for outputs
  ///
  /// In en, this message translates to:
  /// **'Try again in a moment.'**
  String get audioDevicesErrorMessage;

  /// Empty title for outputs
  ///
  /// In en, this message translates to:
  /// **'No outputs found'**
  String get audioDevicesEmptyTitle;

  /// Empty message for outputs
  ///
  /// In en, this message translates to:
  /// **'Connect an audio device and refresh the list to continue.'**
  String get audioDevicesEmptyMessage;

  /// Prompt title to select output
  ///
  /// In en, this message translates to:
  /// **'Choose an output to continue'**
  String get audioSelectPromptTitle;

  /// Prompt message to select output
  ///
  /// In en, this message translates to:
  /// **'As soon as you pick an output, the apps with sound will appear here.'**
  String get audioSelectPromptMessage;

  /// Loading title for sessions
  ///
  /// In en, this message translates to:
  /// **'Refreshing apps'**
  String get audioSessionsLoadingTitle;

  /// Loading message for sessions
  ///
  /// In en, this message translates to:
  /// **'Fetching the audio sessions for the selected output.'**
  String get audioSessionsLoadingMessage;

  /// Error title for sessions
  ///
  /// In en, this message translates to:
  /// **'Could not load apps'**
  String get audioSessionsErrorTitle;

  /// Error message for sessions
  ///
  /// In en, this message translates to:
  /// **'Try another output or refresh the list.'**
  String get audioSessionsErrorMessage;

  /// Empty title for sessions
  ///
  /// In en, this message translates to:
  /// **'No apps with visible audio'**
  String get audioSessionsEmptyTitle;

  /// Empty message for sessions
  ///
  /// In en, this message translates to:
  /// **'When an app starts playing through this output, it will show up in this panel.'**
  String get audioSessionsEmptyMessage;

  /// Active audio session state
  ///
  /// In en, this message translates to:
  /// **'Now playing'**
  String get audioSessionActive;

  /// Inactive audio session state
  ///
  /// In en, this message translates to:
  /// **'Idle'**
  String get audioSessionInactive;

  /// Expired audio session state
  ///
  /// In en, this message translates to:
  /// **'Closed'**
  String get audioSessionExpired;

  /// Muted state label
  ///
  /// In en, this message translates to:
  /// **'Muted'**
  String get audioSessionMuted;

  /// Unmuted state label
  ///
  /// In en, this message translates to:
  /// **'Audio active'**
  String get audioSessionUnmuted;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'pt'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'pt':
      return AppLocalizationsPt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
