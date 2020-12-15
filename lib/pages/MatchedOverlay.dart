import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:unify/Models/user.dart';

class MatchedOverlay extends ModalRoute<void> {
  final PostUser user;

  MatchedOverlay({this.user});

  @override
  Duration get transitionDuration => Duration(milliseconds: 500);

  @override
  bool get opaque => false;

  @override
  bool get barrierDismissible => false;

  @override
  Color get barrierColor => Colors.black.withOpacity(0.9);

  @override
  String get barrierLabel => null;

  @override
  bool get maintainState => true;

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    // This makes sure that text and other content follows the material style
    return Material(
      type: MaterialType.transparency,
      // make sure that the overlay content is not cut off
      child: SafeArea(
        child: _buildOverlayContent(context),
      ),
    );
  }

  Widget _buildOverlayContent(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.pop(context);
      },
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text('Congrats!',
                  style:
                      GoogleFonts.pacifico(color: Colors.white, fontSize: 30.0),
                  textAlign: TextAlign.center),
              SizedBox(height: 30.0),
              user.profileImgUrl == null
                  ? FittedBox(
                      fit: BoxFit.contain,
                      child: Container(
                        decoration: new BoxDecoration(
                          border: Border.all(width: 3, color: Colors.white),
                          shape: BoxShape.circle,
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(140),
                          child: Container(
                              width: 140, height: 140, color: Colors.grey),
                        ),
                      ),
                    )
                  : FittedBox(
                      fit: BoxFit.contain,
                      child: Container(
                        decoration: new BoxDecoration(
                          border: Border.all(width: 3, color: Colors.white),
                          shape: BoxShape.circle,
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(140),
                          child: Image.network(
                            user.profileImgUrl,
                            width: 140,
                            height: 140,
                            fit: BoxFit.cover,
                            loadingBuilder: (BuildContext context, Widget child,
                                ImageChunkEvent loadingProgress) {
                              if (loadingProgress == null) return child;
                              return SizedBox(
                                height: 140,
                                width: 140,
                                child: Center(
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.0,
                                    valueColor:
                                        new AlwaysStoppedAnimation<Color>(
                                            Colors.grey.shade600),
                                    value: loadingProgress.expectedTotalBytes !=
                                            null
                                        ? loadingProgress
                                                .cumulativeBytesLoaded /
                                            loadingProgress.expectedTotalBytes
                                        : null,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
              SizedBox(height: 15.0),
              Text('You and ${user.name} are now friends!',
                  style: GoogleFonts.patrickHandSc(
                      color: Colors.white, fontSize: 25.0),
                  textAlign: TextAlign.center),
              SizedBox(height: 15.0),
              Text('Tap anywhere to close',
                  style:
                      GoogleFonts.poppins(color: Colors.white, fontSize: 15.0),
                  textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    // You can add your own animations for the overlay content
    return FadeTransition(
      opacity: animation,
      child: ScaleTransition(
        scale: animation,
        child: child,
      ),
    );
  }
}
