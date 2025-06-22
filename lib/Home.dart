import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'geocoding_service.dart';
import 'viagem_model.dart';
import 'Mapas.dart';

class Home extends StatefulWidget{
  @override
_HomeState createState() => _HomeState();

}
class _HomeState extends State<Home> {
 final List<Viagem> _listaViagens = [];
 Future<void> _adicionarLocal() async{
   final selectLocation = await Navigator.push<LatLng>(context, MaterialPageRoute(builder: (context)=> Mapas()),
   );
   if(selectLocation != null){
     await _adicionarViagemDaLocalizacao(selectLocation);
   }
 }
 Future <void> _adicionarViagemDaLocalizacao (LatLng location) async {
   try{
     final dadosLocal = await GeocodingService.getAddressFromCoordinates(location);
     final nomeController = TextEditingController(
       text: dadosLocal['name']??
         dadosLocal['address']['amenity'] ?? 'Novo Local',
     );
     final confirmado = await showDialog<bool>(
         context: context,
         builder: (context) => AlertDialog(
             title: const Text('Confirmar Local'),
             content: SingleChildScrollView(
                 child: Column(
                   children: [
                     Text(
                         'Endereço: ${dadosLocal['display_name'] ?? 'Não identificado'}'),
                     const SizedBox(height: 16),
                     TextFormField(
                       controller: nomeController,
                       decoration: const InputDecoration(
                         labelText: 'Nome para este local',
                       ),
                     ),
                   ],
                 )
             ),
           actions: [
             TextButton(
               onPressed: () => Navigator.pop(context, false),
               child: const Text('Cancelar'),
             ),
             TextButton(
               onPressed: () => Navigator.pop(context, true),
               child: const Text('Salvar'),
             ),
           ],
         )
     );
     if (confirmado == true) {
       final novaViagem = Viagem.fromJson(
         dadosLocal,
         nomePersonalizado: nomeController.text,
       );
       setState(() => _listaViagens.add(novaViagem));
     }
   } catch (e) {
// Fallback manual se a API falhar
   final nome = await _mostrarDialogoManual(location);
   if (nome != null) {
   setState(() => _listaViagens.add(
   Viagem(
   coordenadas: location,
   nome: nome,
   endereco:
   'Coordenadas: ${location.latitude.toStringAsFixed(6)}, '
   '${location.longitude.toStringAsFixed(6)}',
   cidade: 'Não identificada',
   estado: '',
   pais: '',
   cep: '',
   ),
   ));
   }
 }
 }
 Future<String?> _mostrarDialogoManual(LatLng location) async {
   final controller = TextEditingController();
   return await showDialog<String>(
       context: context,
       builder: (context) => AlertDialog(
           title: const Text('Adicionar Local Manualmente'),
           content: TextField(
             controller: controller,
             decoration: const InputDecoration(
               labelText: 'Nome do local',
               hintText: 'Ex: Meu ponto favorito',
             ),
           ),
           actions: [
           TextButton(
           onPressed: () => Navigator.pop(context),
   child: const Text('Cancelar'),
   ),
   TextButton(
   onPressed: () => Navigator.pop(context, controller.text),
   child: const Text('Salvar'),
   ),
           ],
       ),
   );
 }
 void _excluirViagem(int index) {
   setState(() {
     _listaViagens.removeAt(index);
   });
 }
 Widget build(BuildContext context) {
   return Scaffold(
       appBar: AppBar(
           title: const Text("Minhas viagens"),
           actions: [
           if (_listaViagens.isNotEmpty)
       IconButton(
       icon: const Icon(Icons.sort),
   onPressed: () async {
   try {
   final position = await Geolocator.getCurrentPosition();
   setState(() {
   _listaViagens.sort((a, b) {
   final distanciaA = const Distance().as(
   LengthUnit.Kilometer,
   LatLng(position.latitude, position.longitude),
   a.coordenadas);
   final distanciaB = const Distance().as(
   LengthUnit.Kilometer,
   LatLng(position.latitude, position.longitude),
   b.coordenadas);
   return distanciaA.compareTo(distanciaB);
   });
   });
   } catch (e) {
   ScaffoldMessenger.of(context).showSnackBar(
   SnackBar(content: Text('Erro ao ordenar: ${e.toString()}')),
   );
   }
   },
   ),
   ],
   ),
   floatingActionButton: FloatingActionButton(
   child: const Icon(Icons.add),
   onPressed: _adicionarLocal,
   ),
   body: _listaViagens.isEmpty
   ? const Center(
   child: Text(
   'Nenhuma viagem adicionada\nClique no + para começar',
   textAlign: TextAlign.center,
   style: TextStyle(fontSize: 18),
   ),
   )
       : ListView.builder(
   itemCount: _listaViagens.length,
   itemBuilder: (context, index) {
   final viagem = _listaViagens[index];
   return Card(
   margin: const EdgeInsets.all(8),
   child: ListTile(
   title: Text(
   viagem.nome,
   style: const TextStyle(fontWeight: FontWeight.bold),
   ),
   subtitle: Column(
   crossAxisAlignment: CrossAxisAlignment.start,
   children: [
   if (viagem.endereco.isNotEmpty) Text(viagem.endereco),
   if (viagem.cidade.isNotEmpty)
   Text('${viagem.cidade}, ${viagem.estado}'),
   if (viagem.pais.isNotEmpty) Text(viagem.pais),
   if (viagem.cep.isNotEmpty) Text('CEP: ${viagem.cep}'),
   Text(
   'Coordenadas: ${viagem.coordenadas.latitude.toStringAsFixed(4)}, '
   '${viagem.coordenadas.longitude.toStringAsFixed(4)}',
   style: const TextStyle(fontSize: 12),
   ),
   ],
   ),
     trailing: IconButton(
       icon: const Icon(Icons.delete, color: Colors.red),
       onPressed: () => _excluirViagem(index),
     ),
     onTap: () {
       Navigator.push(
         context,
         MaterialPageRoute(
           builder: (context) => Mapas(),
         ),
       );
     },
   ),
   );
   },
   ),
   );
 }
}

