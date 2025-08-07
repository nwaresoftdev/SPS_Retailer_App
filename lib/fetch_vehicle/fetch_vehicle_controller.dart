import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../utills/NoInternetScreen.dart';
import '../utills/network_service.dart';

class FetchVehicleController extends GetxController {
  final TextEditingController vehicleController = TextEditingController();
  final TextEditingController barcodeController = TextEditingController();
  final RxnString selectedVoucher = RxnString();


  final RxList<String> voucherList = [
      'Discount10',
      'Fuel50',
      'Holiday100',
     ].obs;

  // @override
  // void onInit() {
  //   selectedVoucher.value = voucherList[0];
  //   super.onInit();
  // }

  void scanBarcode() {
    Get.snackbar("Scan", "Barcode scanner opened (not implemented)");
  }

  void proceed() {
    String vehicleNo = vehicleController.text;
    if (vehicleNo.isEmpty) {
      Get.snackbar("Error", "Please enter a vehicle number",
          backgroundColor: Colors.red, colorText: Colors.white);
    } else {
      Get.snackbar("Success", "Proceeding with: $vehicleNo",
          backgroundColor: Colors.green, colorText: Colors.white);
      // Continue to next screen or API call
    }
  }
  void checkInternet() async {
    final connected = await Get.find<NetworkService>().checkConnection();
    if (!connected) {
      Get.to(() => NoInternetScreen());
    }
  }
}

