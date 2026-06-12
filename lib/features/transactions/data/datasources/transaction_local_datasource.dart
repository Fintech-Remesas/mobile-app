import '../../../../core/data/mock_data_source.dart';
import '../models/contact_model.dart';
import '../models/transaction_detail_model.dart';

abstract class TransactionLocalDataSource {
  Future<List<ContactModel>> fetchContacts();
  Future<TransactionDetailModel> fetchTransactionDetail(String id);
}

class TransactionLocalDataSourceImpl implements TransactionLocalDataSource {
  final MockDataSource mockDataSource;

  TransactionLocalDataSourceImpl({MockDataSource? mockDataSource})
      : mockDataSource = mockDataSource ?? MockDataSource();

  @override
  Future<List<ContactModel>> fetchContacts() async {
    await mockDataSource.simulateDelay();
    return MockDataSource.contacts.map(ContactModel.fromJson).toList();
  }

  @override
  Future<TransactionDetailModel> fetchTransactionDetail(String id) async {
    await mockDataSource.simulateDelay();
    final data = Map<String, dynamic>.from(MockDataSource.transactionDetail);
    data['id'] = id;
    return TransactionDetailModel.fromJson(data);
  }
}
