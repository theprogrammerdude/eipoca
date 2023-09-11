import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:eipoca/firebase_options.dart';
import 'package:eipoca/methods/local.dart';
import 'package:eipoca/pages/home.dart';
import 'package:eipoca/pages/no_internet.dart';
import 'package:eipoca/pages/welcome.dart';
import 'package:eipoca/providers/dm_provider.dart';
import 'package:eipoca/providers/server_provider.dart';
import 'package:eipoca/providers/user_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_windowmanager/flutter_windowmanager.dart';
import 'package:get/route_manager.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await dotenv.load(fileName: ".env");
  await GetStorage.init();
  await FlutterWindowManager.addFlags(FlutterWindowManager.FLAG_SECURE);
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  runApp(const MyApp());
}

final Local _local = Local();

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => ServerProvider()),
        ChangeNotifierProvider(create: (_) => DmProvider()),
      ],
      builder: (context, child) {
        return StreamBuilder<ConnectivityResult>(
          stream: Connectivity().onConnectivityChanged,
          builder: (context, snapshot) {
            if (snapshot.data == ConnectivityResult.none ||
                snapshot.data == null) {
              return const Directionality(
                textDirection: TextDirection.ltr,
                child: NoInternet(),
              );
            }

            return GetMaterialApp(
              title: 'Eipoca',
              debugShowCheckedModeBanner: false,
              theme: FlexThemeData.light(
                useMaterial3: true,
                colorScheme: const ColorScheme.light(
                  primary: Colors.black,
                ),
                visualDensity: VisualDensity.adaptivePlatformDensity,
                fontFamily: GoogleFonts.nunito().fontFamily,
              ),
              home: _local.getUid != '' ? const Home() : const Welcome(),
            );
          },
        );
      },
    );
  }
}
