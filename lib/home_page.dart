import 'dart:io';
import 'dart:typed_data';

import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:image_picker/image_picker.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final Gemini gemini = Gemini.instance;
  List<ChatMessage> messages = [];

  ChatUser currentUser = ChatUser(
      id: "0",
      firstName: "User",
      profileImage:
          "https://w0.peakpx.com/wallpaper/937/426/HD-wallpaper-miyamoto-musashi-art-berserk-vagabond-takehiko-inoue-anime-samurai-seinen-manga-berserk-manga-manga-drawing-vagabond-manga-manga-anime.jpg");
  ChatUser geminiUser = ChatUser(
      id: "1",
      firstName: "Gemini",
      profileImage:
          "https://i.gadgets360cdn.com/large/gemini_ai_google_1701928139717.jpg?downsize=950");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: Drawer(
        child: Container(
          color: Colors.black87,
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              Container(
                height: 120,
                child: DrawerHeader(
                  padding: EdgeInsets.all(20),
                  child: Text(
                    'Gemini',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 10, right: 10),
                child: Divider(
                  color: Colors.grey,
                ),
              ),
              ListTile(
                leading: Icon(
                  Icons.message_outlined,
                  color: Colors.white,
                  size: 25,
                ),
                title: Text(
                  'Temporary Chat',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
                onTap: () {
                  // Handle home navigation
                },
              ),
              Padding(
                padding: const EdgeInsets.only(left: 10, right: 10),
                child: Divider(
                  color: Colors.grey,
                ),
              ),
              ListTile(
                leading: Icon(
                  Icons.settings,
                  color: Colors.white,
                  size: 25,
                ),
                title: Text('Settings',
                    style: TextStyle(color: Colors.white, fontSize: 18)),
                onTap: () {
                  // Handle settings navigation
                },
              ),
              Padding(
                padding: const EdgeInsets.only(left: 10, right: 10),
                child: Divider(
                  color: Colors.grey,
                ),
              ),
              // Add more ListTile widgets for additional sidebar items
            ],
          ),
        ),
      ),
      backgroundColor: Color(0xFF0D0D0D),
      appBar: AppBar(
        title: const Text(
          "Gemini",
          style: TextStyle(fontSize: 23),
        ),
        backgroundColor: Color(0xFF0D0D0D),
        leading: IconButton(
          icon: ImageIcon(
            AssetImage(
              'assets/icon.png',
            ),
            size: 30,
          ),
          onPressed: () {
            _scaffoldKey.currentState?.openDrawer();
          },
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: ImageIcon(
              AssetImage(
                'assets/edit.png',
              ),
              size: 25,
            ),
            onPressed: () {},
          ),
          PopupMenuButton(
            icon: ImageIcon(
              AssetImage('assets/dots.png'), // Path to your image asset
            ), // Options icon
            itemBuilder: (context) => [
              PopupMenuItem(
                child: Row(
                  children: [
                    Icon(Icons.info_outline),
                    SizedBox(
                      width: 5,
                    ),
                    Text(
                      'View Details',
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
                value: 1, // Optional value for selection handling
              ),
              PopupMenuItem(
                child: Row(
                  children: [
                    Icon(Icons.file_upload_outlined),
                    SizedBox(
                      width: 5,
                    ),
                    Text(
                      'Share',
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
                value: 2,
              ),
            ],
            onSelected: (value) {
              // Handle menu item selection based on the value
              print("Selected value: $value");
            },
          ),
        ],
      ),
      body: _buildUI(),
    );
  }

  Widget _buildUI() {
    List<ChatMessage> reversedMessages = List.from(messages.reversed.toList());
    return DashChat(
      scrollToBottomOptions: ScrollToBottomOptions(),
      currentUser: currentUser,
      onSend: _sendMessage,
      messages: reversedMessages,
      messageOptions: MessageOptions(
        showCurrentUserAvatar: true,
        currentUserContainerColor:
            Color(0xFF0D0D0D), // Current user message color
        containerColor: Color(0xFF0D0D0D), // Other user message color
        currentUserTextColor: Colors.white, // Text color for current user
        textColor: Colors.white,
        messageTextBuilder: (ChatMessage message, ChatMessage? previousMessage,
            ChatMessage? nextMessage) {
          return Text(
            message.text,
            style: TextStyle(
                fontSize: 18.0,
                color: Colors.white // Customize the font size here
                ),
          );
        },
        // Text color for other users
      ),
      inputOptions: InputOptions(
        trailing: [
          IconButton(
            onPressed: _sendMediaMessage,
            icon: Icon(
              Icons.image,
              color: Colors.white,
            ),
          ),
        ],
        autocorrect: true,
        sendButtonBuilder: (Function onSend) {
          return IconButton(
            icon: Icon(Icons.send,
                color: Colors.grey), // Customize send button color
            onPressed: () => onSend(),
          );
        },
        sendOnEnter: true,
        inputDecoration: InputDecoration(
          hintText: "Message",
          hintStyle: TextStyle(
              color: Colors.grey, fontSize: 20 // Customize the hint text color
              ),
          filled: true,
          fillColor: Color(0xFF1f1f1f),
          border: OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(20.0), // Customize the border radius
            borderSide: BorderSide.none,
          ),
        ),
        inputTextStyle: TextStyle(
          color: Colors.white, // Customize the text color
        ),
      ),
    );
  }

//containerColor: Color(0xFF1f1f1f)
  void _sendMessage(ChatMessage message) {
    setState(() {
      messages.add(message); // Add user's message to the end of the list
    });
    try {
      String question = message.text;
      List<Uint8List>? images;
      if (message.medias?.isNotEmpty ?? false) {
        images = [File(message.medias!.first.url).readAsBytesSync()];
      }
      gemini.streamGenerateContent(question, images: images).listen((event) {
        String? response = event.content!.parts?.fold(
                "", (previous, current) => "$previous ${current.text}") ??
            "";
        if (response.isNotEmpty) {
          setState(() {
            messages.add(ChatMessage(
              // Add Gemini's reply immediately after the user's message
              user: geminiUser,
              createdAt: DateTime.now(),
              text: response,
            ));
          });
        }
      });
    } catch (e) {
      print(e);
    }
  }

  void _sendMediaMessage() async {
    ImagePicker picker = ImagePicker();
    XFile? file = await picker.pickImage(source: ImageSource.gallery);
    if (file != null) {
      ChatMessage chatMessage = ChatMessage(
          user: currentUser,
          createdAt: DateTime.now(),
          text: "Describe this image",
          medias: [
            ChatMedia(url: file.path, fileName: "", type: MediaType.image)
          ]);
      _sendMessage(chatMessage);
    }
  }
}
