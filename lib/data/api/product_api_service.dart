import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import '../models/product_model.dart';

part 'product_api_service.g.dart';

/// Product API service
@RestApi()
abstract class ProductApiService {
  factory ProductApiService(Dio dio, {String baseUrl}) = _ProductApiService;

  @GET('/products')
  Future<Map<String, dynamic>> getProducts(@Queries() Map<String, dynamic> queries);

  @GET('/products/{id}')
  Future<ProductModel> getProductById(@Path('id') String id);

  @GET('/products/barcode/{barcode}')
  Future<ProductModel> getProductByBarcode(@Path('barcode') String barcode);

  @POST('/products')
  Future<ProductModel> createProduct(@Body() Map<String, dynamic> body);

  @PUT('/products/{id}')
  Future<ProductModel> updateProduct(
    @Path('id') String id,
    @Body() Map<String, dynamic> body,
  );

  @DELETE('/products/{id}')
  Future<void> deleteProduct(@Path('id') String id);
}

