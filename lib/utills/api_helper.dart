import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;

class ApiHelper {

  // Singleton
  static final ApiHelper _instance = ApiHelper._internal();
  factory ApiHelper() => _instance;
  ApiHelper._internal();

  var box = Hive.box('userBox');
  static const String token = '1|KkllzTryrTkAbjGfvinbnhMQIY8m9CJXwY0N7EOy'; // replace with your actual token if needed
  static const String parkingSiteId = '3';
  static const String offerRedeemApiUrl = 'https://crm.secureparking.co.in/customer/accept_offer_redeem/';
  static const String loginApi = 'https://crm.secureparking.co.in/retailer/login_offers/';

  /// Prod Url
  final RxMap<String,String> conutryUrl =
      {
        "India":"https://aps.secureparking.co.in/",
        "Cambodia":"https://aps.secureparking.com.kh/",
      }.obs;

  final String voucherDetailEndPoint = "api/storeRetailerAppVoucherDetail";
  final String barcodeEndPoint = "api/searchByBarcode";
  final String vehicleNumberEndPoint = "api/searchByVehicleNumber";



  /// Uat Url
  final String baseUrl = "http://192.168.1.14/dolphin-aps/public/";
  final String baseUrlVoucherDetail = "http://192.168.1.14/dolphin-retailer/public/";




}
