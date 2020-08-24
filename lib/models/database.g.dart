// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// **************************************************************************
// FloorGenerator
// **************************************************************************

class $FloorAppDatabase {
  /// Creates a database builder for a persistent database.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static _$AppDatabaseBuilder databaseBuilder(String name) =>
      _$AppDatabaseBuilder(name);

  /// Creates a database builder for an in memory database.
  /// Information stored in an in memory database disappears when the process is killed.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static _$AppDatabaseBuilder inMemoryDatabaseBuilder() =>
      _$AppDatabaseBuilder(null);
}

class _$AppDatabaseBuilder {
  _$AppDatabaseBuilder(this.name);

  final String name;

  final List<Migration> _migrations = [];

  Callback _callback;

  /// Adds migrations to the builder.
  _$AppDatabaseBuilder addMigrations(List<Migration> migrations) {
    _migrations.addAll(migrations);
    return this;
  }

  /// Adds a database [Callback] to the builder.
  _$AppDatabaseBuilder addCallback(Callback callback) {
    _callback = callback;
    return this;
  }

  /// Creates the database and initializes it.
  Future<AppDatabase> build() async {
    final path = name != null
        ? await sqfliteDatabaseFactory.getDatabasePath(name)
        : ':memory:';
    final database = _$AppDatabase();
    database.database = await database.open(
      path,
      _migrations,
      _callback,
    );
    return database;
  }
}

class _$AppDatabase extends AppDatabase {
  _$AppDatabase([StreamController<String> listener]) {
    changeListener = listener ?? StreamController<String>.broadcast();
  }

  CatalogDao _catalogDaoInstance;

  RssDao _rssDaoInstance;

  Rss2CatalogDao _rss2catalogDaoInstance;

  Future<sqflite.Database> open(String path, List<Migration> migrations,
      [Callback callback]) async {
    final databaseOptions = sqflite.OpenDatabaseOptions(
      version: 1,
      onConfigure: (database) async {
        await database.execute('PRAGMA foreign_keys = ON');
      },
      onOpen: (database) async {
        await callback?.onOpen?.call(database);
      },
      onUpgrade: (database, startVersion, endVersion) async {
        await MigrationAdapter.runMigrations(
            database, startVersion, endVersion, migrations);

        await callback?.onUpgrade?.call(database, startVersion, endVersion);
      },
      onCreate: (database, version) async {
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `catalogs` (`id` INTEGER PRIMARY KEY AUTOINCREMENT, `catalog` TEXT NOT NULL)');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `rss` (`id` INTEGER PRIMARY KEY AUTOINCREMENT, `title` TEXT, `url` TEXT, `type` TEXT)');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `rss2catalog` (`id` INTEGER PRIMARY KEY AUTOINCREMENT, `catalogId` INTEGER, `rssId` INTEGER, FOREIGN KEY (`catalogId`) REFERENCES `catalogs` (`id`) ON UPDATE NO ACTION ON DELETE NO ACTION, FOREIGN KEY (`rssId`) REFERENCES `rss` (`id`) ON UPDATE NO ACTION ON DELETE NO ACTION)');

        await callback?.onCreate?.call(database, version);
      },
    );
    return sqfliteDatabaseFactory.openDatabase(path, options: databaseOptions);
  }

  @override
  CatalogDao get catalogDao {
    return _catalogDaoInstance ??= _$CatalogDao(database, changeListener);
  }

  @override
  RssDao get rssDao {
    return _rssDaoInstance ??= _$RssDao(database, changeListener);
  }

  @override
  Rss2CatalogDao get rss2catalogDao {
    return _rss2catalogDaoInstance ??=
        _$Rss2CatalogDao(database, changeListener);
  }
}

class _$CatalogDao extends CatalogDao {
  _$CatalogDao(this.database, this.changeListener)
      : _queryAdapter = QueryAdapter(database),
        _catalogEntityInsertionAdapter = InsertionAdapter(
            database,
            'catalogs',
            (CatalogEntity item) =>
                <String, dynamic>{'id': item.id, 'catalog': item.catalog}),
        _catalogEntityDeletionAdapter = DeletionAdapter(
            database,
            'catalogs',
            ['id'],
            (CatalogEntity item) =>
                <String, dynamic>{'id': item.id, 'catalog': item.catalog});

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  static final _catalogsMapper = (Map<String, dynamic> row) =>
      CatalogEntity(row['id'] as int, row['catalog'] as String);

  final InsertionAdapter<CatalogEntity> _catalogEntityInsertionAdapter;

  final DeletionAdapter<CatalogEntity> _catalogEntityDeletionAdapter;

  @override
  Future<List<CatalogEntity>> findAllCatalogs() async {
    return _queryAdapter.queryList('SELECT * FROM catalogs',
        mapper: _catalogsMapper);
  }

  @override
  Future<CatalogEntity> findCatalogById(int id) async {
    return _queryAdapter.query('SELECT * FROM catalogs WHERE id = ?',
        arguments: <dynamic>[id], mapper: _catalogsMapper);
  }

