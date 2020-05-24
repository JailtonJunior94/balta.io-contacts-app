import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'package:contact_app/settings.dart';
import 'package:contact_app/models/contact.model.dart';

class ContactRepository {
  Future<Database> _getDatabase() async {
    return openDatabase(
      join(await getDatabasesPath(), DATABASE_NAME),
      onCreate: (db, version) {
        return db.execute(CREATE_CONTACTS_TABLE_SCRIPT);
      },
      version: 1,
    );
  }

  Future create(ContactModel model) async {
    try {
      final Database db = await _getDatabase();

      await db.insert(
        CONTACTS_TABLE_NAME,
        model.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (error) {
      print(error);
      return;
    }
  }

  Future<List<ContactModel>> getContacts() async {
    try {
      final Database db = await _getDatabase();
      final List<Map<String, dynamic>> maps =
          await db.query(CONTACTS_TABLE_NAME);

      return List.generate(
        maps.length,
        (i) {
          return ContactModel.fromMap(maps[i]);
        },
      );
    } catch (error) {
      print(error);
      return new List<ContactModel>();
    }
  }

  Future<List<ContactModel>> search(String term) async {
    try {
      final Database db = await _getDatabase();
      final List<Map<String, dynamic>> maps = await db.query(
        CONTACTS_TABLE_NAME,
        where: "name LIKE ?",
        whereArgs: ['%$term%'],
      );

      return List.generate(
        maps.length,
        (i) {
          return ContactModel.fromMap(maps[i]);
        },
      );
    } catch (error) {
      print(error);
      return new List<ContactModel>();
    }
  }

  Future<ContactModel> getContact(int id) async {
    try {
      final Database db = await _getDatabase();
      final List<Map<String, dynamic>> maps = await db.query(
        CONTACTS_TABLE_NAME,
        where: "id = ?",
        whereArgs: [id],
      );
      return ContactModel.fromMap(maps[0]);
    } catch (error) {
      print(error);
      return new ContactModel();
    }
  }

  Future update(ContactModel model) async {
    try {
      final Database db = await _getDatabase();
      await db.update(
        CONTACTS_TABLE_NAME,
        model.toMap(),
        where: "id = ?",
        whereArgs: [model.id],
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (error) {
      print(error);
      return;
    }
  }

  Future delete(int id) async {
    try {
      final Database db = await _getDatabase();
      await db.delete(
        CONTACTS_TABLE_NAME,
        where: "id = ?",
        whereArgs: [id],
      );
    } catch (error) {
      print(error);
      return;
    }
  }

  Future updateImage(int id, String imagePath) async {
    try {
      final Database db = await _getDatabase();
      final contact = await getContact(id);

      contact.image = imagePath;
      await db.update(
        CONTACTS_TABLE_NAME,
        contact.toMap(),
        where: "id = ?",
        whereArgs: [contact.id],
      );
    } catch (error) {
      print(error);
      return;
    }
  }
}
