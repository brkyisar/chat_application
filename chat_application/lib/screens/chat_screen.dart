import 'dart:developer';
import 'dart:io';
import 'package:chat_application/helper/my_date_util.dart';
import 'package:chat_application/models/message.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_application/main.dart';
import 'package:chat_application/models/chat_user.dart';
import 'package:chat_application/screens/view_profile_screen%20.dart';
import 'package:chat_application/widgets/message_card.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../api/apis.dart';

class ChatScreen extends StatefulWidget {
  final ChatUser user;

  const ChatScreen({super.key, required this.user});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  List<Message> _list = [];

  final _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  bool _showEmoji = false, _isUploading = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        setState(() {
          _showEmoji = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: SafeArea(
        child: WillPopScope(
          onWillPop: () {
            if (_showEmoji) {
              setState(() {
                _showEmoji = !_showEmoji;
              });
              return Future.value(false);
            } else {
              return Future.value(true);
            }
          },
          child: Scaffold(
            appBar: AppBar(
              automaticallyImplyLeading: false,
              flexibleSpace: _appBar(),
            ),
            backgroundColor: const Color.fromARGB(255, 176, 151, 190),
            body: Column(
              children: [
                Expanded(
                  child: StreamBuilder(
                    stream: APIs.getAllMessages(widget.user),
                    builder: (context, snapshot) {
                      switch (snapshot.connectionState) {
                        //data yükleniyorsa
                        case ConnectionState.waiting:
                        case ConnectionState.none:
                          return const SizedBox();

                        //bütün datalar yüklendiyse
                        case ConnectionState.active:
                        case ConnectionState.done:
                          final data = snapshot.data?.docs;
                          _list = data
                                  ?.map((e) => Message.fromJson(e.data()))
                                  .toList() ??
                              [];

                          if (_list.isNotEmpty) {
                            return ListView.builder(
                                reverse: true,
                                itemCount: _list.length,
                                padding: EdgeInsets.only(top: mq.height * .01),
                                physics: const BouncingScrollPhysics(),
                                itemBuilder: (context, index) {
                                  return MessageCard(
                                    message: _list[index],
                                  );
                                });
                          } else {
                            return const Center(
                              child: Text("Merhaba de!",
                                  style: TextStyle(fontSize: 20)),
                            );
                          }
                      }
                    },
                  ),
                ),
                if (_isUploading)
                  const Align(
                      alignment: Alignment.centerRight,
                      child: Padding(
                          padding:
                              EdgeInsets.symmetric(vertical: 8, horizontal: 20),
                          child: CircularProgressIndicator(strokeWidth: 2))),
                _chatInput(),
                //emoji picker
                if (_showEmoji)
                  SizedBox(
                    height: mq.height * .35,
                    child: EmojiPicker(
                      textEditingController: _textController,
                      config: Config(
                        columns: 8,
                        // Issue: https://github.com/flutter/flutter/issues/28894
                        emojiSizeMax: 28 * (Platform.isIOS ? 1.20 : 1.0),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _appBar() {
    return Padding(
        padding: const EdgeInsets.only(top: 10.0), // Üstten 20 piksel boşluk
        child: InkWell(
            onTap: () {
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (_) => ViewProfileScreen(user: widget.user)));
            },
            child: StreamBuilder(
                stream: APIs.getUserInfo(widget.user),
                builder: ((context, snapshot) {
                  final data = snapshot.data?.docs;
                  final list =
                      data?.map((e) => ChatUser.fromJson(e.data())).toList() ??
                          [];

                  return Row(
                    children: [
                      IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(
                            Icons.arrow_back,
                            color: Colors.black54,
                          )),
                      ClipRRect(
                          borderRadius: BorderRadius.circular(mq.height * .03),
                          child: CachedNetworkImage(
                            width: mq.height * .05,
                            height: mq.height * .05,
                            imageUrl: list.isNotEmpty
                                ? list[0].image
                                : widget.user.image,
                            errorWidget: (context, url, error) =>
                                const CircleAvatar(
                                    child: Icon(CupertinoIcons.person)),
                          )),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                              list.isNotEmpty ? list[0].name : widget.user.name,
                              style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.black87,
                                  fontWeight: FontWeight.w500)),
                          const SizedBox(height: 2),

                          //son gorulme
                          Text(
                              list.isNotEmpty
                                  ? list[0].onlineMi
                                      ? 'Online'
                                      : MyDateUtil.getLastActiveTime(
                                          context: context,
                                          lastActive: list[0].sonGorulme)
                                  : MyDateUtil.getLastActiveTime(
                                      context: context,
                                      lastActive: widget.user.sonGorulme),
                              style: const TextStyle(
                                  fontSize: 13, color: Colors.black54)),
                        ],
                      )
                    ],
                  );
                }))));
  }

  Widget _chatInput() {
    return Padding(
      padding: EdgeInsets.symmetric(
          vertical: mq.height * .01, horizontal: mq.width * .025),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                  child: Row(
                    children: [
                      //emoji button
                      IconButton(
                          onPressed: () {
                            FocusScope.of(context).unfocus();
                            setState(() => _showEmoji = !_showEmoji);
                          },
                          icon: const Icon(
                            Icons.emoji_emotions,
                            color: Color.fromARGB(255, 101, 23, 173),
                            size: 25,
                          )),

                      Expanded(
                          child: TextField(
                              controller: _textController,
                              keyboardType: TextInputType.multiline,
                              maxLines: null,
                              onTap: () {
                                if (_showEmoji)
                                  setState(() => _showEmoji = !_showEmoji);
                              },
                              decoration: const InputDecoration(
                                  hintText: 'Mesajınızı yazınız...',
                                  hintStyle: TextStyle(
                                      color: Color.fromARGB(255, 101, 23, 173)),
                                  border: InputBorder.none))),

                      //galeriden foto
                      IconButton(
                          onPressed: () async {
                            final ImagePicker picker = ImagePicker();
                            // Pick an image.
                            final List<XFile> images =
                                await picker.pickMultiImage(imageQuality: 70);
                            for (var i in images) {
                              log('Image Path: ${i.path}');
                              setState(() => _isUploading = true);

                              await APIs.sendChatImage(
                                  widget.user, File(i.path));
                              setState(() => _isUploading = false);
                            }
                          },
                          icon: const Icon(
                            Icons.image,
                            color: Color.fromARGB(255, 101, 23, 173),
                          )),
                      //kameradan foto
                      IconButton(
                          onPressed: () async {
                            final ImagePicker picker = ImagePicker();

                            // Pick an image
                            final XFile? image = await picker.pickImage(
                                source: ImageSource.camera, imageQuality: 70);
                            if (image != null) {
                              log('Image Path: ${image.path}');
                              setState(() => _isUploading = true);

                              await APIs.sendChatImage(
                                  widget.user, File(image.path));
                              setState(() => _isUploading = false);
                            }
                          },
                          icon: const Icon(Icons.camera_alt_rounded,
                              color: Color.fromARGB(255, 101, 23, 173))),

                      SizedBox(
                        width: mq.width * .01,
                      )
                    ],
                  ),
                ),
              ),

              //mesaj gönderme
              MaterialButton(
                onPressed: () {
                  if (_textController.text.isNotEmpty) {
                    APIs.sendMessage(
                        widget.user, _textController.text, Type.text);
                    _textController.text = '';
                  }
                },
                minWidth: 0,
                padding: const EdgeInsets.only(
                    top: 10, bottom: 10, right: 5, left: 10),
                shape: const CircleBorder(),
                color: const Color.fromARGB(255, 101, 23, 173),
                child: const Icon(Icons.send, color: Colors.white, size: 28),
              )
            ],
          ),
        ],
      ),
    );
  }
}
