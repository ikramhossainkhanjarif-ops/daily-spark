import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'data/datasources/alarm_local_datasource.dart';
import 'data/datasources/native_alarm_bridge.dart';
import 'data/repositories/alarm_repository_impl.dart';
import 'domain/usecases/alarm_usecases.dart';
import 'presentation/bloc/alarm_list/alarm_list_bloc.dart';
import 'presentation/bloc/alarm_list/alarm_list_event.dart';
import 'presentation/pages/alarm_list_page.dart';
import 'presentation/pages/ringing_page.dart';
import 'presentation/theme/app_theme.dart';

final _nativeBridge = NativeAlarmBridge();
final _alarmRepository = AlarmRepositoryImpl(
  localDataSource: AlarmLocalDataSource(),
  nativeBridge: _nativeBridge,
);

final navigatorKey = GlobalKey<NavigatorState>();

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Safety-net reschedule on cold start, mirroring what BootReceiver
  // does natively after a device reboot.
  RescheduleAllAlarms(_alarmRepository)();

  // If the native side launches/foregrounds the app for a firing
  // alarm while the engine is already alive, navigate straight to
  // the ringing page.
  _nativeBridge.setFiringAlarmHandler((alarmId) async {
    navigatorKey.currentState?.push(
      MaterialPageRoute(
        builder: (_) => RingingPage(alarmId: alarmId),
      ),
    );
  });

  runApp(const DailySparkApp());
}

class DailySparkApp extends StatelessWidget {
  const DailySparkApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => AlarmListBloc(
            getAlarms: GetAlarms(_alarmRepository),
            saveAlarm: SaveAlarm(_alarmRepository),
            deleteAlarm: DeleteAlarm(_alarmRepository),
            toggleAlarm: ToggleAlarm(_alarmRepository),
          )..add(const LoadAlarms()),
        ),
      ],
      child: MaterialApp(
        navigatorKey: navigatorKey,
        title: 'Daily Spark',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        home: const AlarmListPage(),
      ),
    );
  }
}
