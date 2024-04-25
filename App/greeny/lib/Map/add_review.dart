import 'package:flutter/material.dart';
//import 'package:flutter_translate/flutter_translate.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class AddReviewPage extends StatefulWidget {
  final dynamic station;

  const AddReviewPage({super .key, required this.station});
  
  @override
  _AddReviewPageState createState() => _AddReviewPageState();
}

class _AddReviewPageState extends State<AddReviewPage> {
  dynamic get station => widget.station;

  final TextEditingController reviewController = TextEditingController();
  //final TextEditingController scoreController = TextEditingController();

  double rating = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Review'),
      ),
      body: Center(
        //child: reviewForm(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('Station: ${widget.station.name}'),
              Expanded(
                child: reviewForm(),
              ),
            ],
          ),
        )
      );
      
      /*body: CustomScrollView(
        scrollDirection: Axis.vertical,
        slivers: [
          SliverFillRemaining(
            hasScrollBody: false,
            child: Container(
              padding: const EdgeInsets.fromLTRB(40, 50, 40, 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Form(
                    //Key: reviewForm,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text( //Hace falta este?
                              'Rating: $rating',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                          ]
                        ),
                        const SizedBox(height: 30),
                        RatingBar.builder(
                          minRating: 1,
                          itemSize: 40,
                          itemPadding: EdgeInsets.symmetric(horizontal: 4),
                          itemBuilder: (context, _) => Icon(Icons.star, color: Colors.amber),
                          updateOnDrag: true,
                          onRatingUpdate: (rating) => setState(() {
                            this.rating = rating;
                          }),
                        ),
                        /*TextFormField(
                          obscureText: false,
                          controller: scoreController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            border: const OutlineInputBorder(),
                            labelText: 'Enter your score (1-5)',
                          ),
                        ),*/
                        const SizedBox(height: 20),
                        TextField(
                          obscureText: false,
                          controller: reviewController,
                          //maxLines: 5,
                          decoration: InputDecoration(
                            border: const OutlineInputBorder(),
                            labelText: 'Write your review here',
                          ),
                        ),
                        SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: sendReview,
                          child: Text('Save Review'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
        /*padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            TextField(
              controller: reviewController,
              maxLines: 5,
              decoration: InputDecoration(
                labelText: 'Write your review here',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            TextFormField(
              controller: scoreController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Enter your score (1-5)',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: sendReview,
              child: Text('Save Review'),
            ),
          ],
        ),*/
      ),
    );*/
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
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Form(
                  //Key: reviewForm,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text( //Hace falta este?
                            'Rating: $rating',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ]
                      ),
                      const SizedBox(height: 30),
                      RatingBar.builder(
                        minRating: 1,
                        itemSize: 40,
                        itemPadding: EdgeInsets.symmetric(horizontal: 4),
                        itemBuilder: (context, _) => Icon(Icons.star, color: Colors.amber),
                        updateOnDrag: true,
                        onRatingUpdate: (rating) => setState(() {
                          this.rating = rating;
                        }),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        obscureText: false,
                        controller: reviewController,
                        //maxLines: 5,
                        decoration: InputDecoration(
                          border: const OutlineInputBorder(),
                          labelText: 'Write your review here',
                        ),
                      ),
                      SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: sendReview,
                        child: Text('Save Review'),
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
    //String scoreText = scoreController.text;

    // Validar los datos antes de enviarlos
    /*if (reviewText.isEmpty) {
      print('Review is empty');
      return;
    }*/

    /*int? score = int.tryParse(scoreText);*/
    if (rating == 0.0 || rating < 1.0 || rating > 5.0) {
      print('Score is not a valid number between 1 and 5');
      return;
    }

    print('Sending review: $reviewText');
    print('Sending score: $rating');
  }
}