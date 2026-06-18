import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/send_bloc.dart';

class SendMoneyPage extends StatefulWidget {
  const SendMoneyPage({super.key});

  @override
  State<SendMoneyPage> createState() => _SendMoneyPageState();
}

class _SendMoneyPageState extends State<SendMoneyPage> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Send Money')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Select Recipient'),
            const SizedBox(height: 16),
            TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Search by name or phone',
              ),
              onChanged: (value) {
                context.read<SendBloc>().add(SearchContacts(value));
              },
            ),
            const SizedBox(height: 32),
            Expanded(
              child: BlocBuilder<SendBloc, SendState>(
                builder: (context, state) {
                  if (state is SendLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (state is SendError) {
                    return Center(child: Text(state.message));
                  }
                  if (state is SendLoaded) {
                    if (state.contacts.isEmpty) {
                      return const Center(
                        child: Text('Type at least 2 characters to search users'),
                      );
                    }
                    return ListView.builder(
                      itemCount: state.contacts.length,
                      itemBuilder: (context, index) {
                        final contact = state.contacts[index];
                        return ListTile(
                          leading: const CircleAvatar(child: Icon(Icons.person)),
                          title: Text(contact.name),
                          subtitle: Text(contact.phone),
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Selected ${contact.name}. Quote flow coming soon.'),
                              ),
                            );
                          },
                        );
                      },
                    );
                  }
                  return const Center(
                    child: Text('Type at least 2 characters to search users'),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
