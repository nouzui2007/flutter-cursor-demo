import 'package:flutter/material.dart';
import '../models/map_pin.dart';
import '../services/storage_service.dart';
import '../l10n/app_localizations.dart';

class PinListScreen extends StatefulWidget {
  final List<MapPin> pins;
  final VoidCallback onPinsChanged;

  const PinListScreen({
    super.key,
    required this.pins,
    required this.onPinsChanged,
  });

  @override
  State<PinListScreen> createState() => _PinListScreenState();
}

class _PinListScreenState extends State<PinListScreen> {
  final StorageService _storageService = StorageService();

  Future<void> _deletePin(MapPin pin) async {
    try {
      await _storageService.removePin(pin.id);
      widget.onPinsChanged();
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

  Future<void> _deleteAllPins() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('確認'),
        content: const Text('すべてのピンを削除しますか？\nこの操作は取り消せません。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('削除'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        for (final pin in widget.pins) {
          await _storageService.removePin(pin.id);
        }
        widget.onPinsChanged();
        if (mounted) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('すべてのピンを削除しました')),
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
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('${l10n.pinList} (${widget.pins.length})'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          if (widget.pins.isNotEmpty)
            IconButton(
              onPressed: _deleteAllPins,
              icon: const Icon(Icons.delete_sweep),
              tooltip: l10n.deleteAllPins,
            ),
        ],
      ),
      body: widget.pins.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.location_off, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(l10n.noPins),
                  Text(l10n.addPinInstruction),
                ],
              ),
            )
          : ListView.builder(
              itemCount: widget.pins.length,
              itemBuilder: (context, index) {
                final pin = widget.pins[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: ListTile(
                    leading: const Icon(Icons.location_on, color: Colors.red),
                    title: Text('ピン ${pin.id}'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('緯度: ${pin.latitude.toStringAsFixed(6)}'),
                        Text('経度: ${pin.longitude.toStringAsFixed(6)}'),
                        Text('作成日時: ${_formatDateTime(pin.createdAt)}'),
                      ],
                    ),
                    trailing: IconButton(
                      onPressed: () => _deletePin(pin),
                      icon: const Icon(Icons.delete, color: Colors.red),
                      tooltip: '削除',
                    ),
                    isThreeLine: true,
                  ),
                );
              },
            ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.day.toString().padLeft(2, '0')} '
        '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
