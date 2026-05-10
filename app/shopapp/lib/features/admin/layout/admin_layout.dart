import 'package:flutter/material.dart';
import '../dashboard/screens/dashboard_screen.dart';
import '../product/screens/product_list_screen.dart';

class AdminLayout extends StatefulWidget {
  final String initialRoute;
  final int userId;

  const AdminLayout({
    super.key,
    required this.initialRoute,
    required this.userId,
  });

  @override
  State<AdminLayout> createState() => _AdminLayoutState();
}

class _AdminLayoutState extends State<AdminLayout> {
  int index = 0;

  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();

  final List<_AdminPage> pages = [];

  @override
  void initState() {
    super.initState();

    pages.addAll([
      _AdminPage(
        "Dashboard",
        Icons.dashboard,
        DashboardScreen(),
      ),

      _AdminPage(
        "Products",
        Icons.shopping_bag,
        ProductListScreen(),
      ),
    ]);

    if (widget.initialRoute == '/admin/products') {
      index = 1;
    }
  }

  void changeTab(int i) {
    setState(() => index = i);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,

      appBar: AppBar(
        title: Text(pages[index].title),
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {
            scaffoldKey.currentState?.openDrawer();
          },
        ),
      ),

      drawer: Drawer(
        child: Container(
          color: const Color(0xFF0F172A),
          child: Column(
            children: [
              const SizedBox(height: 60),

              const CircleAvatar(
                radius: 30,
                backgroundColor: Colors.blue,
                child: Icon(Icons.admin_panel_settings, color: Colors.white),
              ),

              const SizedBox(height: 10),

              const Text(
                "Admin Panel",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 30),

              Expanded(
                child: ListView.builder(
                  itemCount: pages.length,
                  itemBuilder: (context, i) {
                    final selected = index == i;

                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      margin: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color:
                            selected
                                ? Colors.blue.withOpacity(0.2)
                                : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                        border:
                            selected ? Border.all(color: Colors.blue) : null,
                      ),
                      child: ListTile(
                        leading: Icon(
                          pages[i].icon,
                          color: selected ? Colors.blue : Colors.white70,
                        ),
                        title: Text(
                          pages[i].title,
                          style: TextStyle(
                            color: selected ? Colors.blue : Colors.white70,
                            fontWeight:
                                selected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                        onTap: () => changeTab(i),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),

      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: pages[index].screen,
      ),
    );
  }
}

class _AdminPage {
  final String title;
  final IconData icon;
  final Widget screen;

  _AdminPage(this.title, this.icon, this.screen);
}