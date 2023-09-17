import 'package:eipoca/methods/db.dart';
import 'package:eipoca/methods/local.dart';
import 'package:eipoca/pages/create_server.dart';
import 'package:eipoca/pages/create_story.dart';
import 'package:eipoca/pages/profile.dart';
import 'package:eipoca/pages/search.dart';
import 'package:eipoca/providers/user_provider.dart';
import 'package:eipoca/widgets/chat_list.dart';
import 'package:eipoca/widgets/server_list.dart';
import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';
import 'package:provider/provider.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';
import 'package:velocity_x/velocity_x.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final Db _db = Db();
  final Local _local = Local();

  final PageController _controller = PageController(initialPage: 0);

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
    return Scaffold(
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
      ),
      floatingActionButton: _currentIndex == 1
          ? FloatingActionButton(
              onPressed: () {
                Get.to(() => const CreateServer());
              },
              child: const Icon(Icons.create_new_folder_rounded),
            )
          : FloatingActionButton(
              onPressed: () {
                Get.to(() => const CreateStory());
              },
              child: const Icon(Icons.add),
            ),
      bottomNavigationBar: SalomonBottomBar(
        currentIndex: _currentIndex,
        onTap: (i) {
          setState(() => _currentIndex = i);

          switch (_currentIndex) {
            case 0:
              setState(() {
                title = 'Chats';
              });
              break;
            case 1:
              setState(() {
                title = 'Servers';
              });
              break;

            default:
          }

          _controller.animateToPage(
            i,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          );
        },
        items: [
          SalomonBottomBarItem(
            icon: const Icon(Icons.chat),
            title: 'Chats'.text.make(),
          ),
          SalomonBottomBarItem(
            icon: const Icon(Icons.tag),
            title: 'Servers'.text.make(),
          ),
        ],
      ),
      body: PageView(
        controller: _controller,
        physics: const NeverScrollableScrollPhysics(),
        children: const [
          ChatList(),
          ServerList(),
        ],
      ),
    );
  }
}
