// ignore_for_file: prefer_const_constructors

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:greeny/API/requests.dart';
import 'package:greeny/utils/utils.dart';

class AddReviewPage extends StatefulWidget {
  final int stationId;
  final String type;
  final String stationName;

  const AddReviewPage(
      {super.key,
      required this.stationId,
      required this.type,
      required this.stationName});

  @override
  // ignore: library_private_types_in_public_api
  _AddReviewPageState createState() => _AddReviewPageState();
}

class _AddReviewPageState extends State<AddReviewPage> {
  int get stationId => widget.stationId;
  String get stationName => widget.stationName;
  String get type => widget.type;

  final TextEditingController reviewController = TextEditingController();

  double rating = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(translate('Add review')),
        ),
        body: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const SizedBox(height: 35),
              Center(
                child: Text(
                  stationName,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 20, 
                    fontWeight: FontWeight.bold
                  ),
                ),
              ),
              Expanded(
                child: reviewForm(),
              ),
              Center(
                child: ElevatedButton(
                  onPressed: sendReview,
                  child: Text(translate('Save Review')),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ));
  }

  reviewForm() {
    return CustomScrollView(
      scrollDirection: Axis.vertical,
      slivers: [
        SliverFillRemaining(
          hasScrollBody: false,
          child: Container(
            padding: const EdgeInsets.fromLTRB(40, 50, 40, 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Form(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      RatingBar.builder(
                        minRating: 1,
                        itemSize: 40,
                        itemPadding: const EdgeInsets.symmetric(horizontal: 4),
                        itemBuilder: (context, _) =>
                            const Icon(Icons.star, color: Color.fromARGB(255, 1, 167, 164)),
                        updateOnDrag: true,
                        onRatingUpdate: (rating) => setState(() {
                          this.rating = rating;
                        }),
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        obscureText: false,
                        controller: reviewController,
                        maxLines: 14,
                        maxLength: 1000,
                        decoration: InputDecoration(
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Color.fromARGB(255, 1, 167, 164),  // Change this to your desired color
                              width: 4.0,         // Change this to your desired width
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Color.fromARGB(255, 1, 167, 164),  // Change this to your desired color
                              width: 4.0,         // Change this to your desired width
                            ),
                          ),
                          labelText: translate('Write your review here'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> sendReview() async {
    String reviewText = reviewController.text;
    if (rating == 0.0 || rating < 1.0 || rating > 5.0) {
      showMessage(context, translate("Score is not a valid number between 1 and 5"));
      return;
    }

    var response = await httpPost(
        'api/stations/$stationId/reviews/',
        jsonEncode({
          'body': reviewText,
          'puntuation': rating,
        }),
        'application/json');
    if (response.statusCode == 201) {
      // ignore: use_build_context_synchronously
      Navigator.pop(context);
    } else {
      if (mounted) {
        showMessage(context, translate("The review could not be saved"));
      }
    }
  }
}
