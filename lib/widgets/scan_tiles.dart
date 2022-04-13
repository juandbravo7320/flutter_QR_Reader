import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/scan_list_provider.dart';
import 'package:qr_reader/utils/utils.dart';

class ScanTiles extends StatelessWidget {
  final String tipo;

  const ScanTiles({
    Key? key,
    required this.tipo,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final scanListProvider = Provider.of<ScanListProvider>(context);
    final scans = scanListProvider.scans;

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      itemCount: scans.length,
      itemBuilder: (BuildContext context, int i) => Dismissible(
        key: UniqueKey(),
        background: Container(
            padding: const EdgeInsets.only(right: 18),
            alignment: Alignment.centerRight,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: const [
                Text(
                  'Borrar',
                  style: TextStyle(color: Colors.red),
                ),
                SizedBox(
                  width: 10,
                ),
                Icon(
                  Icons.delete,
                  color: Colors.red,
                ),
              ],
            )),
        direction: DismissDirection.endToStart,
        onDismissed: (DismissDirection direction) {
          scanListProvider.borrarScanPorId(scans[i].id!);
        },
        child: ListTile(
          title: Text(scans[i].valor),
          leading: Icon(
              tipo == 'http' ? Icons.home_outlined : Icons.map_outlined,
              color: Theme.of(context).primaryColor),
          subtitle: Text(scans[i].id.toString()),
          trailing: const Icon(Icons.keyboard_arrow_right, color: Colors.grey),
          onTap: () => launchURL(context, scans[i]),
        ),
      ),
    );
  }
}
