class RegionConfig {
  final String region;
  final String area;
  final double latitude;
  final double longitude;

  const RegionConfig({
    required this.region,
    required this.area,
    required this.latitude,
    required this.longitude,
  });
}

const List<RegionConfig> monitoredRegions = [
  RegionConfig(
    region: 'São Paulo',
    area: 'Capital',
    latitude: -23.5505,
    longitude: -46.6333,
  ),
  RegionConfig(
    region: 'Campinas',
    area: 'Interior de SP',
    latitude: -22.9056,
    longitude: -47.0608,
  ),
  RegionConfig(
    region: 'Santos',
    area: 'Litoral de SP',
    latitude: -23.9608,
    longitude: -46.3336,
  ),
  RegionConfig(
    region: 'Rio de Janeiro',
    area: 'Sudeste',
    latitude: -22.9068,
    longitude: -43.1729,
  ),
];