import 'dart:ui';

import 'package:flutter/material.dart';

import '../models/weather_models.dart';

class WeatherPage extends StatelessWidget {
  final RegionWeather weather;
  final List<RegionWeather> allRegions;

  const WeatherPage({
    super.key,
    required this.weather,
    required this.allRegions,
  });

  @override
  Widget build(BuildContext context) {
    final int globalMin =
    weather.daily.map((e) => e.min).reduce((a, b) => a < b ? a : b);
    final int globalMax =
    weather.daily.map((e) => e.max).reduce((a, b) => a > b ? a : b);

    return SafeArea(
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 120),
        child: Column(
          children: [
            const SizedBox(height: 12),

            Text(
              weather.area.toUpperCase(),
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
                color: Colors.white.withOpacity(0.85),
              ),
            ),

            const SizedBox(height: 4),

            Text(
              weather.region,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 42,
                fontWeight: FontWeight.w400,
                height: 1.05,
              ),
            ),

            const SizedBox(height: 4),

            Text(
              '${weather.temperature}°',
              style: const TextStyle(
                fontSize: 104,
                fontWeight: FontWeight.w200,
                height: 1,
              ),
            ),

            Text(
              weather.condition,
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.w500,
                color: Colors.white.withOpacity(0.9),
              ),
            ),

            const SizedBox(height: 2),

            Text(
              'Máx.: ${weather.max}°  Mín.: ${weather.min}°',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 110),

            GlassCard(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.warning_rounded, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          weather.alertTitle,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          weather.alertMessage,
                          style: TextStyle(
                            fontSize: 17,
                            height: 1.25,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Fonte: Open-Meteo | Atualização automática a cada 15 min',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.white.withOpacity(0.45),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SectionTitle(
                    icon: Icons.access_time,
                    title: 'PREVISÃO HORÁRIA',
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    height: 112,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: weather.hourly.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 14),
                      itemBuilder: (context, index) {
                        final item = weather.hourly[index];

                        return HourlyCard(item: item);
                      },
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SectionTitle(
                    icon: Icons.calendar_month,
                    title: 'PREVISÃO PARA 10 DIAS',
                  ),
                  const SizedBox(height: 10),

                  for (final day in weather.daily)
                    DailyForecastRow(
                      day: day,
                      globalMin: globalMin,
                      globalMax: globalMax,
                    ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SectionTitle(
                    icon: Icons.public,
                    title: 'REGIÕES MONITORADAS',
                  ),
                  const SizedBox(height: 12),

                  for (final region in allRegions)
                    RegionTemperatureTile(region: region),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class WeatherBackground extends StatelessWidget {
  const WeatherBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF111827),
                Color(0xFF172033),
                Color(0xFF0B1020),
              ],
            ),
          ),
        ),

        Positioned(
          top: -90,
          left: -40,
          child: BlurCircle(
            size: 260,
            color: Colors.blueAccent.withOpacity(0.28),
          ),
        ),

        Positioned(
          top: 160,
          right: -80,
          child: BlurCircle(
            size: 240,
            color: Colors.indigoAccent.withOpacity(0.20),
          ),
        ),

        Positioned(
          bottom: 80,
          left: -70,
          child: BlurCircle(
            size: 220,
            color: Colors.cyanAccent.withOpacity(0.12),
          ),
        ),
      ],
    );
  }
}

class BlurCircle extends StatelessWidget {
  final double size;
  final Color color;

  const BlurCircle({
    super.key,
    required this.size,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return ImageFiltered(
      imageFilter: ImageFilter.blur(sigmaX: 70, sigmaY: 70),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

class GlassCard extends StatelessWidget {
  final Widget child;

  const GlassCard({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: const Color(0xFF253044).withOpacity(0.62),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: Colors.white.withOpacity(0.10),
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  final IconData icon;
  final String title;

  const SectionTitle({
    super.key,
    required this.icon,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: Colors.white.withOpacity(0.45),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.6,
            color: Colors.white.withOpacity(0.45),
          ),
        ),
      ],
    );
  }
}

class HourlyCard extends StatelessWidget {
  final HourlyWeather item;

  const HourlyCard({
    super.key,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 58,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            item.hour,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          Icon(
            item.icon,
            size: 30,
            color: Colors.white,
          ),
          Text(
            '${item.temperature}°',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class DailyForecastRow extends StatelessWidget {
  final DailyWeather day;
  final int globalMin;
  final int globalMax;

  const DailyForecastRow({
    super.key,
    required this.day,
    required this.globalMin,
    required this.globalMax,
  });

  @override
  Widget build(BuildContext context) {
    final double range = (globalMax - globalMin).toDouble().clamp(1, 100);
    final double start = (day.min - globalMin) / range;
    final double width = (day.max - day.min) / range;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Colors.white.withOpacity(0.10),
          ),
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 68,
            child: Text(
              day.label,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),

          SizedBox(
            width: 54,
            child: Column(
              children: [
                Icon(
                  day.icon,
                  size: 27,
                  color: Colors.white,
                ),
                if (day.rainChance != null)
                  Text(
                    '${day.rainChance}%',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: Colors.cyanAccent,
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          SizedBox(
            width: 42,
            child: Text(
              '${day.min}°',
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.w700,
                color: Colors.white.withOpacity(0.42),
              ),
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final double totalWidth = constraints.maxWidth;
                final double left = totalWidth * start;
                final double barWidth = totalWidth * width.clamp(0.12, 1.0);

                return Stack(
                  alignment: Alignment.centerLeft,
                  children: [
                    Container(
                      height: 6,
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.22),
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                    Positioned(
                      left: left,
                      child: Container(
                        width: barWidth,
                        height: 6,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              Colors.cyanAccent,
                              Colors.yellowAccent,
                              Colors.orangeAccent,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),

          const SizedBox(width: 12),

          SizedBox(
            width: 42,
            child: Text(
              '${day.max}°',
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class RegionTemperatureTile extends StatelessWidget {
  final RegionWeather region;

  const RegionTemperatureTile({
    super.key,
    required this.region,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 12,
      ),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Colors.white.withOpacity(0.10),
          ),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.location_on_rounded, size: 22),
          const SizedBox(width: 10),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  region.region,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  region.condition,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.62),
                  ),
                ),
              ],
            ),
          ),

          Text(
            '${region.temperature}°',
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w300,
            ),
          ),
        ],
      ),
    );
  }
}

class BottomWeatherControls extends StatelessWidget {
  final int selectedIndex;
  final int total;
  final ValueChanged<int> onTapDot;

  const BottomWeatherControls({
    super.key,
    required this.selectedIndex,
    required this.total,
    required this.onTapDot,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GlassCard(
        child: SizedBox(
          width: 190,
          height: 34,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.navigation_rounded, size: 20),
              const SizedBox(width: 16),

              for (int i = 0; i < total; i++)
                GestureDetector(
                  onTap: () => onTapDot(i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    margin: const EdgeInsets.symmetric(horizontal: 5),
                    width: selectedIndex == i ? 11 : 9,
                    height: selectedIndex == i ? 11 : 9,
                    decoration: BoxDecoration(
                      color: selectedIndex == i
                          ? Colors.white
                          : Colors.white.withOpacity(0.35),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),

              const SizedBox(width: 16),
              const Icon(Icons.menu_rounded, size: 24),
            ],
          ),
        ),
      ),
    );
  }
}