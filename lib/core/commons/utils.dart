import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

/// Cast any value to type T
T? cast<T>(dynamic value, {T? fallback}) {
  if ((T == bool && fallback == null)) {
    if (value is T) {
      return value;
    }
    return false as T;
  }
  if (value == null) {
    return null;
  }

  if (value is T) {
    return value;
  } else if (fallback != null) {
    return fallback;
  }
  if (value is T) {
    return value;
  }
  return value as T;
}

double castDouble(dynamic x, {double fallback = 0.0}) {
  return x is num ? x.toDouble() : double.tryParse(x.toString()) ?? fallback;
}

/// Cast a list to List<T>
List<R> castList<R>(dynamic x, {List<R>? fallback}) {
  if (x is List<dynamic>) {
    try {
      if (R == double) {
        return x.map(castDouble).toList() as List<R>;
      }
      if (R == String) {
        return x.map((e) => e.toString()).toList() as List<R>;
      }
      return x.cast<R>();
    } catch (e) {
      debugPrint(e.toString());
    }
  }
  return fallback ?? [];
}

Map<RK, RV> castMap<RK, RV>(dynamic x, {Map<RK, RV> fallback = const {}}) {
  final newMap = <RK, RV>{};

  if (x is Map<dynamic, dynamic>) {
    for (final entry in x.entries) {
      if (entry.key is RK && entry.value is RV) {
        newMap[entry.key as RK] = entry.value as RV;
      } else {
        return fallback;
      }
    }

    return newMap;
  }
  return fallback;
}

extension EnumByName<T extends Enum> on Iterable<T> {
  /// Returns the enum value matching [name] (case-insensitive),
  /// or `null` if not found.
  T? byName(String name) {
    return firstWhereOrNull((e) => e.name.toLowerCase() == name.toLowerCase());
  }
}

extension StringExtension on String {
  String capitalize() {
    return this.split(' ').map((e) => e.capitalize()).join(' ');
  }

  String toSentenceCase() {
    if (isEmpty) return this;

    // Handle camelCase and snake_case
    final words = replaceAllMapped(
      RegExp(r'[A-Z]|_[a-z]'),
      (match) => ' ${match.group(0)?.replaceAll('_', '')}',
    ).trim().split(' ');

    // Capitalize each word
    return words
        .map(
          (word) =>
              word.isEmpty
                  ? ''
                  : '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}',
        )
        .join(' ');
  }
}

extension DateTimeExtension on DateTime {
  bool isToday() {
    return DateTime.now().day == day &&
        DateTime.now().month == month &&
        DateTime.now().year == year;
  }

  bool isSameDay(DateTime other) {
    return day == other.day && month == other.month && year == other.year;
  }
}
