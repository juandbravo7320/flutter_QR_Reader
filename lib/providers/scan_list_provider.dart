import 'package:flutter/material.dart';
import 'package:qr_reader/providers/db_provider.dart';

//? ESTE ARCHIVO SE USA PARA BUSCAR LA INFORMACIÓN RELACIONADA
//? A LOS SCANS, Y ADEMÁS SE ENCARGARÁ DE REDIBUJAR LOS WIDGETS

//? CUANDO SE HAGA'TAP' SOBRE EL BOTÓN DE ESCANEAR, SE HARÁ UN
//? LLAMADO A ESTE ARCHIVO

class ScanListProvider extends ChangeNotifier {
  List<ScanModel> scans = [];
  String tipoSeleccionado = 'http';

  //* MÉTODO PARA INSERTAR UN NUEVO SCAN
  Future<ScanModel> nuevoScan(String valor) async {
    final nuevoScan = ScanModel(valor: valor);
    final id = await DBProvider.db.nuevoScan(nuevoScan);

    //Asignar el id de la base de datos al modelo
    nuevoScan.id = id;

    //Solo actualizamos la interfaz, si el scan que se genera,
    //es del tipo de scan de la pantalla en la que nos encontramos
    if (tipoSeleccionado == nuevoScan.tipo) {
      scans.add(nuevoScan);
      notifyListeners();
    }

    return nuevoScan;
  }

  cargarScans() async {
    final scans = await DBProvider.db.getTodosLosScans();
    this.scans = [...scans];
    notifyListeners();
  }

  cargarScansPorTipo(String tipo) async {
    final scans = await DBProvider.db.getScansPorTipo(tipo);
    this.scans = [...scans];
    tipoSeleccionado = tipo;
    notifyListeners();
  }

  borrarTodos() async {
    await DBProvider.db.deleteAllScans();
    scans = [];
    notifyListeners();
  }

  borrarScanPorId(int id) async {
    await DBProvider.db.deleteScan(id);
    /* cargarScansPorTipo(tipoSeleccionado); */
    //* NOTA: no llamamos a 'notifyListeners()' porque
    //* cuando invocamos a 'cargarScansPorTipo' internamente
    //* se invoca 'notifyListeners()'

    //? NOTA 2: No estamos redibujando el widget con 'notifyListeners()'
    //? porque la forma que implementamos para eliminar un registro por ID,
    //? es mediante un swipe lateral, y este widget, ya se encarga de redibujarlo
  }
}
