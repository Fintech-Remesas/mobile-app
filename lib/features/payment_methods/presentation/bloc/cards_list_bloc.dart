import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/payment_card.dart';
import '../../domain/usecases/delete_card.dart';
import '../../domain/usecases/get_cards.dart';

// Events
abstract class CardsListEvent extends Equatable {
  const CardsListEvent();

  @override
  List<Object?> get props => [];
}

class LoadCards extends CardsListEvent {}

class DeleteCardRequested extends CardsListEvent {
  final String id;
  const DeleteCardRequested(this.id);

  @override
  List<Object?> get props => [id];
}

// States
abstract class CardsListState extends Equatable {
  const CardsListState();

  @override
  List<Object?> get props => [];
}

class CardsListInitial extends CardsListState {}

class CardsListLoading extends CardsListState {}

class CardsListLoaded extends CardsListState {
  final List<PaymentCard> cards;
  const CardsListLoaded(this.cards);

  @override
  List<Object?> get props => [cards];
}

class CardsListFailure extends CardsListState {
  final String message;
  const CardsListFailure(this.message);

  @override
  List<Object?> get props => [message];
}

class CardDeleteSuccess extends CardsListState {}

class CardDeleteFailure extends CardsListState {
  final String message;
  const CardDeleteFailure(this.message);

  @override
  List<Object?> get props => [message];
}

// Bloc
class CardsListBloc extends Bloc<CardsListEvent, CardsListState> {
  final GetCards getCards;
  final DeleteCard deleteCard;

  CardsListBloc({
    required this.getCards,
    required this.deleteCard,
  }) : super(CardsListInitial()) {
    on<LoadCards>(_onLoadCards);
    on<DeleteCardRequested>(_onDeleteCardRequested);
  }

  Future<void> _onLoadCards(
    LoadCards event,
    Emitter<CardsListState> emit,
  ) async {
    emit(CardsListLoading());
    try {
      final cards = await getCards();
      emit(CardsListLoaded(cards));
    } catch (e) {
      emit(CardsListFailure(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<void> _onDeleteCardRequested(
    DeleteCardRequested event,
    Emitter<CardsListState> emit,
  ) async {
    try {
      await deleteCard(event.id);
      emit(CardDeleteSuccess());
      add(LoadCards());
    } catch (e) {
      emit(CardDeleteFailure(e.toString().replaceFirst('Exception: ', '')));
      add(LoadCards()); // Reload anyway to ensure state is consistent
    }
  }
}
