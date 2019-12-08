class Sign {
  final int id;
  final String description;
  final String url;
  int nCorrect;
  int nIncorrect;
  int score;

  Sign({this.id, this.description, this.url, this.nCorrect, this.nIncorrect, this.score});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'description': description,
      'url': url,
      'correct': nCorrect,
      'incorrect': nIncorrect,
      'score': score,
    };
  }
}
