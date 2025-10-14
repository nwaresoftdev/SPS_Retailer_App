import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:retailers/utills/api_helper.dart';
import '../utills/network_service.dart';
import 'login_controller.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({super.key});
  final controller = Get.put(LoginController());
  final networkService = Get.put(NetworkService());
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Obx(() {
      //controller.checkInternet();
      return Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          children: [
            
            /*SafeArea(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                 SizedBox(
          width: 200, // tweak as you like
          child: DropdownButtonFormField<String>(
            value: controller.isSelected.value,
            items: controller.countries.value
                .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                .toList(),
            onChanged: (val) {
              controller.isSelected.value = val??"";
            },
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              // circular/pill border
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(width: 1),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(width: 2),
              ),
            ),
            isExpanded: true,
          ),
        )
                ],
              ),
            ),*/
            
            // Your main UI content
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Retailer Login",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        // color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Container(
                            width: screenWidth, // tweak as you like
                            height: 40,
                            alignment: Alignment.center,
                            // color: Colors.yellow,
                            child: DropdownButtonFormField<String>(
                              hint: Text("Select Country"),
                              value: controller.isSelectedCountry.value.isEmpty
                                  ? null
                                  : controller.isSelectedCountry.value, // null → show hint
                              items: ApiHelper().conutryUrl.keys.toSet().toList().map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                              onChanged: (val) {
                                if (val != null) {
                                  controller.isSelectedCountry.value = val;
                                  // print("SelectURl:- ${ApiHelper().conutryUrl[val]}");
                                }
                              },
                              decoration: InputDecoration(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                // circular/pill border
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(width: 1),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(width: 1),
                                ),
                                prefixIcon: Icon(Icons.flag)
                              ),
                              isExpanded: true,
                            ),
                          ),
                        )
                      ],
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: controller.usernameController,
                      decoration: InputDecoration(
                        labelText: "Username",
                        filled: true,
                        fillColor: Colors.white,
                        prefixIcon: Icon(Icons.person),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: controller.passwordController,
                      obscureText: false,
                      decoration: InputDecoration(
                        labelText: "Password",
                        filled: true,
                        fillColor: Colors.white,
                        prefixIcon: Icon(Icons.lock),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    SizedBox(height:MediaQuery.of(context).size.width * 0.1),
                    SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed:(){
                            if(networkService.isOnline.value){
                              if(controller.isSelectedCountry.value != ""){
                                // 🔹 Close the keyboard
                                FocusScope.of(context).unfocus();
                                controller.login();
                              }
                              else{
                                Get.snackbar("Invalid", "Please Select Country",
                                    backgroundColor: Colors.red, colorText: Colors.white);
                              }
                            }
                          } ,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            backgroundColor:
                               networkService.isOnline.value
                                ?controller.isSelectedCountry.value != ""
                                ?Colors.indigo:Colors.grey
                                :Colors.grey,
                            //fixedSize: Size(MediaQuery.of(context).size.width, 45)
                          ),
                          child:  controller.isLoading.value
                            ?CircularProgressIndicator(color: Colors.white,)
                          : Text(
                            "Login",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                            ),
                          ),
                        ),
                      )
                  ],
                ),
              ),
            ),

            // 🔴 Network Banner at the top
            if (!networkService.isOnline.value)
              Align(
                alignment: Alignment.topCenter,
                child: Container(
                  width: double.infinity,
                  color: Colors.redAccent,
                  padding: const EdgeInsets.all(10),
                  child: const SafeArea(
                    child: Text(
                      "No Internet Connection",
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),


            // ✅ Logo pinned to the bottom of the screen
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Image.asset(
                  'assets/images/secure_park_logo.png',
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}
