enum ConnectionType {
  wifi,
  mobile,
  ethernet,
  bluetooth,
  none;

  bool get isNetwork => this == wifi || this == mobile || this == ethernet;

  String get name {
    switch (this) {
      case wifi:
        return 'WiFi';
      case mobile:
        return 'Mobile Data';
      case ethernet:
        return 'Ethernet';
      case bluetooth:
        return 'Bluetooth';
      case none:
        return 'No Internet';
    }
  }
}
