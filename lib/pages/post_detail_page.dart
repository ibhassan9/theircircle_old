import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:unify/Models/OHS.dart';
import 'package:unify/Widgets/CommentWidget.dart';
import 'package:unify/Components/Constants.dart';
import 'package:unify/Models/club.dart';
import 'package:unify/Models/comment.dart';
import 'package:unify/Models/course.dart';
import 'package:unify/Models/notification.dart';
import 'package:unify/Models/post.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:unify/Models/user.dart';
import 'package:unify/pages/DB.dart';
import 'package:unify/pages/ProfilePage.dart';
import 'package:unify/widgets/PostWidget.dart';

class PostDetailPage extends StatefulWidget {
  final Post post;
  final Course course;
  final Club club;
  final String timeAgo;
  final bool isDiffUni;

  PostDetailPage(
      {Key key,
      this.post,
      this.course,
      this.club,
      this.timeAgo,
      this.isDiffUni = false})
      : super(key: key);
  @override
  _PostDetailPageState createState() => _PostDetailPageState();
}

class _PostDetailPageState extends State<PostDetailPage> {
  TextEditingController commentController = TextEditingController();
  Future<List<Comment>> commentFuture;
  bool isCommenting = false;
  ScrollController _scrollController = new ScrollController();
  List<PostUser> users = [];
  String str = '';
  List<String> tags = [];
  String imgUrl;
  FocusNode focusNode = FocusNode();
  Color color;

