// André Luiz
// Controlador responsável por comunicação e computação de dados;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobifront/models/data_value_model.dart';
import 'package:mobifront/models/sample.model.dart';
import 'package:mobifront/services/http_service.dart';
import 'package:mobifront/services/http_service_interface.dart';
import 'package:mobifront/utils/utl.dart';

class HomeController {
  // serviço de comunicação
  final IHttpService service = HttpService();

  List<Sample>? sampleCases;
  List<Sample>? sampleDeaths;
  List<DataValueModel> cases = [];
  List<DataValueModel> deaths = [];
  List<DataValueModel> daily = [];
  String lastError = "";

  List<DataValueModel> mobile = [];
  List<DataValueXYZModel> report = [];

  // obter todos os cados de Covid no Brasil nos últimos 6 meses.
  getLatestSixMonths() async {
    // carregar os dados
    var resp = await service.get("cases/confirmed/6");

    if (resp?.ok ?? false) {
      sampleCases = resp!.data.map((e) => Sample.fromMap(e)).toList();

      var resp2 = await service.get("cases/deaths/6");
      if (resp2?.ok ?? false) {
        sampleDeaths = resp2!.data.map((e) => Sample.fromMap(e)).toList();
      }
    } else {
      lastError = resp?.message ?? "Erro desconhecido";
    }

    // caso tenha algum dado úlil...
    if (sampleCases != null) {
      // preencher a série para gráfico 1
      cases = sampleCases!
          .map((e) => DataValueModel(
              data: DateFormat("dd/MM").format(e.date),
              area: true,
              color: Colors.blue,
              value: e.total.toDouble()))
          .toList();

      daily = sampleCases!
          .map((e) => DataValueModel(
              data: DateFormat("dd/MM").format(e.date),
              area: true,
              color: Colors.red,
              value: e.cases.toDouble()))
          .toList();

      // calcular a média móvel das ultimas 2 semanas
      DateTime baseDate =
          Utl.onlyDate(DateTime.now()).subtract(const Duration(days: 15));
      var sampleDates =
          sampleCases!.where((e) => e.date.compareTo(baseDate) >= 0);

      // limpar arrays e preparar variaveis de trabalho
      mobile = [];
      report = [];
      bool first = true;
      double lvalue = 0;
      // para cada dia
      for (var sdate in sampleDates) {
        var mstart = sdate.date.subtract(const Duration(days: 6));
        double value = sampleCases!
                .where((e) =>
                    e.date.compareTo(mstart) >= 0 &&
                    e.date.compareTo(sdate.date) <= 0)
                .fold<double>(0, (p, e) => p + e.cases) /
            7;
        if (!first) {
          mobile.add(DataValueModel(
              data: DateFormat("dd/MM").format(sdate.date),
              value: value.truncate().toDouble()));

          report.add(DataValueXYZModel(
            data: DateFormat("dd/MM").format(sdate.date),
            valuex: sdate.cases.toDouble(),
            valuey: value.truncate().toDouble(),
            valuez: lvalue.truncate().toDouble(),
          ));
        }
        lvalue = value;
        first = false;
      }
    }

    // caso tenha algum dado úlil...
    if (sampleDeaths != null) {
      // preencher a série para gráfico 1
      deaths = sampleDeaths!
          .map((e) => DataValueModel(
              data: DateFormat("dd/MM").format(e.date),
              area: true,
              color: Colors.red,
              value: e.total.toDouble()))
          .toList();
    }
  }
}
