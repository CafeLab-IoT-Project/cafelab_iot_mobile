import 'package:cafelab_iot_mobile/features/production/roast_profiles/domain/models/create_roast_profile_input.dart';
import 'package:cafelab_iot_mobile/features/production/roast_profiles/domain/models/roast_profile.dart';
import 'package:cafelab_iot_mobile/features/production/roast_profiles/domain/models/update_roast_profile_input.dart';

abstract class RoastProfilesRepository {
  Future<RoastProfile> create(CreateRoastProfileInput input);
  Future<List<RoastProfile>> getAll();
  Future<List<RoastProfile>> getByUserId(int userId);
  Future<List<RoastProfile>> getByCoffeeLotId(int coffeeLotId);
  Future<RoastProfile> getById(int roastProfileId);
  Future<RoastProfile> update(int roastProfileId, UpdateRoastProfileInput input);
  Future<String> delete(int roastProfileId);
}
