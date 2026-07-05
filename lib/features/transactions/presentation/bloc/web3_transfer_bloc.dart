import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

import '../../data/models/web3/user_search_model.dart';
import '../../data/models/web3/quote_model.dart';
import '../../data/models/web3/remittance_model.dart';
import '../../data/models/web3/timeline_model.dart';
import '../../data/datasources/web3_remote_datasource.dart';

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
  final String senderName;
  const ConfirmTransferEvent(this.senderName);
  @override
  List<Object?> get props => [senderName];
}

class LoadTimelineEvent extends Web3TransferEvent {
  final String remittanceId;
  const LoadTimelineEvent(this.remittanceId);
  @override
  List<Object?> get props => [remittanceId];
}

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
  final Web3TransferState? previousState;
  const TransferError(this.message, {this.previousState});
  @override
  List<Object?> get props => [message, previousState];
}

class Web3TransferBloc extends Bloc<Web3TransferEvent, Web3TransferState> {
  final Web3RemoteDataSource dataSource;

  UserSearchModel? _selectedUser;
  QuoteModel? _quote;
  RemittanceModel? _remittance;
  Timer? _pollingTimer;

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

  Future<void> _onSelectUser(SelectUserEvent event, Emitter<Web3TransferState> emit) async {
    try {
      final profile = await dataSource.fetchPublicProfile(event.user.id);
      _selectedUser = UserSearchModel(
        id: profile.id,
        email: profile.email,
        username: profile.username,
        firstName: profile.firstName,
        lastName: profile.lastName,
        phone: profile.phone,
        country: profile.country ?? event.user.country ?? 'US',
      );
      emit(TransferUserSelected(_selectedUser!));
    } catch (e) {
      _selectedUser = event.user.copyWithCountry(event.user.country ?? 'US');
      emit(TransferUserSelected(_selectedUser!));
    }
  }

  Future<void> _onRequestQuote(RequestQuoteEvent event, Emitter<Web3TransferState> emit) async {
    if (_selectedUser == null) return;
    emit(TransferQuoteLoading(_selectedUser!));
    try {
      _quote = await dataSource.createQuote(
        event.amountUSD,
        destinationCountry: _selectedUser!.country ?? 'US',
      );
      emit(TransferQuoteLoaded(_selectedUser!, _quote!));
    } catch (e) {
      emit(TransferError(e.toString(), previousState: TransferUserSelected(_selectedUser!)));
    }
  }

  Future<void> _onConfirmTransfer(ConfirmTransferEvent event, Emitter<Web3TransferState> emit) async {
    if (_selectedUser == null || _quote == null) return;
    final confirming = TransferConfirming(_selectedUser!, _quote!);
    emit(confirming);
    try {
      _remittance = await dataSource.createRemittance(
        _quote!.quoteId,
        _selectedUser!.id,
        null,
        null,
        event.senderName,
        _selectedUser!.fullName,
        'Apoyo desde App Móvil',
        recipientCountry: _selectedUser!.country ?? 'US',
      );

      await dataSource.confirmDeposit(_remittance!.remittanceId);

      emit(TransferTracking(_remittance!, null));
      add(LoadTimelineEvent(_remittance!.remittanceId));
      _startPolling(_remittance!.remittanceId);
    } catch (e) {
      emit(TransferError('Error confirming transfer: ${e.toString()}', previousState: confirming));
    }
  }

  void _startPolling(String remittanceId) {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (isClosed) return;
      add(LoadTimelineEvent(remittanceId));
    });
  }

  Future<void> _onLoadTimeline(LoadTimelineEvent event, Emitter<Web3TransferState> emit) async {
    if (_remittance == null) return;
    try {
      final timeline = await dataSource.getTimeline(event.remittanceId);
      emit(TransferTracking(_remittance!, timeline));

      final status = timeline.currentStatus.toUpperCase();
      if (status == 'COMPLETED' || status == 'FAILED' || status == 'CANCELLED') {
        _pollingTimer?.cancel();
      }
    } catch (e) {
      debugPrint('Error loading timeline: $e');
    }
  }

  @override
  Future<void> close() {
    _pollingTimer?.cancel();
    return super.close();
  }
}

extension on UserSearchModel {
  UserSearchModel copyWithCountry(String country) {
    return UserSearchModel(
      id: id,
      email: email,
      username: username,
      firstName: firstName,
      lastName: lastName,
      phone: phone,
      country: country,
    );
  }
}
