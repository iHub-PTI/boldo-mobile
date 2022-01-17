import 'package:boldo/constants.dart';
import 'package:boldo/models/Specialization.dart';
import 'package:boldo/provider/utils_provider.dart';
import 'package:provider/provider.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import '../../network/http.dart';

class SpecialitiesFilterScreen extends StatefulWidget {
  const SpecialitiesFilterScreen({Key? key}) : super(key: key);

  @override
  _SpecialitiesFilterScreenState createState() =>
      _SpecialitiesFilterScreenState();
}

class _SpecialitiesFilterScreenState extends State<SpecialitiesFilterScreen> {
  TextEditingController _searchController = TextEditingController();
  String searchValue = "";

  FocusNode _focusNode = FocusNode();

  //we use this in order to hide the keyboard when we are clicking on "done" inside the textfield.
  bool _remove = false;

  List<Specialization> specializationsList = [];
  List<Specialization> filteredSpecializationsList = [];
  List<Specialization> selectedSpecializationsList = [];

  bool _loading = true;

  @override
  void initState() {
    _searchController.addListener(_searchInputChange);
    _setFilterData();
    _focusNode.addListener(() {
      if (_remove) {
        FocusScope.of(context).unfocus();
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _setFilterData() async {
    try {
      Response response = await dio.get("/specializations");
      List<Specialization> specializationsListModel = List<Specialization>.from(
          response.data.map((i) => Specialization.fromJson(i)));

      List<Specialization> selectedSpecializations =
          Provider.of<UtilsProvider>(context, listen: false)
              .getListOfSpecializations;
      List<String?> listOfSpecializationIds =
          selectedSpecializations.map((e) => e.id).toList();
      List<Specialization> filteredSpecializaions = specializationsListModel
          .where((element) => !listOfSpecializationIds.contains(element.id))
          .toList();
      setState(() {
        selectedSpecializationsList = selectedSpecializations;
        specializationsList = specializationsListModel;
        filteredSpecializationsList = filteredSpecializaions;
        _loading = false;
      });
    } on DioError catch (exception, stackTrace) {
      print(exception);
      await Sentry.captureException(
        exception,
        stackTrace: stackTrace,
      );
    } catch (exception, stackTrace) {
      print(exception);
      await Sentry.captureException(
        exception,
        stackTrace: stackTrace,
      );
    }
  }

  void _searchInputChange() {
    if (searchValue != _searchController.text) {
      List<Specialization> newFilteredItems =
          specializationsList.where((element) {
        if (element.description!
                .toLowerCase()
                .contains(_searchController.text.toLowerCase().trim()) &&
            !selectedSpecializationsList.any((el) => el.id == element.id)) {
          return true;
        }

        return false;
      }).toList();

      setState(() {
        filteredSpecializationsList = newFilteredItems;
        searchValue = _searchController.text;
      });
    }
  }

  void onRemoveSelected({required Specialization specialization}) {
    _searchController.text = "";
    setState(() {
      selectedSpecializationsList = selectedSpecializationsList
          .where((element) => element.id != specialization.id)
          .toList();
      filteredSpecializationsList = [
        ...filteredSpecializationsList,
        specialization
      ];
      searchValue = _searchController.text;
    });
  }

  void onTapFiltered({required String specializationId}) {
    _searchController.text = "";
    setState(() {
      selectedSpecializationsList = [
        ...selectedSpecializationsList,
        ...filteredSpecializationsList
            .where((element) => element.id == specializationId)
            .toList()
      ];
      filteredSpecializationsList = filteredSpecializationsList
          .where((element) => element.id != specializationId)
          .toList();
      searchValue = _searchController.text;
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Provider.of<UtilsProvider>(context, listen: false)
            .setListOfSpecializations(
                selectedFilters: selectedSpecializationsList);
        return true;
      },
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: SizedBox(
              width: MediaQuery.of(context).size.width,
              child: _loading
                  ? const Center(
                      child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                          Constants.primaryColor400),
                      backgroundColor: Constants.primaryColor600,
                    ))
                  : Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextField(
                            focusNode: _focusNode,
                            textCapitalization: TextCapitalization.sentences,
                            controller: _searchController,
                            decoration: InputDecoration(
                              suffixIcon: _searchController.text == ""
                                  ? GestureDetector(
                                      onTap: () {
                                        Provider.of<UtilsProvider>(context,
                                                listen: false)
                                            .setListOfSpecializations(
                                                selectedFilters:
                                                    selectedSpecializationsList);
                                        _remove = true;
                                        FocusScope.of(context).unfocus();
                                        Navigator.of(context).pop();
                                      },
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          const Padding(
                                            padding:
                                                EdgeInsets.only(right: 16.0),
                                            child: Text("Listo"),
                                          ),
                                        ],
                                      ),
                                    )
                                  : GestureDetector(
                                      onTap: () {
                                        _searchController.text = "";
                                      },
                                      child: const Icon(
                                        Icons.close,
                                        color: Constants.extraColor300,
                                      ),
                                    ),
                              contentPadding:
                                  const EdgeInsets.only(top: 20, bottom: 20),
                              hintText: "Buscar Especialidades",
                              prefixIcon: const Icon(
                                Icons.search,
                                color: Constants.extraColor300,
                              ),
                            ),
                          ),
                          Expanded(
                            child: ListView.builder(
                              itemCount: _searchController.text == ""
                                  ? filteredSpecializationsList.length +
                                      selectedSpecializationsList.length
                                  : filteredSpecializationsList.length,
                              itemBuilder: (BuildContext context, int index) {
                                if (_searchController.text == "" &&
                                    selectedSpecializationsList.isNotEmpty) {
                                  if (index == 0) {
                                    return Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Padding(
                                          padding: EdgeInsets.only(
                                              left: 8.0, bottom: 7, top: 7),
                                          child: Text(
                                            "Especialidades Seleccionadas",
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        SpecialziationWidget(
                                          isSelected: true,
                                          onRemoveCallback: (specialization) {
                                            onRemoveSelected(
                                                specialization: specialization);
                                          },
                                          index: index,
                                          onTapCallback: (string) {
                                            onTapFiltered(
                                                specializationId: string);
                                          },
                                          specializations:
                                              selectedSpecializationsList,
                                        )
                                      ],
                                    );
                                  } else if (index <
                                      selectedSpecializationsList.length) {
                                    return SpecialziationWidget(
                                      isSelected: true,
                                      onRemoveCallback: (specialization) {
                                        onRemoveSelected(
                                            specialization: specialization);
                                      },
                                      index: index,
                                      onTapCallback: (string) {
                                        onTapFiltered(specializationId: string);
                                      },
                                      specializations:
                                          selectedSpecializationsList,
                                    );
                                  }
                                }
                                if (index ==
                                        selectedSpecializationsList.length &&
                                    _searchController.text == "")
                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Padding(
                                        padding: EdgeInsets.only(
                                            left: 8.0, bottom: 7, top: 7),
                                        child: Text(
                                          "Especialidades",
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      SpecialziationWidget(
                                        isSelected: false,
                                        hideLine: true,
                                        index: index,
                                        onTapCallback: (string) {
                                          onTapFiltered(
                                              specializationId: string);
                                        },
                                        specializations:
                                            filteredSpecializationsList,
                                      ),
                                    ],
                                  );
                                if (filteredSpecializationsList.length >
                                    index) {
                                  return SpecialziationWidget(
                                    isSelected: false,
                                    index: index,
                                    onTapCallback: (string) {
                                      onTapFiltered(specializationId: string);
                                    },
                                    specializations:
                                        filteredSpecializationsList,
                                  );
                                }
                                return const SizedBox();
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

class SpecialziationWidget extends StatelessWidget {
  final bool isSelected;
  final bool hideLine;
  final int index;
  final List<Specialization> specializations;
  final void Function(String specializationId)? onTapCallback;
  final void Function(Specialization)? onRemoveCallback;

  const SpecialziationWidget({
    Key? key,
    required this.specializations,
    this.onTapCallback,
    this.hideLine = false,
    this.onRemoveCallback,
    required this.isSelected,
    required this.index,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (isSelected) return;

        onTapCallback!(specializations[index].id!);
      },
      child: Container(
        color: Colors.transparent,
        width: double.infinity,
        child: Column(
          children: [
            if (index.isOdd && !hideLine)
              Container(height: 1, color: Constants.extraColor200),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      "${specializations[index].description}",
                      textAlign: TextAlign.start,
                    ),
                  ),
                  Opacity(
                    opacity: isSelected ? 1 : 0,
                    child: IconButton(
                      icon: const Icon(
                        Icons.close,
                        color: Constants.extraColor300,
                      ),
                      onPressed: () {
                        if (!isSelected) return;
                        onRemoveCallback!(specializations[index]);
                      },
                    ),
                  )
                ],
              ),
            ),
            if (index.isOdd && index + 1 != specializations.length)
              Container(height: 1, color: Constants.extraColor200),
          ],
        ),
      ),
    );
  }
}
