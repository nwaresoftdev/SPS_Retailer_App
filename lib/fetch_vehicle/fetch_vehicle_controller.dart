import 'dart:async';
import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart';
import 'package:retailers/utills/api_helper.dart';
import '../utills/NoInternetScreen.dart';
import '../utills/network_service.dart';

class FetchVehicleController extends GetxController {
  final TextEditingController vehicleController =
      TextEditingController(text: "2CD8339" /*text: "2W2984"*/);
  final TextEditingController barcodeController = TextEditingController(
      /*text:"0I2B4N0K1A5A3I5DB6"*/ /* text: "0I2B2K0K0A0A8K5CB8"*/);
  final TextEditingController mNoController = TextEditingController();

  final RxnString selectedVoucher = RxnString();
  final RxList voucherList1 = [].obs;
  RxList<dynamic> vehicalList = [].obs;
  RxBool isLoading = false.obs;
  RxBool isShowVocher = false.obs;
  RxString barcodeText = ''.obs;
  RxString vehicalText = ''.obs;
  RxString mNoText = ''.obs;


  final RxList voucherList = [
    {
      "id": 4910,
      "title": "Bomby Liquor",
      "description": "Buy 3 and get 1 half price",
      "valid_from": "2025-08-07",
      "valid_until": "2025-09-25",
      "offer_type": "percent",
      "offer_value": "3",
      "offer_mode": "Offer"
    },
    {
      "id": 4911,
      "title": "Pizza Hub",
      "description": "Get 25% off on all large pizzas",
      "valid_from": "2025-09-01",
      "valid_until": "2025-09-30",
      "offer_type": "percent",
      "offer_value": "25",
      "offer_mode": "Offer"
    },
    {
      "id": 4912,
      "title": "Fuel Saver",
      "description": "Save ₹50 on refilling above ₹1000",
      "valid_from": "2025-07-15",
      "valid_until": "2025-12-31",
      "offer_type": "flat",
      "offer_value": "50",
      "offer_mode": "Offer"
    },
    {
      "id": 4913,
      "title": "Cafe Aroma",
      "description": "Buy 2 coffees, get 1 free",
      "valid_from": "2025-08-10",
      "valid_until": "2025-11-10",
      "offer_type": "free",
      "offer_value": "1",
      "offer_mode": "Offer"
    },
    {
      "id": 4914,
      "title": "Movie Magic",
      "description": "Get ₹100 cashback on 2 movie tickets",
      "valid_from": "2025-10-01",
      "valid_until": "2025-11-01",
      "offer_type": "cashback",
      "offer_value": "100",
      "offer_mode": "Offer"
    },
  ].obs;


  RxBool isLoadingProceed = false.obs;

  // RxBool isClearBtn = false.obs;
  var showAnimation = false.obs;
  RxBool isActiveMno = false.obs;

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
    // List<dynamic> storeData = [];
    final netService = Get.put(NetworkService());
    bool connected = await netService.checkConnection();

    if (!connected) {
      isLoading.value = false;
      isShowVocher.value = false;
      Get.snackbar("No Internet", "Please check your connection",
          backgroundColor: Colors.red, colorText: Colors.white,duration: Duration(seconds: 1));
      return;
    }
    if (vehicleController.text.trim().isEmpty &&
        barcodeController.text.trim().isEmpty) {
      isLoading.value = false;
      Get.snackbar("Invalid", "Please Enter Details",
          backgroundColor: Colors.red, colorText: Colors.white,duration: Duration(seconds: 1));
      return;
    }

    if (vehicleController.text.trim().isNotEmpty &&
        barcodeController.text.trim().isNotEmpty) {
      isLoading.value = false;
      Get.snackbar("Invalid", "Please Enter Details",
          backgroundColor: Colors.red, colorText: Colors.white,duration: Duration(seconds: 1));
      return;
    }

    bool activeBarCode =
        barcodeController.text.trim().isNotEmpty ? true : false;

    // Call API
    final response = await fetchVehicleDetails(
        parkingSiteId: int.parse(ApiHelper.parkingSiteId),
        vehicleNumber: vehicleController.text.trim(),
        barcodeNo: barcodeController.text.trim(),
        isSelected: activeBarCode);

    print('activeBarCode...$activeBarCode....');
    if (!activeBarCode) {
      print('vehicleNumber....${vehicleController.text.trim()}');
    } else {
      print('barcodeNo....${barcodeController.text.trim()}');
    }

