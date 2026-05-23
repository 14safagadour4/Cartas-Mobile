class TherapyReview {
  final int? id;
  final String reviewerName;
  final String reviewContext;
  final int rating;
  final String reviewText;

  TherapyReview({
    this.id,
    required this.reviewerName,
    required this.reviewContext,
    required this.rating,
    required this.reviewText,
  });

  factory TherapyReview.fromJson(Map<String, dynamic> json) {
    return TherapyReview(
      id: json['id'],
      reviewerName: json['reviewerName'] ?? '',
      reviewContext: json['reviewContext'] ?? '',
      rating: json['rating'] ?? 5,
      reviewText: json['reviewText'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'reviewerName': reviewerName,
      'reviewContext': reviewContext,
      'rating': rating,
      'reviewText': reviewText,
    };
  }
}
