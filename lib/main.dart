import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:one_smart_shop/database/database_helper.dart';
import 'package:one_smart_shop/database/firebase_helper.dart';
import 'package:one_smart_shop/firebase_options.dart';
import 'package:one_smart_shop/providers/returns_provider.dart';
import 'package:one_smart_shop/providers/sales_provider.dart';
import 'package:one_smart_shop/screens/returns/return_form.dart';
import 'package:provider/provider.dart';

import 'providers/inventory_provider.dart';
import 'screens/inventory/inventory_list.dart';
import 'screens/billing/billing_screen.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'dart:io'; // For Platform checking

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print("Firebase Initialized Successfully");
  } catch (e) {
    print("Error Initializing Firebase: $e");
  }
  //await DatabaseHelper.instance.database; // Initialize database
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }
  // Verify the final path
  final dbPath = await getDatabasesPath();
  print('Final Database Path: $dbPath');

  // Migrate old data to new database
  final dbHelper = DatabaseHelper.instance;
  await FirebaseAuth.instance.signInAnonymously();
  await dbHelper.migrateOldData();

  // Initialize Firebase with Windows configuration
  // await Firebase.initializeApp(
  //   options: const FirebaseOptions(
  //     apiKey: 'AIzaSyD0EyzD5FLnWcGmjaMjS-Ofk32dLAzP3Bs',
  //     appId: '1:1072910830136:web:aaf7b2475546982b16f4cd',
  //     messagingSenderId: '1072910830136',
  //     projectId: 'onesmart-d8635',
  //   ),
  // );

  dbHelper.syncAllData();
  final products = await dbHelper.getAllProducts();
  for (var product in products) {
    SyncManager.syncWithRetry(() => FirebaseHelper.syncProduct(product));
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => InventoryProvider()),
        ChangeNotifierProvider(create: (_) => SalesProvider()),
        ChangeNotifierProvider(create: (_) => ReturnsProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'One Smart Shop',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  final List<Widget> _children = [
    const InventoryList(),
    const BillingScreen(),
    ReturnForm()
  ];

  @override
  void initState() {
    super.initState();
    // Load products when app starts
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<InventoryProvider>(context, listen: false).loadProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _children[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: onTabTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory),
            label: 'Inventory',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.point_of_sale),
            label: 'Billing',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment_return),
            label: 'Returns',
          ),
        ],
      ),
    );
  }

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }
}
