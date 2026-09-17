import 'dart:async';

import 'package:flutter/material.dart';

import '../config/region_config.dart';
import '../models/weather_models.dart';
import '../services/weather_service.dart';
import '../widgets/weather_widgets.dart';

class WeatherHomePage extends StatefulWidget {
  const WeatherHomePage({super.key});

  @override
  State<WeatherHomePage> createState() => _WeatherHomePageState();
}

class _WeatherHomePageState extends State<WeatherHomePage> {
  final PageController _pageController = PageController();
  final WeatherService _weatherService = WeatherService();

  int selectedIndex = 0;
  List<RegionWeather> regions = [];

  bool isLoading = true;
  bool isRefreshing = false;
  String? errorMessage;

  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _loadWeather();

    _timer = Timer.periodic(
      const Duration(minutes: 15),
          (_) => _loadWeather(isAutoRefresh: true),
    );
  }

  Future<void> _loadWeather({bool isAutoRefresh = false}) async {
    if (!mounted) return;

    setState(() {
      if (regions.isEmpty) {
        isLoading = true;
      } else {
        isRefreshing = true;
      }

      if (!isAutoRefresh) {
        errorMessage = null;
      }
    });

    try {
      final results = await Future.wait(
        monitoredRegions.map(_weatherService.fetchWeather),
      );

      if (!mounted) return;

      setState(() {
        regions = results;
        isLoading = false;
        isRefreshing = false;
        errorMessage = null;

        if (selectedIndex >= regions.length) {
          selectedIndex = 0;
        }
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
        isRefreshing = false;
        errorMessage = 'Não foi possível atualizar o clima.';
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Stack(
          children: [
            WeatherBackground(),
            Center(
              child: CircularProgressIndicator(),
            ),
          ],
        ),
      );
    }

    if (regions.isEmpty && errorMessage != null) {
      return Scaffold(
        body: Stack(
          children: [
            const WeatherBackground(),
            Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: GlassCard(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.cloud_off_rounded, size: 42),
                      const SizedBox(height: 16),
                      Text(
                        errorMessage!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: _loadWeather,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Tentar novamente'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          const WeatherBackground(),

          RefreshIndicator(
            onRefresh: () => _loadWeather(),
            child: PageView.builder(
              controller: _pageController,
              itemCount: regions.length,
              onPageChanged: (index) {
                setState(() {
                  selectedIndex = index;
                });
              },
              itemBuilder: (context, index) {
                return WeatherPage(
                  weather: regions[index],
                  allRegions: regions,
                );
              },
            ),
          ),

          if (isRefreshing)
            Positioned(
              top: MediaQuery.of(context).padding.top + 12,
              right: 20,
              child: const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),

          Positioned(
            left: 0,
            right: 0,
            bottom: 28,
            child: BottomWeatherControls(
              selectedIndex: selectedIndex,
              total: regions.length,
              onTapDot: (index) {
                _pageController.animateToPage(
                  index,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOut,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}