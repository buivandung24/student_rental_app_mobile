import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/room.dart';
import '../models/tenant.dart';
import '../models/contract.dart';
import '../models/payment.dart';

class ApiService {
  static const String _baseRoomsUrl =
      'https://695498b51cd5294d2c7cfbf2.mockapi.io/rooms';
  static const String _baseTenantsUrl =
      'https://695498b51cd5294d2c7cfbf2.mockapi.io/tenants';
  static const String _baseContractsUrl =
      'https://69549de91cd5294d2c7d0909.mockapi.io/contracts';
  static const String _basePaymentsUrl =
      'https://69549de91cd5294d2c7d0909.mockapi.io/payments';

  // ------------------- ROOMS -------------------
  Future<List<Room>> getRooms() async {
    final response = await http.get(Uri.parse(_baseRoomsUrl));

    if (response.statusCode == 200) {
      List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((json) => Room.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load rooms: ${response.statusCode}');
    }
  }

  Future<Room> createRoom(Room room) async {
    final response = await http.post(
      Uri.parse(_baseRoomsUrl),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(room.toJson()),
    );

    if (response.statusCode == 201) {
      return Room.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to create room: ${response.statusCode}');
    }
  }

  Future<Room> updateRoom(Room room) async {
    final response = await http.put(
      Uri.parse('$_baseRoomsUrl/${room.id}'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(room.toJson()),
    );

    if (response.statusCode == 200) {
      return Room.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to update room: ${response.statusCode}');
    }
  }

  Future<void> deleteRoom(String id) async {
    final response = await http.delete(Uri.parse('$_baseRoomsUrl/$id'));

    if (response.statusCode != 200) {
      throw Exception('Failed to delete room: ${response.statusCode}');
    }
  }

  // ------------------- TENANTS -------------------
  Future<List<Tenant>> getTenants() async {
    final response = await http.get(Uri.parse(_baseTenantsUrl));

    if (response.statusCode == 200) {
      List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((json) => Tenant.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load tenants: ${response.statusCode}');
    }
  }

  Future<Tenant> createTenant(Tenant tenant) async {
    final response = await http.post(
      Uri.parse(_baseTenantsUrl),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(tenant.toJson()),
    );

    if (response.statusCode == 201) {
      return Tenant.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to create tenant: ${response.statusCode}');
    }
  }

  Future<Tenant> updateTenant(Tenant tenant) async {
    final response = await http.put(
      Uri.parse('$_baseTenantsUrl/${tenant.id}'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(tenant.toJson()),
    );

    if (response.statusCode == 200) {
      return Tenant.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to update tenant: ${response.statusCode}');
    }
  }

  Future<void> deleteTenant(String id) async {
    final response = await http.delete(Uri.parse('$_baseTenantsUrl/$id'));

    if (response.statusCode != 200) {
      throw Exception('Failed to delete tenant: ${response.statusCode}');
    }
  }

  // ------------------- CONTRACTS -------------------
  Future<List<Contract>> getContracts() async {
    final response = await http.get(Uri.parse(_baseContractsUrl));

    if (response.statusCode == 200) {
      List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((json) => Contract.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load contracts: ${response.statusCode}');
    }
  }

  Future<Contract> createContract(Contract contract) async {
    final response = await http.post(
      Uri.parse(_baseContractsUrl),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(contract.toJson()),
    );

    if (response.statusCode == 201) {
      return Contract.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to create contract: ${response.statusCode}');
    }
  }

  Future<Contract> updateContract(Contract contract) async {
    final response = await http.put(
      Uri.parse('$_baseContractsUrl/${contract.id}'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(contract.toJson()),
    );

    if (response.statusCode == 200) {
      return Contract.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to update contract: ${response.statusCode}');
    }
  }

  Future<void> deleteContract(String id) async {
    final response = await http.delete(Uri.parse('$_baseContractsUrl/$id'));

    if (response.statusCode != 200) {
      throw Exception('Failed to delete contract: ${response.statusCode}');
    }
  }

  Future<List<Contract>> getContractsByRoomId(String roomId) async {
    final response = await http.get(Uri.parse('$_baseContractsUrl?roomId=$roomId'));
    if (response.statusCode == 200) {
      List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((json) => Contract.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load contracts by room');
    }
  }

  Future<List<Contract>> getContractsByTenantId(String tenantId) async {
    final response = await http.get(Uri.parse('$_baseContractsUrl?tenantId=$tenantId'));
    if (response.statusCode == 200) {
      List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((json) => Contract.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load contracts by tenant');
    }
  }

  // ------------------- PAYMENTS -------------------
  Future<List<Payment>> getPayments() async {
    final response = await http.get(Uri.parse(_basePaymentsUrl));

    if (response.statusCode == 200) {
      List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((json) => Payment.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load payments: ${response.statusCode}');
    }
  }

  Future<List<Payment>> getPaymentsByContractId(String contractId) async {
    final response =
    await http.get(Uri.parse('$_basePaymentsUrl?contractId=$contractId'));

    if (response.statusCode == 200) {
      List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((json) => Payment.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load payments for contract: ${response.statusCode}');
    }
  }

  Future<Payment> createPayment(Payment payment) async {
    final response = await http.post(
      Uri.parse(_basePaymentsUrl),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(payment.toJson()),
    );

    if (response.statusCode == 201) {
      return Payment.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to create payment: ${response.statusCode}');
    }
  }
}