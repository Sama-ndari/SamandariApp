// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'Samandari';

  @override
  String get dashboard => 'Tableau de bord';

  @override
  String get tasks => 'Tâches';

  @override
  String get expenses => 'Dépenses';

  @override
  String get notes => 'Notes';

  @override
  String get water => 'Eau';

  @override
  String get habits => 'Habitudes';

  @override
  String get debts => 'Dettes';

  @override
  String get soulSync => 'SoulSync';

  @override
  String get goals => 'Objectifs';

  @override
  String get addTask => 'Ajouter une tâche';

  @override
  String get editTask => 'Modifier la tâche';

  @override
  String get deleteTask => 'Supprimer la tâche';

  @override
  String get taskTitle => 'Titre de la tâche';

  @override
  String get taskDescription => 'Description';

  @override
  String get dueDate => 'Date d\'échéance';

  @override
  String get priority => 'Priorité';

  @override
  String get high => 'Élevée';

  @override
  String get medium => 'Moyenne';

  @override
  String get low => 'Faible';

  @override
  String get save => 'Enregistrer';

  @override
  String get cancel => 'Annuler';

  @override
  String get delete => 'Supprimer';

  @override
  String get confirm => 'Confirmer';

  @override
  String get noTasksYet => 'Aucune tâche pour le moment';

  @override
  String get createFirstTask => 'Créez votre première tâche pour commencer !';

  @override
  String waterIntakeGoal(int goal) {
    return 'Objectif quotidien : ${goal}ml';
  }

  @override
  String waterIntakeProgress(int current, int goal) {
    return '${current}ml sur ${goal}ml';
  }

  @override
  String get congratulations => 'Félicitations !';

  @override
  String get goalReached =>
      'Vous avez atteint votre objectif quotidien d\'eau !';

  @override
  String get addExpense => 'Ajouter une dépense';

  @override
  String get amount => 'Montant';

  @override
  String get category => 'Catégorie';

  @override
  String get description => 'Description';

  @override
  String get noExpensesYet => 'Aucune dépense pour le moment';

  @override
  String get startTrackingExpenses =>
      'Commencez à suivre vos dépenses pour gérer votre budget !';

  @override
  String get addNote => 'Ajouter une note';

  @override
  String get noteTitle => 'Titre de la note';

  @override
  String get noteContent => 'Contenu';

  @override
  String get noNotesYet => 'Aucune note pour le moment';

  @override
  String get createFirstNote =>
      'Créez votre première note pour capturer vos pensées !';

  @override
  String get search => 'Rechercher';

  @override
  String get searchResults => 'Résultats de recherche';

  @override
  String get noResultsFound => 'Aucun résultat trouvé';

  @override
  String get tryDifferentKeywords =>
      'Essayez des mots-clés différents ou vérifiez l\'orthographe';

  @override
  String get settings => 'Paramètres';

  @override
  String get theme => 'Thème';

  @override
  String get darkMode => 'Mode sombre';

  @override
  String get lightMode => 'Mode clair';

  @override
  String get systemMode => 'Système';

  @override
  String get language => 'Langue';

  @override
  String get notifications => 'Notifications';

  @override
  String get backup => 'Sauvegarde';

  @override
  String get backupNow => 'Sauvegarder maintenant';

  @override
  String get restore => 'Restaurer';

  @override
  String get loading => 'Chargement...';

  @override
  String get error => 'Erreur';

  @override
  String get retry => 'Réessayer';

  @override
  String get success => 'Succès';

  @override
  String get taskCompleted => 'Tâche terminée !';

  @override
  String get taskAdded => 'Tâche ajoutée avec succès';

  @override
  String get expenseAdded => 'Dépense ajoutée avec succès';

  @override
  String get noteAdded => 'Note ajoutée avec succès';

  @override
  String get backupCreated => 'Sauvegarde créée avec succès';

  @override
  String get dataRestored => 'Données restaurées avec succès';
}
