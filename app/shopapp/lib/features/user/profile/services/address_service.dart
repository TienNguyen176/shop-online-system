import '../../../../core/api/api_client.dart';
import '../models/location_option.dart';
import '../models/user_address.dart';

class AddressService {
  Future<List<UserAddress>> getAddresses() async {
    final res = await ApiClient.dio.get("/api/user-addresses");
    final data = res.data as List;
    return data
        .map((item) => UserAddress.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  Future<UserAddress> createAddress(Map<String, dynamic> request) async {
    final res = await ApiClient.dio.post("/api/user-addresses", data: request);
    return UserAddress.fromJson(Map<String, dynamic>.from(res.data));
  }

  Future<UserAddress> updateAddress(
    int id,
    Map<String, dynamic> request,
  ) async {
    final res = await ApiClient.dio.put(
      "/api/user-addresses/$id",
      data: request,
    );
    return UserAddress.fromJson(Map<String, dynamic>.from(res.data));
  }

  Future<void> deleteAddress(int id) async {
    await ApiClient.dio.delete("/api/user-addresses/$id");
  }

  Future<List<LocationOption>> getProvinces() async {
    final res = await ApiClient.dio.get("/api/ghn/provinces");
    return _locationsFrom(res.data);
  }

  Future<List<LocationOption>> getDistricts(int provinceId) async {
    final res = await ApiClient.dio.get(
      "/api/ghn/districts",
      queryParameters: {"provinceId": provinceId},
    );
    return _locationsFrom(res.data);
  }

  Future<List<LocationOption>> getWards(int districtId) async {
    final res = await ApiClient.dio.get(
      "/api/ghn/wards",
      queryParameters: {"districtId": districtId},
    );
    return _locationsFrom(res.data);
  }

  Future<double> getShippingFee({
    required int toDistrictId,
    required String toWardCode,
    required double insuranceValue,
    required int quantity,
  }) async {
    final res = await ApiClient.dio.get(
      "/api/ghn/shipping-fee",
      queryParameters: {
        "toDistrictId": toDistrictId,
        "toWardCode": toWardCode,
        "insuranceValue": insuranceValue,
        "quantity": quantity,
      },
    );

    final fee = res.data["fee"];
    if (fee is num) return fee.toDouble();
    return double.tryParse(fee?.toString() ?? "") ?? 0;
  }

  List<LocationOption> _locationsFrom(dynamic data) {
    final list = data as List;
    return list
        .map((item) => LocationOption.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }
}
