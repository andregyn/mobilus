import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math' as m;
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' as w;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:intl/intl.dart';

import '../views/components/future_progress_dialog.dart';

class Utl {
  static DateTime birthDay(DateTime birth) {
    if (Utl.isEmptyDate(birth)) {
      return DateTime(
          DateTime.now().year - 1, DateTime.now().month, DateTime.now().day);
    }
    DateTime birthMonth =
        Utl.lastDayOfMonth(DateTime(DateTime.now().year, birth.month, 1));
    return (birth.day < birthMonth.day)
        ? DateTime(DateTime.now().year, birth.month, birth.day)
        : birthMonth;
  }



static Future<void> execProgress(
    w.BuildContext context, String? message, Future<void> Function() f) async {
  try {
    await w.showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) => FutureProgressDialog(Future(() async {
              await f();
            }),
                message: message == null
                    ? w.Text(message ?? "Aguarde...")
                    : message.isEmpty
                        ? null
                        : w.Text(message)));
  } catch (e) {
    Utl.log("execProgress", e);
  }
}

  static double getRoundedInterval(double val) {
    double m = 1;
    double d = val;
    while (d > 10.0) {
      d = (d / 10).floorToDouble();
      m = m * 10;
    }
    double res = d * m;
    return res;
  }



  static DateTime dateHour(String date, String time) {
    var ddate = Utl.asDate(date);
    var dtime = Utl.asTime(time);
    var rdate = ddate.add(Duration(minutes: dtime.hour * 60 + dtime.minute));
    return rdate;
  }

  static int age(DateTime from, [DateTime? to]) {
    to ??= Utl.onlyDate(DateTime.now());
    int age = to.year - from.year;
    DateTime birth = birthDay(from);
    return (birth.isAfter(to)) ? age - 1 : age;
  }

  static bool get isMobile {
    bool kismobile = false;
    if (!kIsWeb) {
    try {
      if (Platform.isAndroid || Platform.isIOS) {
        kismobile = true;
      } else {
        kismobile = false;
      }
    } catch (e) {
      kismobile = false;
    }
    }
    return kismobile;
  }

  static bool get isIOS {
    bool kismobile = false;
    if (!kIsWeb) {
    try {
      if (Platform.isIOS) {
        kismobile = true;
      } else {
        kismobile = false;
      }
    } catch (e) {
      kismobile = false;
    }
        }    return kismobile;
  }

  static bool get isAndroid {
    bool kismobile = false;
    if (!kIsWeb) {
    try {
      if (Platform.isAndroid) {
        kismobile = true;
      } else {
        kismobile = false;
      }
    } catch (e) {
      kismobile = false;
    }
    }
    return kismobile;
  }

  static bool get isDesktop {
    bool kdesk = false;
    try {
      if (Platform.isLinux ||
          Platform.isMacOS ||
          Platform.isFuchsia ||
          Platform.isWindows) {
        kdesk = true;
      }
    } catch (e) {
      kdesk = false;
    }
    return kdesk;
  }

  static bool get isWeb {
    return (kIsWeb);
  }

  static float2rat(double n, [double tolerance = 0.000001]) {
    var h1 = 1;
    var h2 = 0;
    var k1 = 0;
    var k2 = 1;
    var b = 1 / n;
    do {
      b = 1 / b;
      var a = b.floor();
      var aux = h1;
      h1 = a * h1 + h2;
      h2 = aux;
      aux = k1;
      k1 = a * k1 + k2;
      k2 = aux;
      b = b - a;
    } while ((n - h1 / k1).abs() > n * tolerance);

    return "$h1/$k1";
  }

  static String uniChar(String code) {
    if (code == "1/2") return "½";
    if (code == "1/4") return "¼";
    if (code == "3/4") return "¾";
    return code;
  }

  static DateTime? _time;

  static DateTime get hoje {
    return Utl.onlyDate(DateTime.now());
  }

  static void startCron() {
    _time = DateTime.now();
  }

  static void stopCron(String s) {
    if (_time != null) {
      log(s,
          (DateTime.now().difference(_time!).inMilliseconds.toString() + "ms"));
    }
  }

  static bool validatePassword(String password) {
    String pattern =
        r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$';
    return RegExp(pattern).hasMatch(password) && password.length >= 8;
  }

  static String capitalize(String s) {
    if (Utl.emptyOrNull(s)) {
      return "";
    }
    if (s.length > 1) {
      var ls = s.trim().toLowerCase().split(" ");
      var cs = ls
          .map((e) => ['da', 'de', 'do', 'das', 'dos', 'e'].contains(e)
              ? e
              : e.length < 2
                  ? e
                  : "${e[0].toUpperCase()}${e.substring(1)}")
          .toList();
      return cs.join(" ");
    }
    return s.toUpperCase();
  }

  static String defValue(String s, String defs) {
    if (Utl.emptyOrNull(s)) {
      return defs;
    }
    return s;
  }

  static Future<bool> checkConnection(String url) async {
    bool isConnected = false;
    try {
      final List<InternetAddress> result = await InternetAddress.lookup(url);
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        isConnected = true;
      }
    } on SocketException catch (_) {
      isConnected = false;
      return false;
    }
    return isConnected;
  }

  static bool isInDebugMode() {
    bool inDebugMode = false;
    assert(inDebugMode = true);
    return inDebugMode;
  }

  static isValidCreditCardNumber(String svalue) {
    var value = getNumbers(svalue);
    // The Luhn Algorithm. It's so pretty.
    var nCheck = 0, bEven = false;

    for (var n = value.length - 1; n >= 0; n--) {
      var cDigit = value[n], nDigit = int.parse(cDigit);

      if (bEven && (nDigit *= 2) > 9) nDigit -= 9;

      nCheck += nDigit;
      bEven = !bEven;
    }

    return (nCheck % 10) == 0;
  }

  static void log(String s, [dynamic v]) {
    if (Utl.isInDebugMode()) {
      debugPrint(
          DateTime.now().toIso8601String() +
              ": " +
              s +
              (v != null ? " = " + v.toString() : ""),
          wrapWidth: 160);
    }
  }

  static String oneLine(String s) {
    var ls = const LineSplitter();
    var litems = ls.convert(s);
    StringBuffer out = StringBuffer();
    for (var sitem in litems) {
      out.write(sitem.trim() + " ");
    }
    String sout = out.toString().trim();
    //if (isInDebugMode())
    //Utl.log(sout);
    return sout;
  }

  static bool isValidCellNumber(String number) {
    var n = getNumbers(number);
    if (n.isEmpty) return false;
    var pattern = r"^(?:(55\d{2})|\d{2})[6-9]\d{8}$";
    var res = (n.length >= 8 && RegExp(pattern).hasMatch(n));

    if (!res) {
      pattern = r"^[6-9]\d{8}$";
      res = (n.length >= 8 && RegExp(pattern).hasMatch(n));
    }
    return res;
  }

  static bool isFixPhoneNumber(String number) {
    var n = int.parse(getNumbers(number)).toString();
    var pattern = r"^(?:(55\d{2})|\d{2})[2-4]\d{7}$";
    var res = (n.length >= 8 && RegExp(pattern).hasMatch(n));

    if (!res) {
      pattern = r"^[2-4]\d{7}$";
      res = (n.length >= 8 && RegExp(pattern).hasMatch(n));
    }
    return res;
  }
  

  static bool isValidPhoneNumber(String number) {
    var res = isValidCellNumber(number);
    if (!res) {
      var snum = Utl.getNumbers(number);
      res = snum.startsWith("0800") && snum.length == 11;

      if (!res) {
        res = isFixPhoneNumber(snum);
      }
    }
    return res;
  }

  static String formatCellNumber(String celular) {
    String mask = "+5562900000000";
    String numbers = Utl.asInt(Utl.getNumbers(celular)).toString();
    String naddress = mask.substring(0, 14 - numbers.length) + numbers;
    String address = naddress.substring(0, 3) +
        " " +
        naddress.substring(3, 5) +
        " " +
        naddress.substring(5, 10) +
        '-' +
        naddress.substring(10, 14);
    return address;
  }

  static String formatWhatsAppNumber(String celular) {
    String mask = "+556200000000";
    String numbers = Utl.asInt(Utl.getNumbers(celular)).toString();
    // testar tamanho do numero
    // se tiver 9 digitos, pula o primeiro
    if (numbers.length == 9) numbers = numbers.substring(1);
    // se tiver 11, pula o terceiro
    if (numbers.length == 11) {
      numbers = numbers.substring(0, 2) + numbers.substring(3);
    }
    if (numbers.length == 13) {
      numbers = numbers.substring(0, 4) + numbers.substring(5);
    }
    String naddress = mask.substring(0, 13 - numbers.length) + numbers;
    String address = naddress.substring(0, 3) +
        " (" +
        naddress.substring(3, 5) +
        ") " +
        naddress.substring(5, 9) +
        '-' +
        naddress.substring(9, 13);
    address = address.replaceAll("(56)", "(62)");
    return address;
  }

  static String formatCpfNumber(String cpf) {
    if (cpf.isEmpty) return "";
    String mask = "00000000000";
    String numbers = Utl.asInt(Utl.getNumbers(cpf)).toString();
    String nx = (mask + numbers);
    String naddress = nx.substring(nx.length - 11);
    String address = naddress.substring(0, 3) +
        "." +
        naddress.substring(3, 6) +
        "." +
        naddress.substring(6, 9) +
        '-' +
        naddress.substring(9, 11);
    return address;
  }

  static String formatCEP(String cpf) {
    if (cpf.isEmpty) return "";
    String mask = "00000000";
    String numbers = Utl.asInt(Utl.getNumbers(cpf)).toString();
    String nx = (mask + numbers);
    String naddress = nx.substring(nx.length - 8);
    String address = naddress.substring(0, 2) +
        "." +
        naddress.substring(2, 5) +
        '-' +
        naddress.substring(5);
    return address;
  }


  static bool isNumber(String item) {
    return '0123456789'.split('').contains(item);
  }

  static bool isHex(String item) {
    return '0123456789ABCDEF'.contains(item.toUpperCase());
  }

  static String getNumbers(String text) {
    if (text.isEmpty) return "";
    return text.split("").where((element) => isNumber(element)).join("");
  }

  static String hexNumber(String text) {
    if (text.isEmpty) return "000000";
    return text.split("").where((element) => isHex(element)).join("");
  }

  static DateTime lastDayOfMonth(DateTime d) {
    DateTime d1 = DateTime(d.year, d.month, 1).add(const Duration(days: 32));
    return DateTime(d1.year, d1.month, 1).subtract(const Duration(days: 1));
  }

  static DateTime? firstDayOfMonth(DateTime? d) {
    if (d == null) return null;
    return DateTime(d.year, d.month, 1);
  }

  static DateTime addMonth(DateTime date, {int months = 1}) {
    int month = date.month;
    int year = date.year;
    int day = date.day;
    month = month + months;
    if (months > 0) {
      while (month > 12) {
        month -= 12;
        year++;
      }
    } else {
      while (month < 1) {
        month += 12;
        year--;
      }
    }

    DateTime lday = Utl.lastDayOfMonth(DateTime(year, month, 1));
    if (lday.day < day) day = lday.day;
    return DateTime(year, month, day, date.hour, date.minute, date.second);
  }

  static bool isEmptyDate(dynamic date) {
    if (date == null) return true;
    if (date is String && date == "null") return true;
    if (date is String && date.startsWith("00")) return true;
    if (date is String && date == "1900-01-01") return true;
    if (date is String && asDate(date).isAtSameMomentAs(DateTime(1900, 1, 1))) {
      return true;
    }
    if (date is DateTime && date.isAtSameMomentAs(DateTime(1900, 1, 1))) {
      return true;
    }
    return false;
  }


  static String asNumTransacao(String s) {
    String onum = "00000000000000000000" + Utl.getNumbers(s);
    return onum.substring(onum.length - 20);
  }

  static String asBig(String s) {
    if (emptyOrNull(s)) return "0";
    var ss = Utl.getNumbers(s);
    if (ss == "") ss = "0";
    return BigInt.tryParse(ss).toString();
  }

  static String intNumber(double val, [bool nomilhar = false] ) {
    if (nomilhar) {
    return NumberFormat("0").format(val);
    }
    return NumberFormat("#,###,###,##0").format(val);
  }

  static String brNumber(double val, {bool nomilhar = false, int ndecs = 2}) {
    if (nomilhar) {
      if (ndecs == 0) return NumberFormat("#########0", 'pt-BR').format(val);
      return NumberFormat(
              "#########0." + ("00000000000000000".substring(0, ndecs)),
              'pt-BR')
          .format(val);
    }

    if (ndecs == 0) return NumberFormat("#,###,###,##0", 'pt-BR').format(val);
    return NumberFormat(
            "#,###,###,##0." + ("00000000000000000".substring(0, ndecs)),
            'pt-BR')
        .format(val);
  }

  static String brQty(double val, {bool nomilhar = false, String unit = ""}) {
    if (val == val.floorToDouble()) return intNumber(val, nomilhar) + unit;
    if (val > 0 && val < 1 && unit == "kg") return intNumber(val * 1000) + "g";
    if (nomilhar) {
      return NumberFormat("#########0.000", 'pt-BR').format(val) + unit;
    }

    return NumberFormat("#,###,###,##0.000", 'pt-BR').format(val) + unit;
  }

  static String brFloat(double? val,
      {bool nomilhar = false, String unit = ""}) {
    if (val == null) return intNumber(0) + (unit);
    if (val == val.floorToDouble()) return intNumber(val) + unit;
    if (val > 0 && val < 1 && unit == "kg") return intNumber(val * 1000) + "g";
    if (nomilhar) {
      return NumberFormat("#########0.0##", 'pt-BR').format(val) + unit;
    }

    return NumberFormat("#,###,###,##0.0##", 'pt-BR').format(val) + unit;
  }

  static String percent(double val, [int ndecimals = 0]) {
    String format = "#,###,###,##0" +
        (ndecimals > 0
            ? (".00000000000000000000".substring(0, ndecimals + 1))
            : "");
    String res = NumberFormat(format, 'pt-BR').format(val) + "%";
    return res;
  }

  static String brMoney(double? val) {
    double nval = val ??=  0;
    if (nval < 0) {
      return "R\$ -" + (NumberFormat("0.00", 'pt-BR').format(0 - nval));
    } else {
      return "R\$ " + (NumberFormat("0.00", 'pt-BR').format(nval));
    }
  }


  static String strBetween(String start, String end, String content) {
    var r = content.split(start);
    if (r.length > 1) {
      var j = r[1].split(end);
      return j[0].trim();
    }
    return "";
  }



  static String asString(dynamic s) {
    if (s == null) return "";
    if (s.toString() == "null") return "";
    return s.toString();
  }

  static int asInt(dynamic o) {
    if (o is int) return o;
    if (o == null) return 0;
    if (o is double) return o.floor();
    if (o is String && o.isEmpty) return 0;
    String s = o.toString();
    var i = int.tryParse(s);
    if (i == null) return 0;
    return i;
  }

  static BigInt asLong(dynamic s) {
    if (s == null) return BigInt.from(0);
    if (s is BigInt) return s;
    if (s is String && s.isEmpty) return BigInt.from(0);

    var i = BigInt.tryParse(s.toString());
    if (i == null) return BigInt.from(0);
    return i;
  }

  static double asNumber(dynamic s) {
    if (s is double) return s;
    if (s == null) return 0.0;
    if (s is String && (s.isEmpty || s == "null")) return 0.0;
    var i = double.tryParse(s.toString());
    if (i == null) return 0.0;
    return i;
  }

  static double asFloat(dynamic s) {
    if (s == null) return 0;
    if (s is double) return s;
    if (s is num) return s.toDouble();
    if (s is String && (s.isEmpty || s == "null")) return 0.0;
    num? n = 0;
    var ss = s.toString();
    int cpos = ss.lastIndexOf(",");
    int dpos = ss.lastIndexOf(".");
    if (cpos > dpos) {
      ss = ss.replaceAll(".", "").replaceAll(",", ".");
      n = num.tryParse(ss);
    } else {
      ss = ss.replaceAll(",", ".");
      n = num.tryParse(ss);
    }

    return n?.toDouble() ?? 0;
  }

  static DateTime asDate(String? s) {
    if (Utl.emptyOrNull(s)) return DateTime(1900, 1, 1);
    DateTime? d;
    try {
      d = DateTime.tryParse(s!);
    } catch (e) {
      d = null;
    }
    if (d == null) {
      try {
        d = HttpDate.parse(s!);
      } catch (e) {
        d = null;
      }
    }
    if (d == null) {
      try {
        var formatter = DateFormat(null, Intl.defaultLocale);
        d = formatter.parse(s!);
      } catch (e) {
        d = null;
      }
    }
    return d ?? DateTime(1900, 1, 1);
  }


  static DateTime asTime(String? s) {
    if (s == null) return DateTime(1900, 1, 1);
    var d = DateTime.tryParse("1900-01-01 $s");
    if (d == null) return DateTime(1900, 1, 1);
    return d;
  }

  static bool emptyOrNull(String? s) {
    if (s == null) return true;
    if (s.trim().isEmpty) return true;
    if (s.toLowerCase() == "null") return true;
    return false;
  }

  static bool preposition(String s) {
    return "|DA|DO|DAS|DOS|DE|".contains("|${s.toUpperCase()}|");
  }

  static String mesAno(DateTime date) {
    return DateFormat("MMMM/yyyy").format(date);
  }

  static String mesAnoCurto(DateTime date) {
    return DateFormat("MMM/yy").format(date);
  }

  static String mesCurto(int mes) {
    return DateFormat("MMM").format(DateTime(2000, mes, 1));
  }

  static String ansiDate(dynamic date) {
    if (date is String) {
      if (Utl.emptyOrNull(date)) {
        return "";
      }
      var d = asDate(date);
      return DateFormat("yyyy-MM-dd").format(d);
    }
    if (date is DateTime) return DateFormat("yyyy-MM-dd").format(date);
    return "";
  }

  static DateTime onlyDate(dynamic date) {
    if (date is String) {
      DateTime dtx = Utl.asDate(date);
      return Utl.asDate(DateFormat("yyyy-MM-dd").format(dtx));
    }
    if (date is DateTime) {
      return Utl.asDate(DateFormat("yyyy-MM-dd").format(date));
    }
    return Utl.asDate(DateFormat("yyyy-MM-dd").format(DateTime.now()));
  }

  static String ansiDateTime(dynamic date) {
    if (Utl.isEmptyDate(date)) {
      return "";
    }
    if (date is String) {
      return DateFormat("yyyy-MM-dd HH:mm:ss").format(Utl.asDate(date));
    }
    if (date is DateTime) return DateFormat("yyyy-MM-dd HH:mm:ss").format(date);
    return "";
  }

  static String hour(dynamic date) {
    if (date == null) return "";
    if (date is DateTime) return DateFormat("HH:mm").format(date);
    return "";
  }

  static String brDate(DateTime? date) {
    if (date == null) return "";
    var s = DateFormat("dd/MM/yyyy").format(date);
    if (s == '01/01/1900') return "";
    return s;
  }

  static String localeDate(DateTime? date) {
    if (date == null) return "";
    var formatter = DateFormat(null, Intl.defaultLocale);
    var s = formatter.format(Utl.onlyDate(date));
    if (s == formatter.format(DateTime(1900, 1, 1))) return "";
    return s.replaceAll(" 12:00:00 AM", "");
  }

  static String localeFloat(double? value) {
    if (value == null) return "";
    var formatter = NumberFormat(null, Intl.defaultLocale);
    return formatter.format(value);
  }

  static String localeDateTime(DateTime? date) {
    if (date == null) return "";
    var formatter = DateFormat(null, Intl.defaultLocale);
    var s = formatter.format(date);
    if (s == formatter.format(DateTime(1900, 1, 1))) return "";
    return s;
  }

  static String brDateTime(DateTime date) {
    var s = DateFormat("dd/MM/yyyy HH:mm:ss").format(date);
    if (s == '01/01/1900') return "";
    return s;
  }

  static String strTime(DateTime date) {
    return DateFormat("HH:mm").format(date);
  }

  static String brDateL(DateTime date) {
    var s = DateFormat("dd/MMM").format(date);
    if (s == '01/01/1900') return "";
    return s;
  }

  static String brDateLY(DateTime date) {
    var s = DateFormat("dd/MMM/yyyy").format(date);
    if (s == '01/01/1900') return "";
    return s;
  }

  static bool like(String searchText, String text) {
    if (emptyOrNull(searchText)) return true;
    if (emptyOrNull(text)) return false;
    var words = searchText.toLowerCase().split(" ");

    int i = 0;
    bool nofound = true;
    for (var s in words) {
      int y = text.toLowerCase().indexOf(s, i);
      if (y >= 0) {
        nofound = false;
      }
    }

    if (nofound) return false;
    return true;
  }


  static bool isCnpj(String cnpj) {
    var multiplicador1 = [5, 4, 3, 2, 9, 8, 7, 6, 5, 4, 3, 2];
    var multiplicador2 = [6, 5, 4, 3, 2, 9, 8, 7, 6, 5, 4, 3, 2];
    int soma;
    int resto;
    String digito;
    String tempCnpj;
    cnpj = cnpj.trim();
    cnpj = cnpj.replaceAll(".", "").replaceAll("-", "").replaceAll("/", "");
    if (cnpj.length != 14) return false;
    tempCnpj = cnpj.substring(0, 12);
    soma = 0;
    for (int i = 0; i < 12; i++) {
      soma += int.parse(tempCnpj[i].toString()) * multiplicador1[i];
    }
    resto = (soma % 11);
    if (resto < 2) {
      resto = 0;
    } else {
      resto = 11 - resto;
    }
    digito = resto.toString();
    tempCnpj = tempCnpj + digito;
    soma = 0;
    for (int i = 0; i < 13; i++) {
      soma += int.parse(tempCnpj[i].toString()) * multiplicador2[i];
    }
    resto = (soma % 11);
    if (resto < 2) {
      resto = 0;
    } else {
      resto = 11 - resto;
    }
    digito = digito + resto.toString();
    return cnpj.endsWith(digito);
  }

  static bool isEmail(String email) {
    return RegExp(
            r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
        .hasMatch(email);
  }

  static bool isCpf(String cpf) {
    var multiplicador1 = [10, 9, 8, 7, 6, 5, 4, 3, 2];
    var multiplicador2 = [11, 10, 9, 8, 7, 6, 5, 4, 3, 2];
    String tempCpf;
    String digito;
    int soma;
    int resto;
    cpf = cpf.trim();
    cpf = cpf.replaceAll(".", "").replaceAll("-", "");
    if (cpf.length != 11) return false;
    tempCpf = cpf.substring(0, 9);
    soma = 0;

    for (int i = 0; i < 9; i++) {
      soma += int.parse(tempCpf[i].toString()) * multiplicador1[i];
    }
    resto = soma % 11;
    if (resto < 2) {
      resto = 0;
    } else {
      resto = 11 - resto;
    }
    digito = resto.toString();
    tempCpf = tempCpf + digito;
    soma = 0;
    for (int i = 0; i < 10; i++) {
      soma += int.parse(tempCpf[i].toString()) * multiplicador2[i];
    }
    resto = soma % 11;
    if (resto < 2) {
      resto = 0;
    } else {
      resto = 11 - resto;
    }
    digito = digito + resto.toString();
    return cpf.endsWith(digito);
  }

  static double calcDistanceBetween(
      double latFrom, double lngFrom, double latTo, double lngTo) {
    // encontrar diferencas entre latitude e longitude
    double dla = latFrom - latTo;
    double dlo = lngFrom - lngTo;
    if (dla < 0) dla = 0 - dla;
    if (dlo < 0) dlo = 0 - dlo;

    // teorema de pitágoras
    return m.sqrt((dla * dla) + (dlo * dlo)) * 107.78;
  }

  static bool isDateBetween(DateTime d, DateTime dtinicial, DateTime dtfinal) {
    if (onlyDate(d).isAtSameMomentAs(onlyDate(dtinicial))) return true;
    if (onlyDate(d).isAtSameMomentAs(onlyDate(dtfinal))) return true;
    return d.isAfter(dtinicial) && d.isBefore(dtfinal);
  }

  static String getGoogleMapUrl(String s) {
//            String parameters = s.toLowerCase().replaceAll("-", " ").replaceAll(" ", "+");
    String parameters = s.toLowerCase().replaceAll(" ", "+");
    return Uri.encodeFull(
        "https://www.google.com/maps/search/?api=1&q=$parameters");
  }


  static Future<w.MemoryImage> imageProvider(ui.Image image) async {
    return w.MemoryImage(((await image.toByteData())!).buffer.asUint8List());
  }

  static Future<w.Image> asImage(ui.Image image,
      [double width = 400, double height = 300]) async {
    var prov = await imageProvider(image);
    return w.Image(
      image: prov,
      fit: w.BoxFit.fitWidth,
      height: height,
      width: width,
    );
  }

  static Future<ui.Image> uiImageFromFile(File f) async {
    var img = w.FileImage(f);
    Completer<w.ImageInfo> completer = Completer();
    img
        .resolve(const w.ImageConfiguration())
        .addListener(w.ImageStreamListener((w.ImageInfo info, bool _) {
      completer.complete(info);
    }));
    // guardar a imagem na memória
    w.ImageInfo imageInfo = await completer.future;
    return imageInfo.image;
  }

  static Future<ui.Image> uiImageFromNetwork(String path) async {
    var img = w.NetworkImage(path);
    Completer<w.ImageInfo> completer = Completer();
    img
        .resolve(const w.ImageConfiguration())
        .addListener(w.ImageStreamListener((w.ImageInfo info, bool _) {
      completer.complete(info);
    }));

    // guardar a imagem na memória
    w.ImageInfo imageInfo = await completer.future;
    return imageInfo.image;
  }

  static String pluralize(double qty, String single, String plural) {
    if (qty == 0) return "nenhum " + single;
    return Utl.brQty(qty) + " " + ((qty < 2) ? single : plural);
  }

  static bool asBool(dynamic v) {
    if (v == null) return false;
    if (v is bool) return v;
    return ["yes", 'sim', 's', 'y', '1'].contains(v.toString().toLowerCase());
  }

  static String removeAccents(String str) {
    var withDia =
        'ÀÁÂÃÄÅàáâãäåÒÓÔÕÕÖØòóôõöøÈÉÊËèéêëðÇçÐÌÍÎÏìíîïÙÚÛÜùúûüÑñŠšŸÿýŽž';
    var withoutDia =
        'AAAAAAaaaaaaOOOOOOOooooooEEEEeeeeeCcDIIIIiiiiUUUUuuuuNnSsYyyZz';

    for (int i = 0; i < withDia.length; i++) {
      str = str.replaceAll(withDia[i], withoutDia[i]);
    }

    return str;
  }

  static double relevance(String tosearch, String document) {
    var s1 = tosearch.split(' ');
    // total no rank
    double rank = 0;
    int n = 0;
    var palavras = document.toLowerCase().split(' ');
    for (var x in s1) {
      int i = document.toLowerCase().indexOf(x.toLowerCase());
      if (i >= 0) {
        // peso por palavra inteira
        int ix = palavras.indexOf(x.toLowerCase());
        if (ix >= 0) rank += (10 - (m.log(ix + 1)));

        // peso por posição e tamanho do documento
        rank += (4 - (m.log(i + 1))) + (6 - m.log(document.length));
        n++;
      }
    }
    double result = (rank * n) / s1.length;
    //Utl.log("relevance ${tosearch} / ${document}", result);
    return result;
  }

  static rightStr(String s, int length) {
    return s.substring(s.length - length);
  }

  static bool checkSync(Function func) {
    if (func is Future Function()) return true;
    // Repeat as long as you want to.
    return false;
  }

  static String weekDay(DateTime date) {
    return [
      "Domingo",
      "Segunda",
      "Terça",
      "Quarta",
      "Quinta",
      "Sexta",
      "Sábado",
      "Domingo"
    ][date.weekday];
  }

  static w.Widget futureWidget(Future<w.Widget> future) {
    return w.FutureBuilder<w.Widget>(
        future: future,
        builder: (_, snapshot) {
          return snapshot.hasData
              ? snapshot.data!
              : const w.Center(
                  child: w.CircularProgressIndicator(color: w.Colors.blue));
        });
  }
}

extension FirstWhereOrNullExtension<E> on Iterable<E> {
  E? firstWhereOrNull(bool Function(E) test) {
    for (E element in this) {
      if (test(element)) return element;
    }
    return null;
  }
}

extension GlobalKeyExtension on w.GlobalKey {
  w.Rect? get globalPaintBounds {
    final renderObject = currentContext?.findRenderObject();
    var translation = renderObject?.getTransformTo(null).getTranslation();
    if (translation != null && renderObject?.paintBounds != null) {
      return renderObject!.paintBounds
          .shift(w.Offset(translation.x, translation.y));
    } else {
      return null;
    }
  }
}
