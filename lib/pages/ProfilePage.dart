import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stretchy_header/stretchy_header.dart';
import 'package:toast/toast.dart';
import 'package:unify/Components/Constants.dart';
import 'package:unify/Models/post.dart' as p;
import 'package:unify/Models/user.dart';
import 'package:unify/pages/ChatPage.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:unify/pages/MyProfilePage.dart';
import 'package:unify/pages/VideoPreview.dart';
import 'package:unify/widgets/PostWidget.dart';

class ProfilePage extends StatefulWidget {
  final PostUser user;
  final String heroTag;
  final bool isFromChat;
  final bool isMyProfile;

  ProfilePage(
      {Key key, this.user, this.heroTag, this.isFromChat, this.isMyProfile})
      : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with AutomaticKeepAliveClientMixin {
  bool isBlocked;
  Future<List<p.Post>> postsFuture;
  Future<List<p.Video>> videosFuture;
  PostUser user;

  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
        appBar: AppBar(
          elevation: 0.0,
          backgroundColor: Colors.transparent,
          leading: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: Icon(FlutterIcons.arrow_back_mdi,
                  color: Theme.of(context).accentColor)),
          actions: [
            widget.isMyProfile != null
                ? widget.isMyProfile
                    ? IconButton(
                        icon: Icon(FlutterIcons.edit_2_fea,
                            color: Theme.of(context).accentColor),
                        onPressed: () async {
                          Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => MyProfilePage(
                                          user: user, heroTag: widget.heroTag)))
                              .then((value) async {
                            PostUser _u = await getUserWithUniversity(
                                widget.user.id, widget.user.university);
                            setState(() {
                              user = _u;
                            });
                          });
                        },
                      )
                    : InkWell(
                        onTap: () {
                          isBlocked
                              ? unblock(widget.user.id)
                              : block(widget.user.id, widget.user.university);
                          setState(() {
                            isBlocked = isBlocked ? false : true;
                          });
                        },
                        child: Container(
                          decoration: BoxDecoration(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(2.0)),
                          width: 75,
                          height: 20,
                          child: Center(
                            child: Text(
                              isBlocked ? "Unblock" : "Block",
                              style: GoogleFonts.questrial(
                                textStyle: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                      )
                : InkWell(
                    onTap: () {
                      isBlocked
                          ? unblock(widget.user.id)
                          : block(widget.user.id, widget.user.university);
                      setState(() {
                        isBlocked = isBlocked ? false : true;
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(2.0)),
                      width: 75,
                      height: 20,
                      child: Center(
                        child: Text(
                          isBlocked ? "Unblock" : "Block",
                          style: GoogleFonts.questrial(
                            textStyle: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  ),
          ],
        ),
        backgroundColor: Theme.of(context).backgroundColor,
        // body: StretchyHeader.singleChild(
        //   headerData: HeaderData(
        //     headerHeight: height,
        //     header: picture(),
        //     highlightHeaderAlignment: HighlightHeaderAlignment.bottom,
        //     highlightHeader: Container(
        //       width: MediaQuery.of(context).size.width,
        //       child:
        //           Padding(padding: const EdgeInsets.all(8.0), child: socials()),
        //     ),
        //     blurContent: false,
        //   ),
        //   child: Padding(
        //     padding: const EdgeInsets.only(top: 20.0),
        //     child: body(),
        //   ),
        // ),
        body: ListView(children: [Center(child: picture()), body()]));
  }

  Widget body() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10.0, 15.0, 10.0, 5.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    user.name,
                    style: GoogleFonts.questrial(
                      textStyle: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).accentColor),
                    ),
                  ),
                  SizedBox(
                    height: 5.0,
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Icon(FlutterIcons.graduation_cap_ent,
                      //     color: Theme.of(context).buttonColor, size: 17.0),
                      // SizedBox(width: 5.0),
                      Text(
                        user.university == "UofT"
                            ? "University of Toronto"
                            : widget.user.university == "YorkU"
                                ? "York University"
                                : "Western University",
                        style: GoogleFonts.questrial(
                          textStyle: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: Theme.of(context).buttonColor),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 5.0),
                  Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        InkWell(
                            onTap: () {
                              if (user.instagramHandle != null &&
                                  user.instagramHandle.isNotEmpty) {
                                showHandle(text: user.instagramHandle);
                              } else {
                                Toast.show('Instagram not available', context);
                              }
                            },
                            child: Icon(FlutterIcons.instagram_ant,
                                color: Colors.purple)),
                        SizedBox(
                          width: 15.0,
                        ),
                        InkWell(
                            onTap: () {
                              if (user.linkedinHandle != null &&
                                  user.linkedinHandle.isNotEmpty) {
                                showHandle(text: user.linkedinHandle);
                              } else {
                                Toast.show('LinkedIn not available', context);
                              }
                            },
                            child: Icon(FlutterIcons.linkedin_box_mco,
                                color: Colors.blue)),
                        SizedBox(
                          width: 15.0,
                        ),
                        InkWell(
                          onTap: () {
                            if (user.snapchatHandle != null &&
                                user.snapchatHandle.isNotEmpty) {
                              showHandle(text: user.snapchatHandle);
                            } else {
                              Toast.show('Snapchat not available', context);
                            }
                          },
                          child: Icon(FlutterIcons.snapchat_ghost_faw,
                              color: Colors.yellow[700]),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          Divider(),
          about(),
          // Text(
          //   "My accomplishments",
          //   style: GoogleFonts.questrial(
          //     textStyle: TextStyle(
          //         fontSize: 16,
          //         fontWeight: FontWeight.w700,
          //         color: Colors.grey[700]),
          //   ),
          // ),
          Divider(),
          accomplishments(),
          // SizedBox(height: 20.0),
          // Text("Places i've visited"),
          // Divider(),

          //places(),
          interests(),
          Divider(),
          userVideos(),
          Divider(),
          userPosts()
        ],
      ),
    );
  }

  Widget userVideos() {
    return FutureBuilder(
      future: videosFuture,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return Center(
              child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              valueColor: new AlwaysStoppedAnimation<Color>(
                  Theme.of(context).accentColor),
              strokeWidth: 2.0,
            ),
          ));
        } else if (snap.hasData) {
          return Container(
            height: MediaQuery.of(context).size.height / 4,
            width: MediaQuery.of(context).size.width,
            child: ListView.builder(
              shrinkWrap: true,
              scrollDirection: Axis.horizontal,
              physics: AlwaysScrollableScrollPhysics(),
              itemCount: snap.data != null ? snap.data.length : 0,
              itemBuilder: (BuildContext context, int index) {
                p.Video video = snap.data[index];
                return Padding(
                  padding: const EdgeInsets.only(right: 20.0),
                  child: Container(
                      width: MediaQuery.of(context).size.width / 4,
                      height: MediaQuery.of(context).size.height / 4,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10.0),
                          color: Colors.grey[300]),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10.0),
                        child: InkWell(
                          onTap: () {
                            var timeAgo =
                                new DateTime.fromMillisecondsSinceEpoch(
                                    video.timeStamp);
                            Function delete = () async {
                              await p.VideoApi.delete(video.id).then((value) {
                                //refreshList();
                              });
                            };
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => VideoPreview(
                                        video: video,
                                        timeAgo: timeago.format(timeAgo),
                                        delete: delete)));
                          },
                          child: CachedNetworkImage(
                            imageUrl: video.thumbnailUrl,
                            fit: BoxFit.cover,
                          ),
                        ),
                      )),
                );
              },
            ),
          );
        } else {
          return Container();
        }
      },
    );
  }

  Widget userPosts() {
    return FutureBuilder(
        future: postsFuture,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return Center(
                child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                valueColor: new AlwaysStoppedAnimation<Color>(
                    Theme.of(context).accentColor),
                strokeWidth: 2.0,
              ),
            ));
          } else if (snap.hasData) {
            var r = 0;
            return ListView.builder(
              shrinkWrap: true,
              scrollDirection: Axis.vertical,
              physics: NeverScrollableScrollPhysics(),
              itemCount: snap.data != null ? snap.data.length : 0,
              itemBuilder: (BuildContext context, int index) {
                p.Post post = snap.data[index];
                Function f = () async {
                  var res = await p.deletePost(post.id, null, null);
                  Navigator.pop(context);
                  if (res) {
                    setState(() {
                      postsFuture = p.fetchUserPost(widget.user);
                    });
                    p.previewMessage("Post Deleted", context);
                  } else {
                    p.previewMessage("Error deleting post!", context);
                  }
                };
                Function b = () async {
                  var res = await block(post.userId, post.userId);
                  Navigator.pop(context);
                  if (res) {
                    setState(() {
                      postsFuture = p.fetchUserPost(widget.user);
                    });
                    p.previewMessage("User blocked.", context);
                  }
                };

                Function h = () async {
                  var res = await p.hidePost(post.id);
                  Navigator.pop(context);
                  if (res) {
                    setState(() {
                      postsFuture = p.fetchUserPost(widget.user);
                    });
                    p.previewMessage("Post hidden from feed.", context);
                  }
                };
                var timeAgo =
                    new DateTime.fromMillisecondsSinceEpoch(post.timeStamp);
                return PostWidget(
                    key: ValueKey(post.id),
                    post: post,
                    timeAgo: timeago.format(timeAgo),
                    deletePost: f,
                    block: b,
                    hide: h);
              },
            );
          } else if (snap.hasError) {
            return Center(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(
                    sameUniversity() ? FlutterIcons.sad_cry_faw5 : Icons.lock,
                    color: Theme.of(context).accentColor,
                    size: 17.0,
                  ),
                  SizedBox(width: 10),
                  Text(
                      sameUniversity()
                          ? "Cannot find any posts :("
                          : "You cannot view posts from a different institution",
                      style: GoogleFonts.questrial(
                        textStyle: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: Theme.of(context).accentColor),
                      )),
                ],
              ),
            );
          } else {
            return Text('');
          }
        });
  }

  Widget picture() {
    return Container(
      child: Hero(
        tag: widget.heroTag,
        child: user.profileImgUrl != null && user.profileImgUrl.isNotEmpty
            ? Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(30.0),
                  child: Container(
                    color: Colors.red,
                    height: 60,
                    width: 60,
                    child: Image.network(
                      widget.user.profileImgUrl,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                      loadingBuilder: (BuildContext context, Widget child,
                          ImageChunkEvent loadingProgress) {
                        if (loadingProgress == null) return child;
                        return SizedBox(
                          height: 60,
                          width: 60,
                          child: Center(
                            child: SizedBox(
                              width: 60,
                              height: 60,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.0,
                                valueColor: new AlwaysStoppedAnimation<Color>(
                                    Colors.grey.shade600),
                                value: loadingProgress.expectedTotalBytes !=
                                        null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes
                                    : null,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              )
            : Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(30.0)),
                child: Icon(AntDesign.user, color: Colors.black)),
      ),
    );
  }

  Widget about() {
    return widget.user.about != null && widget.user.about.isNotEmpty
        ? Text(
            widget.user.about,
            style: GoogleFonts.questrial(
              textStyle: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: Theme.of(context).accentColor),
            ),
          )
        : Container();
  }

  Widget accomplishments() {
    String result = '';
    if (widget.user.accomplishments != null) {
      for (var acc in widget.user.accomplishments) {
        if (acc.isNotEmpty) {
          result = result + '$acc\n\n';
        }
      }
    }
    result.trimRight();
    return result.isNotEmpty
        ? Text(
            result,
            textAlign: TextAlign.center,
            style: GoogleFonts.questrial(
              textStyle: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: Theme.of(context).accentColor),
            ),
          )
        : SizedBox();
  }

  Widget interests() {
    return user.interests != null && user.interests.isNotEmpty
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Text(
              //   "I'm interested in",
              //   style: GoogleFonts.questrial(
              //     textStyle: TextStyle(
              //         fontSize: 15,
              //         fontWeight: FontWeight.w500,
              //         color: Theme.of(context).accentColor),
              //   ),
              // ),
              // Divider(),
              Wrap(
                children: _buildChoicesList(),
              ),
              SizedBox(height: 5.0),
            ],
          )
        : SizedBox();
  }

  Widget socials() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        InkWell(
          onTap: () {
            if (widget.user.snapchatHandle != null &&
                widget.user.snapchatHandle.isNotEmpty) {
              showHandle(text: widget.user.snapchatHandle);
            } else {
              Toast.show('Snapchat not available', context);
            }
          },
          child: CircleAvatar(
              backgroundColor: Colors.white,
              radius: 20.0,
              child:
                  Icon(FlutterIcons.snapchat_ghost_faw, color: Colors.black)),
        ),
        SizedBox(width: 5.0),
        InkWell(
          onTap: () {
            if (widget.user.linkedinHandle != null &&
                widget.user.linkedinHandle.isNotEmpty) {
              showHandle(text: widget.user.linkedinHandle);
            } else {
              Toast.show('LinkedIn not available', context);
            }
          },
          child: CircleAvatar(
              backgroundColor: Colors.white,
              radius: 20.0,
              child: Icon(FlutterIcons.linkedin_faw, color: Colors.blue)),
        ),
        SizedBox(width: 5.0),
        InkWell(
          onTap: () {
            if (widget.user.instagramHandle != null &&
                widget.user.instagramHandle.isNotEmpty) {
              showHandle(text: widget.user.instagramHandle);
            } else {
              Toast.show('Instagram not available', context);
            }
          },
          child: CircleAvatar(
              backgroundColor: Colors.white,
              radius: 20.0,
              child: Icon(FlutterIcons.instagram_faw, color: Colors.black)),
        ),
        SizedBox(width: 5.0),
        Visibility(
          visible: widget.isFromChat == null && sameUniversity(),
          child: InkWell(
            onTap: () {
              goToChat();
            },
            child: CircleAvatar(
                backgroundColor: Colors.white,
                radius: 20.0,
                child: Icon(FlutterIcons.message1_ant, color: Colors.black)),
          ),
        ),
      ],
    );
  }

  _buildChoicesList() {
    List<Widget> choices = List();
    for (var interest in user.interests) {
      choices.add(Container(
        padding: const EdgeInsets.only(left: 0.0, right: 2.0),
        child: ChoiceChip(
          selectedColor: Colors.deepPurpleAccent,
          label: Text(
            interest,
            style: GoogleFonts.questrial(
              textStyle: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: Colors.white),
            ),
          ),
          onSelected: (selected) {
            setState(() {});
          },
          selected: true,
        ),
      ));
    }

    return choices;
  }

  Widget places() {
    return widget.user.interests != null && widget.user.interests.isNotEmpty
        ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(
              "Places i've been to",
              style: GoogleFonts.questrial(
                textStyle: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).accentColor),
              ),
            ),
            Divider(),
            Wrap(
              children: _buildPlacesList(),
            ),
            Divider(),
          ])
        : SizedBox();
  }

  _buildPlacesList() {
    List<Widget> choices = List();
    for (var interest in widget.user.interests) {
      choices.add(Container(
        padding: const EdgeInsets.only(left: 0.0, right: 2.0),
        child: ChoiceChip(
          selectedColor: Colors.deepPurpleAccent,
          avatar: Text('🇸🇩'),
          label: Text(
            'Sudan',
            style: GoogleFonts.questrial(
              textStyle: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: Colors.white),
            ),
          ),
          onSelected: (selected) {
            setState(() {});
          },
          selected: true,
        ),
      ));
    }

    return choices;
  }

  goToChat() {
    var chatId = '';
    var myID = firebaseAuth.currentUser.uid;
    var peerId = widget.user.id;
    if (myID.hashCode <= peerId.hashCode) {
      chatId = '$myID-$peerId';
    } else {
      chatId = '$peerId-$myID';
    }
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ChatPage(
                  receiver: widget.user,
                  chatId: chatId,
                )));
  }

  showHandle({String text}) {
    AwesomeDialog(
      context: context,
      animType: AnimType.SCALE,
      dialogType: DialogType.NO_HEADER,
      body: Center(
        child: Text(
          text,
          style: GoogleFonts.questrial(
            textStyle: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).accentColor),
          ),
        ),
      ),
    )..show();
  }

  @override
  void initState() {
    super.initState();
    isBlocked = widget.user.isBlocked;
    user = widget.user;
    postsFuture = p.fetchUserPost(widget.user);
    videosFuture = p.VideoApi.fetchUserVideos(user);
  }

  bool sameUniversity() {
    var uni = Constants.checkUniversity() == 0
        ? 'UofT'
        : Constants.checkUniversity() == 1
            ? 'YorkU'
            : 'WesternU';
    return uni == widget.user.university;
  }

  bool get wantKeepAlive => true;
}
