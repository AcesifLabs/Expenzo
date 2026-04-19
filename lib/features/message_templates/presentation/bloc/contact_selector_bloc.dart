import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../sms_parser/data/datasources/sms_local_datasource.dart';
import 'contact_selector_event.dart';
import 'contact_selector_state.dart';

class ContactSelectorBloc
    extends Bloc<ContactSelectorEvent, ContactSelectorState> {
  final SmsLocalDatasource smsDatasource;

  int _currentOffset = 0;
  final int _batchSize = 200;
  final Map<String, DeviceContact> _contactsMap = {};

  ContactSelectorBloc({required this.smsDatasource})
    : super(ContactSelectorInitial()) {
    on<LoadContacts>(_onLoadContacts);
    on<LoadMoreContacts>(_onLoadMoreContacts);
  }

  Future<void> _onLoadContacts(
    LoadContacts event,
    Emitter<ContactSelectorState> emit,
  ) async {
    emit(ContactSelectorLoading());
    _currentOffset = 0;
    _contactsMap.clear();

    try {
      final messages = await smsDatasource.getSmsBatched(
        start: _currentOffset,
        count: _batchSize,
      );

      _processMessages(messages);

      final sortedContacts = _contactsMap.values.toList()
        ..sort((a, b) => b.lastMessageDate.compareTo(a.lastMessageDate));

      emit(
        ContactSelectorLoaded(
          contacts: sortedContacts,
          hasReachedMax: messages.length < _batchSize,
        ),
      );

      _currentOffset += messages.length;
    } catch (e) {
      emit(ContactSelectorError(message: e.toString()));
    }
  }

  Future<void> _onLoadMoreContacts(
    LoadMoreContacts event,
    Emitter<ContactSelectorState> emit,
  ) async {
    final currentState = state;
    if (currentState is! ContactSelectorLoaded) return;
    if (currentState.hasReachedMax || currentState.isLoadingMore) return;

    emit(currentState.copyWith(isLoadingMore: true));

    try {
      final messages = await smsDatasource.getSmsBatched(
        start: _currentOffset,
        count: _batchSize,
      );

      if (messages.isEmpty) {
        emit(currentState.copyWith(hasReachedMax: true, isLoadingMore: false));
        return;
      }

      _processMessages(messages);

      final sortedContacts = _contactsMap.values.toList()
        ..sort((a, b) => b.lastMessageDate.compareTo(a.lastMessageDate));

      emit(
        ContactSelectorLoaded(
          contacts: sortedContacts,
          hasReachedMax: messages.length < _batchSize,
          isLoadingMore: false,
        ),
      );

      _currentOffset += messages.length;
    } catch (e) {
      emit(ContactSelectorError(message: e.toString()));
    }
  }

  void _processMessages(List<dynamic> messages) {
    for (final msg in messages) {
      if (!_contactsMap.containsKey(msg.address)) {
        _contactsMap[msg.address] = DeviceContact(
          address: msg.address,
          displayName: msg.address,
          lastMessage: msg.body,
          lastMessageDate: msg.date,
          sourceType: 'sms',
        );
      } else {
        final existing = _contactsMap[msg.address]!;
        if (msg.date.isAfter(existing.lastMessageDate)) {
          _contactsMap[msg.address] = DeviceContact(
            address: msg.address,
            displayName: msg.address,
            lastMessage: msg.body,
            lastMessageDate: msg.date,
            sourceType: 'sms',
          );
        }
      }
    }
  }
}
