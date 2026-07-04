import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/add_card.dart';

// Events
abstract class AddCardEvent extends Equatable {
  const AddCardEvent();

  @override
  List<Object?> get props => [];
}

class AddCardSubmitted extends AddCardEvent {
  final String cardholderName;
  final String cardNumber;
  final int expiryMonth;
  final int expiryYear;
  final String cardBrand;
  final String cardType;
  final String? alias;

  const AddCardSubmitted({
    required this.cardholderName,
    required this.cardNumber,
    required this.expiryMonth,
    required this.expiryYear,
    required this.cardBrand,
    required this.cardType,
    this.alias,
  });

  @override
  List<Object?> get props => [
        cardholderName,
        cardNumber,
        expiryMonth,
        expiryYear,
        cardBrand,
        cardType,
        alias,
      ];
}

// States
abstract class AddCardState extends Equatable {
  const AddCardState();

  @override
  List<Object?> get props => [];
}

class AddCardInitial extends AddCardState {}

class AddCardLoading extends AddCardState {}

class AddCardSuccess extends AddCardState {}

class AddCardFailure extends AddCardState {
  final String message;
  const AddCardFailure(this.message);

  @override
  List<Object?> get props => [message];
}

// Bloc
class AddCardBloc extends Bloc<AddCardEvent, AddCardState> {
  final AddCard addCard;

  AddCardBloc({required this.addCard}) : super(AddCardInitial()) {
    on<AddCardSubmitted>(_onAddCardSubmitted);
  }

  Future<void> _onAddCardSubmitted(
    AddCardSubmitted event,
    Emitter<AddCardState> emit,
  ) async {
    emit(AddCardLoading());
    try {
      await addCard(AddCardParams(
        cardholderName: event.cardholderName,
        cardNumber: event.cardNumber,
        expiryMonth: event.expiryMonth,
        expiryYear: event.expiryYear,
        cardBrand: event.cardBrand,
        cardType: event.cardType,
        alias: event.alias,
      ));
      emit(AddCardSuccess());
    } catch (e) {
      emit(AddCardFailure(e.toString().replaceFirst('Exception: ', '')));
    }
  }
}
