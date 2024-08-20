import 'package:dart/user_screen/profile_setup.dart';
import 'package:dart/user_screen/service_technical_support.dart';
import 'package:dart/user_screen/consumables_stock_issue.dart';
import 'package:dart/user_screen/consumables_stock_issue_records.dart';
import 'package:flutter/material.dart';
import '../widgets/system_functions_manager.dart';
import 'inventory_list_view.dart';
import 'inventory_register.dart';
import 'list_of_ticket.dart';
import 'location_create.dart';
import 'new_service_request.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<UIWidgets> uiWidgets = [];
  final List<Widget> widgets = [];

  @override
  void initState() {
    super.initState();
    setControl(UserCredential().getUserType);
  }

  void setControl(String userType) {
    switch (userType) {
      case "ADMIN":
        _tabController = TabController(length: 9, vsync: this);
        break;
      case "SUPPORT":
        _tabController = TabController(length: 6, vsync: this);
        break;
      case "USER":
        _tabController = TabController(length: 3, vsync: this);
        break;
      case "STORES":
        _tabController = TabController(length: 4, vsync: this);
        break;
      default:
        break;
    }
    checkAccess();
  }

  void checkAccess() {
    String userType = UserCredential().getUserType;
    switch (userType) {
      case "ADMIN":
        _addAdminWidgets();
        break;
      case "SUPPORT":
        _addSupportWidgets();
        break;
      case "USER":
        _addUserWidgets();
        break;
      case "STORES":
        _addStoresWidgets();
        break;
      default:
        break;
    }
    setState(() {});
  }

  void _addAdminWidgets() {
    uiWidgets.addAll([
      UIWidgets(
          type: NewTicket, uiName: 'New Ticket', uiIcon: Icons.airplane_ticket),
      UIWidgets(
          type: TechnicalUpdate,
          uiName: 'Technical Update',
          uiIcon: Icons.settings),
      UIWidgets(
          type: ListOfTickets,
          uiName: 'List of Tickets',
          uiIcon: Icons.list_alt),
      UIWidgets(
          type: InventoryRegister,
          uiName: 'Inventory Register',
          uiIcon: Icons.app_registration),
      UIWidgets(
          type: AsssetListView,
          uiName: 'Inventory List View',
          uiIcon: Icons.videogame_asset),
      UIWidgets(
          type: ConsumablesStockIssue,
          uiName: 'Consumables Stock',
          uiIcon: Icons.keyboard_alt),
      UIWidgets(
          type: ConsumablesStockIssueRecord,
          uiName: "Consumables Issue Report",
          uiIcon: Icons.list),
      UIWidgets(
          type: LocationCreate,
          uiName: 'Location Create',
          uiIcon: Icons.location_disabled),
      UIWidgets(
          type: ProfileSetup, uiName: 'Profile Setup', uiIcon: Icons.person),
    ]);

    widgets.addAll([
      NewTicket(tagNo: ""),
      TechnicalUpdate(tktID: ""),
      ListOfTickets(),
      InventoryRegister(tagNo: ""),
      AsssetListView(),
      ConsumablesStockIssue(),
      ConsumablesStockIssueRecord(),
      LocationCreate(),
      ProfileSetup(),
    ]);
  }

  void _addSupportWidgets() {
    uiWidgets.addAll([
      UIWidgets(
          type: NewTicket, uiName: 'New Ticket', uiIcon: Icons.airplane_ticket),
      UIWidgets(
          type: TechnicalUpdate,
          uiName: 'Technical Update',
          uiIcon: Icons.settings),
      UIWidgets(
          type: ListOfTickets,
          uiName: 'List of Tickets',
          uiIcon: Icons.list_alt),
      UIWidgets(
          type: InventoryRegister,
          uiName: 'Inventory Register',
          uiIcon: Icons.app_registration),
      UIWidgets(
          type: AsssetListView,
          uiName: 'Inventory List View',
          uiIcon: Icons.videogame_asset),
      UIWidgets(
          type: ProfileSetup, uiName: 'Profile Setup', uiIcon: Icons.person),
    ]);

    widgets.addAll([
      NewTicket(tagNo: ""),
      TechnicalUpdate(tktID: ""),
      ListOfTickets(),
      InventoryRegister(tagNo: ""),
      AsssetListView(),
      ProfileSetup(),
    ]);
  }

  void _addUserWidgets() {
    uiWidgets.addAll([
      UIWidgets(
          type: NewTicket, uiName: 'New Ticket', uiIcon: Icons.airplane_ticket),
      UIWidgets(
          type: AsssetListView,
          uiName: 'Inventory List View',
          uiIcon: Icons.videogame_asset),
      UIWidgets(
          type: ProfileSetup, uiName: 'Profile Setup', uiIcon: Icons.person),
    ]);

    widgets.addAll([
      NewTicket(tagNo: ""),
      AsssetListView(),
      ProfileSetup(),
    ]);
  }

  void _addStoresWidgets() {
    uiWidgets.addAll([
      UIWidgets(
          type: NewTicket, uiName: 'New Ticket', uiIcon: Icons.airplane_ticket),
      UIWidgets(
          type: AsssetListView,
          uiName: 'Inventory List View',
          uiIcon: Icons.videogame_asset),
      UIWidgets(
          type: ConsumablesStockIssue,
          uiName: 'Consumables Stock',
          uiIcon: Icons.list_alt),
      UIWidgets(
          type: ProfileSetup, uiName: 'Profile Setup', uiIcon: Icons.person),
    ]);

    widgets.addAll([
      NewTicket(tagNo: ""),
      AsssetListView(),
      ConsumablesStockIssue(),
      ProfileSetup(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.sizeOf(context).width;
    return Scaffold(
      appBar: _buildAppBar(sw),
      drawer: _buildDrawer(),
      body: TabBarView(
        controller: _tabController,
        children: widgets,
      ),
    );
  }

  AppBar _buildAppBar(double sw) {
    return AppBar(
      title: Text(
        'WELCOME | ${UserCredential().getUserName}',
        style: TextStyle(color: Colors.black, fontSize: sw * 0.07),
      ),
      iconTheme: const IconThemeData(color: Colors.black54, weight: 20),
      leading: Builder(
        builder: (context) {
          return IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          );
        },
      ),
      backgroundColor: Colors.blue,
    );
  }

  Drawer _buildDrawer() {
    return Drawer(
      child: ListView(
        children: [
          for (var i = 0; i < uiWidgets.length; i++)
            ListTile(
              leading: Icon(uiWidgets[i].uiIcon),
              title: Text(
                uiWidgets[i].uiName,
                overflow: TextOverflow.ellipsis,
              ),
              onTap: () {
                _tabController.animateTo(i);
                _handleTabChange();
                Navigator.pop(context);
              },
            ),
        ],
      ),
    );
  }

  void _handleTabChange() {
    setState(() {});
  }
}

class UIWidgets {
  final Type type;
  final String uiName;
  final IconData uiIcon;

  UIWidgets({
    required this.type,
    required this.uiName,
    required this.uiIcon,
  });
}
