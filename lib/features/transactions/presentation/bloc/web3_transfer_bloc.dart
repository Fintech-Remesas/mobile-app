import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

import '../../data/models/web3/user_search_model.dart';
import '../../data/models/web3/quote_model.dart';
import '../../data/models/web3/remittance_model.dart';
import '../../data/models/web3/timeline_model.dart';
import '../../data/datasources/web3_remote_datasource.dart';

// Events
abstract class Web3TransferEvent extends Equatable {
  const Web3TransferEvent();

  @override
  List<Object?> get props => [];
}

class SearchUsersEvent extends Web3TransferEvent {
  final String query;
  const SearchUsersEvent(this.query);
  @override
  List<Object?> get props => [query];
}

class SelectUserEvent extends Web3TransferEvent {
  final UserSearchModel user;
  const SelectUserEvent(this.user);
  @override
  List<Object?> get props => [user];
}

class RequestQuoteEvent extends Web3TransferEvent {
  final double amountUSD;
  const RequestQuoteEvent(this.amountUSD);
  @override
  List<Object?> get props => [amountUSD];
}

class ConfirmTransferEvent extends Web3TransferEvent {
  const ConfirmTransferEvent();
}

class LoadTimelineEvent extends Web3TransferEvent {
  final String remittanceId;
  const LoadTimelineEvent(this.remittanceId);
  @override
  List<Object?> get props => [remittanceId];
}

// States
abstract class Web3TransferState extends Equatable {
  const Web3TransferState();

  @override
  List<Object?> get props => [];
}

class TransferInitial extends Web3TransferState {}

class TransferSearchLoading extends Web3TransferState {}

class TransferSearchLoaded extends Web3TransferState {
  final List<UserSearchModel> users;
  const TransferSearchLoaded(this.users);
  @override
  List<Object?> get props => [users];
}

class TransferUserSelected extends Web3TransferState {
  final UserSearchModel selectedUser;
  const TransferUserSelected(this.selectedUser);
  @override
  List<Object?> get props => [selectedUser];
}

class TransferQuoteLoading extends Web3TransferState {
  final UserSearchModel selectedUser;
  const TransferQuoteLoading(this.selectedUser);
  @override
  List<Object?> get props => [selectedUser];
}

class TransferQuoteLoaded extends Web3TransferState {
  final UserSearchModel selectedUser;
  final QuoteModel quote;
  const TransferQuoteLoaded(this.selectedUser, this.quote);
  @override
  List<Object?> get props => [selectedUser, quote];
}

class TransferConfirming extends Web3TransferState {
  final UserSearchModel selectedUser;
  final QuoteModel quote;
  const TransferConfirming(this.selectedUser, this.quote);
  @override
  List<Object?> get props => [selectedUser, quote];
}

class TransferTracking extends Web3TransferState {
  final RemittanceModel remittance;
  final TimelineModel? timeline;
  const TransferTracking(this.remittance, this.timeline);
  @override
  List<Object?> get props => [remittance, timeline];
}

class TransferError extends Web3TransferState {
  final String message;
  const TransferError(this.message);
  @override
  List<Object?> get props => [message];
}

// Bloc
class Web3TransferBloc extends Bloc<Web3TransferEvent, Web3TransferState> {
  final Web3RemoteDataSource dataSource;

  UserSearchModel? _selectedUser;
  QuoteModel? _quote;
  RemittanceModel? _remittance;

  UserSearchModel? get selectedUser => _selectedUser;
  QuoteModel? get quote => _quote;
  RemittanceModel? get remittance => _remittance;

  Web3TransferBloc({required this.dataSource}) : super(TransferInitial()) {
    on<SearchUsersEvent>(_onSearchUsers);
    on<SelectUserEvent>(_onSelectUser);
    on<RequestQuoteEvent>(_onRequestQuote);
    on<ConfirmTransferEvent>(_onConfirmTransfer);
    on<LoadTimelineEvent>(_onLoadTimeline);
  }

  Future<void> _onSearchUsers(SearchUsersEvent event, Emitter<Web3TransferState> emit) async {
    emit(TransferSearchLoading());
    try {
      final users = await dataSource.searchUsers(event.query);
      emit(TransferSearchLoaded(users));
    } catch (e) {
      emit(TransferError(e.toString()));
    }
  }

  void _onSelectUser(SelectUserEvent event, Emitter<Web3TransferState> emit) {
    _selectedUser = event.user;
    emit(TransferUserSelected(event.user));
  }

  Future<void> _onRequestQuote(RequestQuoteEvent event, Emitter<Web3TransferState> emit) async {
    if (_selectedUser == null) return;
    emit(TransferQuoteLoading(_selectedUser!));
    try {
      _quote = await dataSource.createQuote(event.amountUSD);
      emit(TransferQuoteLoaded(_selectedUser!, _quote!));
    } catch (e) {
      emit(TransferError(e.toString()));
    }
  }

  Future<void> _onConfirmTransfer(ConfirmTransferEvent event, Emitter<Web3TransferState> emit) async {
    if (_selectedUser == null || _quote == null) return;
    emit(TransferConfirming(_selectedUser!, _quote!));
    try {
      // Step 1: Create Remittance
      // Note: We need mock wallet data if real one isn't available for destination
      final mockWalletAddress = "0x3D7E4B8F9C1A2E5D6F0B3C8A9E4D1F2B5C7A0E3";
      final mockBankAccountId = "5d2795c3-769b-45b3-9f0c-9b697db829e2"; // Real mock provided by user

      _remittance = await dataSource.createRemittance(
        _quote!.quoteId,
        _selectedUser!.id,
        mockBankAccountId,
        mockWalletAddress,
        "Apoyo desde App Móvil"
      );

      // Step 2: Confirm Deposit immediately as requested
      await dataSource.confirmDeposit(_remittance!.remittanceId);

      // Transition to Tracking state
      emit(TransferTracking(_remittance!, null));

      // Trigger timeline load
      add(LoadTimelineEvent(_remittance!.remittanceId));

    } catch (e) {
      emit(TransferError("Error confirming transfer: ${e.toString()}"));
    }
  }

  Future<void> _onLoadTimeline(LoadTimelineEvent event, Emitter<Web3TransferState> emit) async {
    if (_remittance == null) return;
    try {
      final timeline = await dataSource.getTimeline(event.remittanceId);
      emit(TransferTracking(_remittance!, timeline));
    } catch (e) {
      debugPrint("Error loading timeline: $e");
      // Don't emit generic error, just retain tracking state without timeline or show snackbar
      // But we can emit a new state if needed.
    }
  }
}
