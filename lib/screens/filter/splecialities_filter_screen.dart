import 'package:boldo/constants.dart';
import 'package:boldo/models/Specialization.dart';
import 'package:boldo/widgets/wrapper.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../network/http.dart';

class SpecialitiesFilterScreen extends StatefulWidget {
  const SpecialitiesFilterScreen({Key key}) : super(key: key);

  @override
  _SpecialitiesFilterScreenState createState() =>
      _SpecialitiesFilterScreenState();
}

class _SpecialitiesFilterScreenState extends State<SpecialitiesFilterScreen> {
  TextEditingController _searchController = TextEditingController();
  String searchValue = "";

  List<Specialization> specializationsList = [];
  List<Specialization> filteredSpecializationsList = [];
  bool _loading = true;
  @override
  void initState() {
    _searchController.addListener(_searchInputChange);
    _setFilterData();

    super.initState();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _setFilterData() async {
    try {
      Response response = await dio.get("/specializations");
      List<Specialization> specializationsListModel = List<Specialization>.from(
          response.data.map((i) => Specialization.fromJson(i)));
      setState(() {
        specializationsList = specializationsListModel;
        filteredSpecializationsList = specializationsListModel;
        _loading = false;
      });
    } on DioError catch (err) {
      print(err);
    } catch (err) {
      print(err);
    }
  }

  void _searchInputChange() {
    if (searchValue != _searchController.text) {
      List<Specialization> newFilteredItems =
          specializationsList.where((element) {
        if (element.description
            .toLowerCase()
            .contains(_searchController.text.toLowerCase().trim())) {
          return true;
        }

        return false;
      }).toList();

      setState(() {
        filteredSpecializationsList = _searchController.text == ""
            ? specializationsList
            : newFilteredItems;
        searchValue = _searchController.text;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leadingWidth: 200,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child:
              SvgPicture.asset('assets/Logo.svg', semanticsLabel: 'BOLDO Logo'),
        ),
      ),
      body: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      textCapitalization: TextCapitalization.sentences,
                      controller: _searchController,
                      decoration: InputDecoration(
                        suffixIcon: GestureDetector(
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
                        hintText: "Search Specialities",
                        prefixIcon: const Icon(
                          Icons.search,
                          color: Constants.extraColor300,
                        ),
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: filteredSpecializationsList.length,
                        itemBuilder: (BuildContext context, int index) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (index.isOdd)
                                Container(
                                    height: 1, color: Constants.extraColor200),
                              SpecialziationWidget(
                                specialization:
                                    filteredSpecializationsList[index],
                              ),
                              if (index.isOdd &&
                                  index + 1 !=
                                      filteredSpecializationsList.length)
                                Container(
                                    height: 1, color: Constants.extraColor200),
                            ],
                          );
                        },
                      ),
                    )
                  ],
                ),
              ),
      ),
    );
  }
}

class SpecialziationWidget extends StatelessWidget {
  final Specialization specialization;
  const SpecialziationWidget({Key key, @required this.specialization})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
      child: Text(
        "${specialization.description}",
        textAlign: TextAlign.start,
      ),
    );
  }
}
