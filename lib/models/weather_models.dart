import 'package:flutter/material.dart';

class RegionWeather {
  final String region;
  final String area;
  final int temperature;
  final String condition;
  final int min;
  final int max;
  final String alertTitle;
  final String alertMessage;
  final List<HourlyWeather> hourly;
  final List<DailyWeather> daily;

  RegionWeather({
    required this.region,
    required this.area,
    required this.temperature,
    required this.condition,
    required this.min,
    required this.max,
    required this.alertTitle,
    required this.alertMessage,
    required this.hourly,
    required this.daily,
  });
}

class HourlyWeather {
  final String hour;
  final int temperature;
  final IconData icon;

  HourlyWeather(
      this.hour,
      this.temperature,
      this.icon,
      );
}

class DailyWeather {
  final String label;
  final int min;
  final int max;
  final int? rainChance;
  final IconData icon;

  DailyWeather(
      this.label,
      this.min,
      this.max,
      this.rainChance,
      this.icon,
      );
}