import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:geocoding/geocoding.dart';
class GeocodingService{
  static const nominatimUrl = 'https://nominatim.openstreetmap.org/reverse';
  static Future <Map<String,dynamic>> getAddressFromCoordinates(LatLng coords) async{
    final response = await http.get(
      Uri.parse(
        '$nominatimUrl?format=jsonv2&lat=${coords.latitude}&lon=${coords.longitude}'
      ),
      headers: {'User-Agent': 'YourAppName/1.0'}
    );
    if(response.statusCode == 200){
      return json.decode(response.body);
    }
    else{
      throw Exception('Falha ao obter endereço');
    }
  }

 static Future<LatLng?> buscarComNominatim(String endereco) async {
   final url = Uri.parse(
     'https://nominatim.openstreetmap.org/search?q=${Uri.encodeComponent(
         endereco)}&format=json&limit=1',
   );

   final response = await http.get(url, headers: {
     'User-Agent': 'flutter_app_italo/1.0' // Obrigatório pela API!
   });

   if (response.statusCode == 200) {
     final List dados = jsonDecode(response.body);
     if (dados.isNotEmpty) {
       final local = dados.first;
       final lat = double.parse(local['lat']);
       final lon = double.parse(local['lon']);
       return LatLng(lat, lon);
     }
   }
   else{
     throw Exception("Erro ao obter coodenadas");
   }
 }
  }