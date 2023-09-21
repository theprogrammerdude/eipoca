import 'package:eipoca/methods/db.dart';
import 'package:eipoca/methods/local.dart';
import 'package:eipoca/pages/create_server.dart';
import 'package:eipoca/pages/profile.dart';
import 'package:eipoca/pages/search.dart';
import 'package:eipoca/providers/user_provider.dart';
import 'package:eipoca/widgets/chat_list.dart';
import 'package:eipoca/widgets/server_list.dart';
import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';
import 'package:provider/provider.dart';
import 'package:velocity_x/velocity_x.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with TickerProviderStateMixin {
  final Db _db = Db();
  final Local _local = Local();

  var _currentIndex = 0;
  String title = 'Chats';

  @override
  void initState() {
    _db.getUserData(_local.getUid).listen((event) {
      Map<String, dynamic> d = event.data() as Map<String, dynamic>;
      Provider.of<UserProvider>(context, listen: false).updateUser(d);
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          leading: Image.asset(
            'assets/logo.png',
          ),
          title: title.text.bold.make(),
          centerTitle: true,
          actions: [
            IconButton(
              onPressed: () {
                Get.to(() => Search(type: _currentIndex));
              },
              icon: const Icon(Icons.search),
            ),
            IconButton(
              onPressed: () {
                Get.to(() => const Profile());
              },
              icon: const Icon(Icons.person),
            )
          ],
          bottom: TabBar(
            onTap: (i) {
              setState(() => _currentIndex = i);
            },
            tabs: [
              Tab(
                child: 'Chats'.text.make(),
              ),
              // Tab(
              //   child: 'Stories'.text.make(),
              // ),
              Tab(
                child: 'Servers'.text.make(),
              )
            ],
          ),
        ),
        floatingActionButton: _currentIndex == 1
            ? FloatingActionButton(
                onPressed: () {
                  Get.to(() => const CreateServer());
                },
                child: const Icon(Icons.create_new_folder_rounded),
              )
            // : _currentIndex == 1
            //     ? FloatingActionButton(
            //         onPressed: () {
            //           Get.to(() => CreateStory(
            //                 user: user,
            //               ));
            //         },
            //         child: const Icon(Icons.add),
            //       )
            //     :
            : const SizedBox(height: 0),
        // bottomNavigationBar: SalomonBottomBar(
        //   currentIndex: _currentIndex,
        //   onTap: (i) {
        //     setState(() => _currentIndex = i);

        //     switch (_currentIndex) {
        //       case 0:
        //         setState(() {
        //           title = 'Chats';
        //         });
        //         break;
        //       case 1:
        //         setState(() {
        //           title = 'Servers';
        //         });
        //         break;

        //       default:
        //     }

        //     _controller!.animateTo(
        //       i,
        //       duration: const Duration(milliseconds: 500),
        //       curve: Curves.easeInOut,
        //     );
        //   },
        //   items: [
        //     SalomonBottomBarItem(
        //       icon: const Icon(Icons.chat),
        //       title: 'Chats'.text.make(),
        //     ),
        //     SalomonBottomBarItem(
        //       icon: const Icon(Icons.tag),
        //       title: 'Servers'.text.make(),
        //     ),
        //   ],
        // ),
        body: const TabBarView(
          physics: NeverScrollableScrollPhysics(),
          children: [
            ChatList(),
            // Stories(),
            ServerList(),
          ],
        ),
      ),
    );
  }
}
