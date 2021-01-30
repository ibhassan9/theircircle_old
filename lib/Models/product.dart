import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:unify/Components/Constants.dart';
import 'package:unify/Models/user.dart';

class Product {
  String id;
  String title;
  String description;
  String sellerId;
  String sellerName;
  List<String> imgUrls;
  String price;
  int timeStamp;
  String sellerImgUrl;
  PostUser seller;

  Product(
      {this.id,
      this.title,
      this.description,
      this.sellerId,
      this.sellerName,
      this.imgUrls,
      this.price,
      this.timeStamp,
      this.sellerImgUrl,
      this.seller});

  static var theircircle = FirebaseDatabase.instance.reference();

  static Future<bool> remove(String id) async {
    var uniKey = Constants.checkUniversity();
    var university = uniKey == 0
        ? 'UofT'
        : uniKey == 1
            ? 'YorkU'
            : 'WesternU';
    var db = theircircle.child('listings').child(university).child(id);
    var mydb = theircircle
        .child('users')
        .child(university)
        .child(FirebaseAuth.instance.currentUser.uid)
        .child('mylistings')
        .child(id);
    await mydb.remove().catchError((e) {
      return false;
    });
    await db.remove().catchError((e) {
      return false;
    });
    return true;
  }

  static Future<bool> createListing(Product prod, List<File> files) async {
    //PostUser user = await getUser(FirebaseAuth.instance.currentUser.uid);
    var uniKey = Constants.checkUniversity();
    var university = uniKey == 0
        ? 'UofT'
        : uniKey == 1
            ? 'YorkU'
            : 'WesternU';
    var db = theircircle.child('listings').child(university).push();
    var mydb = theircircle
        .child('users')
        .child(university)
        .child(FirebaseAuth.instance.currentUser.uid)
        .child('mylistings')
        .child(db.key);
    var urlStrings = await uploadImagesToStorage(files);
    Map<String, dynamic> data = {
      'id': db.key,
      'title': prod.title,
      'description': prod.description,
      'sellerId': FirebaseAuth.instance.currentUser.uid,
      'imgUrls': urlStrings,
      'price': prod.price,
      'timeStamp': DateTime.now().millisecondsSinceEpoch
    };
    await db.set(data).then((_) {
      mydb.set(true).then((_) {
        return true;
      }).catchError((e) {
        return false;
      });
    }).catchError((e) {
      return false;
    });

    return true;
  }

  static Future<List<Product>> products() async {
    List<Product> prods = [];
    var uniKey = Constants.checkUniversity();
    var blocks = await getBlocks();
    var university = uniKey == 0
        ? 'UofT'
        : uniKey == 1
            ? 'YorkU'
            : 'WesternU';
    var db = theircircle.child('listings').child(university);
    DataSnapshot snap = await db.once();
    Map<dynamic, dynamic> values = snap.value;
    if (snap.value != null) {
      for (var value in values.values) {
        var sellerId = value['sellerId'];
        if (blocks.containsKey(sellerId)) {
          print('seller blocked');
        } else {
          print('seller not blocked');
          PostUser seller = await getUser(sellerId as String);
          Product prod = Product(
              id: value['id'],
              title: value['title'],
              description: value['description'],
              sellerId: value['sellerId'],
              sellerName: seller.name,
              imgUrls:
                  (value['imgUrls'] as List<dynamic>).cast<String>().toList(),
              price: value['price'],
              timeStamp: value['timeStamp'],
              sellerImgUrl: seller.profileImgUrl,
              seller: seller);
          print(value['imgUrls']);
          prods.add(prod);
        }
      }
      prods.sort((a, b) => b.timeStamp.compareTo(a.timeStamp));
      return prods;
    } else {
      return prods;
    }
  }

  static Future<List<String>> uploadImagesToStorage(List<File> files) async {
    List<String> urlStrings = [];
    try {
      for (var file in files) {
        final DateTime now = DateTime.now();
        final int millSeconds = now.millisecondsSinceEpoch;
        final String month = now.month.toString();
        final String date = now.day.toString();
        final String storageId = (millSeconds.toString());
        final String today = ('$month-$date');

        StorageReference ref = FirebaseStorage.instance
            .ref()
            .child("files")
            .child(today)
            .child(storageId);
        StorageUploadTask uploadTask = ref.putFile(file);

        var snapShot = await uploadTask.onComplete;

        var url = await snapShot.ref.getDownloadURL();
        var urlString = url.toString();
        urlStrings.add(urlString);
      }
      print(urlStrings);
      return urlStrings;
    } catch (e) {
      return [];
    }
  }

  static Future<Product> info(String id) async {
    var uniKey = Constants.checkUniversity();
    //var blocks = await getBlocks();
    var university = uniKey == 0
        ? 'UofT'
        : uniKey == 1
            ? 'YorkU'
            : 'WesternU';
    var db = theircircle.child('listings').child(university).child(id);
    DataSnapshot snap = await db.once();
    Map<dynamic, dynamic> value = snap.value;
    print(value);
    if (snap.value != null) {
      var sellerId = value['sellerId'];
      PostUser seller = await getUser(sellerId);
      Product prod = Product(
          id: value['id'],
          title: value['title'],
          description: value['description'],
          sellerId: value['sellerId'],
          seller: seller,
          sellerName: seller.name,
          imgUrls: (value['imgUrls'] as List<dynamic>).cast<String>().toList(),
          price: value['price'],
          timeStamp: value['timeStamp'],
          sellerImgUrl: seller.profileImgUrl);
      print('this is prod');
      print(prod);
      return prod;
    } else {
      return null;
    }
  }

  static Future<List<Product>> myListings() async {
    List<Product> listings = [];
    var uniKey = Constants.checkUniversity();
    //var blocks = await getBlocks();
    var university = uniKey == 0
        ? 'UofT'
        : uniKey == 1
            ? 'YorkU'
            : 'WesternU';
    var db = theircircle
        .child('users')
        .child(university)
        .child(FirebaseAuth.instance.currentUser.uid)
        .child('mylistings');
    DataSnapshot snap = await db.once();
    if (snap.value != null) {
      Map<dynamic, dynamic> value = snap.value;
      for (var key in value.keys) {
        Product prod = await info(key);
        listings.add(prod);
      }
      listings.sort((a, b) => b.timeStamp.compareTo(a.timeStamp));
      return listings;
    } else {
      return listings;
    }
  }
}
