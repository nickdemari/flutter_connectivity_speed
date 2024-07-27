import 'package:flutter_connectivity_speed/entities/connection_types.dart';

class ConnectivityCheck {
  final ConnectionType connectionType;
  final double speed;

  ConnectivityCheck({required this.connectionType, required this.speed});
}
