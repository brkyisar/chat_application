import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_application/helper/my_date_util.dart';

import 'package:chat_application/models/chat_user.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../main.dart';

class ViewProfileScreen extends StatefulWidget {
  final ChatUser user;

  const ViewProfileScreen({super.key, required this.user});

  @override
  State<ViewProfileScreen> createState() => _ViewProfileScreenState();
}

class _ViewProfileScreenState extends State<ViewProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // gizli klavye için
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
          //app bar
          appBar: AppBar(title: Text(widget.user.name)),
          floatingActionButton:
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            const Text(
              'Katılma Tarihi: ',
              style: TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.w500,
                  fontSize: 16),
            ),
            Text(
                MyDateUtil.getLastMessageTime(
                    context: context,
                    time: widget.user.olusturulmaTarihi,
                    showYear: true),
                style: const TextStyle(color: Colors.black87, fontSize: 16)),
          ]),
          body: Padding(
            padding: EdgeInsets.symmetric(horizontal: mq.width * .05),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  //bosluk eklemek icin
                  SizedBox(width: mq.width, height: mq.height * .03),

                  //profil resmi

                  ClipRRect(
                    borderRadius: BorderRadius.circular(mq.height * .1),
                    child: CachedNetworkImage(
                      width: mq.height * .2,
                      height: mq.height * .2,
                      fit: BoxFit.cover,
                      imageUrl: widget.user.image,
                      errorWidget: (context, url, error) => const CircleAvatar(
                          child: Icon(CupertinoIcons.person)),
                    ),
                  ),
                  //bosluk eklemek icin
                  SizedBox(width: mq.width, height: mq.height * .03),
                  //mail
                  Text(widget.user.email,
                      style:
                          const TextStyle(color: Colors.black87, fontSize: 16)),
                  SizedBox(width: mq.width, height: mq.height * .02),
                  //hakkında
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Hakkında: ',
                        style: TextStyle(
                            color: Colors.black87,
                            fontWeight: FontWeight.w500,
                            fontSize: 16),
                      ),
                      Text(widget.user.about,
                          style: const TextStyle(
                              color: Colors.black87, fontSize: 16)),
                    ],
                  ),
                ],
              ),
            ),
          )),
    );
  }
}
