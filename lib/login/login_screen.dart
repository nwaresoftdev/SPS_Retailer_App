import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../utills/network_service.dart';
import 'login_controller.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({super.key});
  final controller = Get.put(LoginController());
  final networkService = Get.put(NetworkService());
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      //controller.checkInternet();
      return Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          children: [
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
                    const SizedBox(height: 40),
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

                          controller.isLoading.value
                          ? CircularProgressIndicator()
                        : SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed:(){
                            if(networkService.isOnline.value){
                              controller.login();
                            }
                          } ,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            backgroundColor:
                            networkService.isOnline.value
                            ?Colors.indigo:Colors.grey,
                            //fixedSize: Size(MediaQuery.of(context).size.width, 45)
                          ),
                          child: const Text(
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
