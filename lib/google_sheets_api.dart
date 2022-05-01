import 'package:gsheets/gsheets.dart';

class GoogleSheetsApi {
  // create credentials
  static const _credentials = r'''
  {
  "type": "service_account",
  "project_id": "expense-tracker-348909",
  "private_key_id": "84190402e73299e86f7aba36f19fb661dac29090",
  "private_key": "-----BEGIN PRIVATE KEY-----\nMIIEvgIBADANBgkqhkiG9w0BAQEFAASCBKgwggSkAgEAAoIBAQDOcRLGtsq8dnH9\nxsM/IGlgqRY7q7Pxe1pVHcGiQHJuDM1Esz5fJMDFqxXnMRTTGjyLGqq3VBETaVAc\nb/uuvsU8on8LFHk+iP1rRo4vSIOBZUeH6dt8vM3eA7tt3b6y/UnnfR0KMZJHCKZ9\n6jmXjVKgO5NkYM/SCD0bGNIi66qBa9dcLGen5KSYhJnoUDM+4bdi4ZLfeIbm0778\nP2WQTFWe4/RMg9v+CC32mAFmUWSaNSYYCKFf8hKwYc/ANVQGgVWiqKDnM8rTJe0c\nGEnyc5DouL30M8zjmmn0upmYxXnyNhOJSJVfBOg35dlg/rxZyP8zPots3n2PQ8XB\nzpdK3WMbAgMBAAECggEARzfpA1ayMDwobSUx3EhBMlCC1AkTJd6pNi3yzBexoleW\nRPoVLVuPiWHRR5W+Gmm1s0N6244L6gdt1LGpQQqdHqLscxUYEsPNsUGA8bzxaSVY\nfQHnb2vvFYVyFp/mFveclFisOQUK8qiAT3YLckYV2CNVYM6pQ0sGUZ/JdrSYeNbt\nrdyiKjqCIy7dsf/Io2XXjFNifaY2YTDH6GaSBfFTvVeSNhp4JM+scbZkIdDZ/cND\n/qMouJE7fOuiYor6/WywhPuklmVfBUmVvybCST+ALO9/6jrai1l9uagO1gt1a2YC\nr1lXVJ/8Dfkytmz6S3HvFoYmVbEDRiU5PMunStjZuQKBgQDpKJXICesKSuU5ttZs\nuUZJ3pElYuLtsDGXo8euRaglSIHKgxdXs+DjmGvatkurKOIDTP9I+t/1ex0Q1cR4\nsqcnknWy++QMG3ShZG8CqxFGpV6UMeQHGH0fOeDpt3jGe2VVaamaaigTtO1oOfXk\nnDOYK+ou2p9cGYXe/xelW8zk/wKBgQDiqnPw6tDqU2iV41p4wQY/traYtLRCuW8b\n3LD7h24gHYzYKd1nTL+dasm+zwk5sMOhxP0CtL1ION4q/bg6/Yeoum0LIcOP/eBj\nLneLDstcrji9UouvTcTtTYHfRtQ1Yo3HJ7dz6IoqQrXDzYH3nBxGbLwmLYCrDeeq\n1ueWXBR15QKBgQC8NDN7Tm44V65igPDiwEc5d3vIJuMwo8nUMrMLPFT3C2khM+IS\nvDMq5C0jVYUM+yo9KdjjawZ+28rhfPxjxSnianmxaVxyXXMul6h4CegfE3udugvr\nolvVad3gKmZGKPLqGCl8aHZDOgds22ReDawkCEa3XWfHax7Bmz3WD5z7twKBgEvm\n/HA+kbsGN02KFq+9I5SOYNL+ICb/5Z8U5gc0sMH8Yz+3tTZ0Uu4p5mkI93PkJ36y\ncm9HiuL2eB85W0oVwCnWU9GYet5rC4rq8okUaTEd/k4XqEMJ7dnxTH4yP7moyQVZ\n3WrpAeto72kkFlOOaUGEA/Vc42tkeqGQ2XhWWVupAoGBAK9+6zXtfP4XjHzspDp5\nPlmmGoqlyg852R9mWlZ0wpOEQA4hwC5/fyxJa1LX8xi+QO98CNvM4m3c6NNQCUW6\n2YhEMUMYHUFiv8X/l536DpfczvVeddq4pzd6eOOstc3NOThYyP7iirwu1zZRKhGb\n4GV1Px8sAtIB+fMxBOZ/S8wr\n-----END PRIVATE KEY-----\n",
  "client_email": "expense-tracker@expense-tracker-348909.iam.gserviceaccount.com",
  "client_id": "116344341245850767553",
  "auth_uri": "https://accounts.google.com/o/oauth2/auth",
  "token_uri": "https://oauth2.googleapis.com/token",
  "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
  "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/expense-tracker%40expense-tracker-348909.iam.gserviceaccount.com"
  }

  ''';

  // set up & connect to the spreadsheet
  static final _spreadsheetId = '1NuWYcPElhjCA0fMhrv1iIgwRIKyWciqZ5F8FSvt8IF4';
  static final _gsheets = GSheets(_credentials);
  static Worksheet? _worksheet;

  // some variables to keep track of..
  static int numberOfTransactions = 0;
  static List<List<dynamic>> currentTransactions = [];
  static bool loading = true;

  // initialise the spreadsheet!
  Future init() async {
    final ss = await _gsheets.spreadsheet(_spreadsheetId);
    _worksheet = ss.worksheetByTitle('Worksheet1');
    countRows();
  }

  // count the number of notes
  static Future countRows() async {
    while ((await _worksheet!.values
            .value(column: 1, row: numberOfTransactions + 1)) !=
        '') {
      numberOfTransactions++;
    }
    // now we know how many notes to load, now let's load them!
    loadTransactions();
  }

  // load existing notes from the spreadsheet
  static Future loadTransactions() async {
    if (_worksheet == null) return;

    for (int i = 1; i < numberOfTransactions; i++) {
      final String transactionName =
          await _worksheet!.values.value(column: 1, row: i + 1);
      final String transactionAmount =
          await _worksheet!.values.value(column: 2, row: i + 1);
      final String transactionType =
          await _worksheet!.values.value(column: 3, row: i + 1);

      if (currentTransactions.length < numberOfTransactions) {
        currentTransactions.add([
          transactionName,
          transactionAmount,
          transactionType,
        ]);
      }
    }
    print(currentTransactions);
    // this will stop the circular loading indicator
    loading = false;
  }

  // insert a new transaction
  static Future insert(String name, String amount, bool _isIncome) async {
    if (_worksheet == null) return;
    numberOfTransactions++;
    currentTransactions.add([
      name,
      amount,
      _isIncome == true ? 'income' : 'expense',
    ]);
    await _worksheet!.values.appendRow([
      name,
      amount,
      _isIncome == true ? 'income' : 'expense',
    ]);
  }

  // CALCULATE THE TOTAL INCOME!
  static double calculateIncome() {
    double totalIncome = 0;
    for (int i = 0; i < currentTransactions.length; i++) {
      if (currentTransactions[i][2] == 'income') {
        totalIncome += double.parse(currentTransactions[i][1]);
      }
    }
    return totalIncome;
  }

  // CALCULATE THE TOTAL EXPENSE!
  static double calculateExpense() {
    double totalExpense = 0;
    for (int i = 0; i < currentTransactions.length; i++) {
      if (currentTransactions[i][2] == 'expense') {
        totalExpense += double.parse(currentTransactions[i][1]);
      }
    }
    return totalExpense;
  }
}
