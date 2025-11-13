import 'package:fuodz/constants/api.dart';
import 'package:fuodz/models/api_response.dart';
import 'package:fuodz/services/http.service.dart';

class DriverRequest extends HttpService {
  //
  Future<bool> syncLocation({
    required double lat,
    required double lng,
    required double rotation,
  }) async {
    final apiResult = await post(
      Api.driverLocationSync,
      {
        "lat": lat,
        "lng": lng,
        "rotation": rotation,
      },
    );

    //
    final apiResponse = ApiResponse.fromResponse(apiResult);
    return apiResponse.allGood;
  }
}
