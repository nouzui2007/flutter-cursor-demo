import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'l10n/app_localizations.dart';
import 'models/map_pin.dart';
import 'services/storage_service.dart';
import 'widgets/email_dialog.dart';
import 'screens/pin_list_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'), // English
        Locale('ja'), // Japanese
      ],
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MapPage(),
    );
  }
}

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  GoogleMapController? _mapController;
  final Set<Marker> _markers = {};
  final List<MapPin> _pins = [];
  final StorageService _storageService = StorageService();
  MapType _mapType = MapType.normal;
  bool _isLoading = true;

  // 初期位置（東京）
  static const CameraPosition _initialPosition = CameraPosition(
    target: LatLng(35.6762, 139.6503),
    zoom: 10.0,
  );

  @override
  void initState() {
    super.initState();
    _loadPins();
  }

  Future<void> _loadPins() async {
    try {
      final pins = await _storageService.loadPins();
      setState(() {
        _pins.clear();
        _pins.addAll(pins);
        _updateMarkers();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _updateMarkers() {
    _markers.clear();
    for (final pin in _pins) {
      _markers.add(
        Marker(
          markerId: MarkerId(pin.id),
          position: LatLng(pin.latitude, pin.longitude),
          infoWindow: InfoWindow(
            title: 'ピン ${pin.id}',
            snippet: '緯度: ${pin.latitude.toStringAsFixed(6)}\n経度: ${pin.longitude.toStringAsFixed(6)}',
          ),
          onTap: () => _showPinOptions(pin),
        ),
      );
    }
  }

  void _showPinOptions(MapPin pin) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('ピン ${pin.id}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('緯度: ${pin.latitude.toStringAsFixed(6)}'),
            Text('経度: ${pin.longitude.toStringAsFixed(6)}'),
            Text('作成日時: ${pin.createdAt.toString()}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('閉じる'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _deletePin(pin);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('削除'),
          ),
        ],
      ),
    );
  }

  Future<void> _deletePin(MapPin pin) async {
    try {
      await _storageService.removePin(pin.id);
      setState(() {
        _pins.removeWhere((p) => p.id == pin.id);
        _updateMarkers();
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('ピンを削除しました')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('ピンの削除に失敗しました')),
        );
      }
    }
  }

  void _onMapTap(LatLng position) {
    _addPin(position);
  }

  Future<void> _addPin(LatLng position) async {
    final pin = MapPin(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      latitude: position.latitude,
      longitude: position.longitude,
      createdAt: DateTime.now(),
    );

    try {
      await _storageService.addPin(pin);
      setState(() {
        _pins.add(pin);
        _updateMarkers();
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('ピンを追加しました')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('ピンの追加に失敗しました')),
        );
      }
    }
  }

  void _toggleMapType() {
    setState(() {
      _mapType = _mapType == MapType.normal ? MapType.satellite : MapType.normal;
    });
  }

  void _showEmailDialog() {
    showDialog(
      context: context,
      builder: (context) => EmailDialog(pins: _pins),
    );
  }

  void _showPinList() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => PinListScreen(
          pins: _pins,
          onPinsChanged: () {
            setState(() {
              _updateMarkers();
            });
          },
        ),
      ),
    );
    // 画面から戻った際にピンデータを再読み込み
    await _loadPins();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(l10n.appTitle),
        actions: [
          IconButton(
            onPressed: _toggleMapType,
            icon: Icon(_mapType == MapType.normal ? Icons.satellite : Icons.map),
            tooltip: l10n.mapTypeToggle,
          ),
          IconButton(
            onPressed: _showEmailDialog,
            icon: const Icon(Icons.email),
            tooltip: l10n.emailSend,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('地図を読み込み中...'),
                  Text('（APIキーの設定を確認してください）'),
                ],
              ),
            )
          : Stack(
              children: [
                GoogleMap(
                  onMapCreated: (GoogleMapController controller) {
                    _mapController = controller;
                  },
                  initialCameraPosition: _initialPosition,
                  mapType: _mapType,
                  markers: _markers,
                  onTap: _onMapTap,
                  myLocationEnabled: true,
                  myLocationButtonEnabled: false, // カスタムボタンを使用
                  zoomControlsEnabled: true, // ズームボタンを有効化
                ),
                // 左側のボタン群
                Positioned(
                  left: 16,
                  bottom: 120, // ズームボタンの上に配置
                  child: Column(
                    children: [
                      FloatingActionButton(
                        onPressed: _showPinList,
                        tooltip: 'ピンリスト',
                        child: const Icon(Icons.list),
                        heroTag: 'pinList',
                      ),
                      const SizedBox(height: 16),
                      FloatingActionButton(
                        onPressed: _showEmailDialog,
                        tooltip: l10n.emailSend,
                        child: const Icon(Icons.email),
                        heroTag: 'email',
                      ),
                      const SizedBox(height: 16),
                      FloatingActionButton(
                        onPressed: () {
                          if (_mapController != null) {
                            _mapController!.animateCamera(
                              CameraUpdate.newCameraPosition(_initialPosition),
                            );
                          }
                        },
                        tooltip: l10n.returnToInitialPosition,
                        child: const Icon(Icons.my_location),
                        heroTag: 'location',
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
