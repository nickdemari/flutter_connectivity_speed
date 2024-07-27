import 'package:flutter_connectivity_speed/entities/condition_type.dart';

class NetworkCondition {
  final double downlinkSpeed;
  final double uplinkSpeed;
  final ConditionType condition;

  NetworkCondition({
    required this.downlinkSpeed,
    required this.uplinkSpeed,
    required this.condition,
  });

  @override
  String toString() {
    return 'NetworkCondition(downlinkSpeed: $downlinkSpeed, uplinkSpeed: $uplinkSpeed, condition: $condition)';
  }
}
