import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shop_app/domain/repositories/order_repository.dart';
import 'package:shop_app/domain/usecases/submit_order_usecase.dart';
import 'package:shop_app/models/order.dart';
import 'package:shop_app/models/cart_item.dart';

class MockOrderRepository extends Mock implements IOrderRepository {}

void main() {
  late SubmitOrderUseCase useCase;
  late MockOrderRepository mockRepository;

  setUp(() {
    mockRepository = MockOrderRepository();
    useCase = SubmitOrderUseCase(mockRepository);
  });

  setUpAll(() {
    registerFallbackValue(<CartItem>[]);
  });

  group('SubmitOrderUseCase', () {
    const testSellerId = 'seller123';
    const testAddressId = 'address456';
    final testItems = [
      CartItem(
        productId: 'product1',
        name: 'Product 1',
        price: 100.0,
        quantity: 2,
        imageUrl: 'https://example.com/image1.jpg',
      ),
      CartItem(
        productId: 'product2',
        name: 'Product 2',
        price: 50.0,
        quantity: 1,
        imageUrl: 'https://example.com/image2.jpg',
      ),
    ];

    final mockOrder = Order(
      id: 'order123',
      sellerId: testSellerId,
      items: testItems,
      totalAmount: 250.0,
      status: 'pending',
      createdAt: DateTime.now(),
      deliveryAddressId: testAddressId,
    );

    test('should successfully submit order with valid data', () async {
      // Arrange
      when(() => mockRepository.submitOrder(
            sellerId: any(named: 'sellerId'),
            items: any(named: 'items'),
            deliveryAddressId: any(named: 'deliveryAddressId'),
          )).thenAnswer((_) async => mockOrder);

      // Act
      final result = await useCase.execute(
        sellerId: testSellerId,
        items: testItems,
        deliveryAddressId: testAddressId,
      );

      // Assert
      expect(result, equals(mockOrder));
      verify(() => mockRepository.submitOrder(
            sellerId: testSellerId,
            items: testItems,
            deliveryAddressId: testAddressId,
          )).called(1);
    });

    test('should throw ArgumentError for empty seller ID', () async {
      // Act & Assert
      expect(
        () => useCase.execute(
          sellerId: '',
          items: testItems,
          deliveryAddressId: testAddressId,
        ),
        throwsA(isA<ArgumentError>()),
      );

      verifyNever(() => mockRepository.submitOrder(
            sellerId: any(named: 'sellerId'),
            items: any(named: 'items'),
            deliveryAddressId: any(named: 'deliveryAddressId'),
          ));
    });

    test('should throw ArgumentError for empty items list', () async {
      // Act & Assert
      expect(
        () => useCase.execute(
          sellerId: testSellerId,
          items: [],
          deliveryAddressId: testAddressId,
        ),
        throwsA(isA<ArgumentError>()),
      );

      verifyNever(() => mockRepository.submitOrder(
            sellerId: any(named: 'sellerId'),
            items: any(named: 'items'),
            deliveryAddressId: any(named: 'deliveryAddressId'),
          ));
    });

    test('should throw ArgumentError for empty address ID', () async {
      // Act & Assert
      expect(
        () => useCase.execute(
          sellerId: testSellerId,
          items: testItems,
          deliveryAddressId: '',
        ),
        throwsA(isA<ArgumentError>()),
      );

      verifyNever(() => mockRepository.submitOrder(
            sellerId: any(named: 'sellerId'),
            items: any(named: 'items'),
            deliveryAddressId: any(named: 'deliveryAddressId'),
          ));
    });

    test('should sanitize IDs before submitting', () async {
      // Arrange
      const sellerIdWithSpaces = '  seller123  ';
      const addressIdWithSpaces = '  address456  ';
      when(() => mockRepository.submitOrder(
            sellerId: any(named: 'sellerId'),
            items: any(named: 'items'),
            deliveryAddressId: any(named: 'deliveryAddressId'),
          )).thenAnswer((_) async => mockOrder);

      // Act
      await useCase.execute(
        sellerId: sellerIdWithSpaces,
        items: testItems,
        deliveryAddressId: addressIdWithSpaces,
      );

      // Assert
      verify(() => mockRepository.submitOrder(
            sellerId: testSellerId,
            items: testItems,
            deliveryAddressId: testAddressId,
          )).called(1);
    });

    test('should calculate total amount correctly', () async {
      // Arrange
      when(() => mockRepository.submitOrder(
            sellerId: any(named: 'sellerId'),
            items: any(named: 'items'),
            deliveryAddressId: any(named: 'deliveryAddressId'),
          )).thenAnswer((_) async => mockOrder);

      // Act
      final result = await useCase.execute(
        sellerId: testSellerId,
        items: testItems,
        deliveryAddressId: testAddressId,
      );

      // Assert
      expect(result.totalAmount, equals(250.0)); // (100*2) + (50*1)
    });

    test('should propagate repository errors', () async {
      // Arrange
      when(() => mockRepository.submitOrder(
            sellerId: any(named: 'sellerId'),
            items: any(named: 'items'),
            deliveryAddressId: any(named: 'deliveryAddressId'),
          )).thenThrow(Exception('Payment failed'));

      // Act & Assert
      expect(
        () => useCase.execute(
          sellerId: testSellerId,
          items: testItems,
          deliveryAddressId: testAddressId,
        ),
        throwsA(isA<Exception>()),
      );
    });
  });
}