    if (response != null && !response['error']) {
      isLoading.value = false;
      isShowVocher.value = true;
      Map getData = response['results']['data'];
      String errorSms =
          ((response["results"] ?? "")["message"] ?? "Vehical Not Found");

      if (getData.isNotEmpty) {
        // getData.forEach((key, value) {
        //   storeData.add(value);
        //   },);
        List<dynamic> storeData = getData.values.toSet().toList();

        print('storeData....$storeData');
        vehicalList.clear();

        activeBarCode
            ? vehicalList.assignAll(storeData
                .where((p0) =>
                    p0['entry_barcode'].toString().toLowerCase() ==
                    barcodeController.text.trim().toString().toLowerCase())
                .toSet()
                .toList())
            : vehicalList.assignAll(storeData
                .where((p0) =>
                    p0['vehicle_number'].toString().toLowerCase() ==
                    vehicleController.text.trim().toString().toLowerCase())
                .toSet()
                .toList());
        print('vehicalList..${vehicalList.length}');

        if (vehicalList.length > 1) {
          Map<String, dynamic>? getFirstIndex =
              getLatestVehicleByTime(vehicalList);
          vehicalList.clear();
          vehicalList.add(getFirstIndex);
          print('vehicalList..${vehicalList.length}');
        }
      } else {
        Get.snackbar("Error", errorSms,
            backgroundColor: Colors.red, colorText: Colors.white,duration: Duration(seconds: 1));
      }
    } else {
      isLoading.value = false;
      isShowVocher.value = false;
      String errorSms = response?['message'] ?? 'Not Valid';
      Get.snackbar("Error", errorSms,
          backgroundColor: Colors.red, colorText: Colors.white,duration: Duration(seconds: 1));
    }
  }

  Map<String, dynamic>? getLatestVehicleByTime(List<dynamic> dataList) {
    if (dataList.isEmpty) return null;

    // Sort list by vehicle_in_time descending
    dataList.sort((a, b) {
      DateTime timeA = DateTime.parse(a['vehicle_in_time']);
      DateTime timeB = DateTime.parse(b['vehicle_in_time']);
      return timeB.compareTo(timeA); // descending (latest first)
    });

    // Return the latest JSON object
    return dataList.first;
  }

  Future<void> proceed() async {
    isLoading.value = true;
    String vehicleNo = vehicleController.text;
    String barcodeNo = barcodeController.text;
    if (vehicleNo.isEmpty && barcodeNo.isEmpty) {
      Get.snackbar("Error", "Please enter a vehicle number",
          backgroundColor: Colors.red, colorText: Colors.white,duration: Duration(seconds: 1));
    } else {

      Map<String, dynamic> getFirstIndex = vehicalList.first;
      Map<String, dynamic> selectedOfferIndex = voucherList.value
          .where((element) => element['id'] == int.parse(selectedVoucher.value ?? "00"))
          .toSet()
          .toList()
          .first;

      // print('getVehicalFirstIndex...$getFirstIndex');
      // print('getOfferFirstIndex...$getOfferFirstIndex');
      String txnId = getFirstIndex['transaction_id'].toString() ?? "";
      String vehicle_num = getFirstIndex['vehicle_number'] ?? "";
      String barcode = getFirstIndex['entry_barcode'] ?? "";
      String parking_site_id = ApiHelper.parkingSiteId;

      final result = await storeRetailerAppVoucherDetail(vehicleDetails: {
        "parking_site_id": parking_site_id,
        "vehicle_number": vehicle_num,
        "barcode": barcode,
        "transaction_id": txnId,
      }, voucherDetails: selectedOfferIndex);

      if (result != null) {
        print("🎉 API Success: $result");

        final resData = await acceptOfferRedeem(
          offerId: selectedVoucher.value.toString(),
          customerMobile: mNoController.text.trim(),
          offerMode: "Offer",
        );

        if (resData != null) {
          print("🎉 API Success: $resData");
          if(resData.containsKey('success')){
            print('offer Applied successfully');
            showVoucherDialog();
          }
        }
        else {
          print("❌ API failed or returned null");
        }

        isLoading.value = false;
      }
      else {
        isLoading.value = false;
        print("❌ API failed or returned null");
      }
    }
  }
  void showVoucherDialog() {
    Get.dialog(
      Center(
        child: SizedBox(
          width: 250,
          height: 250,
          child:
          Lottie.asset(
            'assets/voucher.json',
            repeat: false,
            onLoaded: (composition) {
              Future.delayed(composition.duration, () {
                Get.back();
                clear();
              });
            },
          ),
        ),
      ),
      barrierDismissible: false, // Prevent user from closing manually
    );
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
  }) async {
    if (!await isConnected()) {
      Get.snackbar("No Internet", "Please check your connection.",duration: Duration(seconds: 1));
      return null;
    }

    /// UAT
    final url = isSelected
        ? '${ApiHelper().baseUrl}${ApiHelper().barcodeEndPoint}?parking_site_id=$parkingSiteId&barcode=$barcodeNo'
        : '${ApiHelper().baseUrl}${ApiHelper().vehicleNumberEndPoint}?parking_site_id=$parkingSiteId&vehicle_number=$vehicleNumber';

    /// Prod
    // String baseUrl = await ApiHelper().box.get('country_url');
    // final url = isSelected
    //     ? '$baseUrl${ApiHelper().barcodeEndPoint}?parking_site_id=$parkingSiteId&barcode=$barcodeNo'
    //     : '$baseUrl${ApiHelper().vehicleNumberEndPoint}?parking_site_id=$parkingSiteId&vehicle_number=$vehicleNumber';

    try {
      // print('enter The Try');
      print('RequestUrl...$url');
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer ${ApiHelper.token}',
          'Content-Type': 'application/json',
        },
      );

      print(
          'response....URL..$url...statusCode...${response.statusCode}....${jsonDecode(response.body)}');
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return jsonDecode(response.body);
        ;
      }
    } catch (e) {
      // Get.snackbar("Error", "Exception: $e",
      //     backgroundColor: Colors.red, colorText: Colors.white);
      return null;
    }
  }

  void clear() {
    vehicalList.value = [];
    vehicleController.clear();
    selectedVoucher.value = null;
    barcodeController.clear();
    isLoading.value = false;
    ApiHelper().box.clear();
    barcodeText.value = '';
    vehicalText.value = '';
    mNoController.clear();
  }

  Future<Map<String, dynamic>?> storeRetailerAppVoucherDetail({
    required Map<String, dynamic> vehicleDetails,
    required Map<String, dynamic> voucherDetails,
  }) async {
    // 🔹 Check Internet
    if (!await isConnected()) {
      Get.snackbar("No Internet", "Please check your connection.",
          backgroundColor: Colors.red, colorText: Colors.white,duration: Duration(seconds: 1));
      return null;
    }


    /// UAT
    String apiUrl = '${ApiHelper().baseUrlVoucherDetail}${ApiHelper().voucherDetailEndPoint}';

    /// prod
    // String baseUrl = await ApiHelper().box.get('country_url');
    // String apiUrl = '$baseUrl${ApiHelper().voucherDetailEndPoint}';


    final body = {
      "vehicle_details": vehicleDetails,
      "voucher_details": voucherDetails,
    };

    try {
      print("➡️ Sending POST request to: $apiUrl");
      print("📦 Request body: ${jsonEncode(body)}");

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Bearer ${ApiHelper.token}',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );

      print("✅ Response status: ${response.statusCode}");
      print("✅ Response body: ${response.body}");

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        // Server responded with error
        Get.snackbar(
          "Error",
          "Server responded with code ${response.statusCode}",
          backgroundColor: Colors.orange,
          colorText: Colors.white,
            duration: Duration(seconds: 1)
        );
        return jsonDecode(response.body);
      }
    } catch (e) {
      return null;
    }
  }

  Future<Map<String, dynamic>?> acceptOfferRedeem({
    required String offerId,
    required String customerMobile,
    required String offerMode,
  }) async {
    // 🔹 1. Check internet connection
    if (!await isConnected()) {
      Get.snackbar("No Internet", "Please check your connection.",
          backgroundColor: Colors.red, colorText: Colors.white,duration: Duration(seconds: 1));
      return null;
    }

    final body = {
      "offer_id": offerId,
      "customer_mobile": customerMobile,
      "offer_mode": offerMode,
    };

    try {
      print("➡️ Sending POST (form-data) to: ${ApiHelper.offerRedeemApiUrl}");
      print("📦 Request body: $body");

      // 🔹 Use 'application/x-www-form-urlencoded' for form data
      final response = await http.post(
        Uri.parse(ApiHelper.offerRedeemApiUrl),
        headers: {
          'Authorization': 'Bearer ${ApiHelper.token}',
          'Content-Type': 'application/x-www-form-urlencoded',
          'token': 'kql3_bhd45_mauq34',
        },
        body: body, // no jsonEncode here!
      );

      print("✅ Response Status: ${response.statusCode}");
      print("✅ Response Body: ${response.body}");

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        Get.snackbar(
          "Error",
          "Server responded with code ${response.statusCode}",
          backgroundColor: Colors.orange,
          colorText: Colors.white,
            duration: Duration(seconds: 1)
        );
        return jsonDecode(response.body);
      }
    } catch (e) {
      return null;
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose

    super.dispose();
  }
}