  @override
  Future<CatalogEntity> findCatalogByCatalog(String catalog) async {
    return _queryAdapter.query('SELECT * FROM catalogs WHERE catalog = ?',
        arguments: <dynamic>[catalog], mapper: _catalogsMapper);
  }

  @override
  Future<int> insertCatalog(CatalogEntity catalogEntity) {
    return _catalogEntityInsertionAdapter.insertAndReturnId(
        catalogEntity, OnConflictStrategy.abort);
  }

  @override
  Future<void> deleteCatalog(CatalogEntity catalogEntity) async {
    await _catalogEntityDeletionAdapter.delete(catalogEntity);
  }
}

class _$RssDao extends RssDao {
  _$RssDao(this.database, this.changeListener)
      : _queryAdapter = QueryAdapter(database),
        _rssEntityInsertionAdapter = InsertionAdapter(
            database,
            'rss',
            (RssEntity item) => <String, dynamic>{
                  'id': item.id,
                  'title': item.title,
                  'url': item.url,
                  'type': item.type
                }),
        _rssEntityDeletionAdapter = DeletionAdapter(
            database,
            'rss',
            ['id'],
            (RssEntity item) => <String, dynamic>{
                  'id': item.id,
                  'title': item.title,
                  'url': item.url,
                  'type': item.type
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  static final _rssMapper = (Map<String, dynamic> row) => RssEntity(
      row['id'] as int,
      row['title'] as String,
      row['url'] as String,
      row['type'] as String);

  final InsertionAdapter<RssEntity> _rssEntityInsertionAdapter;

  final DeletionAdapter<RssEntity> _rssEntityDeletionAdapter;

  @override
  Future<List<RssEntity>> findAllRss() async {
    return _queryAdapter.queryList('SELECT * FROM rss', mapper: _rssMapper);
  }

  @override
  Future<RssEntity> findRssById(int id) async {
    return _queryAdapter.query('SELECT * FROM rss WHERE id = ?',
        arguments: <dynamic>[id], mapper: _rssMapper);
  }

  @override
  Future<List<RssEntity>> findRssByUrl(String url) async {
    return _queryAdapter.queryList('SELECT * FROM rss WHERE url = ?',
        arguments: <dynamic>[url], mapper: _rssMapper);
  }

  @override
  Future<int> insertRss(RssEntity rssEntity) {
    return _rssEntityInsertionAdapter.insertAndReturnId(
        rssEntity, OnConflictStrategy.abort);
  }

  @override
  Future<void> deleteRss(RssEntity rssEntity) async {
    await _rssEntityDeletionAdapter.delete(rssEntity);
  }

  @override
  Future<void> deleteRssList(List<RssEntity> rssEntities) async {
    await _rssEntityDeletionAdapter.deleteList(rssEntities);
  }
}

class _$Rss2CatalogDao extends Rss2CatalogDao {
  _$Rss2CatalogDao(this.database, this.changeListener)
      : _queryAdapter = QueryAdapter(database),
        _rss2CatalogEntityInsertionAdapter = InsertionAdapter(
            database,
            'rss2catalog',
            (Rss2CatalogEntity item) => <String, dynamic>{
                  'id': item.id,
                  'catalogId': item.catalogId,
                  'rssId': item.rssId
                }),
        _rss2CatalogEntityDeletionAdapter = DeletionAdapter(
            database,
            'rss2catalog',
            ['id'],
            (Rss2CatalogEntity item) => <String, dynamic>{
                  'id': item.id,
                  'catalogId': item.catalogId,
                  'rssId': item.rssId
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  static final _rss2catalogMapper = (Map<String, dynamic> row) =>
      Rss2CatalogEntity(
          row['id'] as int, row['catalogId'] as int, row['rssId'] as int);

  final InsertionAdapter<Rss2CatalogEntity> _rss2CatalogEntityInsertionAdapter;

  final DeletionAdapter<Rss2CatalogEntity> _rss2CatalogEntityDeletionAdapter;

  @override
  Future<List<Rss2CatalogEntity>> findAllRss2Catalogs() async {
    return _queryAdapter.queryList('SELECT * FROM rss2catalog',
        mapper: _rss2catalogMapper);
  }

  @override
  Future<List<Rss2CatalogEntity>> findRssByCatalogId(int catalogId) async {
    return _queryAdapter.queryList(
        'SELECT * FROM rss2catalog WHERE catalogId = ?',
        arguments: <dynamic>[catalogId],
        mapper: _rss2catalogMapper);
  }

  @override
  Future<List<int>> insertRss2CatalogList(
      List<Rss2CatalogEntity> rss2CatalogEntityList) {
    return _rss2CatalogEntityInsertionAdapter.insertListAndReturnIds(
        rss2CatalogEntityList, OnConflictStrategy.abort);
  }

  @override
  Future<int> insertRss2Catalog(Rss2CatalogEntity rss2CatalogEntityList) {
    return _rss2CatalogEntityInsertionAdapter.insertAndReturnId(
        rss2CatalogEntityList, OnConflictStrategy.abort);
  }

  @override
  Future<void> deleteRss2Catalog(Rss2CatalogEntity rss2CatalogEntity) async {
    await _rss2CatalogEntityDeletionAdapter.delete(rss2CatalogEntity);
  }
}
