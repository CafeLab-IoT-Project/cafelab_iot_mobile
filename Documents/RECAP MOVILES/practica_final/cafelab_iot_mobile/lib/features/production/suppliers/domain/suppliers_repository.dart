import 'package:cafelab_iot_mobile/features/production/suppliers/domain/models/create_supplier_input.dart';
import 'package:cafelab_iot_mobile/features/production/suppliers/domain/models/supplier.dart';
import 'package:cafelab_iot_mobile/features/production/suppliers/domain/models/update_supplier_input.dart';

abstract class SuppliersRepository {
  Future<Supplier> create(CreateSupplierInput input);
  Future<List<Supplier>> getAll();
  Future<List<Supplier>> getByUserId(int userId);
  Future<Supplier> getById(int supplierId);
  Future<Supplier> update(int supplierId, UpdateSupplierInput input);
  Future<String> delete(int supplierId);
}
