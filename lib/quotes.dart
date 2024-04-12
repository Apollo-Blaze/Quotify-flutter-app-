import 'dart:convert';

class Quote {
 late String text;
  late String source;


  Quote(this.text, this.source);

  // Convert Quote object to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'source': source,
    };
  }

  // Create a Quote object from a JSON map
  factory Quote.fromJson(Map<String, dynamic> json) {
    return Quote(
      json['text'] as String,
      json['source'] as String,
    );
  }

  // Create a Quote object from a JSON-formatted string
  // factory Quote.fromJsonString(String jsonString) {
  //   Map<String, dynamic> json = jsonDecode(jsonString);
  //   return Quote.fromJson(json);
  // }

  // Convert Quote object to a JSON-formatted string
  // String toJsonString() {
  //   return jsonEncode(toJson());
  // }
  Quote.fromJsonString(String jsonString) {
    Map<String, dynamic> jsonMap = json.decode(jsonString);
    text = jsonMap['text'];
    source = jsonMap['source'];
  }

  // Serialize a Quote object to a JSON string
  String toJsonString() {
    Map<String, dynamic> jsonMap = {
      'text': text,
      'source': source,
    };
    return json.encode(jsonMap);
  }
}
