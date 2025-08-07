import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:simple_barcode_scanner/simple_barcode_scanner.dart';

import '../login/login_screen.dart';
import 'fetch_vehicle_controller.dart';

class FetchVehicleScreen extends StatelessWidget {
  final controller = Get.put(FetchVehicleController());

   FetchVehicleScreen({super.key}); // 👈 No binding class


  void showLogoutDialog() {
    Get.dialog(
      AlertDialog(
        shape:RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5)
        ) ,
        title: const Text("Logout"),
        content: const Text("Are you sure you want to logout?"),
        actions: [
          TextButton(
            onPressed: () {
              Get.back(); // Close dialog
            },
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Get.back(); // Close dialog first
              Get.offAll(() => LoginScreen()); // Navigate to Login
            },
            child: const Text("Logout"),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }


  @override
  Widget build(BuildContext context) {
    //controller.checkInternet();
    return Scaffold(
      appBar: AppBar(
        title:  Text('Retailer',style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold,),),
        automaticallyImplyLeading: false,
        centerTitle: true,
        backgroundColor: Colors.grey.withOpacity(0.2),
        actions: [
          Padding(
            padding: const EdgeInsets.all(5),
            child: IconButton(
              icon: const Icon(Icons.logout,size: 30,),
              onPressed: () {
                showLogoutDialog();
              },
            ),
          )
        ],
      ),
      body: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        child:Column(
            children: [
              TextField(
                controller: controller.vehicleController,
                inputFormatters: [
                  UpperCaseTextFormatter(), // 👈 Force uppercase
                ],
                decoration: InputDecoration(
                  hintText: "Enter Vehicle No",
                  filled: true,
                  fillColor: Colors.white,
                  prefixIcon: Icon(Icons.directions_car),
                  suffixIcon: IconButton(
                    icon: Icon(Icons.clear),
                    onPressed: () {
                      controller.vehicleController.clear();
                    },
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              Row(
                children: [
                  const Expanded(
                    child: Divider(
                      thickness: 1,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Text(
                      "OR",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Expanded(
                    child: Divider(
                      thickness: 1,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),
              TextField(
                controller: controller.barcodeController, // You’ll define this in controller
                inputFormatters: [
                  UpperCaseTextFormatter(), // 👈 Makes input uppercase
                ],
                decoration: InputDecoration(
                  hintText: "Scan the Bar Code",
                  filled: true,
                  fillColor: Colors.white,
                  prefixIcon: Icon(Icons.key_outlined),
                  suffixIcon: IconButton(
                    icon: Icon(Icons.qr_code_scanner),
                      onPressed: () async {
                        var status = await Permission.camera.status;

                        if (!status.isGranted) {
                          status = await Permission.camera.request();
                        }

                        if (status.isGranted) {

                          String? res = await SimpleBarcodeScanner.scanBarcode(
                            context,
                            barcodeAppBar: const BarcodeAppBar(
                              appBarTitle: 'Test',
                              centerTitle: false,
                              enableBackButton: true,
                              backButtonIcon: Icon(Icons.arrow_back_ios),
                            ),
                            isShowFlashIcon: true,
                            delayMillis: 500,
                            cameraFace: CameraFace.back,
                            scanFormat: ScanFormat.ONLY_BARCODE,
                          );

                          if (res is String && res.isNotEmpty) {
                            controller.barcodeController.text = res;
                          }

                          print('getCode...$res');

                        } else {
                          Get.snackbar(
                            "Permission Denied",
                            "Camera permission is needed to scan barcode",
                            snackPosition: SnackPosition.BOTTOM,
                          );
                        }
                      }
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // 👇 Dropdown for Voucher
              Obx(() {
                return Container(
                  margin: const EdgeInsets.only(top: 20),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey),
                  ),
                  child: DropdownButton<String>(
                    value: controller.selectedVoucher.value,
                    isExpanded: true,
                    underline: SizedBox(),
                    hint: Text('Select Voucher', style: TextStyle(color: Colors.grey),),
                    icon: Icon(Icons.arrow_drop_down),
                    items: controller.voucherList.map((dynamic value) {
                      return DropdownMenuItem<String>(
                        value: value['id'].toString(),
                        child: Text(value['title'].toString()),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      controller.selectedVoucher.value = newValue!;
                      print('controller.selectedVoucher?.value...${controller.selectedVoucher?.value}');
                    },
                  ),
                );
              }),

              const Spacer(),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: controller.proceed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "Proceed",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold,color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          )
      ),
    );
  }
}
class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue,
      TextEditingValue newValue,
      ) {
    return newValue.copyWith(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}