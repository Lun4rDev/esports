import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

class EsportsLocalizations {
  EsportsLocalizations(this.locale);

  static const _EsportsLocalizationsDelegate delegate =
      _EsportsLocalizationsDelegate();

  final Locale locale;

  static EsportsLocalizations of(BuildContext context) {
    return Localizations.of<EsportsLocalizations>(
        context, EsportsLocalizations);
  }

  static Map<String, Map<String, String>> _localizedValues = {
    "en": {
      // Matches
      "matches": "Matches",
      "nomatches": "No matches",
      "refresh" : "Refresh",
      "live": "Live",
      "today": "Today",
      "game": "Game",

      // Tournaments
      "tournaments": "Tournaments",
      "notournament": "No tournaments",
      "ongoing":  "Ongoing",
      "upcoming": "Upcoming",
    },
    "fr": {
      // Matches
      "matches": "Matchs",
      "nomatches": "Aucun match",
      "refresh" : "Rafraîchir",
      "live": "Direct",
      "today": "Aujourd'hui",
      "game": "Partie",

      // Tournaments
      "tournaments": "Tournois",
      "notournament": "Aucun tournoi",
      "ongoing":  "En cours",
      "upcoming": "Prochainement",
    },
  };

  String get(String key) {
    return _localizedValues[locale.languageCode][key];
  }
}

class _EsportsLocalizationsDelegate
    extends LocalizationsDelegate<EsportsLocalizations> {
  const _EsportsLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ["en", "fr"].contains(locale.languageCode);

  @override
  Future<EsportsLocalizations> load(Locale locale) {
    return SynchronousFuture<EsportsLocalizations>(
        EsportsLocalizations(locale));
  }

  @override
  bool shouldReload(_EsportsLocalizationsDelegate old) => false;
}