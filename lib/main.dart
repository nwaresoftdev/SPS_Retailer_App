import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:retailers/utills/NoInternetScreen.dart';
import 'package:retailers/utills/network_service.dart';
import 'login/login_binding.dart';
import 'login/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Get.putAsync(() => NetworkService().init());

  await Hive.initFlutter();
  await Hive.openBox('userBox');

  // final network = Get.put(NetworkService());
  // final connected = await network.checkConnection();
  runApp(
      GetMaterialApp(
      debugShowCheckedModeBanner: false,
      initialBinding: LoginBinding(),
        home: true ? LoginScreen() : NoInternetScreen(), // 👈 control here
  )
  );
}

