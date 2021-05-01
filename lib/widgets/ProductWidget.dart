import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:unify/Models/product.dart';
import 'package:unify/pages/ProductDetailPage.dart';
import 'package:timeago/timeago.dart' as timeago;

class ProductWidget extends StatefulWidget {
  final Product prod;
  final Function refresh;
  ProductWidget({Key key, this.prod, this.refresh}) : super(key: key);
  @override
  _ProductWidgetState createState() => _ProductWidgetState();
}

class _ProductWidgetState extends State<ProductWidget> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        // Navigator.push(
        //     context,
        //     MaterialPageRoute(
        //         builder: (context) => ProductDetailPage(prod: widget.prod)));
        showMaterialModalBottomSheet(
                context: context,
                expand: true,
                builder: (context) => ProductDetailPage(prod: widget.prod))
            .then((value) {
          if (value == true) {
            //refresh
            widget.refresh();
          }
        });
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: MediaQuery.of(context).size.width,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 5.0),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(100),
                    child: Image.network(
                      widget.prod.seller.profileImgUrl != null
                          ? widget.prod.seller.profileImgUrl
                          : '',
                      width: 20,
                      height: 20,
                      fit: BoxFit.cover,
                      loadingBuilder: (BuildContext context, Widget child,
                          ImageChunkEvent loadingProgress) {
                        if (loadingProgress == null) return child;
                        return SizedBox(
                          height: 20,
                          width: 20,
                          child: Center(
                            child: SizedBox(
                                width: 20,
                                height: 20,
                                child: LoadingIndicator(
                                  indicatorType:
                                      Indicator.ballClipRotateMultiple,
                                  color: Theme.of(context).accentColor,
                                )),
                          ),
                        );
                      },
                    ),
                  ),
                  SizedBox(width: 5.0),
                  Flexible(
                    child: Text(
                      (widget.prod.sellerId ==
                                  FirebaseAuth.instance.currentUser.uid
                              ? 'You'
                              : widget.prod.sellerName) +
                          ' • ' +
                          timeago.format(
                              new DateTime.fromMillisecondsSinceEpoch(
                                  widget.prod.timeStamp),
                              locale: 'en_short'),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.quicksand(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).accentColor),
                    ),
                  )
                ],
              ),
            ),
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(5.0),
            child: Container(
              height: 230,
              decoration: BoxDecoration(
                color: Colors.grey[100],
              ),
              child: CachedNetworkImage(
                imageUrl: widget.prod != null ? widget.prod.imgUrls[0] : '',
                width: MediaQuery.of(context).size.width,
                height: 200,
                fit: BoxFit.cover,
              ),
            ),
          ),
          SizedBox(height: 5.0),
          Text(
            widget.prod.title + r' • $' + widget.prod.price,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.quicksand(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).accentColor),
          ),
          Text(
            widget.prod.description,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.quicksand(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).accentColor.withOpacity(0.5)),
          )
        ],
      ),
    );
  }
}
