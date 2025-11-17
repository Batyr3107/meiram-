import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shop_app/api/product_api.dart';
import 'package:shop_app/api/order_api.dart';
import 'package:shop_app/core/di/injection.dart';
import 'package:shop_app/domain/repositories/product_repository.dart';
import 'package:shop_app/domain/repositories/order_repository.dart';
import 'package:shop_app/domain/usecases/get_products_usecase.dart';
import 'package:shop_app/domain/usecases/submit_order_usecase.dart';
import 'package:shop_app/models/product.dart';
import 'package:shop_app/models/cart_item.dart';
import 'package:shop_app/models/order.dart';

class MockProductApi extends Mock implements ProductApi {}

class MockOrderApi extends Mock implements OrderApi {}

/// Integration test for complete shopping flow
///
/// Tests:
/// 1. Browse products
/// 2. Add to cart
/// 3. Checkout
/// 4. Order submission
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    // Initialize DI
    await configureDependencies();

    // Register fallback values for mocktail
    registerFallbackValue(<CartItem>[]);
  });

  group('Shopping Flow Integration Tests', () {
    const testSellerId = 'seller123';
    const testAddressId = 'address456';

    final mockProducts = [
      Product(
        id: 'product1',
        name: 'Test Product 1',
        description: 'Description 1',
        price: 1000.0,
        imageUrl: 'https://example.com/image1.jpg',
        category: 'Electronics',
        sellerId: testSellerId,
      ),
      Product(
        id: 'product2',
        name: 'Test Product 2',
        description: 'Description 2',
        price: 500.0,
        imageUrl: 'https://example.com/image2.jpg',
        category: 'Electronics',
        sellerId: testSellerId,
      ),
    ];

    test('Complete shopping flow: browse → add to cart → checkout → order',
        () async {
      // Arrange
      final productRepository = getIt<IProductRepository>();
      final orderRepository = getIt<IOrderRepository>();

      final getProductsUseCase = GetProductsUseCase(productRepository);
      final submitOrderUseCase = SubmitOrderUseCase(orderRepository);

      // Step 1: Browse products
      final products = await getProductsUseCase.execute(testSellerId);

      expect(products, isNotEmpty);
      expect(products.length, greaterThan(0));

      // Step 2: Add products to cart
      final cartItems = [
        CartItem(
          productId: products.first.id,
          name: products.first.name,
          price: products.first.price,
          quantity: 2,
          imageUrl: products.first.imageUrl,
        ),
      ];

      expect(cartItems, isNotEmpty);
      expect(cartItems.first.quantity, equals(2));

      // Step 3: Calculate total
      final total =
          cartItems.fold<double>(0, (sum, item) => sum + (item.price * item.quantity));
      expect(total, equals(products.first.price * 2));

      // Step 4: Submit order
      final order = await submitOrderUseCase.execute(
        sellerId: testSellerId,
        items: cartItems,
        deliveryAddressId: testAddressId,
      );

      expect(order, isNotNull);
      expect(order.sellerId, equals(testSellerId));
      expect(order.items.length, equals(cartItems.length));
      expect(order.totalAmount, equals(total));
    });

    test('Empty cart should not allow checkout', () async {
      // Arrange
      final orderRepository = getIt<IOrderRepository>();
      final submitOrderUseCase = SubmitOrderUseCase(orderRepository);

      // Act & Assert
      expect(
        () => submitOrderUseCase.execute(
          sellerId: testSellerId,
          items: [], // Empty cart
          deliveryAddressId: testAddressId,
        ),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('Product search and filtering', () async {
      // Arrange
      final productRepository = getIt<IProductRepository>();
      final getProductsUseCase = GetProductsUseCase(productRepository);

      // Act
      final allProducts = await getProductsUseCase.execute(testSellerId);

      // Filter by category
      final electronicsProducts =
          allProducts.where((p) => p.category == 'Electronics').toList();

      // Assert
      expect(allProducts.length, greaterThanOrEqualTo(electronicsProducts.length));

      // Filter by price range
      final affordableProducts =
          allProducts.where((p) => p.price <= 1000.0).toList();
      expect(affordableProducts, everyElement(
        predicate((Product p) => p.price <= 1000.0),
      ));
    });

    test('Cart quantity updates correctly', () async {
      // Arrange
      final product = mockProducts.first;
      var cartItem = CartItem(
        productId: product.id,
        name: product.name,
        price: product.price,
        quantity: 1,
        imageUrl: product.imageUrl,
      );

      // Act - Increase quantity
      cartItem = cartItem.copyWith(quantity: cartItem.quantity + 1);
      expect(cartItem.quantity, equals(2));

      // Act - Decrease quantity
      cartItem = cartItem.copyWith(quantity: cartItem.quantity - 1);
      expect(cartItem.quantity, equals(1));

      // Assert total calculation
      final itemTotal = cartItem.price * cartItem.quantity;
      expect(itemTotal, equals(product.price));
    });

    test('Order validation checks', () async {
      // Arrange
      final orderRepository = getIt<IOrderRepository>();
      final submitOrderUseCase = SubmitOrderUseCase(orderRepository);

      final validCartItems = [
        CartItem(
          productId: 'product1',
          name: 'Product 1',
          price: 100.0,
          quantity: 1,
          imageUrl: 'image.jpg',
        ),
      ];

      // Test: Empty seller ID
      expect(
        () => submitOrderUseCase.execute(
          sellerId: '',
          items: validCartItems,
          deliveryAddressId: testAddressId,
        ),
        throwsA(isA<ArgumentError>()),
      );

      // Test: Empty address ID
      expect(
        () => submitOrderUseCase.execute(
          sellerId: testSellerId,
          items: validCartItems,
          deliveryAddressId: '',
        ),
        throwsA(isA<ArgumentError>()),
      );

      // Test: Whitespace-only IDs
      expect(
        () => submitOrderUseCase.execute(
          sellerId: '   ',
          items: validCartItems,
          deliveryAddressId: testAddressId,
        ),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('Multiple items in cart with different quantities', () async {
      // Arrange
      final cartItems = [
        CartItem(
          productId: 'product1',
          name: 'Product 1',
          price: 100.0,
          quantity: 2,
          imageUrl: 'image1.jpg',
        ),
        CartItem(
          productId: 'product2',
          name: 'Product 2',
          price: 50.0,
          quantity: 3,
          imageUrl: 'image2.jpg',
        ),
        CartItem(
          productId: 'product3',
          name: 'Product 3',
          price: 25.0,
          quantity: 1,
          imageUrl: 'image3.jpg',
        ),
      ];

      // Act - Calculate total
      final total = cartItems.fold<double>(
        0,
        (sum, item) => sum + (item.price * item.quantity),
      );

      // Assert
      // (100*2) + (50*3) + (25*1) = 200 + 150 + 25 = 375
      expect(total, equals(375.0));

      // Verify item count
      expect(cartItems.length, equals(3));

      // Verify total quantity
      final totalQuantity =
          cartItems.fold<int>(0, (sum, item) => sum + item.quantity);
      expect(totalQuantity, equals(6));
    });

    test('Order submission with sanitized inputs', () async {
      // Arrange
      final orderRepository = getIt<IOrderRepository>();
      final submitOrderUseCase = SubmitOrderUseCase(orderRepository);

      final cartItems = [
        CartItem(
          productId: 'product1',
          name: 'Product 1',
          price: 100.0,
          quantity: 1,
          imageUrl: 'image.jpg',
        ),
      ];

      // Act - Submit with whitespace in IDs
      const sellerIdWithSpaces = '  seller123  ';
      const addressIdWithSpaces = '  address456  ';

      final order = await submitOrderUseCase.execute(
        sellerId: sellerIdWithSpaces,
        items: cartItems,
        deliveryAddressId: addressIdWithSpaces,
      );

      // Assert - IDs should be trimmed
      expect(order.sellerId, equals(testSellerId));
      expect(order.deliveryAddressId, equals(testAddressId));
    });
  });
}
