import 'dart:developer';

import 'package:pub_checkgia/firebase_options.dart';
import 'package:pub_checkgia/screen/authen/register_screen.dart';
import 'package:pub_checkgia/screen/home_screen.dart';
import 'package:pub_checkgia/screen/authen/login_screen.dart';
import 'package:pub_checkgia/screen/notification/notification_screen.dart';
import 'package:pub_checkgia/screen/tabbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:pub_dmclcheckgia/pub_DMCLcheckgia.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  await Firebase.initializeApp();
  log("Handling a background message: ${message.messageId}");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  runApp(const MyHomePage());
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    super.initState();

    // initUniLink();
    // initUniStream();
    initFirebase();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    return NotificationListener(
      onNotification: (AppNotifi notification) {
        if (notification.value == AppNotifiType.onChangeUX) {
          var mode = notification.mode;
          log('ux.change $mode');
        }

        return false;
      },
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'ĐMCL CheckGiá',
        theme: ThemeData(
            // primarySwatch: Colors.blue,
            // colorScheme: ColorScheme.fromSwatch(
            //     primarySwatch: GlobalStyles.primaryColor.toMaterialColor()),
            // useMaterial3: AppSetting.instance.enableMaterial3,
            ),
        home: LoginScreen(),
        routes: {
          '/register': (context) => const ResigterScreen(),
          '/login': (context) => LoginScreen(),
          '/tabbar': (context) => const BottomNavBar(),
          '/home': (context) => HomeScreen(),
          '/notification': (context) => const NotificationScreen()
        },
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  initFirebase() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    var fcmToken = await messaging.getToken();
    log('GoogleFCM.Token $fcmToken');

    // ignore: unused_local_variable
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: true,
      badge: true,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
  }
}
//
// enum UXAdvanceMode { normal, advance }
//
// enum AppNotifiType { dismissPopup, registerDevice, onChangeUX, asyncGetStock }
//
// class AppNotifi extends Notification {
//   UXAdvanceMode? mode;
//   AppNotifiType? value;
//
//   AppNotifi({
//     this.value,
//     this.mode = UXAdvanceMode.normal,
//   });
// }
