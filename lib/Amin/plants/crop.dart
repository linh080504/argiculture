class Crop {
  String id;
  String name;
  String definition;
  String imageUrl;
  String introduction;
  String environment;
  String propagation;
  String planting;

  // Các bước chi tiết cho từng phần
  List<Map<String, dynamic>> introductionSteps;
  List<Map<String, dynamic>> environmentSteps;
  List<Map<String, dynamic>> propagationSteps;
  List<Map<String, dynamic>> plantingSteps;

  // Constructor với các tham số mới
  Crop({
    required this.id,
    required this.name,
    required this.definition,
    required this.imageUrl,
    required this.introduction,
    required this.environment,
    required this.propagation,
    required this.planting,
    required this.introductionSteps,
    required this.environmentSteps,
    required this.propagationSteps,
    required this.plantingSteps,
  });

  // Convert Crop object to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'definition': definition,
      'imageUrl': imageUrl,
      'introduction': introduction,
      'environment': environment,
      'propagation': propagation,
      'planting': planting,
      'introductionSteps': introductionSteps,
      'environmentSteps': environmentSteps,
      'propagationSteps': propagationSteps,
      'plantingSteps': plantingSteps,
    };
  }

  // Create Crop object from JSON
  factory Crop.fromJson(Map<String, dynamic> json) {
    return Crop(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      definition: json['definition'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      introduction: json['introduction'] ?? '',
      environment: json['environment'] ?? '',
      propagation: json['propagation'] ?? '',
      planting: json['planting'] ?? '',
      introductionSteps: json['introductionSteps'] != null
          ? List<Map<String, dynamic>>.from(json['introductionSteps'])
          : [],  // Trả về danh sách rỗng nếu 'introductionSteps' là null
      environmentSteps: json['environmentSteps'] != null
          ? List<Map<String, dynamic>>.from(json['environmentSteps'])
          : [],
      propagationSteps: json['propagationSteps'] != null
          ? List<Map<String, dynamic>>.from(json['propagationSteps'])
          : [],
      plantingSteps: json['plantingSteps'] != null
          ? List<Map<String, dynamic>>.from(json['plantingSteps'])
          : [],
    );
  }

  // Phương thức copyWith để tạo bản sao với các thuộc tính mới
  Crop copyWith({
    String? id,
    String? name,
    String? definition,
    String? imageUrl,
    String? introduction,
    String? environment,
    String? propagation,
    String? planting,
    List<Map<String, dynamic>>? introductionSteps,
    List<Map<String, dynamic>>? environmentSteps,
    List<Map<String, dynamic>>? propagationSteps,
    List<Map<String, dynamic>>? plantingSteps,
  }) {
    return Crop(
      id: id ?? this.id,
      name: name ?? this.name,
      definition: definition ?? this.definition,
      imageUrl: imageUrl ?? this.imageUrl,
      introduction: introduction ?? this.introduction,
      environment: environment ?? this.environment,
      propagation: propagation ?? this.propagation,
      planting: planting ?? this.planting,
      introductionSteps: introductionSteps ?? this.introductionSteps,
      environmentSteps: environmentSteps ?? this.environmentSteps,
      propagationSteps: propagationSteps ?? this.propagationSteps,
      plantingSteps: plantingSteps ?? this.plantingSteps,
    );
  }
}
