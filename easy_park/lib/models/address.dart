class Address {
  String street;
  String city;
  String region;
  String country;

  Address(this.street, this.city, this.region, this.country);

  @override
  String toString() {
    return "$street, $city";
  }
}
