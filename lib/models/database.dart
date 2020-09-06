// database.dart

// required package imports
import 'dart:async';
import 'package:floor/floor.dart';
import 'package:rss/models/dao/feeds_dao.dart';
import 'package:rss/models/entity/feeds_entity.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

import 'dao/catalog_dao.dart';
import 'dao/rss2catalog_dao.dart';
import 'dao/rss_dao.dart';
import 'entity/catalog_entity.dart';
import 'entity/rss2catalog_entity.dart';
import 'entity/rss_entities.dart';
import 'entity/rss_entity.dart';


part 'database.g.dart'; // the generated code will be there

@Database(version: 4, entities: [CatalogEntity,RssEntity,Rss2CatalogEntity,FeedsEntity],views: [MultiRssEntity])
abstract class AppDatabase extends FloorDatabase {
  CatalogDao get catalogDao;
  RssDao get rssDao;
  Rss2CatalogDao get rss2catalogDao;
  FeedsDao get feedsDao;
}