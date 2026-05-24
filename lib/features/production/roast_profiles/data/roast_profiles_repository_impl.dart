import 'package:cafelab_iot_mobile/features/production/roast_profiles/data/dto/create_roast_profile_request_dto.dart';
import 'package:cafelab_iot_mobile/features/production/roast_profiles/data/dto/update_roast_profile_request_dto.dart';
import 'package:cafelab_iot_mobile/features/production/roast_profiles/data/mappers/roast_profile_mapper.dart';
import 'package:cafelab_iot_mobile/features/production/roast_profiles/data/roast_profiles_api_service.dart';
import 'package:cafelab_iot_mobile/features/production/roast_profiles/domain/models/create_roast_profile_input.dart';
import 'package:cafelab_iot_mobile/features/production/roast_profiles/domain/models/roast_profile.dart';
import 'package:cafelab_iot_mobile/features/production/roast_profiles/domain/models/update_roast_profile_input.dart';
import 'package:cafelab_iot_mobile/features/production/roast_profiles/domain/roast_profiles_repository.dart';

class RoastProfilesRepositoryImpl implements RoastProfilesRepository {
  RoastProfilesRepositoryImpl({RoastProfilesApiService? apiService})
      : _apiService = apiService ?? RoastProfilesApiService();

  final RoastProfilesApiService _apiService;

  @override
  Future<RoastProfile> create(CreateRoastProfileInput input) async {
    final dto = CreateRoastProfileRequestDto.fromInput(input);
    final response = await _apiService.create(dto);
    return RoastProfileMapper.toDomain(response);
  }

  @override
  Future<String> delete(int roastProfileId) => _apiService.delete(roastProfileId);

  @override
  Future<List<RoastProfile>> getAll() async {
    final list = await _apiService.getAll();
    return list.map(RoastProfileMapper.toDomain).toList();
  }

  @override
  Future<RoastProfile> getById(int roastProfileId) async {
    final dto = await _apiService.getById(roastProfileId);
    return RoastProfileMapper.toDomain(dto);
  }

  @override
  Future<List<RoastProfile>> getByCoffeeLotId(int coffeeLotId) async {
    final list = await _apiService.getByCoffeeLotId(coffeeLotId);
    return list.map(RoastProfileMapper.toDomain).toList();
  }

  @override
  Future<List<RoastProfile>> getByUserId(int userId) async {
    final list = await _apiService.getByUserId(userId);
    return list.map(RoastProfileMapper.toDomain).toList();
  }

  @override
  Future<RoastProfile> update(int roastProfileId, UpdateRoastProfileInput input) async {
    final dto = UpdateRoastProfileRequestDto.fromInput(input);
    final response = await _apiService.update(roastProfileId, dto);
    return RoastProfileMapper.toDomain(response);
  }
}
