class Address {
  String street;
  String city;
  String region;
  String country;

  Address(this.street, this.city, this.region, this.country);

  Address.fromJson(Map<String, dynamic> json)
      : street = json['street'] ?? '',
        city = json['city'] ?? '',
        region = json['region'] ?? '',
        country = json['country'] ?? '';

  Map<String, dynamic> toJson() =>
      {'street': street, 'city': city, 'region': region, 'country': country};

  @override
  String toString() {
    return "$street, $city";
  }
}
