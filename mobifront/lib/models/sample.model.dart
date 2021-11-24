import 'dart:convert';

import 'package:mobifront/utils/utl.dart';

// André Luiz
// dados de amostragem para cálculos estatísticos de Covid-19
class Sample {
  DateTime date;
  int cases;
  int total;
  Sample({
    required this.date,
    required this.cases,
    required this.total,
  });

  Sample copyWith({
    DateTime? date,
    int? cases,
    int? total,
  }) {
    return Sample(
      date: date ?? this.date,
      cases: cases ?? this.cases,
      total: total ?? this.total
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'date': Utl.ansiDate(date),
      'cases': cases,
      'total': total
    };
  }

  factory Sample.fromMap(Map<String, dynamic> map) {
    return Sample(
      date: Utl.asDate(map['date']),
      cases: Utl.asInt(map['cases']),
      total: Utl.asInt(map['total']),
    );
  }

  String toJson() => json.encode(toMap());

  factory Sample.fromJson(String source) => Sample.fromMap(json.decode(source));

  @override
  String toString() => 'Sample(date: $date, cases: $cases, total: $total)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Sample && other.date == date && other.cases == cases && other.total == total;
  }

  @override
  int get hashCode => date.hashCode ^ cases.hashCode ^ total.hashCode;
}
