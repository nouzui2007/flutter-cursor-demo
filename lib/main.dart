import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'l10n/app_localizations.dart';
import 'models/map_pin.dart';
import 'services/storage_service.dart';
import 'services/location_service.dart';
import 'widgets/email_dialog.dart';
import 'screens/pin_list_screen.dart';
import 'screens/home_screen.dart';
import 'screens/api_connection_screen.dart';

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
      home: const MainNavigationScreen(),
    );
  }
}

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const MapPage(),
    const ApiConnectionScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'ホーム',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: '地図',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.api),
            label: 'API接続',
          ),
        ],
      ),
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

  // 初期位置（現在位置 - 東京）
  static const CameraPosition _initialPosition = CameraPosition(
    target: LatLng(35.6762, 139.6503),
    zoom: 15.0, // 街路レベルのズーム
  );

  // 現在位置表示時のズームレベル
  static const double _currentLocationZoom = 18.0; // 建物レベルのズーム

  @override
  void initState() {
    super.initState();
    _loadPins();
    _requestLocationPermission();
  }

  /// 位置情報の許可を要求
  Future<void> _requestLocationPermission() async {
    bool needsPermission = await LocationService.needsLocationPermission();
    if (needsPermission) {
      await LocationService.requestPermission();
    }
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

  /// 現在位置に移動
  Future<void> _goToCurrentLocation() async {
    // 位置情報の許可を確認
    bool needsPermission = await LocationService.needsLocationPermission();
    if (needsPermission) {
      // 許可を要求
      PermissionStatus permission = await LocationService.requestPermission();
      if (permission.isDenied || permission.isPermanentlyDenied) {
        // 許可が拒否された場合
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('位置情報の許可が必要です。設定から許可してください。'),
              duration: Duration(seconds: 3),
            ),
          );
        }
        return;
      }
    }

    // 位置情報サービスが有効かチェック
    bool isLocationEnabled = await LocationService.isLocationServiceEnabled();
    if (!isLocationEnabled) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('位置情報サービスが無効です。設定から有効にしてください。'),
            duration: Duration(seconds: 3),
          ),
        );
      }
      return;
    }

    // 現在位置を取得して地図を移動
    try {
      // 実際の現在位置を取得
      final currentLocation = await LocationService.getCurrentLatLng();
      
      if (currentLocation != null && _mapController != null) {
        _mapController!.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: currentLocation,
              zoom: _currentLocationZoom, // 定数で定義されたズームレベル
            ),
          ),
        );
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('現在位置に移動しました。地図の中心に配置し、詳細表示しています。'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('現在位置を取得できませんでした。'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('現在位置の取得に失敗しました。'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
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
                        onPressed: _goToCurrentLocation,
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
