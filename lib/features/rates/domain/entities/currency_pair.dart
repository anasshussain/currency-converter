/// A from/to currency pair. Records give us value equality for free, which
/// makes it a safe key for Riverpod `family` providers.
typedef CurrencyPair = ({String from, String to});
