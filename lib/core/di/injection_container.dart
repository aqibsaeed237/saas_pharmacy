import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../configs/app_config.dart';
import '../network/dio_client.dart';
import '../../data/api/auth_api_service.dart';
import '../../data/api/product_api_service.dart';
import '../../data/api/sale_api_service.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../data/repositories/product_repository_impl.dart';
import '../../data/repositories/sale_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/product_repository.dart';
import '../../domain/repositories/sale_repository.dart';
import '../../domain/usecases/auth/login_usecase.dart';
import '../../domain/usecases/auth/register_pharmacy_usecase.dart';
import '../../domain/usecases/auth/logout_usecase.dart';
import '../../domain/usecases/auth/get_current_user_usecase.dart';
import '../../domain/usecases/products/get_products_usecase.dart';
import '../../domain/usecases/products/create_product_usecase.dart';
import '../../domain/usecases/sales/create_sale_usecase.dart';
import '../../presentation/authentication/bloc/auth_bloc.dart';
import '../../presentation/products/bloc/product_bloc.dart';
import '../../presentation/sales/bloc/sale_bloc.dart';
import '../../presentation/categories/bloc/category_bloc.dart';
import '../../presentation/customers/bloc/customer_bloc.dart';
import '../../presentation/wallet/bloc/wallet_bloc.dart';
import '../../presentation/payment_methods/bloc/payment_method_bloc.dart';
import '../../presentation/search/bloc/search_bloc.dart';
import '../../presentation/stores/bloc/store_bloc.dart';
import '../utils/theme_manager.dart';
import '../utils/locale_manager.dart';

/// Dependency injection container
final getIt = GetIt.instance;

/// Initialize dependency injection
Future<void> init() async {
  // External
  final secureStorage = FlutterSecureStorage();
  getIt.registerLazySingleton<FlutterSecureStorage>(() => secureStorage);

  // Network
  final dioClient = DioClient(secureStorage);
  getIt.registerLazySingleton<Dio>(() => dioClient.dio);
  getIt.registerLazySingleton<DioClient>(() => dioClient);

  // API Services
  getIt.registerLazySingleton<AuthApiService>(
    () => AuthApiService(getIt<Dio>()),
  );
  getIt.registerLazySingleton<ProductApiService>(
    () => ProductApiService(getIt<Dio>()),
  );
  getIt.registerLazySingleton<SaleApiService>(
    () => SaleApiService(getIt<Dio>()),
  );

  // Repositories
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      apiService: getIt<AuthApiService>(),
      secureStorage: getIt<FlutterSecureStorage>(),
    ),
  );
  getIt.registerLazySingleton<ProductRepository>(
    () => ProductRepositoryImpl(getIt<ProductApiService>()),
  );
  getIt.registerLazySingleton<SaleRepository>(
    () => SaleRepositoryImpl(getIt<SaleApiService>()),
  );

  // Use Cases
  getIt.registerLazySingleton(() => LoginUseCase(getIt<AuthRepository>()));
  getIt.registerLazySingleton(
    () => RegisterPharmacyUseCase(getIt<AuthRepository>()),
  );
  getIt.registerLazySingleton(() => LogoutUseCase(getIt<AuthRepository>()));
  getIt.registerLazySingleton(
    () => GetCurrentUserUseCase(getIt<AuthRepository>()),
  );
  getIt.registerLazySingleton(
    () => GetProductsUseCase(getIt<ProductRepository>()),
  );
  getIt.registerLazySingleton(
    () => CreateProductUseCase(getIt<ProductRepository>()),
  );
  getIt.registerLazySingleton(
    () => CreateSaleUseCase(getIt<SaleRepository>()),
  );

  // BLoCs
  getIt.registerFactory(
    () => AuthBloc(
      loginUseCase: getIt<LoginUseCase>(),
      registerPharmacyUseCase: getIt<RegisterPharmacyUseCase>(),
      logoutUseCase: getIt<LogoutUseCase>(),
      getCurrentUserUseCase: getIt<GetCurrentUserUseCase>(),
    ),
  );
  getIt.registerFactory(
    () => ProductBloc(
      getProductsUseCase: getIt<GetProductsUseCase>(),
      createProductUseCase: getIt<CreateProductUseCase>(),
    ),
  );
  getIt.registerFactory(
    () => SaleBloc(
      createSaleUseCase: getIt<CreateSaleUseCase>(),
    ),
  );
  getIt.registerFactory(() => CustomerBloc());
  getIt.registerFactory(() => CategoryBloc());
      getIt.registerFactory(() => WalletBloc());
      getIt.registerFactory(() => PaymentMethodBloc());
      getIt.registerFactory(() => SearchBloc());
      getIt.registerFactory(() => StoreBloc());

  // Managers
  getIt.registerLazySingleton<ThemeManager>(() => ThemeManager());
  getIt.registerLazySingleton<LocaleManager>(() => LocaleManager());
}

