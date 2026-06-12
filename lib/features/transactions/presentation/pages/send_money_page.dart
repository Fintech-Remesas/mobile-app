import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/send_bloc.dart';

class SendMoneyPage extends StatelessWidget {
  const SendMoneyPage({super.key});

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
            const TextField(decoration: InputDecoration(hintText: 'Search by name or phone')),
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
                              const SnackBar(
                                content: Text('Selected. Implement Send flow.'),
                              ),
                            );
                          },
                        );
                      },
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
