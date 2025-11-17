import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shop_app/api/product_api.dart';
import 'package:shop_app/data/repositories/product_repository_impl.dart';
import 'package:shop_app/models/product.dart';

class MockProductApi extends Mock implements ProductApi {}

void main() {
  late ProductRepositoryImpl repository;
  late MockProductApi mockApi;

  setUp(() {
    mockApi = MockProductApi();
    repository = ProductRepositoryImpl(mockApi);
  });

  group('ProductRepositoryImpl', () {
    group('getProducts', () {
      const testSellerId = 'seller123';
      final mockProducts = [
        Product(
          id: '1',
          name: 'Product 1',
          description: 'Description 1',
          price: 100.0,
          imageUrl: 'https://example.com/image1.jpg',
          category: 'Category 1',
          sellerId: testSellerId,
        ),
        Product(
          id: '2',
          name: 'Product 2',
          description: 'Description 2',
          price: 200.0,
          imageUrl: 'https://example.com/image2.jpg',
          category: 'Category 2',
          sellerId: testSellerId,
        ),
      ];

      test('should successfully retrieve products', () async {
        // Arrange
        when(() => mockApi.getProducts(testSellerId))
            .thenAnswer((_) async => mockProducts);

        // Act
        final result = await repository.getProducts(testSellerId);

        // Assert
        expect(result, equals(mockProducts));
        expect(result.length, equals(2));
        verify(() => mockApi.getProducts(testSellerId)).called(1);
      });

      test('should return empty list when no products', () async {
        // Arrange
        when(() => mockApi.getProducts(testSellerId))
            .thenAnswer((_) async => []);

        // Act
        final result = await repository.getProducts(testSellerId);

        // Assert
        expect(result, isEmpty);
        verify(() => mockApi.getProducts(testSellerId)).called(1);
      });

      test('should propagate API errors', () async {
        // Arrange
        when(() => mockApi.getProducts(testSellerId))
            .thenThrow(Exception('Network error'));

        // Act & Assert
        expect(
          () => repository.getProducts(testSellerId),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('getProductById', () {
      const testSellerId = 'seller123';
      const testProductId = 'product1';
      final mockProduct = Product(
        id: testProductId,
        name: 'Product 1',
        description: 'Description 1',
        price: 100.0,
        imageUrl: 'https://example.com/image1.jpg',
        category: 'Category 1',
        sellerId: testSellerId,
      );

      test('should successfully retrieve product by ID', () async {
        // Arrange
        when(() => mockApi.getProductById(testSellerId, testProductId))
            .thenAnswer((_) async => mockProduct);

        // Act
        final result =
            await repository.getProductById(testSellerId, testProductId);

        // Assert
        expect(result, equals(mockProduct));
        verify(() => mockApi.getProductById(testSellerId, testProductId))
            .called(1);
      });

      test('should propagate not found errors', () async {
        // Arrange
        when(() => mockApi.getProductById(testSellerId, testProductId))
            .thenThrow(Exception('Product not found'));

        // Act & Assert
        expect(
          () => repository.getProductById(testSellerId, testProductId),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('searchProducts', () {
      const testSellerId = 'seller123';
      const testQuery = 'test';
      final mockProducts = [
        Product(
          id: '1',
          name: 'Test Product',
          description: 'Test Description',
          price: 100.0,
          imageUrl: 'https://example.com/image1.jpg',
          category: 'Category',
          sellerId: testSellerId,
        ),
      ];

      test('should successfully search products', () async {
        // Arrange
        when(() => mockApi.searchProducts(testSellerId, testQuery))
            .thenAnswer((_) async => mockProducts);

        // Act
        final result = await repository.searchProducts(testSellerId, testQuery);

        // Assert
        expect(result, equals(mockProducts));
        verify(() => mockApi.searchProducts(testSellerId, testQuery)).called(1);
      });

      test('should return empty list for no matches', () async {
        // Arrange
        when(() => mockApi.searchProducts(testSellerId, testQuery))
            .thenAnswer((_) async => []);

        // Act
        final result = await repository.searchProducts(testSellerId, testQuery);

        // Assert
        expect(result, isEmpty);
      });
    });
  });
}
