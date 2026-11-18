class CustomerModel {
  const CustomerModel({
    required this.id,
    required this.documentType,
    required this.documentNumber,
    required this.fullName,
    required this.status,
    required this.createdAt,
  });

  final String id;
  final String documentType;
  final String documentNumber;
  final String fullName;
  final String status;
  final String createdAt;

  factory CustomerModel.fromJson(Map<String, dynamic> json) {
    return CustomerModel(
      id: (json['id'] as String?) ?? '',
      documentType: (json['document_type'] as String?) ?? '',
      documentNumber: (json['document_number'] as String?) ?? '',
      fullName: (json['full_name'] as String?) ?? '',
      status: (json['status'] as String?) ?? '',
      createdAt: (json['created_at'] as String?) ?? '',
    );
  }

  bool get isActive => status.toUpperCase() == 'ACTIVE';
}
