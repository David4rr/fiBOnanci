part of '../finance_repository.dart';

abstract class DriftRepoBase {
  AppDatabase get db;
  Uuid get uuid;
}
