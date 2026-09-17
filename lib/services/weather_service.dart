import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../config/region_config.dart';
import '../models/weather_models.dart';

class WeatherService {
  Future<RegionWeather> fetchWeather(RegionConfig config) async {
    final uri = Uri.parse(
      'https://api.open-meteo.com/v1/forecast'
          '?latitude=${config.latitude}'
          '&longitude=${config.longitude}'
          '&current=temperature_2m,weather_code'
          '&hourly=temperature_2m,weather_code,precipitation_probability'
          '&daily=temperature_2m_max,temperature_2m_min,precipitation_probability_max,weather_code'
          '&timezone=America%2FSao_Paulo'
          '&forecast_days=10',
    );

    final response = await http.get(uri);

    debugPrint('CONSULTANDO API: $uri');
    debugPrint('STATUS CODE: ${response.statusCode}');
    debugPrint('RESPOSTA API: ${response.body}');

    if (response.statusCode != 200) {
      throw Exception('Falha ao consultar clima. Código: ${response.statusCode}');
    }

    final Map<String, dynamic> data =
    jsonDecode(response.body) as Map<String, dynamic>;

    final current = data['current'] as Map<String, dynamic>;
    final hourly = data['hourly'] as Map<String, dynamic>;
    final daily = data['daily'] as Map<String, dynamic>;

    final int currentTemp = _toInt(current['temperature_2m']);
    final int currentWeatherCode = _toInt(current['weather_code']);
    final String currentTime = current['time'].toString();

    final List<dynamic> hourlyTimes = hourly['time'] as List<dynamic>;
    final List<dynamic> hourlyTemps = hourly['temperature_2m'] as List<dynamic>;
    final List<dynamic> hourlyCodes = hourly['weather_code'] as List<dynamic>;

    final int startIndex = _findCurrentHourIndex(
      hourlyTimes: hourlyTimes,
      currentTime: currentTime,
    );

    final List<HourlyWeather> hourlyList = [];

    for (int i = startIndex; i < startIndex + 6 && i < hourlyTemps.length; i++) {
      hourlyList.add(
        HourlyWeather(
          i == startIndex ? 'Agora' : _extractHour(hourlyTimes[i].toString()),
          _toInt(hourlyTemps[i]),
          _weatherIcon(_toInt(hourlyCodes[i])),
        ),
      );
    }

    final List<dynamic> dailyTimes = daily['time'] as List<dynamic>;
    final List<dynamic> dailyMin = daily['temperature_2m_min'] as List<dynamic>;
    final List<dynamic> dailyMax = daily['temperature_2m_max'] as List<dynamic>;
    final List<dynamic> dailyRain =
    daily['precipitation_probability_max'] as List<dynamic>;
    final List<dynamic> dailyCodes = daily['weather_code'] as List<dynamic>;

    final List<DailyWeather> dailyList = [];

    for (int i = 0; i < dailyTimes.length; i++) {
      dailyList.add(
        DailyWeather(
          i == 0 ? 'Hoje' : _weekdayLabel(dailyTimes[i].toString()),
          _toInt(dailyMin[i]),
          _toInt(dailyMax[i]),
          dailyRain[i] == null ? null : _toInt(dailyRain[i]),
          _weatherIcon(_toInt(dailyCodes[i])),
        ),
      );
    }

    return RegionWeather(
      region: config.region,
      area: config.area,
      temperature: currentTemp,
      condition: _weatherDescription(currentWeatherCode),
      min: dailyList.first.min,
      max: dailyList.first.max,
      alertTitle: _alertTitle(currentWeatherCode),
      alertMessage: _alertMessage(currentWeatherCode),
      hourly: hourlyList,
      daily: dailyList,
    );
  }

  int _toInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.round();
    if (value is num) return value.round();
    return int.tryParse(value.toString()) ?? 0;
  }

  int _findCurrentHourIndex({
    required List<dynamic> hourlyTimes,
    required String currentTime,
  }) {
    final int exactIndex = hourlyTimes.indexWhere(
          (time) => time.toString() == currentTime,
    );

    if (exactIndex >= 0) return exactIndex;

    final DateTime now = DateTime.parse(currentTime);

    final int closestIndex = hourlyTimes.indexWhere((time) {
      final parsed = DateTime.parse(time.toString());
      return parsed.isAfter(now) || parsed.isAtSameMomentAs(now);
    });

    return closestIndex >= 0 ? closestIndex : 0;
  }

  String _extractHour(String isoDate) {
    final date = DateTime.parse(isoDate);
    return date.hour.toString().padLeft(2, '0');
  }

  String _weekdayLabel(String isoDate) {
    final date = DateTime.parse(isoDate);

    switch (date.weekday) {
      case DateTime.monday:
        return 'Seg.';
      case DateTime.tuesday:
        return 'Ter.';
      case DateTime.wednesday:
        return 'Qua.';
      case DateTime.thursday:
        return 'Qui.';
      case DateTime.friday:
        return 'Sex.';
      case DateTime.saturday:
        return 'Sáb.';
      case DateTime.sunday:
        return 'Dom.';
      default:
        return '';
    }
  }

  String _weatherDescription(int code) {
    if (code == 0) return 'Céu limpo';
    if ({1, 2, 3}.contains(code)) return 'Parcialmente nublado';
    if ({45, 48}.contains(code)) return 'Neblina';
    if ({51, 53, 55}.contains(code)) return 'Garoa';
    if ({56, 57}.contains(code)) return 'Garoa congelante';
    if ({61, 63, 65}.contains(code)) return 'Chuva';
    if ({66, 67}.contains(code)) return 'Chuva congelante';
    if ({71, 73, 75, 77}.contains(code)) return 'Neve';
    if ({80, 81, 82}.contains(code)) return 'Pancadas de chuva';
    if ({95, 96, 99}.contains(code)) return 'Tempestade';

    return 'Condição variável';
  }

  IconData _weatherIcon(int code) {
    if (code == 0) return Icons.wb_sunny;
    if ({1, 2, 3}.contains(code)) return Icons.cloud;
    if ({45, 48}.contains(code)) return Icons.foggy;

    if ({
      51,
      53,
      55,
      56,
      57,
      61,
      63,
      65,
      66,
      67,
      80,
      81,
      82,
    }.contains(code)) {
      return Icons.water_drop;
    }

    if ({71, 73, 75, 77}.contains(code)) return Icons.ac_unit;
    if ({95, 96, 99}.contains(code)) return Icons.thunderstorm;

    return Icons.cloud;
  }

  String _alertTitle(int code) {
    if ({95, 96, 99}.contains(code)) return 'Risco de tempestade';
    if ({61, 63, 65, 80, 81, 82}.contains(code)) return 'Chuva prevista';
    if ({45, 48}.contains(code)) return 'Baixa visibilidade';
    if (code == 0) return 'Tempo estável';

    return 'Atenção ao clima';
  }

  String _alertMessage(int code) {
    if ({95, 96, 99}.contains(code)) {
      return 'Possibilidade de tempestade. Atenção a rajadas, descargas atmosféricas e alagamentos.';
    }

    if ({61, 63, 65, 80, 81, 82}.contains(code)) {
      return 'Previsão de chuva. Avalie deslocamentos, áreas abertas e pontos sujeitos a alagamento.';
    }

    if ({45, 48}.contains(code)) {
      return 'Neblina prevista. Atenção à visibilidade em deslocamentos.';
    }

    if (code == 0) {
      return 'Condição climática favorável no momento.';
    }

    return 'Condição climática sujeita a variação ao longo do dia.';
  }
}