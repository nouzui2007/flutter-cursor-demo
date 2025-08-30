import 'package:flutter/material.dart';
import '../models/map_pin.dart';
import '../services/email_service.dart';
import '../services/storage_service.dart';

class EmailDialog extends StatefulWidget {
  final List<MapPin> pins;

  const EmailDialog({super.key, required this.pins});

  @override
  State<EmailDialog> createState() => _EmailDialogState();
}

class _EmailDialogState extends State<EmailDialog> {
  final _emailController = TextEditingController();
  final _storageService = StorageService();
  final _emailService = EmailService();
  String _selectedOption = 'all'; // 'all' or 'new'
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadSavedEmail();
  }

  Future<void> _loadSavedEmail() async {
    final savedEmail = await _storageService.loadEmail();
    if (savedEmail != null) {
      _emailController.text = savedEmail;
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _sendEmail() async {
    if (_emailController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('メールアドレスを入力してください')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final email = _emailController.text.trim();
      final subject = '地図ピンデータ';
      
      List<MapPin> pinsToSend;
      if (_selectedOption == 'new') {
        // 新規ピンのみ（過去1時間以内）
        final oneHourAgo = DateTime.now().subtract(const Duration(hours: 1));
        pinsToSend = _emailService.getNewPins(widget.pins, oneHourAgo);
      } else {
        // 全ピン
        pinsToSend = widget.pins;
      }

      final body = _emailService.createEmailBody(pinsToSend);
      
      await _emailService.sendEmail(
        to: email,
        subject: subject,
        body: body,
      );

      // メールアドレスを保存
      await _storageService.saveEmail(email);

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('メールを送信しました')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('エラーが発生しました: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('メール送信'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _emailController,
            decoration: const InputDecoration(
              labelText: 'メールアドレス',
              hintText: 'example@example.com',
            ),
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 16),
          const Text('送信するピン:'),
          RadioListTile<String>(
            title: const Text('全てのピン'),
            value: 'all',
            groupValue: _selectedOption,
            onChanged: (value) {
              setState(() {
                _selectedOption = value!;
              });
            },
          ),
          RadioListTile<String>(
            title: const Text('新規ピンのみ（過去1時間）'),
            value: 'new',
            groupValue: _selectedOption,
            onChanged: (value) {
              setState(() {
                _selectedOption = value!;
              });
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('キャンセル'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _sendEmail,
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('送信'),
        ),
      ],
    );
  }
}
