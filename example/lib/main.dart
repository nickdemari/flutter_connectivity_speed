// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:flutter_connectivity_speed/entities/network_connection.dart';
import 'package:flutter_connectivity_speed/flutter_connectivity_speed.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider(
          create: (_) => FlutterConnectivitySpeed(),
        ),
      ],
      child: MaterialApp(
        title: 'Connectivity Speed Checker',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: const ConnectivityScreen(),
      ),
    );
  }
}

class ConnectivityScreen extends StatefulWidget {
  const ConnectivityScreen({super.key});

  @override
  _ConnectivityScreenState createState() => _ConnectivityScreenState();
}

class _ConnectivityScreenState extends State<ConnectivityScreen> {
  late FlutterConnectivitySpeed checker;

  @override
  void initState() {
    super.initState();
    checker = Provider.of<FlutterConnectivitySpeed>(context, listen: false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Connectivity Speed'),
      ),
      body: StreamBuilder<NetworkCondition>(
        stream: checker.onNetworkConditionChanged,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final lastCondition = snapshot.data!;

            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Condition: ${lastCondition.condition}'),
                  Text('Download Speed: ${lastCondition.downlinkSpeed}'),
                  Text('Upload Speed: ${lastCondition.uplinkSpeed}'),
                ],
              ),
            );
          }
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }
}
