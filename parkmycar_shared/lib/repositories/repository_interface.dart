abstract interface class RepositoryInterface<T> {
  Future<T?> create(T item);
  Future<T?> update(T item);
  Future<T?> getById(String id);
  Future<List<T>> getAll([String? orderByField, bool descending = true]);
  Future<bool> delete(String id);
}
