import 'package:sqflite/sqflite.dart';
import 'dart:async';
import 'package:path/path.dart';


class AutoLoginDB{
  static final AutoLoginDB instance = AutoLoginDB._init();
  static Database?_database;
  AutoLoginDB._init();

  Future<Database> get database async{
    if(_database!=null) return _database!;
    _database =await _initDB('helpdesk.db');
    return _database!;
  }
  Future<Database> _initDB(String filePath) async{
    final dbPath = await getDatabasesPath();
    final path = join(dbPath,filePath);
    print(dbPath);
    return await openDatabase(path,version: 1,onCreate: _createDB);

  }

  Future _createDB(Database db,int version) async{
    final  intType = 'INTEGER NOT NULL';
    final textType = 'TEXT NOT NULL';
    await db.execute('CREATE TABLE $tableUser('
        '${UserLoginInfoFields.id} $intType,'
        '${UserLoginInfoFields.name} $textType,'
        '${UserLoginInfoFields.password} $textType)');
  }

  Future<UserLoginInfo> create (UserLoginInfo userLoginInfo) async{
    try{
      final db = await instance.database;
      final id = await db.insert(tableUser, userLoginInfo.toJson());
      print(id);
    }
    catch(e){
      print(e.toString());
    }
    return userLoginInfo.copy();
  }


  Future<List<UserLoginInfo>> readAllData() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(tableUser);

    return List.generate(maps.length, (index) {
      return UserLoginInfo(
        id: maps[index][UserLoginInfoFields.id],
        name: maps[index][UserLoginInfoFields.name],
        password: maps[index][UserLoginInfoFields.password],
      );
    });
  }
  Future<int> updateUser(UserLoginInfo updatedUser) async {
    final db = await database;

    return await db.update(
      tableUser,
      updatedUser.toJson(),
      where: '${UserLoginInfoFields.id} = ?',
      whereArgs: [updatedUser.id],
    );
  }
  Future<UserLoginInfo?> getUserById(int userId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableUser,
      where: '${UserLoginInfoFields.id} = ?',
      whereArgs: [userId],
    );

    if (maps.isNotEmpty) {
      return UserLoginInfo(
        id: maps[0][UserLoginInfoFields.id],
        name: maps[0][UserLoginInfoFields.name],
        password: maps[0][UserLoginInfoFields.password],

      );
    } else {
      return null;
    }
  }


  Future close() async {
    final db = await instance.database;
    db.close();
  }

}

final String tableUser = 'users';

class UserLoginInfoFields{
  static final String id = '_id';
  static final String name = '_name';
  static final String password = '_password';
}

class UserLoginInfo {
  final int? id;
  final String name;
  final String password;

  const UserLoginInfo({this.id, required this.name, required this.password});

  Map<String, Object?> toJson() =>
      {
        UserLoginInfoFields.id: id,
        UserLoginInfoFields.name: name,
        UserLoginInfoFields.password: password
      };

  UserLoginInfo copy({int?id, String?name, String?password}) =>
      UserLoginInfo(
          id: id ?? this.id,
          name: name ?? this.name,
          password: password ?? this.password
      );
}