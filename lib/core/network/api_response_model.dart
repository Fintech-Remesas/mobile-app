class ApiResponseModel<T> {
  final bool success;
  final String? message;
  final T? data;

  const ApiResponseModel({
    required this.success,
    this.message,
    this.data,
  });

  factory ApiResponseModel.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT,
  ) {
    final status = json['status'] as String?;
    final success = json['success'] as bool? ?? status == 'SUCCESS';

    return ApiResponseModel(
      success: success,
      message: json['message'] as String?,
      data: json['data'] is Map<String, dynamic>
          ? fromJsonT(json['data'] as Map<String, dynamic>)
          : null,
    );
  }
}
