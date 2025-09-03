import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:simple_barcode_scanner/simple_barcode_scanner.dart';

import '../login/login_screen.dart';
import '../utills/network_service.dart';
import 'fetch_vehicle_controller.dart';

class FetchVehicleScreen extends StatelessWidget {
  final controller = Get.put(FetchVehicleController());
  final networkService = Get.put(NetworkService());
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

              controller.clear();
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
    return Stack(
      children: [
        Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            title:  Text('Retailer App',style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold,),),
            automaticallyImplyLeading: false,
            centerTitle: true,
            backgroundColor: Colors.grey.withOpacity(0.2),
            actions: [
              Padding(
                padding: const EdgeInsets.all(5),
                child: IconButton(
                  icon: const Icon(Icons.power_settings_new,size: 30,),
                  onPressed: () {
                    showLogoutDialog();
                  },
                ),
              )
            ],
          ),
          body: Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(10,10,10,0),
            child: Column(
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
                    suffixIcon:Obx(() {

                      return controller.vehicalText.value.isEmpty
                          ?SizedBox()
                          :IconButton(
                        icon: Icon(Icons.clear),
                        onPressed: () {
                          controller.clear();
                        },
                      );
                    },),


                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onChanged: (value) {
                    controller.vehicalText.value = value;
                  },
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
                    suffixIcon: Obx(() {
                      return  controller.barcodeText.value.isEmpty
                          ?IconButton(
                          icon: Icon(Icons.qr_code_scanner),
                          onPressed: () async {
                            if(networkService.isOnline.value){
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
                                  controller.barcodeText.value = res;
                                }

                                print('getCode...$res');

                              }
                              else {
                                Get.snackbar(
                                  "Permission Denied",
                                  "Camera permission is needed to scan barcode",
                                  snackPosition: SnackPosition.BOTTOM,
                                );
                              }
                            }
                          }
                      )
                          :IconButton(
                          icon: Icon(Icons.clear),
                          onPressed: () async {
                            controller.clear();
                          }
                      );
                    },),

                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onChanged: (value) {
                    controller.barcodeText.value = value;
                  },
                ),


                const SizedBox(height: 10),

                Obx(() {
                  return Visibility(
                    visible:controller.vehicalList.isNotEmpty,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          InkWell(
                            onTap: () {
                              controller.clear();
                            },

                            borderRadius: BorderRadius.circular(15), // same as shape
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
                              decoration: BoxDecoration(
                                color: Colors.grey.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Text(
                                'Reset',
                                style: TextStyle(fontWeight: FontWeight.bold), // add color for visibility
                              ),
                            ),
                          )

                        ],
                      ),
                    ),
                  );
                },),


                Obx(() {
                  return  Visibility(
                      visible: controller.isShowVocher.value,
                      child: Expanded(
                        child: ListView.builder(
                          physics: BouncingScrollPhysics(),
                          itemCount: controller.vehicalList.length,
                          itemBuilder: (context, index) {
                            var data = controller.vehicalList[index];
                            return buildVehicleCards(data);
                          },
                        ),
                      )

                  );
                },),


                controller.isShowVocher.value
                    ?SizedBox()
                    :Spacer(),

                Obx(() {
                  return controller.vehicalList.isEmpty
                      ? controller.isLoading.value
                      ?CircularProgressIndicator()
                      :SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed:(){
                     if (networkService.isOnline.value){
                           controller.fetchVehical(context: context);
                       }
                      } ,
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                        networkService.isOnline.value
                        ?Colors.green
                        :Colors.grey,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        "Search Vehicle",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold,color: Colors.white),
                      ),
                    ),
                  )
                      :controller.isLoading.value
                      ?CircularProgressIndicator()
                      :SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed:(){
                        print("networkValue...${networkService.isOnline.value}");
                        if (networkService.isOnline.value){
                          if(controller.selectedVoucher.value == null){
                            Get.snackbar(
                                "Failed",
                                "Please Select Voucher",
                                snackPosition: SnackPosition.TOP,
                                backgroundColor: Colors.red,
                                colorText: Colors.white
                            );
                          }
                          else{
                            showVoucherDialog();
                          }
                        }
                        else{
                          print("No Internet");
                        }
                      } ,
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                        controller.selectedVoucher.value == null
                        ?Colors.grey
                        :Colors.green,



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
                  );
                },),
                const SizedBox(height: 20),
              ],
            )
          ),
        ),
        // 🔴 Network Banner at the top
        Obx(() {
          return
            !networkService.isOnline.value
                ?Align(
              alignment: Alignment.topCenter,
              child: Container(
                width: double.infinity,
                color: Colors.redAccent,
                padding: const EdgeInsets.all(10),
                child: Text(
                  "No Internet Connection",
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
            )
                :Container();
        },)
      ],
    );
  }

  void showVoucherDialog() {
    Get.dialog(
      Center(
        child: SizedBox(
          width: 250,
          height: 250,
          child:
          //Image.asset('assets/images/voucher.gif')
          Lottie.asset(
            'assets/voucher.json',
            repeat: false,
            onLoaded: (composition) {
              Future.delayed(composition.duration, () {
                Get.back();
                controller.proceed();
              });
            },
          ),
        ),
      ),
      barrierDismissible: false, // Prevent user from closing manually
    );
  }



  Widget buildVehicleCards(dynamic vehicle) {
      return Card(
        margin: const EdgeInsets.symmetric(horizontal: 8,),
        elevation: 4,
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        child: ListTile(
          contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          leading: const Icon(Icons.directions_car, color: Colors.indigo),
          title: Text(
            "Vehicle No: ${vehicle['vehicle_number'] ?? '-'}",
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16,color: Colors.indigo),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 5),
              Text("In Time: ${vehicle['vehicle_in_time'] ?? '-'}"),
             // Text("Gate ID: ${vehicle['vehicle_in_gate_id'] ?? '-'}"),
              SizedBox(height: 5,),
              DropdownButton<String>(
                value: controller.selectedVoucher.value,
                isExpanded: true,
                iconEnabledColor: Colors.black,
                dropdownColor: Colors.white,
                underline: Container(
                  height: 1,
                  color: Colors.grey, // Change this to your desired underline color
                ),
                hint: Text('Select Voucher', style: TextStyle(color: Colors.black),),
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
              )
            ],
          ),
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