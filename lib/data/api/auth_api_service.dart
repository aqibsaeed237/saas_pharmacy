import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import '../models/auth_model.dart';
import '../models/user_model.dart';

part 'auth_api_service.g.dart';

/// Authentication API service
@RestApi()
abstract class AuthApiService {
  factory AuthApiService(Dio dio, {String baseUrl}) = _AuthApiService;

  @POST('/auth/login')
  Future<AuthResponseModel> login(@Body() Map<String, dynamic> body);

  @POST('/auth/register-pharmacy')
  Future<AuthResponseModel> registerPharmacy(@Body() Map<String, dynamic> body);

  @GET('/auth/me')
  Future<UserModel> getCurrentUser();

  @POST('/auth/refresh')
  Future<Map<String, dynamic>> refreshToken(@Body() Map<String, dynamic> body);

  @POST('/auth/logout')
  Future<void> logout();
}

