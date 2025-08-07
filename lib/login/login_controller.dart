import 'package:get/get.dart';
import 'package:flutter/material.dart';

import '../fetch_vehicle/fetch_vehicle_screen.dart';
import '../utills/NoInternetScreen.dart';
import '../utills/network_service.dart';

class LoginController extends GetxController {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  void login() async {
    final netService = Get.find<NetworkService>();
    bool connected = await netService.checkConnection();

    if (!connected) {
      Get.snackbar("No Internet", "Please check your connection",
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    // Proceed with login
    String username = usernameController.text;
    String password = passwordController.text;

    if (username.isEmpty || password.isEmpty) {
      Get.snackbar("Error", "Please enter both username and password",
          backgroundColor: Colors.redAccent, colorText: Colors.white);
    } else {
      Get.snackbar("Success", "Login Successful",
          backgroundColor: Colors.green, colorText: Colors.white);
      Get.to(() => FetchVehicleScreen());

    }
  }

  void checkInternet() async {
    final connected = await Get.find<NetworkService>().checkConnection();
    if (!connected) {
      Get.to(() => NoInternetScreen());
    }
  }


}
