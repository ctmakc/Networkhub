import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:networkhub/app/router.dart';
import 'package:networkhub/app/theme.dart';
import 'package:networkhub/core/storage/offline_queue.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await dotenv.load(fileName: '.env');

  // Initialize Hive
  await Hive.initFlutter();
  Hive.registerAdapter(ContactDraftAdapter());
  await Hive.openBox<ContactDraft>(OfflineQueue.boxName);

  runApp(
    const ProviderScope(
      child: NetworkHubApp(),
    ),
  );
}

class NetworkHubApp extends ConsumerWidget {
  const NetworkHubApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'NetworkHub',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
