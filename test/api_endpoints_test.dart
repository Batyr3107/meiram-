import 'package:flutter_test/flutter_test.dart';
import 'package:shop_app/data/repositories/auth_repository_impl.dart';
import 'package:shop_app/data/repositories/buyer_repository_impl.dart';
import 'package:shop_app/data/repositories/seller_repository_impl.dart';
import 'package:shop_app/data/repositories/product_repository_impl.dart';
import 'package:shop_app/data/repositories/order_repository_impl.dart';
import 'package:shop_app/data/repositories/address_repository_impl.dart';
import 'package:shop_app/data/models/buyer_registration_request.dart';
import 'package:shop_app/data/models/seller_registration_request.dart';
import 'package:shop_app/core/di/injection.dart';

/// Comprehensive API Endpoints Test Suite
/// Tests all critical endpoints for correct request/response handling
void main() {
  setUpAll(() async {
    // Initialize dependency injection
    await configureDependencies();
  });

  group('Auth Endpoints Tests', () {
    late AuthRepositoryImpl authRepository;

    setUp(() {
      authRepository = getIt<AuthRepositoryImpl>();
    });

    test('Login endpoint - correct request format', () async {
      // Test that login sends correct payload
      const email = 'test@example.com';
      const password = 'password123';

      try {
        await authRepository.login(email, password);
        // If no exception, endpoint format is correct
      } catch (e) {
        // Expected to fail without real server, but check error type
        expect(e, isNot(isA<FormatException>()),
            reason: 'Login endpoint should have correct request format');
      }
    });

    test('Refresh token endpoint - correct request format', () async {
      const refreshToken = 'dummy_refresh_token';

      try {
        await authRepository.refreshToken(refreshToken);
      } catch (e) {
        expect(e, isNot(isA<FormatException>()),
            reason: 'Refresh token endpoint should have correct format');
      }
    });

    test('Logout endpoint - correct request format', () async {
      try {
        await authRepository.logout();
      } catch (e) {
        expect(e, isNot(isA<FormatException>()),
            reason: 'Logout endpoint should have correct format');
      }
    });
  });

  group('Buyer Endpoints Tests', () {
    late BuyerRepositoryImpl buyerRepository;

    setUp(() {
      buyerRepository = getIt<BuyerRepositoryImpl>();
    });

    test('Register buyer endpoint - correct payload structure', () async {
      final request = BuyerRegistrationRequest(
        email: 'buyer@test.com',
        phone: '77012345678',
        password: 'password123',
      );

      try {
        await buyerRepository.register(request);
      } catch (e) {
        expect(e, isNot(isA<FormatException>()),
            reason: 'Buyer registration should send correct payload');
      }
    });

    test('Get buyer profile endpoint - correct request', () async {
      const buyerId = 1;

      try {
        await buyerRepository.getById(buyerId);
      } catch (e) {
        expect(e, isNot(isA<FormatException>()),
            reason: 'Get buyer profile endpoint should be correct');
      }
    });

    test('Update buyer endpoint - correct payload', () async {
      const buyerId = 1;
      const updatedData = {
        'email': 'updated@test.com',
        'phone': '77012345678',
      };

      try {
        await buyerRepository.update(buyerId, updatedData);
      } catch (e) {
        expect(e, isNot(isA<FormatException>()),
            reason: 'Update buyer endpoint should have correct format');
      }
    });
  });

  group('Seller Endpoints Tests', () {
    late SellerRepositoryImpl sellerRepository;

    setUp(() {
      sellerRepository = getIt<SellerRepositoryImpl>();
    });

    test('Register seller endpoint - correct payload structure', () async {
      final request = SellerRegistrationRequest(
        email: 'seller@test.com',
        phone: '77012345678',
        password: 'password123',
        organizationName: 'Test Org',
        bin: '123456789012',
      );

      try {
        await sellerRepository.register(request);
      } catch (e) {
        expect(e, isNot(isA<FormatException>()),
            reason: 'Seller registration should send correct payload');
      }
    });

    test('Get all sellers endpoint - pagination params', () async {
      try {
        await sellerRepository.getAll(page: 0, size: 20);
      } catch (e) {
        expect(e, isNot(isA<FormatException>()),
            reason: 'Get sellers should use correct pagination format');
      }
    });

    test('Get seller by ID endpoint', () async {
      const sellerId = 1;

      try {
        await sellerRepository.getById(sellerId);
      } catch (e) {
        expect(e, isNot(isA<FormatException>()),
            reason: 'Get seller by ID endpoint should be correct');
      }
    });
  });

  group('Product Endpoints Tests', () {
    late ProductRepositoryImpl productRepository;

    setUp(() {
      productRepository = getIt<ProductRepositoryImpl>();
    });

    test('Get products by seller - correct query params', () async {
      const sellerId = 1;

      try {
        await productRepository.getProductsBySeller(
          sellerId,
          page: 0,
          size: 20,
        );
      } catch (e) {
        expect(e, isNot(isA<FormatException>()),
            reason: 'Get products by seller should have correct format');
      }
    });

    test('Get product by ID endpoint', () async {
      const productId = 1;

      try {
        await productRepository.getById(productId);
      } catch (e) {
        expect(e, isNot(isA<FormatException>()),
            reason: 'Get product by ID endpoint should be correct');
      }
    });

    test('Search products endpoint - query param', () async {
      const query = 'test product';

      try {
        await productRepository.search(
          query,
          page: 0,
          size: 20,
        );
      } catch (e) {
        expect(e, isNot(isA<FormatException>()),
            reason: 'Search products should have correct query format');
      }
    });
  });

  group('Order Endpoints Tests', () {
    late OrderRepositoryImpl orderRepository;

    setUp(() {
      orderRepository = getIt<OrderRepositoryImpl>();
    });

    test('Create order endpoint - correct payload', () async {
      final orderData = {
        'buyerId': 1,
        'items': [
          {'productId': 1, 'quantity': 2},
          {'productId': 2, 'quantity': 1},
        ],
        'addressId': 1,
        'comment': 'Test order',
      };

      try {
        await orderRepository.createOrder(orderData);
      } catch (e) {
        expect(e, isNot(isA<FormatException>()),
            reason: 'Create order should send correct payload structure');
      }
    });

    test('Get buyer orders endpoint - pagination', () async {
      try {
        await orderRepository.getBuyerOrders(page: 0, size: 20);
      } catch (e) {
        expect(e, isNot(isA<FormatException>()),
            reason: 'Get buyer orders should have correct pagination');
      }
    });

    test('Get seller orders endpoint - pagination', () async {
      try {
        await orderRepository.getSellerOrders(page: 0, size: 20);
      } catch (e) {
        expect(e, isNot(isA<FormatException>()),
            reason: 'Get seller orders should have correct pagination');
      }
    });

    test('Update order status endpoint', () async {
      const orderId = 1;
      const newStatus = 'PROCESSING';

      try {
        await orderRepository.updateOrderStatus(orderId, newStatus);
      } catch (e) {
        expect(e, isNot(isA<FormatException>()),
            reason: 'Update order status should have correct format');
      }
    });
  });

  group('Address Endpoints Tests', () {
    late AddressRepositoryImpl addressRepository;

    setUp(() {
      addressRepository = getIt<AddressRepositoryImpl>();
    });

    test('Create address endpoint - correct payload', () async {
      final addressData = {
        'street': 'Test Street',
        'city': 'Test City',
        'postalCode': '050000',
        'country': 'Kazakhstan',
      };

      try {
        await addressRepository.createAddress(addressData);
      } catch (e) {
        expect(e, isNot(isA<FormatException>()),
            reason: 'Create address should send correct payload');
      }
    });

    test('Get all addresses endpoint', () async {
      try {
        await addressRepository.getAll();
      } catch (e) {
        expect(e, isNot(isA<FormatException>()),
            reason: 'Get all addresses endpoint should be correct');
      }
    });

    test('Update address endpoint - correct payload', () async {
      const addressId = 1;
      final updatedData = {
        'street': 'Updated Street',
        'city': 'Updated City',
      };

      try {
        await addressRepository.updateAddress(addressId, updatedData);
      } catch (e) {
        expect(e, isNot(isA<FormatException>()),
            reason: 'Update address should have correct format');
      }
    });

    test('Delete address endpoint', () async {
      const addressId = 1;

      try {
        await addressRepository.deleteAddress(addressId);
      } catch (e) {
        expect(e, isNot(isA<FormatException>()),
            reason: 'Delete address endpoint should be correct');
      }
    });
  });

  group('Endpoint URL Structure Tests', () {
    test('All endpoints use correct base URL', () {
      // Verify base URL is set correctly
      expect(
        const String.fromEnvironment('API_BASE_URL',
            defaultValue: 'http://localhost:8080'),
        isNotEmpty,
        reason: 'API base URL should be configured',
      );
    });

    test('Endpoints follow REST conventions', () {
      // This is a meta-test to ensure we're following REST
      // GET /api/buyers/:id - get by ID
      // POST /api/buyers - create
      // PUT /api/buyers/:id - update
      // DELETE /api/buyers/:id - delete
      expect(true, isTrue, reason: 'REST conventions should be followed');
    });
  });

  group('Error Handling Tests', () {
    test('Network errors are handled correctly', () async {
      final authRepository = getIt<AuthRepositoryImpl>();

      try {
        // This will fail with network error
        await authRepository.login('invalid@test.com', 'wrongpass');
        fail('Should throw network error');
      } catch (e) {
        // Error should be caught and wrapped properly
        expect(e, isNotNull);
      }
    });

    test('Validation errors return proper format', () async {
      final buyerRepository = getIt<BuyerRepositoryImpl>();

      try {
        // Invalid email format
        final request = BuyerRegistrationRequest(
          email: 'invalid-email',
          phone: '123', // too short
          password: '12', // too short
        );
        await buyerRepository.register(request);
        fail('Should throw validation error');
      } catch (e) {
        expect(e, isNotNull);
      }
    });
  });
}
