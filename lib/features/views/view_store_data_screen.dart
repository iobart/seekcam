import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:seekcam/features/router/routes.dart';
import 'package:seekcam/features/storage/secure_storage.dart';

@injectable
class ViewStoredDataScreen extends StatefulWidget {
  const ViewStoredDataScreen({super.key});
  @factoryMethod
  static ViewStoredDataScreen create() => const ViewStoredDataScreen();
  @override
  _ViewStoredDataScreenState createState() => _ViewStoredDataScreenState();
}

class _ViewStoredDataScreenState extends State<ViewStoredDataScreen> {
  late final SecureStorage _secureStorage;
  final ValueNotifier<String?> _storedQrCode = ValueNotifier<String?>(null);

  @override
  void initState() {
    super.initState();
    _secureStorage = GetIt.instance<SecureStorage>();
    _loadStoredData();
  }

  Future<void> _loadStoredData() async {
    final qrCode = await _secureStorage.read('qr_code');
    _storedQrCode.value = qrCode;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stored QR Code'),
        backgroundColor: Colors.blueGrey[800],
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pushNamed(context, Routes.auth),
        ),
      ),
      body: Center(
        child: ValueListenableBuilder<String?>(
          valueListenable: _storedQrCode,
          builder: (context, qrCode, child) {
            return qrCode != null
                ? Text('Stored QR Code: $qrCode')
                : const Text('No QR Code stored');
          },
        ),
      ),
    );
  }
}