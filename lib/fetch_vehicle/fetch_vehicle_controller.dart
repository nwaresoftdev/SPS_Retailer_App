import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:retailers/utills/api_helper.dart';
import '../utills/NoInternetScreen.dart';
import '../utills/network_service.dart';

class FetchVehicleController extends GetxController {
  final TextEditingController vehicleController = TextEditingController();
  final TextEditingController barcodeController = TextEditingController();
  final RxnString selectedVoucher = RxnString();
  final RxList voucherList = [].obs;
   RxList<dynamic> vehicalList = [].obs;
  RxBool isLoading = false.obs;
  RxBool isShowVocher = false.obs;
  RxString barcodeText = ''.obs;
  RxString vehicalText = ''.obs;
  // RxBool isClearBtn = false.obs;
  var showAnimation = false.obs;

  @override
  void onInit() {
    // TODO: implement onInit
    vehicleController.clear();
    barcodeController.clear();
    super.onInit();
  }


  void fetchVehical({required BuildContext context}) async {
    isLoading.value = true;
    FocusScope.of(context).unfocus();
    List<dynamic> abc = [];
    final netService = Get.put(NetworkService());
    bool connected = await netService.checkConnection();

    if (!connected) {
      isLoading.value = false;
      isShowVocher.value = false;
      Get.snackbar("No Internet", "Please check your connection",
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }
    if(vehicleController.text.trim().isEmpty && barcodeController.text.trim().isEmpty){
      isLoading.value = false;
      Get.snackbar("Invalid Formated", "Please Enter Details",
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    if(vehicleController.text.trim().isNotEmpty && barcodeController.text.trim().isNotEmpty){
      isLoading.value = false;
      Get.snackbar("Invalid Formated", "Please Enter Details One Filed",
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    bool activeBarCode = barcodeController.text.trim().isNotEmpty?true:false;

    // Call API
    final response = await fetchVehicleDetails(
      parkingSiteId:2,
      vehicleNumber:vehicleController.text.trim(),
      token: '',
      barcodeNo: barcodeController.text.trim(),
      isSelected: activeBarCode
    );

    print('activeBarCode...$activeBarCode');

    if (response != null && !response['error']) {
       isLoading.value = false;
       isShowVocher.value = true;
       dynamic getData = response['results']['data'];

       if(getData.isNotEmpty){
        getData.forEach((key, value) {
         abc.add(value);
       },);

        activeBarCode
        ?vehicalList.assignAll(
            abc.where((p0) => p0['entry_barcode'].toString().toLowerCase() ==
                barcodeController.text.trim().toString().toLowerCase()).toSet().toList()
        )
       :vehicalList.assignAll(
           abc.where((p0) => p0['vehicle_number'].toString().toLowerCase() ==
               vehicleController.text.trim().toString().toLowerCase()).toSet().toList()
       );
     }
     else{
       Get.snackbar("Error", 'Vehical Data Not Found',
           backgroundColor: Colors.red, colorText: Colors.white);
     }

    }
    else{
      isLoading.value = false;
      isShowVocher.value = false;
      String errorSms = response?['message']??'Not Valid';
      Get.snackbar("Error", errorSms,
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }


  void proceed() {
    String vehicleNo = vehicleController.text;
    String barcodeNo = barcodeController.text;
    if (vehicleNo.isEmpty && barcodeNo.isEmpty) {
      Get.snackbar("Error", "Please enter a vehicle number",
          backgroundColor: Colors.red, colorText: Colors.white);
    }
    else {
      // Get.snackbar("Success", "Proceeding with: $vehicleNo",
      //     backgroundColor: Colors.green, colorText: Colors.white);
      // Continue to next screen or API call
      clear();
    }
  }
  void checkInternet() async {
    final connected = await Get.find<NetworkService>().checkConnection();
    if (!connected) {
      Get.to(() => NoInternetScreen());
    }
  }
  /// Check network availability
  Future<bool> isConnected() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    return connectivityResult != ConnectivityResult.none;
  }

  Future<Map<String, dynamic>?> fetchVehicleDetails({
    required int parkingSiteId,
    required String vehicleNumber,
    required String barcodeNo,
    required bool isSelected,
    required String token,
  })
  async {
    if (!await isConnected()) {
      Get.snackbar("No Internet", "Please check your connection.");
      return null;
    }

    final url =  isSelected
        ? 'http://192.168.1.14/dolphin-aps/public/api/searchByBarcode?parking_site_id=$parkingSiteId&barcode=$barcodeNo'
        :'http://192.168.1.14/dolphin-aps/public/api/searchByVehicleNumber?parking_site_id=$parkingSiteId&vehicle_number=$vehicleNumber';


    final token = '1|KkllzTryrTkAbjGfvinbnhMQIY8m9CJXwY0N7EOy';

    try {
      print('enter The Try');
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      print('response....URL..$url...statusCode...${response.statusCode}....${jsonDecode(response.body)}');
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }

      else {
        return jsonDecode(response.body);;
      }
    } catch (e) {
      Get.snackbar("Error", "Exception: $e",
          backgroundColor: Colors.red, colorText: Colors.white);
      return null;
    }
  }

  void clear(){
    vehicalList.value = [];
    vehicleController.clear();
    selectedVoucher.value = null;
    barcodeController.clear();
    isLoading.value= false;
    ApiHelper().box.clear();
    barcodeText.value='';
    vehicalText.value='';
  }


}

