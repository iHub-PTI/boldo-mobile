import 'package:boldo/blocs/organization_bloc/organization_bloc.dart';
import 'package:boldo/models/Organization.dart';
import 'package:boldo/models/Patient.dart';
import 'package:boldo/widgets/loading.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ConfirmRequest extends StatelessWidget {

  ConfirmRequest({
    required this.organizationsSelected,
    required this.patientSelected,
  });
  final Patient patientSelected;
  final List<Organization> organizationsSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          BlocBuilder<OrganizationBloc, OrganizationBlocState>(
            builder: (context, state) {
              return ElevatedButton(
                onPressed: organizationsSelected.isEmpty ||
                    (state is Loading )
                    ? null
                    : () {
                  BlocProvider.of<OrganizationBloc>(context).add(
                    SubscribeToAnManyOrganizations(
                      organizations: organizationsSelected,
                      patientSelected: patientSelected,
                      context: context,
                    ),
                  );
                },
                child: Container(
                  child: (state is Loading ) ?
                  loadingStatus() :
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Solicitar${organizationsSelected.isNotEmpty
                            ? '(${organizationsSelected.length})'
                            : ''}',
                      ),
                      const SizedBox(
                        width: 8,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

}