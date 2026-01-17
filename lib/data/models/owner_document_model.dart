class OwnerDocumentResponse {
  final bool status;
  final String message;
  final List<OwnerDocumentGroup> data;

  OwnerDocumentResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory OwnerDocumentResponse.fromJson(Map<String, dynamic> json) {
    return OwnerDocumentResponse(
      status: json['status'] ?? false,
      message: json['message'] ?? "",
      data: (json['data'] as List?)
              ?.map((e) => OwnerDocumentGroup.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class OwnerDocumentGroup {
  final int ownerId;
  final String name;
  final String email;
  final String phone;
  final String address;
  final List<DocumentItem> documents;

  OwnerDocumentGroup({
    required this.ownerId,
    required this.name,
    required this.email,
    required this.phone,
    required this.address,
    required this.documents,
  });

  factory OwnerDocumentGroup.fromJson(Map<String, dynamic> json) {
    return OwnerDocumentGroup(
      ownerId: json['owner_id'] ?? 0,
      name: json['name'] ?? "",
      email: json['email'] ?? "",
      phone: json['phone'] ?? "",
      address: json['address'] ?? "",
      documents: (json['documents'] as List?)
              ?.map((e) => DocumentItem.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class DocumentItem {
  final int id;
  final String documentName;
  final String documentUrl;

  DocumentItem({
    required this.id,
    required this.documentName,
    required this.documentUrl,
  });

  factory DocumentItem.fromJson(Map<String, dynamic> json) {
    return DocumentItem(
      id: json['id'] ?? 0,
      documentName: json['document_name'] ?? "",
      documentUrl: json['document_url'] ?? "",
    );
  }
}
