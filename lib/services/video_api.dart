import 'package:http/http.dart' as http;
import 'package:eduniger/models/Video.dart';
import 'package:eduniger/utils/helper.dart';


Future<List<Video>> getVideosFromApi({VideoSort filter = VideoSort.id}) async {
  final url = 'https://orangevalleycaa.org/api/videos/order/${filter.filterName()}';

  // Correction: utiliser Uri.parse() au lieu de (url as Uri)
  var response = await http.get(Uri.parse(url));

  if (response.statusCode == 200) {
    var json = response.body;
    return videoFromJson(json);
  } else {
    return [];
  }
}