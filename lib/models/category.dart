import 'package:cloud_firestore/cloud_firestore.dart';

class CategoryModel{
  final String title;
  final String uid;
  final Timestamp createdAt;
  final int colorCode;

  const CategoryModel({
    required this.title,
    required this.uid,
    required this.createdAt,
    required this.colorCode
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'uid': uid,
      'createdAt': createdAt,
      'colorCode' : colorCode
    };
  }

  factory CategoryModel.fromMap(Map<String, dynamic> map) {
    return CategoryModel(
      title: map['title'] as String,
      uid: map['uid'] as String,
      createdAt: map['createdAt'] as Timestamp,
      colorCode: map['colorCode'] as int,
    );
  }
}