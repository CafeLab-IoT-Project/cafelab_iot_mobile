import 'package:cafelab_iot_mobile/features/production/suppliers/data/dto/create_supplier_request_dto.dart';
import 'package:cafelab_iot_mobile/features/production/suppliers/data/dto/update_supplier_request_dto.dart';
import 'package:cafelab_iot_mobile/features/production/suppliers/data/mappers/supplier_mapper.dart';
import 'package:cafelab_iot_mobile/features/production/suppliers/data/suppliers_api_service.dart';
import 'package:cafelab_iot_mobile/features/production/suppliers/domain/models/create_supplier_input.dart';
import 'package:cafelab_iot_mobile/features/production/suppliers/domain/models/supplier.dart';
import 'package:cafelab_iot_mobile/features/production/suppliers/domain/models/update_supplier_input.dart';
import 'package:cafelab_iot_mobile/features/production/suppliers/domain/suppliers_repository.dart';

class SuppliersRepositoryImpl implements SuppliersRepository {
  SuppliersRepositoryImpl({SuppliersApiService? apiService})
      : _apiService = apiService ?? SuppliersApiService();

  final SuppliersApiService _apiService;

  @override
  Future<Supplier> create(CreateSupplierInput input) async {
    final dto = CreateSupplierRequestDto.fromInput(input);
    final result = await _apiService.createSupplier(dto);
    return SupplierMapper.toDomain(result);
  }

  @override
  Future<String> delete(int supplierId) async {
    final result = await _apiService.deleteSupplier(supplierId);
    return result.message;
  }

  @override
  Future<List<Supplier>> getAll() async {
    final list = await _apiService.getSuppliers();
    return list.map(SupplierMapper.toDomain).toList();
  }

  @override
  Future<Supplier> getById(int supplierId) async {
    final result = await _apiService.getSupplierById(supplierId);
    return SupplierMapper.toDomain(result);
  }

  @override
  Future<List<Supplier>> getByUserId(int userId) async {
    final list = await _apiService.getSuppliersByUserId(userId);
    return list.map(SupplierMapper.toDomain).toList();
  }

  @override
  Future<Supplier> update(int supplierId, UpdateSupplierInput input) async {
    final dto = UpdateSupplierRequestDto.fromInput(input);
    final result = await _apiService.updateSupplier(supplierId, dto);
    return SupplierMapper.toDomain(result);
  }
}
