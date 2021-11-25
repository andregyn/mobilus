// André Luiz
// Controlador responsável por comunicação e computação de dados;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:location/location.dart';
import 'package:mobifront/models/data_value_model.dart';
import 'package:mobifront/models/sample.model.dart';
import 'package:mobifront/services/http_service.dart';
import 'package:mobifront/services/http_service_interface.dart';
import 'package:mobifront/services/osm_nominatim.dart';
import 'package:mobifront/utils/utl.dart';
import 'package:platform_device_id/platform_device_id.dart';

class HomeController {
  // serviço de comunicação
  final IHttpService service = HttpService();

  List<Sample>? sampleCases;
  List<Sample>? sampleDeaths;

  List<DataValueModel> cases = [];
  List<DataValueModel> deaths = [];
  List<DataValueModel> daily = [];
  List<DataValueModel> mobile = [];
  List<DataValueXYZModel> report = [];

  String lastError = "";
  String locationError = "";

  LocationData? locationData;
  Place? place;

  /// obter posição atual
  Future<bool> getCurrentPosition([bool fillplace = true]) async {
    // inicializa as variaveis
    locationError = "";
    Location location = Location();
    PermissionStatus _permissionGranted = PermissionStatus.denied;

    // o serviço de Geolocalização do dispositivo está desabilitado? Pedir para habilitar
    bool _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
    }

    // se foi habilitado, então verificar se sem permissão para usar.
    if (_serviceEnabled) {
      _permissionGranted = await location.hasPermission();
      if (_permissionGranted == PermissionStatus.denied) {
        _permissionGranted = await location.requestPermission();
      }
    } else {
      locationError =
          "O serviço de localização não está ativado no seu dispositivo. Por favor habilite-o para usar este recurso.";
      return false;
    }

    // se tiver permissão para usar o serviço de geolocalização, obtenha
    if (_permissionGranted == PermissionStatus.granted) {
      LocationData _locationData = await location.getLocation();
      if (_locationData.latitude != null) {
        locationData = _locationData;
        place = await Nominatim.reverseSearch(
          lat: locationData!.latitude,
          lon: locationData!.longitude,
          addressDetails: true,
          extraTags: true,
          nameDetails: true,
        );
        return true;
      }
    } else {
      locationError =
          "Permissão para usar o serviço de geolocalização foi negada.";
    }
    return false;
  }

  /// classificar a matriz do relatório
  sortReport(String column, String direction) {
    if (column == "date") {
      report.sort((a, b) => direction == "asc"
          ? a.data.compareTo(b.data)
          : b.data.compareTo(a.data));
    } else if (column == "cases") {
      report.sort((a, b) => direction == "asc"
          ? (a.valuex - b.valuex).truncate()
          : (b.valuex - a.valuex).truncate());
    } else if (column == "media") {
      report.sort((a, b) => direction == "asc"
          ? (a.valuey - b.valuey).truncate()
          : (b.valuey - a.valuey).truncate());
    } else {
      report.sort((a, b) => direction == "asc"
          ? ((a.valuex - b.valuex) * 1000).truncate()
          : ((b.valuex - a.valuex) * 1000).truncate());
    }
  }

  /// requisito (questão) 2
  /// calcular a média móvel dos ultimos 14 dias (duas semanas)
  calcMovingAverage() {
    // data base para leitura.
    DateTime baseDate =
        Utl.onlyDate(DateTime.now()).subtract(const Duration(days: 15));
    var sampleDates =
        sampleCases!.where((e) => e.date.compareTo(baseDate) >= 0);

    // limpar arrays e preparar variaveis de trabalho
    mobile = [];
    report = [];
    daily = [];
    bool first = true;
    double lvalue = 0;

    // para cada dia
    for (var sdate in sampleDates) {
      // para calcular a média, pegar os ultimos 7 dias.
      var mstart = sdate.date.subtract(const Duration(days: 6));
      double value = sampleCases!
              .where((e) =>
                  e.date.compareTo(mstart) >= 0 &&
                  e.date.compareTo(sdate.date) <= 0)
              .fold<double>(0, (p, e) => p + e.cases) /
          7;

      // deve pular o primeiro dia, pois ele serve somente para "saldo anterior"
      if (!first) {
        mobile.add(DataValueModel(
            data: DateFormat("dd/MM").format(sdate.date),
            value: value.truncate().toDouble()));

        report.add(DataValueXYZModel(
          data: Utl.ansiDate(sdate.date),
          valuex: sdate.cases.toDouble(),
          valuey: value.truncate().toDouble(),
          valuez: lvalue.truncate().toDouble(),
        ));

        daily.add(DataValueModel(
            data: DateFormat("dd/MM").format(sdate.date),
            area: true,
            color: Colors.red,
            value: sdate.cases.toDouble()));
      }
      // atualiar o "saldo" e apontar que já não é o primeiro item do loop
      lvalue = value;
      first = false;
    }
  }

  /// requisito (questão) 4
  /// pegar o dia com maior quantidade de casos no ultimo mês
  /// pegar o dia com maior quantidade de numero de mortes no último mês
  /// obter a geolocalização do usuário e persistir em uma tabela.
  Future<bool> getTopMost() async {
    // obter a data inicial.
    var mstart = Utl.addMonth(Utl.onlyDate(DateTime.now()), months: -1)
        .add(const Duration(days: 1));
    var scases =
        sampleCases!.where((e) => e.date.compareTo(mstart) >= 0).toList();
    var sdeaths =
        sampleDeaths!.where((e) => e.date.compareTo(mstart) >= 0).toList();

    // classificar por quantidade de casos em order DECRESCENTE
    scases.sort((a, b) => b.cases - b.cases);
    sdeaths.sort((a, b) => a.cases - a.cases);

    String? deviceId = await PlatformDeviceId.getDeviceId;

    if ((deviceId ?? "").isNotEmpty) {
      if (await getCurrentPosition()) {
        // persistir dados no firestore
        await FirebaseFirestore.instance.collection("top_mosts").add({
          "device": deviceId!,
          "date": Utl.ansiDateTime(DateTime.now()),
          "deaths": sdeaths.first.cases,
          "deaths_at": Utl.ansiDate(sdeaths.first.date),
          "cases": scases.first.cases,
          "cases_at": Utl.ansiDate(scases.first.date),
          "latitude": locationData!.latitude,
          "longitude": locationData!.longitude,
          "city": place?.address?['city'] ?? "",
          "state": place?.address?['state'] ?? "",
        });

        return true;
      }
    }

    return false;
  }

  /// requisito (questão) 1
  /// obter todos os cados de Covid no Brasil nos últimos 6 meses.
  getLatestSixMonths() async {
    // carregar os dados sobre os casos confirmados com Covid-19
    var resp = await service.get("cases/confirmed/6");

    // se conseguiu, preencha a lista e pesquise também as mortes causadas.
    if (resp?.ok ?? false) {
      sampleCases = resp!.data.map((e) => Sample.fromMap(e)).toList();

      // carregar os dados sobre as mortes causadas por Covid-19
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

      // calcular a média móvel.
      calcMovingAverage();
    }

    // caso tenha algum dado ...
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
