import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:unify/Components/Constants.dart';

int uniKey = Constants.checkUniversity();

// ASSIGNMENT REFERENCES

// ignore_for_file: non_constant_identifier_names
final DatabaseReference ASSIGNMENTS_DB =
    FirebaseDatabase.instance.reference().child("assignments");

DatabaseReference EVENT_REMINDERS_DB =
    FirebaseDatabase.instance.reference().child("eventreminders");

// CLUBS REFERENCES

DatabaseReference CLUBS_DB =
    FirebaseDatabase.instance.reference().child("clubs");

// USERS REFERENCES

String FIR_UID = FirebaseAuth.instance.currentUser.uid;

DatabaseReference USERS_DB =
    FirebaseDatabase.instance.reference().child('users');

// POSTS REFERENCES

DatabaseReference POSTS_DB =
    FirebaseDatabase.instance.reference().child('posts');

DatabaseReference COURSE_POSTS_DB =
    FirebaseDatabase.instance.reference().child('courseposts');

DatabaseReference CLUB_POSTS_DB =
    FirebaseDatabase.instance.reference().child('clubposts');

DatabaseReference VIDEOS_DB =
    FirebaseDatabase.instance.reference().child('videos');

// COURSE REFERENCES

DatabaseReference COURSE_REQUESTS_DB =
    FirebaseDatabase.instance.reference().child('courserequests');

DatabaseReference COURSES_DB =
    FirebaseDatabase.instance.reference().child("courses");

// MESSAGING REFERENCES

DatabaseReference CHATS_DB =
    FirebaseDatabase.instance.reference().child('chats');

// NOTIFICATION REFERENCES

DatabaseReference NOTIFICATIONS_DB =
    FirebaseDatabase.instance.reference().child('notifications');

// PROMO

DatabaseReference PROMO_DB =
    FirebaseDatabase.instance.reference().child('promoImageUrl');

// BUY AND SELL REFERENCES

DatabaseReference LISTINGS_DB =
    FirebaseDatabase.instance.reference().child('listings');

// ROOMS REFERENCES

DatabaseReference ROOMS_DB =
    FirebaseDatabase.instance.reference().child('rooms');

FirebaseAuth FIR_AUTH = FirebaseAuth.instance;
