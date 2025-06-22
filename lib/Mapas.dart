import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'geocoding_service.dart';

class Mapas extends StatefulWidget {
  const Mapas({Key? key}) : super(key: key);

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<Mapas> {
  final MapController _mapController = MapController();
  final TextEditingController _searchController = TextEditingController();
  LatLng? _currentLocation;
  LatLng? _selectedLocation;
  bool _isLoading = true;
  String _errorMessage = '';
  bool _mapInitialized = false;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<bool> _checkPermissions() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() {
        _errorMessage = 'Serviço de localização desabilitado';
        _isLoading = false;
      });
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() {
          _errorMessage = 'Permissão de localização negada';
          _isLoading = false;
        });
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() {
        _errorMessage = 'Permissão permanentemente negada. Ative nas configurações.';
        _isLoading = false;
      });
      return false;
    }

    return true;
  }

  Future<void> _getCurrentLocation() async {
    if (!await _checkPermissions()) return;
    try {
      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.best);
      setState(() {
        _currentLocation = LatLng(position.latitude, position.longitude);
        _isLoading = false;
      });

      if (_mapInitialized) {
        _mapController.move(_currentLocation!, 16);
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Erro ao obter localização: ${e.toString()}';
      });
    }
  }

  void _handleTap(TapPosition tapPosition, LatLng latLng) {
    setState(() {
      _selectedLocation = latLng;
    });
  }

  Future<void> _buscarEndereco(String endereco) async {
    if (endereco.trim().isEmpty) {
      _mostrarSnackBar('Digite um endereço');
      return;
    }

    final destino = await GeocodingService.buscarComNominatim(endereco);
    if (destino != null) {
      setState(() => _selectedLocation = destino);
      _mapController.move(destino, 16);
    } else {
      _mostrarSnackBar('Local não encontrado');
    }
  }
  void _mostrarSnackBar(String mensagem) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(mensagem)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Selecione um Local"),
        actions: [
          if (_selectedLocation != null)
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: () {
                Navigator.pop(context, _selectedLocation);
              },
            ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buscar endereço...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
              textInputAction: TextInputAction.search,
              onSubmitted: _buscarEndereco,
            ),
          ),
          Expanded(child: _buildMapContent()),
        ],
      ),
      floatingActionButton: _selectedLocation != null
          ? FloatingActionButton(
        child: const Icon(Icons.my_location),
        onPressed: () {
          _mapController.move(_selectedLocation!, 16);
        },
      )
          : null,
    );
  }

  Widget _buildMapContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_errorMessage),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _getCurrentLocation,
              child: const Text('Tentar Novamente'),
            ),
            if (_errorMessage.contains('permanentemente'))
              TextButton(
                onPressed: () => Geolocator.openAppSettings(),
                child: const Text('Abrir Configurações'),
              ),
          ],
        ),
      );
    }

    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: _currentLocation ?? const LatLng(0, 0),
        initialZoom: 16,
        onTap: _handleTap,
        onMapReady: () {
          setState(() => _mapInitialized = true);
          if (_currentLocation != null) {
            _mapController.move(_currentLocation!, 16);
          }
        },
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.example.app',
        ),
        if (_currentLocation != null)
          MarkerLayer(
            markers: [
              Marker(
                point: _currentLocation!,
                child: const Icon(Icons.person_pin_circle, size: 50, color: Colors.blue),
              ),
            ],
          ),
        if (_selectedLocation != null)
          MarkerLayer(
            markers: [
              Marker(
                point: _selectedLocation!,
                child: const Icon(Icons.location_pin, size: 50, color: Colors.red),
              ),
            ],
          ),
      ],
    );
  }
}