import 'package:dio/dio.dart';

class ErrorInterceptor extends Interceptor {

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {

    if(err.response?.statusCode == 401){
      // token hết hạn
    }

    return handler.next(err);
  }

}