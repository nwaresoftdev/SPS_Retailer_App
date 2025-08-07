import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';

class NetworkService extends GetxService {
  final Connectivity _connectivity = Connectivity();
  final RxBool isOnline = true.obs;

  @override
  void onInit() {
    super.onInit();
    _initConnectivity();
    _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
  }

  Future<void> _initConnectivity() async {
    final status = await _connectivity.checkConnectivity();
    _updateConnectionStatus(status); // Convert single status to list
  }

  void _updateConnectionStatus(List<ConnectivityResult> result) {
    isOnline.value = result.any((r) => r != ConnectivityResult.none);
  }

  Future<bool> checkConnection() async {
    final result = await _connectivity.checkConnectivity();
    return result != ConnectivityResult.none;
  }

  Future<NetworkService> init() async {
    return this;
  }
}
