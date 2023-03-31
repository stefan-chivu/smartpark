class Address {
  late String street;
  late String city;
  late String region;
  late String country;

  Address(this.street, this.city, this.region, this.country);

  Address.empty() {
    street = '';
    city = '';
    region = '';
    country = '';
  }

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
