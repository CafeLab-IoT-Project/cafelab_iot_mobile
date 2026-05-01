import 'package:cafelab_iot_mobile/features/production/roast_profiles/data/dto/roast_profile_response_dto.dart';
import 'package:cafelab_iot_mobile/features/production/roast_profiles/domain/models/roast_profile.dart';

class RoastProfileMapper {
  static RoastProfile toDomain(RoastProfileResponseDto dto) {
    return RoastProfile(
      id: dto.id,
      userId: dto.userId,
      name: dto.name,
      type: dto.type,
      duration: dto.duration,
      tempStart: dto.tempStart,
      tempEnd: dto.tempEnd,
      coffeeLotId: dto.coffeeLotId,
      isFavorite: dto.isFavorite,
    );
  }
}
