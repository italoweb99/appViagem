import 'package:latlong2/latlong.dart';

    class Viagem {
      final LatLng coordenadas;
      final String nome;
      final String endereco;
      final String cidade;
      final String estado;
      final String pais;
      final String cep;
      final String? bairro;
      final String? referencia;

      Viagem({
        required this.coordenadas,
        required this.nome,
        required this.endereco,
        required this.cidade,
        required this.estado,
        required this.pais,
        required this.cep,
        this.bairro,
        this.referencia,
      });

      factory Viagem.fromJson(Map<String, dynamic> json,
          {required String nomePersonalizado}) {
        final endereco = json['address'];
        return Viagem(
          coordenadas: LatLng(
            double.parse(json['lat']),
            double.parse(json['lon']),
          ),
          nome: nomePersonalizado,
          endereco:
          '${endereco['road'] ?? ''}, ${endereco['house_number'] ?? ''}'.trim(),
          cidade: endereco['city'] ?? endereco['town'] ?? endereco['village'] ??
              '',
          estado: endereco['state'] ?? '',
          pais: endereco['country'] ?? '',
          cep: endereco['postcode'] ?? '',
          bairro: endereco['suburb'] ?? endereco['neighbourhood'] ?? '',
          referencia: endereco['amenity'] ?? endereco['building'] ?? '',
        );
      }
    }