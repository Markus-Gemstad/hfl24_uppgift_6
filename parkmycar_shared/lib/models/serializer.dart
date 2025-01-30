abstract class Serializer<T> {
  Map<String, dynamic> toJson(T item);
  T fromJson(Map<String, dynamic> json);
}