  @override
  Widget build(BuildContext context) {
    @override
    void dispose() {
      super.dispose();
      commentController.dispose();
      _scrollController.dispose();
    }

    Padding commentBox = Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: BoxDecoration(
            color: Theme.of(context).backgroundColor,
            border:
                Border(top: BorderSide(color: Theme.of(context).dividerColor))),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 10.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              str.isNotEmpty
                  ? Container(
                      constraints: BoxConstraints(maxHeight: 200),
                      child: ListView(
                          shrinkWrap: true,
                          children: users.map((s) {
                            if (('@' + s.name)
                                .toLowerCase()
                                .contains(str.toLowerCase())) {
                              return Padding(
                                padding: const EdgeInsets.fromLTRB(
                                    10.0, 5.0, 10.0, 5.0),
                                child: InkWell(
                                  onTap: () {
                                    String tmp = str.substring(0, str.length);
                                    print(tmp);
                                    setState(() {
                                      str = '';
                                      commentController.text = commentController
                                          .text
                                          .replaceFirst(tmp, '@');
                                      commentController.text +=
                                          s.name.trimRight() + ' ';
                                      commentController.value =
                                          commentController.value.copyWith(
                                        text: commentController.text,
                                        selection: TextSelection(
                                            baseOffset:
                                                commentController.text.length,
                                            extentOffset:
                                                commentController.text.length),
                                        composing: TextRange.empty,
                                      );
                                    });
                                    String tag = '@' + s.name.trimRight();
                                    tags.add(tag);
                                    print(s.name);
                                  },
                                  child: Row(
                                    children: [
                                      s.profileImgUrl == null ||
                                              s.profileImgUrl == ''
                                          ? CircleAvatar(
                                              radius: 15,
                                              backgroundColor: Colors.grey[300],
                                              child: Text(
                                                  s.name.substring(0, 1),
                                                  style: GoogleFonts.kulimPark(
                                                      fontSize: 13,
                                                      color: Colors.black)))
                                          : ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(30),
                                              child: CachedNetworkImage(
                                                imageUrl: s.profileImgUrl,
                                                width: 30,
                                                height: 30,
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                      SizedBox(width: 5.0),
                                      Text(
                                        s.name,
                                        style: GoogleFonts.kulimPark(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                            color:
                                                Theme.of(context).accentColor),
                                      )
                                    ],
                                  ),
                                ),
                              );
                            }
                            return SizedBox();
                          }).toList()),
                    )
                  : Container(),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Flexible(
                      child: TextField(
                    focusNode: focusNode,
                    onTap: () {
                      Timer(
                          Duration(milliseconds: 300),
                          () => _scrollController.animateTo(
                              _scrollController.position.maxScrollExtent,
                              duration: Duration(milliseconds: 300),
                              curve: Curves.easeIn));
                    },
                    onChanged: (val) {
                      setState(() {
                        var words = val.split(' ');
                        str = words.length > 0 &&
                                words[words.length - 1].startsWith('@')
                            ? words[words.length - 1]
                            : '';
                      });
                    },
                    maxLines: null,
                    textInputAction: TextInputAction.done,
                    controller: commentController,
                    decoration: new InputDecoration(
                        border: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        errorBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                        contentPadding: EdgeInsets.only(
                            left: 15, bottom: 11, top: 11, right: 15),
                        hintText: "Comment Here"),
                    style: GoogleFonts.kulimPark(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).accentColor),
                  )),
                  IconButton(
                    icon: Icon(
                      AntDesign.arrowright,
                      color: Theme.of(context).accentColor,
                    ),
                    onPressed: () async {
                      Map<String, dynamic> newTags = {};
                      for (var tag in tags) {
                        if (commentController.text.contains(tag)) {
                          var name = tag.replaceAll('@', '');
                          name = name.replaceAll('_', ' ');
                          var uid = users
                              .where((element) => element.name.trim() == name);
                          newTags[name] = {
                            'id': uid.first.id,
                            'token': uid.first.deviceToken
                          };
                        }
                      }
                      print(newTags);
                      if (commentController.text.isEmpty || isCommenting) {
                        return;
                      }
                      setState(() {
                        isCommenting = true;
                      });
                      Comment comment =
                          Comment(content: commentController.text);
                      var res;

                      if (widget.post.type != null) {
                        switch (widget.post.type) {
                          case 'post':
                            res = await postComment(comment, widget.post, null,
                                null, newTags.isNotEmpty ? newTags : null);
                            break;
                          case 'club':
                            res = await postComment(
                                comment,
                                widget.post,
                                null,
                                Club(id: widget.post.typeId),
                                newTags.isNotEmpty ? newTags : null);
                            break;
                          case 'course':
                            res = await postComment(
                                comment,
                                widget.post,
                                Course(id: widget.post.typeId),
                                null,
                                newTags.isNotEmpty ? newTags : null);
                            break;
                          case 'onehealingspace':
                            res = await OneHealingSpace.postComment(
                                comment, widget.post);
                            break;
                          default:
                            res = await postComment(
                                comment,
                                widget.post,
                                widget.course == null ? null : widget.course,
                                widget.club == null ? null : widget.club,
                                newTags.isNotEmpty ? newTags : null);
                            break;
                        }
                      } else {
                        res = await postComment(
                            comment,
                            widget.post,
                            widget.course == null ? null : widget.course,
                            widget.club == null ? null : widget.club,
                            newTags.isNotEmpty ? newTags : null);
                      }

                      if (res) {
                        var user = await getUser(widget.post.userId);
                        var token = user.deviceToken;
                        if (user.id != FIR_UID) {
                          if (newTags.isNotEmpty) {
                            newTags.forEach((key, value) {
                              var id = value['id'];
                              print(id);
                              print(value['id']);
                              if (id != widget.post.userId) {
                                var _token = value['token'];
                                if (widget.club == null &&
                                    widget.course == null) {
                                  sendPush(2, _token, comment.content,
                                      widget.post.id, value['id']);
                                } else if (widget.club != null) {
                                  sendPushClub(
                                      widget.club,
                                      7,
                                      _token,
                                      comment.content,
                                      widget.post.id,
                                      value['id']);
                                } else if (widget.course != null) {
                                  sendPushCourse(
                                      widget.course,
                                      5,
                                      _token,
                                      comment.content,
                                      widget.post.id,
                                      value['id']);
                                }
                              }
                            });
                          }

                          if (widget.club == null && widget.course == null) {
                            await sendPush(1, token, comment.content,
                                widget.post.id, user.id);
                          } else if (widget.club != null) {
                            await sendPushClub(widget.club, 1, token,
                                comment.content, widget.post.id, user.id);
                          } else if (widget.course != null) {
                            await sendPushCourse(widget.course, 1, token,
                                comment.content, widget.post.id, user.id);
                          }
                        }
                        commentController.clear();
                      } else {}
                      if (this.mounted) {
                        if (widget.post.type != null) {
                          switch (widget.post.type) {
                            case 'post':
                              this.setState(() {
                                commentFuture = fetchComments(
                                    widget.post,
                                    null,
                                    null,
                                    widget.post.university != null
                                        ? widget.post.university
                                        : Constants.checkUniversity() == 0
                                            ? 'UofT'
                                            : Constants.checkUniversity() == 1
                                                ? 'YorkU'
                                                : 'WesternU');
                              });
                              break;
                            case 'club':
                              this.setState(() {
                                commentFuture = fetchComments(
                                    widget.post,
                                    null,
                                    Club(id: widget.post.typeId),
                                    widget.post.university != null
                                        ? widget.post.university
                                        : Constants.checkUniversity() == 0
                                            ? 'UofT'
                                            : Constants.checkUniversity() == 1
                                                ? 'YorkU'
                                                : 'WesternU');
                              });
                              break;
                            case 'course':
                              this.setState(() {
                                commentFuture = fetchComments(
                                    widget.post,
                                    Course(id: widget.post.typeId),
                                    null,
                                    widget.post.university != null
                                        ? widget.post.university
                                        : (Constants.checkUniversity() == 0
                                            ? 'UofT'
                                            : Constants.checkUniversity() == 1
                                                ? 'YorkU'
                                                : 'WesternU'));
                              });
                              break;
                            case 'onehealingspace':
                              this.setState(() {
                                commentFuture =
                                    OneHealingSpace.fetchComments(widget.post);
                              });
                              break;
                            default:
                              this.setState(() {
                                commentFuture = fetchComments(
                                    widget.post,
                                    widget.course,
                                    widget.club,
                                    widget.post.university != null
                                        ? widget.post.university
                                        : Constants.checkUniversity() == 0
                                            ? 'UofT'
                                            : Constants.checkUniversity() == 1
                                                ? 'YorkU'
                                                : 'WesternU');
                              });
                              break;
                          }
                        } else {
                          this.setState(() {
                            commentFuture = fetchComments(
                                widget.post,
                                widget.course,
                                widget.club,
                                widget.post.university != null
                                    ? widget.post.university
                                    : Constants.checkUniversity() == 0
                                        ? 'UofT'
                                        : Constants.checkUniversity() == 1
                                            ? 'YorkU'
                                            : 'WesternU');
                          });
                        }
                      }
                      setState(() {
                        isCommenting = false;
                      });
                      Timer(
                          Duration(milliseconds: 300),
                          () => _scrollController.animateTo(
                              _scrollController.position.maxScrollExtent,
                              duration: Duration(milliseconds: 300),
                              curve: Curves.easeIn));
                    },
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );

    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: AppBar(
        centerTitle: false,
        title: userBar(),
        titleSpacing: 0.0,
        leadingWidth: 30.0,
        // title: Text(
        //   "Comments",
        //   style: GoogleFonts. inter(
        //fontFamily: Constants.fontFamily,
        //       fontSize: 20,
        //       fontWeight: FontWeight.w500,
        //       color: Theme.of(context).accentColor),
        // ),
        backgroundColor: Theme.of(context).backgroundColor,
        elevation: 0.0,
        iconTheme: IconThemeData(color: Theme.of(context).accentColor),
      ),
      body: RefreshIndicator(
        onRefresh: refresh,
        child: Stack(
          children: <Widget>[
            ListView(
              controller: _scrollController,
              children: <Widget>[
                PostWidget(
                    hide: () async {
                      var res = await hidePost(widget.post.id);
                      Navigator.pop(context);
                      if (res) {
                        previewMessage("Post hidden from feed.", context);
                      }
                    },
                    block: () async {
                      var res = await block(widget.post.userId, '');
                      Navigator.pop(context);
                      if (res) {
                        previewMessage("User blocked.", context);
                      }
                    },
                    deletePost: () async {
                      var res;

                      if (widget.post.type != null) {
                        switch (widget.post.type) {
                          case 'post':
                            res = await deletePost(widget.post.id, null, null);
                            break;
                          case 'club':
                            res = await deletePost(widget.post.id, null,
                                Club(id: widget.post.typeId));
                            break;
                          case 'course':
                            res = await deletePost(widget.post.id,
                                Course(id: widget.post.typeId), null);
                            break;
                          case 'onehealingspace':
                            res = await OneHealingSpace.deletePost(
                                widget.post.id);
                            break;
                          default:
                            res = await deletePost(widget.post.id, null, null);
                            break;
                        }
                      } else {
                        res = await deletePost(widget.post.id, null, null);
                      }

                      Navigator.pop(context);
                      if (res) {
                        previewMessage("Post Deleted", context);
                      } else {
                        previewMessage("Error deleting post!", context);
                      }
                    },
                    fromComments: true,
                    post: widget.post,
                    course: widget.course,
                    club: widget.club,
                    timeAgo: widget.timeAgo),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: FutureBuilder(
                    future: commentFuture,
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return ListView.builder(
                          shrinkWrap: true,
                          scrollDirection: Axis.vertical,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount:
                              snapshot.data != null ? snapshot.data.length : 0,
                          itemBuilder: (BuildContext context, int index) {
                            Comment comment = snapshot.data[index];
                            var timeAgo =
                                new DateTime.fromMillisecondsSinceEpoch(
                                    comment.timeStamp);
                            Function reply = () {
                              String tmp = str.substring(0, str.length);
                              print(tmp);
                              setState(() {
                                str = '';
                                // commentController.text = commentController.text
                                //     .replaceFirst(tmp, '@');
                                commentController.text +=
                                    '@' + comment.username.trimRight() + ' ';
                                commentController.value =
                                    commentController.value.copyWith(
                                  text: commentController.text,
                                  selection: TextSelection(
                                      baseOffset: commentController.text.length,
                                      extentOffset:
                                          commentController.text.length),
                                  composing: TextRange.empty,
                                );
                              });
                              String tag = '@' + comment.username.trimRight();
                              if (!tags.contains(tag)) {
                                tags.add(tag);
                              }
                              print(tags);
                              FocusScope.of(context).requestFocus(focusNode);
                              Timer(
                                  Duration(milliseconds: 300),
                                  () => _scrollController.animateTo(
                                      _scrollController
                                          .position.maxScrollExtent,
                                      duration: Duration(milliseconds: 300),
                                      curve: Curves.easeIn));
                            };
                            return CommentWidget(
                              comment: comment,
                              uni: widget.post.university,
                              timeAgo:
                                  timeago.format(timeAgo, locale: 'en_short'),
                              respond: reply,
                            );
                          },
                        );
                      } else {
                        return Container(
                          height: MediaQuery.of(context).size.height / 1.4,
                          child: Center(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Icon(
                                  Icons.face,
                                  color: Theme.of(context).accentColor,
                                ),
                                SizedBox(width: 10),
                                Text(
                                  "There are no comments :(",
                                  style: GoogleFonts.kulimPark(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: Theme.of(context).accentColor),
                                ),
                              ],
                            ),
                          ),
                        );
                      }
                    },
                  ),
                ),
              ],
            )
          ],
        ),
      ),
      bottomNavigationBar: Padding(
          padding: EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 10.0),
          child: widget.isDiffUni
              ? Padding(
                  padding: const EdgeInsets.only(bottom: 20.0),
                  child: Text(
                    "Commenting is disabled for different universities",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.kulimPark(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).accentColor),
                  ),
                )
              : commentBox),
    );
  }

  Widget userBar() {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Container(
          child: Row(children: [
        InkWell(
          onTap: () async {
            var user = await getUser(widget.post.userId);
            if (widget.post.userId != fAuth.currentUser.uid) {
              // if (widget.post.isAnonymous == false) {
              //   showProfile(
              //       user, context, bioC, sC, igC, lC, null, null);
              // }
              if (widget.post.isAnonymous == false) {
                showBarModalBottomSheet(
                    context: context,
                    expand: true,
                    builder: (context) =>
                        ProfilePage(user: user, heroTag: null));

                // Navigator.push(
                //     context,
                //     MaterialPageRoute(
                //         builder: (context) => ProfilePage(
                //             user: user, heroTag: widget.post.id)));
              }
            } else {
              // showProfile(
              //     user, context, bioC, sC, igC, lC, null, null);
              showBarModalBottomSheet(
                  context: context,
                  expand: true,
                  builder: (context) => ProfilePage(
                        user: user,
                        heroTag: null,
                        isMyProfile: true,
                      ));

              // Navigator.push(
              //     context,
              //     MaterialPageRoute(
              //         builder: (context) => ProfilePage(
              //               user: user,
              //               heroTag: widget.post.id,
              //               isMyProfile: true,
              //             )));
            }
          },
          child: widget.post.isAnonymous
              ? Container(
                  width: 40,
                  height: 40,
                  child: Center(
                    child: Icon(Feather.feather,
                        color: Theme.of(context).backgroundColor, size: 15.0),
                  ),
                  decoration: BoxDecoration(
                      color: Theme.of(context).buttonColor,
                      borderRadius: BorderRadius.circular(25.0)),
                )
              : imgUrl == null || imgUrl == ''
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(25),
                      child: Container(
                        width: 40,
                        height: 40,
                        color: Theme.of(context).dividerColor,
                        child: Center(
                          child: Icon(Feather.feather,
                              color: Theme.of(context).accentColor, size: 15.0),
                        ),
                      ),
                    )
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(25),
                      child: CachedNetworkImage(
                        imageUrl: imgUrl,
                        width: 40,
                        height: 40,
                        fit: BoxFit.cover,
                      ),
                    ),
        ),
        SizedBox(width: 5.0),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    widget.post.userId == FIR_UID
                        ? "You"
                        : widget.post.isAnonymous
                            ? "Anon"
                            : widget.post.feeling != null
                                ? widget.post.username.trim()
                                : widget.post.username
                                    .trim()
                                    .replaceFirst(' ', '\n'),
                    style: GoogleFonts.kulimPark(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: widget.post.userId == FIR_UID
                            ? Colors.indigo
                            : Theme.of(context).accentColor),
                  ),
                  Text(
                    " • ${widget.timeAgo}",
                    style: GoogleFonts.kulimPark(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).buttonColor),
                  ),
                ],
              ),
              // Visibility(
              //   visible: widget.post.tcQuestion != null,
              //   child: Padding(
              //     padding: const EdgeInsets.only(
              //         top: 3.0, bottom: 3.0),
              //     child: Text(
              //       'answered a question!',
              //       style: GoogleFonts. inter(
              //  fontFamily: Constants.fontFamily,
              //           fontSize: 12,
              //           fontWeight: FontWeight.w500,
              //           color: Colors.indigo),
              //     ),
              //   ),
              // ),
              // Visibility(
              //   visible: _user.about != null,
              //   child: Text(
              //     _user.about != null
              //         ? _user.about
              //         : 'No bio available',
              //     style: GoogleFonts. inter(
              //    fontFamily: Constants.fontFamily,
              //         fontSize: 12,
              //         fontWeight: FontWeight.w600,
              //         color: Colors.grey[500]),
              //   ),
              // )

              widget.post.feeling != null
                  ? Text(
                      'is feeling ${widget.post.feeling.toLowerCase()} ' +
                          Constants.feelings[widget.post.feeling],
                      style: GoogleFonts.kulimPark(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: color,
                      ))
                  : Container()
            ],
          ),
        ])
      ]))
    ]);
  }

  Future<Null> refresh() async {
    if (widget.post.type != null) {
      switch (widget.post.type) {
        case 'post':
          this.setState(() {
            commentFuture = fetchComments(
                widget.post,
                null,
                null,
                widget.post.university != null
                    ? widget.post.university
                    : Constants.checkUniversity() == 0
                        ? 'UofT'
                        : Constants.checkUniversity() == 1
                            ? 'YorkU'
                            : 'WesternU');
          });
          break;
        case 'club':
          this.setState(() {
            commentFuture = fetchComments(
                widget.post,
                null,
                Club(id: widget.post.typeId),
                widget.post.university != null
                    ? widget.post.university
                    : Constants.checkUniversity() == 0
                        ? 'UofT'
                        : Constants.checkUniversity() == 1
                            ? 'YorkU'
                            : 'WesternU');
          });
          break;
        case 'course':
          this.setState(() {
            commentFuture = fetchComments(
                widget.post,
                Course(id: widget.post.typeId),
                null,
                widget.post.university != null
                    ? widget.post.university
                    : Constants.checkUniversity() == 0
                        ? 'UofT'
                        : Constants.checkUniversity() == 1
                            ? 'YorkU'
                            : 'WesternU');
          });
          break;
        case 'onehealingspace':
          this.setState(() {
            commentFuture = OneHealingSpace.fetchComments(widget.post);
          });
          break;
        default:
          this.setState(() {
            commentFuture = fetchComments(
                widget.post,
                widget.course,
                widget.club,
                widget.post.university != null
                    ? widget.post.university
                    : Constants.checkUniversity() == 0
                        ? 'UofT'
                        : Constants.checkUniversity() == 1
                            ? 'YorkU'
                            : 'WesternU');
          });
          break;
      }
    } else {
      this.setState(() {
        commentFuture = fetchComments(
            widget.post,
            widget.course,
            widget.club,
            widget.post.university != null
                ? widget.post.university
                : Constants.checkUniversity() == 0
                    ? 'UofT'
                    : Constants.checkUniversity() == 1
                        ? 'YorkU'
                        : 'WesternU');
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    color = Constants.color();
    if (widget.post.type != null) {
      switch (widget.post.type) {
        case 'post':
          this.setState(() {
            commentFuture = fetchComments(
                widget.post,
                null,
                null,
                widget.post.university != null
                    ? widget.post.university
                    : Constants.checkUniversity() == 0
                        ? 'UofT'
                        : Constants.checkUniversity() == 1
                            ? 'YorkU'
                            : 'WesternU');
          });
          break;
        case 'club':
          this.setState(() {
            commentFuture = fetchComments(
                widget.post,
                null,
                Club(id: widget.post.typeId),
                widget.post.university != null
                    ? widget.post.university
                    : Constants.checkUniversity() == 0
                        ? 'UofT'
                        : Constants.checkUniversity() == 1
                            ? 'YorkU'
                            : 'WesternU');
          });
          break;
        case 'course':
          this.setState(() {
            commentFuture = fetchComments(
                widget.post,
                Course(id: widget.post.typeId),
                null,
                widget.post.university != null
                    ? widget.post.university
                    : Constants.checkUniversity() == 0
                        ? 'UofT'
                        : Constants.checkUniversity() == 1
                            ? 'YorkU'
                            : 'WesternU');
          });
          break;
        case 'onehealingspace':
          this.setState(() {
            commentFuture = OneHealingSpace.fetchComments(widget.post);
          });
          break;
        default:
          this.setState(() {
            commentFuture = fetchComments(
                widget.post,
                widget.course,
                widget.club,
                widget.post.university != null
                    ? widget.post.university
                    : Constants.checkUniversity() == 0
                        ? 'UofT'
                        : Constants.checkUniversity() == 1
                            ? 'YorkU'
                            : 'WesternU');
          });
          break;
      }
    } else {
      this.setState(() {
        commentFuture = fetchComments(
            widget.post,
            widget.course,
            widget.club,
            widget.post.university != null
                ? widget.post.university
                : Constants.checkUniversity() == 0
                    ? 'UofT'
                    : Constants.checkUniversity() == 1
                        ? 'YorkU'
                        : 'WesternU');
      });
    }

    getUser(widget.post.userId).then((value) {
      setState(() {
        imgUrl = value.profileImgUrl;
      });
    });

    myCampusUsers().then((value) {
      setState(() {
        users = value;
      });
    });

    Timer(
        Duration(milliseconds: 300),
        () => _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: Duration(milliseconds: 300),
            curve: Curves.easeIn));
  }
}
