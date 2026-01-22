import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import '../models/sale_model.dart';

part 'sale_api_service.g.dart';

/// Sale API service
@RestApi()
abstract class SaleApiService {
  factory SaleApiService(Dio dio, {String baseUrl}) = _SaleApiService;

  @GET('/sales')
  Future<Map<String, dynamic>> getSales(@Queries() Map<String, dynamic> queries);

  @GET('/sales/{id}')
  Future<SaleModel> getSaleById(@Path('id') String id);

  @POST('/sales')
  Future<SaleModel> createSale(@Body() Map<String, dynamic> body);

  @GET('/sales/invoice-number')
  Future<Map<String, dynamic>> generateInvoiceNumber();
}

