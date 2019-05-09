// Copyright 2018 The Flutter Team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';
import 'package:path_provider/path_provider.dart' as paths;
import 'package:multiplatform/data/local_veggie_provider.dart';
import 'package:multiplatform/data/veggie.dart';

part 'models.g.dart';

bool _datesAreSameDay(DateTime a, DateTime b) {
  return a?.year == b?.year && a?.month == b?.month && a?.day == b?.day;
}

enum MealType {
  breakfast,
  lunch,
  dinner,
}

/// Represents a line in the log about one food eaten.
@JsonSerializable(nullable: false)
class LogEntry {
  const LogEntry({
    @required this.veggieId,
    @required this.servings,
    @required this.timestamp,
    this.mealType = MealType.lunch,
  });

  final int veggieId;
  final int servings;
  final DateTime timestamp;
  final MealType mealType;

  factory LogEntry.fromJson(Map<String, dynamic> json) =>
      _$LogEntryFromJson(json);

  Map<String, dynamic> toJson() => _$LogEntryToJson(this);
}

/// ViewModel that combines data from a single LogEntry with the veggie it
/// references.
class LogEntryViewModel {
  LogEntryViewModel(LogEntry entry, this.veggie)
      : timestamp = entry.timestamp,
        servings = entry.servings,
        calories = veggie.caloriesPerServing * entry.servings,
        vitaminAPercentage = veggie.vitaminAPercentage * entry.servings,
        vitaminCPercentage = veggie.vitaminCPercentage * entry.servings;

  final DateTime timestamp;
  final Veggie veggie;
  final int servings;
  final int calories;
  final int vitaminAPercentage;
  final int vitaminCPercentage;
}

/// ViewModel summarizing data for an entire day's worth of [LogEntry] objects.
class DailySummaryViewModel {
  const DailySummaryViewModel(this.day, this.entries);

  final List<LogEntryViewModel> entries;
  final DateTime day;

  int get calories => entries.map((e) => e.calories).reduce((v, e) => v + e);

  int get vitaminAPercentage =>
      entries.map((e) => e.vitaminAPercentage).reduce((v, e) => v + e);

  int get vitaminCPercentage =>
      entries.map((e) => e.vitaminCPercentage).reduce((v, e) => v + e);
}

/// The current state of the app.
///
/// This class is basically just a list of log entries, plus the available
/// library of veggies and some code to serialize data to and from files as
/// JSON. It's also a Listenable, so ScopedModel descendants will be updated
/// each time [notifyListeners] is invoked.
class AppState extends ChangeNotifier {
  AppState() {
    _readEntriesFromStorage().then((list) {
      logEntries.addAll(list);
      notifyListeners();
    });
  }

  final allVeggies = LocalVeggieProvider.veggies;

  final logEntries = <LogEntry>[];

  List<DateTime> get days {
    return logEntries.map((e) => e.timestamp).fold(<DateTime>[], (t, e) {
      return (t.isEmpty || !_datesAreSameDay(t.last, e)) ? (t..add(e)) : t;
    }).toList();
  }

  Veggie veggieById(int id) => allVeggies.firstWhere((e) => e.id == id);

  Iterable<LogEntry> entriesForDay(DateTime day) {
    return logEntries.where((e) => _datesAreSameDay(day, e.timestamp)).toList();
  }

  void addLogEntry(LogEntry entry) {
    logEntries.add(entry);
    _writeEntriesToStorage(logEntries);
    notifyListeners();
  }

  Future<void> _writeEntriesToStorage(List<LogEntry> entries) async {
    final dir = await paths.getApplicationDocumentsDirectory();
    final file = File('${dir.path}/entries.json');

    return file.writeAsString(
      json.encode(entries.map((e) => e.toJson()).toList()),
    );
  }

  Future<List<LogEntry>> _readEntriesFromStorage() async {
    final dir = await paths.getApplicationDocumentsDirectory();
    final file = File('${dir.path}/entries.json');

    if (await file.exists()) {
      final jsonStr = await file.readAsString();
      final decoded = json.decode(jsonStr);
      return decoded.map<LogEntry>((x) => LogEntry.fromJson(x)).toList();
    } else {
      return <LogEntry>[];
    }
  }
}
