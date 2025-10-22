import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
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
    Locale('fr'),
  ];

  /// The title of the application
  ///
  /// In en, this message translates to:
  /// **'Samandari'**
  String get appTitle;

  /// Dashboard screen title
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboard;

  /// Tasks screen title
  ///
  /// In en, this message translates to:
  /// **'Tasks'**
  String get tasks;

  /// Expenses screen title
  ///
  /// In en, this message translates to:
  /// **'Expenses'**
  String get expenses;

  /// Notes screen title
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notes;

  /// Water tracking screen title
  ///
  /// In en, this message translates to:
  /// **'Water'**
  String get water;

  /// Habits screen title
  ///
  /// In en, this message translates to:
  /// **'Habits'**
  String get habits;

  /// Debts screen title
  ///
  /// In en, this message translates to:
  /// **'Debts'**
  String get debts;

  /// SoulSync journaling screen title
  ///
  /// In en, this message translates to:
  /// **'SoulSync'**
  String get soulSync;

  /// Goals screen title
  ///
  /// In en, this message translates to:
  /// **'Goals'**
  String get goals;

  /// Button text to add a new task
  ///
  /// In en, this message translates to:
  /// **'Add Task'**
  String get addTask;

  /// Button text to edit a task
  ///
  /// In en, this message translates to:
  /// **'Edit Task'**
  String get editTask;

  /// Button text to delete a task
  ///
  /// In en, this message translates to:
  /// **'Delete Task'**
  String get deleteTask;

  /// Label for task title input field
  ///
  /// In en, this message translates to:
  /// **'Task Title'**
  String get taskTitle;

  /// Label for task description input field
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get taskDescription;

  /// Label for due date selection
  ///
  /// In en, this message translates to:
  /// **'Due Date'**
  String get dueDate;

  /// Label for priority selection
  ///
  /// In en, this message translates to:
  /// **'Priority'**
  String get priority;

  /// High priority option
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get high;

  /// Medium priority option
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get medium;

  /// Low priority option
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get low;

  /// Save button text
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// Cancel button text
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Delete button text
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// Confirm button text
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// Empty state title when no tasks exist
  ///
  /// In en, this message translates to:
  /// **'No tasks yet'**
  String get noTasksYet;

  /// Empty state message for tasks
  ///
  /// In en, this message translates to:
  /// **'Create your first task to get started!'**
  String get createFirstTask;

  /// Water intake daily goal display
  ///
  /// In en, this message translates to:
  /// **'Daily Goal: {goal}ml'**
  String waterIntakeGoal(int goal);

  /// Water intake progress display
  ///
  /// In en, this message translates to:
  /// **'{current}ml of {goal}ml'**
  String waterIntakeProgress(int current, int goal);

  /// Congratulations message
  ///
  /// In en, this message translates to:
  /// **'Congratulations!'**
  String get congratulations;

  /// Message when water goal is reached
  ///
  /// In en, this message translates to:
  /// **'You\'ve reached your daily water goal!'**
  String get goalReached;

  /// Button text to add new expense
  ///
  /// In en, this message translates to:
  /// **'Add Expense'**
  String get addExpense;

  /// Label for amount input field
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get amount;

  /// Label for category selection
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// Label for description input field
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// Empty state title when no expenses exist
  ///
  /// In en, this message translates to:
  /// **'No expenses yet'**
  String get noExpensesYet;

  /// Empty state message for expenses
  ///
  /// In en, this message translates to:
  /// **'Start tracking your expenses to manage your budget!'**
  String get startTrackingExpenses;

  /// Button text to add new note
  ///
  /// In en, this message translates to:
  /// **'Add Note'**
  String get addNote;

  /// Label for note title input field
  ///
  /// In en, this message translates to:
  /// **'Note Title'**
  String get noteTitle;

  /// Label for note content input field
  ///
  /// In en, this message translates to:
  /// **'Content'**
  String get noteContent;

  /// Empty state title when no notes exist
  ///
  /// In en, this message translates to:
  /// **'No notes yet'**
  String get noNotesYet;

  /// Empty state message for notes
  ///
  /// In en, this message translates to:
  /// **'Create your first note to capture your thoughts!'**
  String get createFirstNote;

  /// Search placeholder text
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// Search results screen title
  ///
  /// In en, this message translates to:
  /// **'Search Results'**
  String get searchResults;

  /// Message when search returns no results
  ///
  /// In en, this message translates to:
  /// **'No results found'**
  String get noResultsFound;

  /// Suggestion when no search results found
  ///
  /// In en, this message translates to:
  /// **'Try different keywords or check your spelling'**
  String get tryDifferentKeywords;

  /// Settings screen title
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// Theme settings label
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// Dark mode toggle label
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// Light mode option
  ///
  /// In en, this message translates to:
  /// **'Light Mode'**
  String get lightMode;

  /// System theme mode option
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get systemMode;

  /// Language settings label
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// Notifications settings label
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// Backup settings label
  ///
  /// In en, this message translates to:
  /// **'Backup'**
  String get backup;

  /// Button text to create backup
  ///
  /// In en, this message translates to:
  /// **'Backup Now'**
  String get backupNow;

  /// Button text to restore from backup
  ///
  /// In en, this message translates to:
  /// **'Restore'**
  String get restore;

  /// Loading state message
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// Error state title
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// Retry button text
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// Success message
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get success;

  /// Message when task is marked as completed
  ///
  /// In en, this message translates to:
  /// **'Task completed!'**
  String get taskCompleted;

  /// Message when task is added
  ///
  /// In en, this message translates to:
  /// **'Task added successfully'**
  String get taskAdded;

  /// Message when expense is added
  ///
  /// In en, this message translates to:
  /// **'Expense added successfully'**
  String get expenseAdded;

  /// Message when note is added
  ///
  /// In en, this message translates to:
  /// **'Note added successfully'**
  String get noteAdded;

  /// Message when backup is created
  ///
  /// In en, this message translates to:
  /// **'Backup created successfully'**
  String get backupCreated;

  /// Message when data is restored
  ///
  /// In en, this message translates to:
  /// **'Data restored successfully'**
  String get dataRestored;
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
      <String>['en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
