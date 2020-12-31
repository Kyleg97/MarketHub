class EarningsModel {
  EarningsModel(
    this.company,
    this.datetime,
    this.epsEstimate,
    this.ticker,
    this.volume,
  );

  String company;
  String datetime;
  String epsEstimate;
  String ticker;
  int volume;

  static List<dynamic> parseData(List data) {
    return data
        .map(
          (entry) => EarningsModel(
            entry['company'].toString(),
            entry['datetime'].toString(),
            entry['eps_estimate'].toString(),
            entry['ticker'].toString(),
            int.parse(entry['volume'].toString()),
          ),
        )
        .toList();
  }
}
