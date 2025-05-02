import 'package:equatable/equatable.dart';

class LocationSuggestion extends Equatable {
  final String name;
  final String? country;
  final String? state;
  final double? lat;
  final double? lon;

  const LocationSuggestion({
    required this.name,
    this.country,
    this.state,
    this.lat,
    this.lon
  });

  // Helper để tạo chuỗi hiển thị thân thiện
  String get displayName {
    List<String?> parts = [name, state, country];
    parts.removeWhere((part) => part == null || part.isEmpty);
    if (parts.length > 1 && parts[0] == parts[1]) {
      parts.removeAt(1);
    }
    return parts.join(', '); // Ví dụ: "Hanoi, VN" hoặc "London, GB" hoặc "London, Ontario, CA"
  }

  @override
  List<Object?> get props => [name, country, state,lat,lon];

}