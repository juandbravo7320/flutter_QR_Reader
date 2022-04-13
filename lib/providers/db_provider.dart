import 'dart:io';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import 'package:qr_reader/models/scan_model.dart';
export 'package:qr_reader/models/scan_model.dart';

//? La idea de este archivo, es crear un SINGLETON

class DBProvider {
  static Database? _database;

  //? Instacia de la clase personalizada
  //? "._()" significa que es un constructor privado
  static final DBProvider db = DBProvider._();

  //? El contructor privado, me ayuda a que siempre que se
  //? ejecute "new DBProvider()" voy a obtener la misma instancia siempre
  DBProvider._();

  //? Es un método asíncrono debido a que la lectura de la base de
  //? NO es un proceso síncrono, por tanto, tengo que esperar la respuesta
  Future<Database> get database async => _database ??= await initDB();

  Future<Database> initDB() async {
    // Path de donde almacenaremos la base de datos
    Directory documentsDirectory = await getApplicationDocumentsDirectory();

    final path = join(documentsDirectory.path, 'ScansDB.db');
    print(path);

    // Crear base de datos
    return await openDatabase(
      path,
      version: 1,
      onOpen: (db) {},
      onCreate: (Database db, int version) async {
        await db.execute('''
          CREATE TABLE Scans(
            id INTEGER Primary KEY,
            tipo TEXT,
            valor TEXT
          )
        ''');
      },
    );
  }

  Future<int> nuevoScanRaw(ScanModel nuevoScan) async {
    final id = nuevoScan.id;
    final tipo = nuevoScan.tipo;
    final valor = nuevoScan.valor;

    //Verificar la base de datos
    final db = await database;

    final res = await db.rawInsert('''
      INSERT INTO Scans(id, tipo, valor)
      VALUES($id, '$tipo', '$valor')
    ''');

    return res;
  }

  //* INSERTAR REGISTROS
  Future<int> nuevoScan(ScanModel nuevoScan) async {
    //Verifiacmos la base de datos
    final db = await database;

    final res = await db.insert('Scans', nuevoScan.toJson());

    // Es el ID del último registro insertado
    return res;
  }

  //* OBTENER SCAN POR ID
  Future<ScanModel?> getScanById(int id) async {
    final db = await database;

    //Extraemos los registros que cumplan con la condición
    final res = await db.query('Scans', where: 'id = ?', whereArgs: [id]);

    //Puede ser que no se encuentre ningún registro con el ID especificado
    //Si no encuentra ningun registro, regresamos null, en caso contrario,
    //regresamos una instancia de ScanModel, que eso es lo que hace el método
    //"fromJson", de un mapa crea una instancia de ScanModel
    return res.isNotEmpty ? ScanModel.fromJson(res.first) : null;
  }

  //* OBTENER TODOS LOS SCANS
  Future<List<ScanModel>> getTodosLosScans() async {
    final db = await database;

    final res = await db.query('Scans');

    return res.isNotEmpty
        ? res.map((scan) => ScanModel.fromJson(scan)).toList()
        : [];
  }

  //* OBTENER SCAN POR TIPO
  Future<List<ScanModel>> getScansPorTipo(String tipo) async {
    final db = await database;

    final res = await db.rawQuery('''
      SELECT * FROM Scans WHERE tipo = '$tipo'
    ''');

    return res.isNotEmpty
        ? res.map((scan) => ScanModel.fromJson(scan)).toList()
        : [];
  }

  //* ACTUALIZACIÓN DE UN REGISTRO EXISTENTE
  Future<int> updateScan(ScanModel nuevoScan) async {
    final db = await database;

    //Si no usamos el 'where' y 'whereArgs' se van a actualizar todos los registros
    final res = await db.update('Scans', nuevoScan.toJson(),
        where: 'id = ?', whereArgs: [nuevoScan.id]);

    return res;
  }

  //* ELIMINACIÓN DE UN REGISTRO
  Future<int> deleteScan(int id) async {
    final db = await database;
    final res = await db.delete('Scans', where: 'id = ?', whereArgs: [id]);
    return res;
  }

  //* ELIMINACIÓN DE TODOS LOS REGISTROS (OPCIÓN 1)
  /* Future<int> deleteAllScans() async {
    final db = await database;
    final res = await db.delete('Scans');
    return res;
  } */

  //* ELIMINACIÓN DE TODOS LOS REGISTROS (OPCIÓN 2)
  Future<int> deleteAllScans() async {
    final db = await database;
    final res = await db.rawDelete('''
      DELETE FROM Scans
    ''');
    return res;
  }
}
