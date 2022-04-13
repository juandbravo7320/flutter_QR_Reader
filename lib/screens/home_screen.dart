import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:qr_reader/providers/db_provider.dart';
import 'package:qr_reader/providers/scan_list_provider.dart';
import 'package:qr_reader/providers/ui_provider.dart';

import 'package:qr_reader/screens/screens.dart';
import 'package:qr_reader/widgets/widgets.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final scanListProvider = Provider.of<ScanListProvider>(context);
    final tipo = scanListProvider.tipoSeleccionado;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_forever),
            onPressed: () {
              print(tipo);
              scanListProvider.borrarTodos();
            },
          ),
        ],
      ),
      body: const _HomeScreenBody(),
      bottomNavigationBar: const CustomNavigationBar(),
      floatingActionButton: const ScanButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}

class _HomeScreenBody extends StatelessWidget {
  const _HomeScreenBody({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    //* Obtener el selected menu opt
    final uiProvider = Provider.of<UiProvider>(context);

    //* Cambiar para mostrar la página respectiva
    final currentIndex = uiProvider.selectedMenuOpt;

    // TODO: Temporal leer la base de datos

    /* final tempScan = ScanModel(valor: 'http://google.com');
    DBProvider.db.nuevoScan(tempScan);
    DBProvider.db.getScanById(5).then((scan) => print(scan!.valor));
    DBProvider.db.deleteAllScans().then(print); */

    //? Usar el ScanListProvider
    final scanListProvider =
        Provider.of<ScanListProvider>(context, listen: false);

    switch (currentIndex) {
      case 0:
        scanListProvider.cargarScansPorTipo('geo');
        return const MapasScreen();

      case 1:
        scanListProvider.cargarScansPorTipo('http');
        return const DireccionesScreen();

      default:
        return const MapasScreen();
    }
  }
}
