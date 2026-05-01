class MessageResponseDto {
  final String message;

  const MessageResponseDto({required this.message});

  factory MessageResponseDto.fromJson(Map<String, dynamic> json) {
    return MessageResponseDto(
      message: (json['message'] as String?) ?? '',
    );
  }
}
