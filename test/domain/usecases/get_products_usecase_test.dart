import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shop_app/domain/repositories/product_repository.dart';
import 'package:shop_app/domain/usecases/get_products_usecase.dart';
import 'package:shop_app/models/product.dart';

class MockProductRepository extends Mock implements IProductRepository {}

void main() {
  late GetProductsUseCase useCase;
  late MockProductRepository mockRepository;

  setUp(() {
    mockRepository = MockProductRepository();
    useCase = GetProductsUseCase(mockRepository);
  });

  group('GetProductsUseCase', () {
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

    test('should successfully retrieve products for valid seller', () async {
      // Arrange
      when(() => mockRepository.getProducts(testSellerId))
          .thenAnswer((_) async => mockProducts);

      // Act
      final result = await useCase.execute(testSellerId);

      // Assert
      expect(result, equals(mockProducts));
      expect(result.length, equals(2));
      verify(() => mockRepository.getProducts(testSellerId)).called(1);
    });

    test('should throw ArgumentError for empty seller ID', () async {
      // Act & Assert
      expect(
        () => useCase.execute(''),
        throwsA(isA<ArgumentError>()),
      );

      verifyNever(() => mockRepository.getProducts(any()));
    });

    test('should throw ArgumentError for whitespace-only seller ID', () async {
      // Act & Assert
      expect(
        () => useCase.execute('   '),
        throwsA(isA<ArgumentError>()),
      );

      verifyNever(() => mockRepository.getProducts(any()));
    });

    test('should return empty list when no products found', () async {
      // Arrange
      when(() => mockRepository.getProducts(testSellerId))
          .thenAnswer((_) async => []);

      // Act
      final result = await useCase.execute(testSellerId);

      // Assert
      expect(result, isEmpty);
      verify(() => mockRepository.getProducts(testSellerId)).called(1);
    });

    test('should propagate repository errors', () async {
      // Arrange
      when(() => mockRepository.getProducts(testSellerId))
          .thenThrow(Exception('Network error'));

      // Act & Assert
      expect(
        () => useCase.execute(testSellerId),
        throwsA(isA<Exception>()),
      );
    });

    test('should sanitize seller ID before fetching', () async {
      // Arrange
      const sellerIdWithSpaces = '  seller123  ';
      when(() => mockRepository.getProducts(any()))
          .thenAnswer((_) async => mockProducts);

      // Act
      await useCase.execute(sellerIdWithSpaces);

      // Assert
      verify(() => mockRepository.getProducts(testSellerId)).called(1);
    });
  });
}
