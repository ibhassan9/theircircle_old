import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:toast/toast.dart';

class MultiSelectChip extends StatefulWidget {
  final Map<String, dynamic> reportList;
  final List<String> sChoices;
  MultiSelectChip(this.reportList, this.sChoices);
  @override
  _MultiSelectChipState createState() => _MultiSelectChipState();
}

class _MultiSelectChipState extends State<MultiSelectChip> {
  List<String> selectedChoices = List();
  String filter;
  String title = 'Choose up to 20 interests';

  _buildChoiceList() {
    if (widget.sChoices != null && widget.sChoices.isNotEmpty) {
      selectedChoices = widget.sChoices;
    }
    List<Widget> choices = List();
    for (var key in widget.reportList.keys) {
      if (filter == null || filter.trim() == "") {
        choices.add(Container(
          padding: const EdgeInsets.only(left: 0.0, right: 2.0),
          child: ChoiceChip(
            selectedColor: Colors.deepPurpleAccent,
            backgroundColor: Colors.grey[300],
            label: Text(
              key,
              style: GoogleFonts.quicksand(
                textStyle: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    color: selectedChoices.contains(key)
                        ? Colors.white
                        : Colors.black),
              ),
            ),
            selected: selectedChoices.contains(key),
            onSelected: (selected) {
              if (selectedChoices.length < 20) {
                setState(() {
                  selectedChoices.contains(key)
                      ? selectedChoices.remove(key)
                      : selectedChoices.add(key);
                });
              } else {
                if (selectedChoices.contains(key)) {
                  setState(() {
                    selectedChoices.remove(key);
                  });
                } else {
                  Toast.show('You can only choose up to 20 interests.', context,
                      duration: Toast.LENGTH_LONG);
                }
              }
            },
          ),
        ));
      } else {
        if (key.toLowerCase().trim().contains(filter.toLowerCase().trim())) {
          choices.add(Container(
            padding: const EdgeInsets.only(left: 0.0, right: 2.0),
            child: ChoiceChip(
              selectedColor: Colors.deepPurpleAccent,
              backgroundColor: Colors.grey[300],
              label: Text(
                key,
                style: GoogleFonts.quicksand(
                  textStyle: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color: selectedChoices.contains(key)
                          ? Colors.white
                          : Colors.black),
                ),
              ),
              selected: selectedChoices.contains(key),
              onSelected: (selected) {
                if (selectedChoices.length < 20) {
                  setState(() {
                    selectedChoices.contains(key)
                        ? selectedChoices.remove(key)
                        : selectedChoices.add(key);
                  });
                } else {
                  if (selectedChoices.contains(key)) {
                    setState(() {
                      selectedChoices.remove(key);
                    });
                  } else {
                    Toast.show(
                        'You can only choose up to 20 interests.', context,
                        duration: Toast.LENGTH_LONG);
                  }
                }
              },
            ),
          ));
        }
      }
    }
    return choices;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).backgroundColor,
        elevation: 0.0,
        leading: IconButton(
          icon: Icon(Icons.done),
          onPressed: () {
            Navigator.pop(context, selectedChoices);
          },
        ),
        title: Text(
          title,
          style: GoogleFonts.quicksand(
            textStyle: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).accentColor),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView(children: [
          Container(
            child: TextField(
              onChanged: (value) {
                setState(() {
                  filter = value;
                });
              },
              decoration: new InputDecoration(
                border: InputBorder.none,
                focusedBorder: InputBorder.none,
                enabledBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
                contentPadding:
                    EdgeInsets.only(left: 0, bottom: 11, top: 11, right: 0),
                hintText: "Search Interests",
                hintStyle: GoogleFonts.quicksand(
                  textStyle: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).accentColor),
                ),
              ),
              style: GoogleFonts.quicksand(
                textStyle: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).accentColor),
              ),
            ),
          ),
          Wrap(
            children: _buildChoiceList(),
          ),
        ]),
      ),
    );
  }
}
