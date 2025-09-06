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
import 'screens/attendance_screen.dart';

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
    const AttendanceScreen(),
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
            icon: Icon(Icons.access_time),
            label: '勤怠管理',
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

  // 初期位置（現在位置を動的に取得）
  CameraPosition? _initialPosition;

  @override
  void initState() {
    super.initState();
    _initializeMap();
  }

  /// 地図の初期化（位置情報取得完了まで待つ）
  Future<void> _initializeMap() async {
    try {
      // 位置情報の許可を要求
      await _requestLocationPermission();
      
      // 現在位置を取得して初期位置として設定
      await _initializeInitialPosition();
      
      // ピンデータを読み込み
      await _loadPins();
      
      // ローディング状態を解除
      setState(() {
        _isLoading = false;
      });
      
      // 現在位置の初期化（必要に応じて）
      _initializeCurrentLocation();
    } catch (e) {
      // エラーが発生した場合でも地図は表示する
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// 初期位置を設定
  Future<void> _initializeInitialPosition() async {
    int retryCount = 0;
    const maxRetries = 3;
    
    while (retryCount < maxRetries) {
      try {
        // 現在位置を取得して初期位置として設定
        final currentLocation = await LocationService.getCurrentLatLng();
        if (currentLocation != null) {
          _initialPosition = CameraPosition(
            target: currentLocation,
            zoom: 15.0, // 街路レベルのズーム
          );
          return; // 成功したら終了
        }
        
        // 位置情報が取得できない場合は少し待ってから再試行
        retryCount++;
        if (retryCount < maxRetries) {
          await Future.delayed(Duration(seconds: 2 * retryCount)); // 指数バックオフ
        }
      } catch (e) {
        retryCount++;
        if (retryCount < maxRetries) {
          await Future.delayed(Duration(seconds: 2 * retryCount));
        }
      }
    }
    
    // 最大試行回数に達した場合はデフォルト位置
    _initialPosition = const CameraPosition(
      target: LatLng(35.0, 135.0),
      zoom: 8.0, // より広い範囲
    );
  }

  /// 位置情報の許可を要求
  Future<void> _requestLocationPermission() async {
    bool needsPermission = await LocationService.needsLocationPermission();
    if (needsPermission) {
      // ユーザーに許可の理由を説明
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: const Text('位置情報の許可'),
            content: const Text(
              'このアプリは地図上で現在位置を表示し、ピンの位置を管理するために位置情報を使用します。\n\n'
              '位置情報は地図の表示とピンの追加・管理にのみ使用され、他の目的には使用されません。',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _requestPermissionDirectly();
                },
                child: const Text('許可する'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('後で'),
              ),
            ],
          ),
        );
      }
    }
  }

  /// 直接許可を要求
  Future<void> _requestPermissionDirectly() async {
    print('🔍 直接許可を要求中...');
    PermissionStatus permission = await LocationService.requestPermission();
    print('📋 許可要求結果: $permission');
    
    if (permission.isDenied || permission.isPermanentlyDenied) {
      print('❌ 位置情報の許可が拒否されました');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('位置情報の許可が必要です。設定から許可してください。'),
            duration: Duration(seconds: 3),
          ),
        );
      }
    } else if (permission.isGranted) {
      print('✅ 位置情報の許可が取得されました');
      // 許可が取得されたら現在位置を再試行
      _initializeCurrentLocation();
    }
  }

  /// 現在位置に移動（初期位置が現在位置と異なる場合のみ）
  Future<void> _initializeCurrentLocation() async {
    try {
      print('🔍 現在位置の初期化を開始...');
      
      // 位置情報の許可を確認
      bool needsPermission = await LocationService.needsLocationPermission();
      print('📋 位置情報許可が必要: $needsPermission');
      
      if (needsPermission) {
        print('❌ 位置情報の許可がありません');
        return; // 許可がなければ初期位置のまま
      }

      // 位置情報サービスが有効かチェック
      bool isLocationEnabled = await LocationService.isLocationServiceEnabled();
      print('📍 位置情報サービス有効: $isLocationEnabled');
      
      if (!isLocationEnabled) {
        print('❌ 位置情報サービスが無効です');
        return; // サービスが無効なら初期位置のまま
      }

      // 現在位置を取得
      print('🎯 現在位置を取得中...');
      final currentLocation = await LocationService.getCurrentLatLng();
      print('📍 取得した位置: $currentLocation');
      
      if (currentLocation != null && _mapController != null) {
        print('✅ 現在位置を取得しました: ${currentLocation.latitude}, ${currentLocation.longitude}');
        
        // 初期位置と現在位置が異なる場合のみ移動
        if (_initialPosition != null &&
            (_initialPosition!.target.latitude != currentLocation.latitude ||
             _initialPosition!.target.longitude != currentLocation.longitude)) {
          print('🗺️ 地図を現在位置に移動中...');
          _mapController!.animateCamera(
            CameraUpdate.newCameraPosition(
              CameraPosition(
                target: currentLocation,
                zoom: 15.0,
              ),
            ),
          );
        } else {
          print('ℹ️ 初期位置と現在位置が同じです');
        }
      } else {
        print('❌ 現在位置の取得に失敗しました');
        if (currentLocation == null) {
          print('❌ currentLocation が null です');
        }
        if (_mapController == null) {
          print('❌ _mapController が null です');
        }
      }
    } catch (e) {
      print('❌ 現在位置の初期化でエラーが発生: $e');
    }
  }

  Future<void> _loadPins() async {
    try {
      final pins = await _storageService.loadPins();
      setState(() {
        _pins.clear();
        _pins.addAll(pins);
        _updateMarkers();
      });
    } catch (e) {
      // エラーが発生した場合は空のリストのまま
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

  /// 現在位置に移動（ズームレベル18で）
  Future<void> _goToCurrentLocation() async {
    try {
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

      // 実際の現在位置を取得
      final currentLocation = await LocationService.getCurrentLatLng();
      
      if (currentLocation != null && _mapController != null) {
        // 現在位置に移動（ズームレベル18）
        _mapController!.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: currentLocation,
              zoom: 18.0, // 建物レベルのズーム
            ),
          ),
        );
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('現在位置に移動し、詳細表示にズームしました。'),
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
            content: Text('現在位置の移動に失敗しました。'),
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
            onPressed: _goToCurrentLocation,
            icon: const Icon(Icons.my_location),
            tooltip: '現在位置に移動',
          ),
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
                  Text('位置情報を取得中...'),
                  Text('現在位置を取得してから地図を表示します'),
                  SizedBox(height: 8),
                  Text('（最大30秒程度かかる場合があります）'),
                ],
              ),
            )
          : Stack(
              children: [
                GoogleMap(
                  onMapCreated: (GoogleMapController controller) {
                    _mapController = controller;
                  },
                  initialCameraPosition: _initialPosition ?? const CameraPosition(
                    target: LatLng(35.0, 135.0),
                    zoom: 8.0,
                  ),
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
                        heroTag: 'pinList',
                        child: const Icon(Icons.list),
                      ),
                      const SizedBox(height: 16),
                      FloatingActionButton(
                        onPressed: _showEmailDialog,
                        tooltip: l10n.emailSend,
                        heroTag: 'email',
                        child: const Icon(Icons.email),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
