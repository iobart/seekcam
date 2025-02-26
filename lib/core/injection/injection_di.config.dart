// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:ui' as _i264;

import 'package:flutter/material.dart' as _i409;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;

import '../../features/auth/auth.dart' as _i430;
import '../../features/auth/auth_impl.dart' as _i403;
import '../../features/auth/biometric_auth.dart' as _i779;
import '../../features/handler/permision_handler.dart' as _i833;
import '../../features/handler/permission_handler_screen.dart' as _i651;
import '../../features/handler/permission_hanlder_impl.dart' as _i338;
import '../../features/storage/secure_storage.dart' as _i599;
import '../../features/storage/secure_storage_impl.dart' as _i461;
import '../../features/views/view_store_data_screen.dart' as _i699;

// initializes the registration of main-scope dependencies inside of GetIt
_i174.GetIt $initConfigInjection(
  _i174.GetIt getIt, {
  String? environment,
  _i526.EnvironmentFilter? environmentFilter,
}) {
  final gh = _i526.GetItHelper(
    getIt,
    environment,
    environmentFilter,
  );
  gh.factory<_i651.PermissionHandlerScreen>(
      () => _i651.PermissionHandlerScreen.create());
  gh.factory<_i699.ViewStoredDataScreen>(
      () => _i699.ViewStoredDataScreen.create());
  gh.factory<_i430.Auth>(() => _i403.AuthImpl());
  gh.factory<_i599.SecureStorage>(() => _i461.SecureStorageImpl());
  gh.factory<_i833.PermissionHandler>(() => _i338.PermissionHandlerImpl());
  gh.factory<_i779.BiometricAuth>(() => _i779.BiometricAuth.create(
        gh<_i409.Key>(),
        gh<_i264.VoidCallback>(),
      ));
  return getIt;
}
