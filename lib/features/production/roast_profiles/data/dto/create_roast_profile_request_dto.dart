import 'package:cafelab_iot_mobile/features/production/roast_profiles/domain/models/create_roast_profile_input.dart';

class CreateRoastProfileRequestDto {
  final String name;
  final String type;
  final int duration;
  final double tempStart;
  final double tempEnd;
  final int lot;
  final bool? isFavorite;

  const CreateRoastProfileRequestDto({
    required this.name,
    required this.type,
    required this.duration,
    required this.tempStart,
    required this.tempEnd,
    required this.lot,
    this.isFavorite,
  });

  factory CreateRoastProfileRequestDto.fromInput(CreateRoastProfileInput input) {
    return CreateRoastProfileRequestDto(
      name: input.name,
      type: input.type,
      duration: input.duration,
      tempStart: input.tempStart,
      tempEnd: input.tempEnd,
      lot: input.lot,
      isFavorite: input.isFavorite,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'type': type,
      'duration': duration,
      'tempStart': tempStart,
      'tempEnd': tempEnd,
      'lot': lot,
      if (isFavorite != null) 'isFavorite': isFavorite,
    };
  }
}
