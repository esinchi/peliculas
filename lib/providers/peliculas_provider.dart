import 'dart:async';

import 'package:http/http.dart' as http;

import 'dart:convert';

import 'package:peliculas/models/pelicula_model.dart';

class PeliculasProvider {
  //definimos parametros de consulta
  String _apikey = 'e9f8391d8cd686e6d8a91ab56062c510';
  String _url = 'api.themoviedb.org';
  String _language = 'es-ES';
  int _popularesPage = 0;

  List<Pelicula> _populares = List<Pelicula>.empty(growable: true);
  final _popularesStreamController =
      StreamController<List<Pelicula>>.broadcast();

//inicio de la tuberia
  Function(List<Pelicula>) get popularesSink =>
      _popularesStreamController.sink.add;

//escucho datos
  Stream<List<Pelicula>> get popularesStream =>
      _popularesStreamController.stream;

  void disposeStream() {
    _popularesStreamController?.close();
  }

  Future<List<Pelicula>> getEnCines() async {
    final url = Uri.https(_url, '3/movie/now_playing', {
      'api_key': _apikey,
      'language': _language,
    });
    return await _procesarRespuesta(url);
  }

  Future<List<Pelicula>> getPopulares() async {
    _popularesPage++;
    final url = Uri.https(_url, '3/movie/popular', {
      'api_key': _apikey,
      'language': _language,
      'page': _popularesPage.toString()
    });

    final resp = await _procesarRespuesta(url);
    _populares.addAll(resp);

    popularesSink(_populares);
  }

  Future<List<Pelicula>> _procesarRespuesta(Uri url) async {
    final resp = await http.get(url);
    final decodeData = json.decode(resp.body);
    final peliculas = new Peliculas.fromJsonList(decodeData['results']);
    return peliculas.items;
  }
}
