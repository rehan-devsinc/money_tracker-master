import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:money_tracker/controllers/filters_collapse_controller.dart';
import 'package:money_tracker/models/transaction.dart';
import 'package:money_tracker/screens/search_screen.dart';
import 'package:money_tracker/utils/collection_names.dart';
import 'package:money_tracker/widgets/transaction_card.dart';
import '../controllers/transaction_screen_amount_controller.dart';
import '../utils/global_constants.dart';
import '../models/category.dart';
import '../widgets/dropdown_button.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({Key? key}) : super(key: key);

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  DateTime? selectedStartDate;
  DateTime? selectedEndDate;
  String selectedCategory = "All Categories";

  final TransactionScreenAmountController amountController =
      TransactionScreenAmountController();

  final FiltersCollapseController collapseController =
      FiltersCollapseController();

  final bool streamBuilderLoaded = false;

  String? selectedPaymentMode = 'Both Payment Modes';

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final TextEditingController startTimeController = TextEditingController();

  final TextEditingController endTimeController = TextEditingController();

  final TextEditingController searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {

    print("total added cash is : ${amountController.totalAddedCash}");

    // print(amountController.totalAmountCard);
    // amountController.reset();
    return Scaffold(
      appBar: AppBar(
          title: const Text("Kitaab"),
          centerTitle: true,
          actions: [
            InkWell(
              onTap: () {
                Get.to(SearchScreen());
              },
              child: const Icon(
                Icons.search,
                color: Colors.white,
              ),
            ),
            const SizedBox(
              width: 20,
            )
          ]),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Form(
            key: formKey,
            child: Column(
              // mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(
                  height: 10,
                ),
                Obx(() => InkWell(
                      onTap: () {
                        collapseController.collapse.value =
                            !collapseController.collapse.value;
                      },
                      child: Row(
                        children: [
                          Text(collapseController.collapse.value
                              ? "Expand Filters"
                              : "Collapse Filters"),
                          const Icon(Icons.arrow_drop_down_sharp),
                        ],
                      ),
                    )),
                Obx(() => Container(
                      child: collapseController.collapse.value
                          ? const SizedBox()
                          : Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const SizedBox(
                                  height: 20,
                                ),
                                Row(
                                  children: [
                                    Expanded(
                                        child: TextFormField(
                                      controller: startTimeController,
                                      onTap: () async {
                                        selectedStartDate = await showDatePicker(
                                            context: context,
                                            initialDate: DateTime.now(),
                                            firstDate: DateTime(2020),
                                            lastDate: DateTime(2025));
                                        if (selectedStartDate != null) {
                                          startTimeController.text =
                                              DateFormat("dd-MM-yyyy")
                                                  .format(selectedStartDate!)
                                                  .toString();
                                          // setState(() {});
                                        }
                                      },

                                      validator: (value) {
                                        if (selectedStartDate == null) {
                                          return "field is required";
                                        }
                                        return null;
                                      },

                                      decoration: const InputDecoration(
                                          labelText: "Start Date",
                                          hintText: "Start Date",
                                          border: OutlineInputBorder(),
                                          focusedBorder: OutlineInputBorder(),
                                          disabledBorder: OutlineInputBorder(),
                                          enabledBorder: OutlineInputBorder(),
                                          isDense: true),
                                      maxLines: 1,
                                      readOnly: true,
                                      // enabled: false,
                                    )),
                                    const SizedBox(
                                      width: 20,
                                    ),
                                    Expanded(
                                        child: TextFormField(
                                      controller: endTimeController,
                                      onTap: () async {
                                        selectedEndDate = await showDatePicker(
                                            context: context,
                                            initialDate: DateTime.now(),
                                            firstDate: DateTime(2020),
                                            lastDate: DateTime(2025));
                                        if (selectedEndDate != null) {
                                          endTimeController.text =
                                              DateFormat("dd-MM-yyyy")
                                                  .format(selectedEndDate!)
                                                  .toString();
                                          // setState(() {});
                                        }
                                      },

                                      validator: (value) {
                                        if (selectedEndDate == null) {
                                          return "field is required";
                                        }
                                        return null;
                                      },

                                      decoration: const InputDecoration(
                                          labelText: "End Date",
                                          hintText: "End Date",
                                          border: OutlineInputBorder(),
                                          focusedBorder: OutlineInputBorder(),
                                          disabledBorder: OutlineInputBorder(),
                                          enabledBorder: OutlineInputBorder(),
                                          isDense: true),
                                      maxLines: 1,
                                      readOnly: true,
                                      // enabled: false,
                                    ))
                                  ],
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                TextFormField(
                                  controller: searchController,
                                  decoration: const InputDecoration(
                                      labelText: "Search",
                                      hintText: "Search",
                                      border: OutlineInputBorder(),
                                      focusedBorder: OutlineInputBorder(),
                                      disabledBorder: OutlineInputBorder(),
                                      enabledBorder: OutlineInputBorder(),
                                      isDense: true,

                                  ),
                                  maxLines: 1,
                                  // enabled: false,
                                ),
                                const SizedBox(
                                  height: 10,
                                ),

                                StreamBuilder(
                                    stream: FirebaseFirestore.instance
                                        .collection(Collections.categories)
                                        .orderBy('createdAt')
                                        .snapshots(),
                                    builder: (context,
                                        AsyncSnapshot<
                                                QuerySnapshot<
                                                    Map<String, dynamic>>>
                                            snapshot) {
                                      List<String> categories = [];

                                      final Map<String, Color> colorsMap = {};

                                      if ((snapshot.hasData) &&
                                          (!(snapshot.connectionState ==
                                              ConnectionState.waiting))) {
                                        categories = snapshot.data!.docs
                                            .map((DocumentSnapshot<
                                                        Map<String, dynamic>>
                                                    document) =>
                                                CategoryModel.fromMap(
                                                        document.data()!)
                                                    .title)
                                            .toList();
                                        categories.insert(0, "All Categories");

                                        for (var snapshot
                                            in snapshot.data!.docs) {
                                          CategoryModel model =
                                              CategoryModel.fromMap(
                                                  snapshot.data());
                                          colorsMap[model.title] =
                                              Color(model.colorCode)
                                                  .withOpacity(1);
                                        }
                                      }

                                      return MyDropDownButton(
                                        dropdownValue: selectedCategory,
                                        items: categories,
                                        function: (String v) {
                                          selectedCategory = v;
                                        },
                                        hintText: "Select Category",
                                        colorsMap: colorsMap,
                                      );
                                    }),
                                const SizedBox(
                                  height: 10,
                                ),
                                MyDropDownButton(
                                  dropdownValue: selectedPaymentMode,
                                  items: const [
                                    'Both Payment Modes',
                                    'cash',
                                    'card',
                                  ],
                                  function: (String v) {
                                    selectedPaymentMode = v;
                                  },
                                  hintText: "Select Payment Mode",
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                buttonsRow(),
                                const SizedBox(height: 10),
                                StreamBuilder(
                                  stream: (selectedStartDate == null || selectedEndDate == null)
                                      ? FirebaseFirestore.instance
                                      .collection(Collections.transactions)
                                      .orderBy("createdAt", descending: true)
                                      .snapshots()
                                      : FirebaseFirestore.instance
                                      .collection(Collections.transactions)
                                      .where("createdAt",
                                      isGreaterThanOrEqualTo: selectedStartDate,
                                      isLessThanOrEqualTo: selectedEndDate)
                                      .orderBy("createdAt", descending: true)
                                      .snapshots(),
                                  builder: (context, AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
                                    amountController.reset();
                                    if(snapshot.hasData && (!(snapshot.connectionState==ConnectionState.waiting)) ){
                                      int count = 0;
                                      for(int i=0; i< snapshot.data!.docs.length; i++){
                                        TransactionModel transaction = TransactionModel.fromMap(snapshot.data!.docs[i].data());
                                        if (((transaction.category == selectedCategory) ||
                                            selectedCategory.toLowerCase() ==
                                                'all categories') &&
                                            ((transaction.transactionType ==
                                                selectedPaymentMode) ||
                                                selectedPaymentMode!.toLowerCase() ==
                                                    'both payment modes')
                                            && (transaction.desc.toLowerCase().contains(searchController.text.toLowerCase()) || transaction.category.toLowerCase().contains(searchController.text.toLowerCase()))
                                        ){
                                          count++;
                                          // print("before transaction $count :");
                                          // print("total added cash: ${amountController.totalAddedCash}");
                                          // print("total withdraw cash: ${amountController.totalWithdrawCash}");
                                          // print("total added card: ${amountController.totalAddedCard}");
                                          // print("total withdraw card: ${amountController.totalWithdrawCard}");
                                          setAmounts(transaction);
                                          // print("after transaction $count :");
                                          // print("total added cash: ${amountController.totalAddedCash}");
                                          // print("total withdraw cash: ${amountController.totalWithdrawCash}");
                                          // print("total added card: ${amountController.totalAddedCard}");
                                          // print("total withdraw card: ${amountController.totalWithdrawCard}\n\n");


                                          // print("before transaction $count :");
                                          // // setAmounts(transaction);
                                          // print("after transaction $count :");





                                        }
                                      }
                                    }

                                    return Row(
                                      children: [
                                        Expanded(
                                            child: amountContainer(
                                          "Total Amount (Cash)",
                                          amountController.totalAmountCash.toString(),
                                          amountController.totalAddedCash.toString(),
                                          amountController.totalWithdrawCash
                                              .toString(),
                                        )),
                                        const SizedBox(
                                          width: 15,
                                        ),
                                        Expanded(
                                            child: amountContainer(
                                          "Total Amount (Card)",
                                          amountController.totalAmountCard.toString(),
                                          amountController.totalAddedCard.toString(),
                                          amountController.totalWithdrawCard
                                              .toString(),
                                        )),
                                      ],
                                    );
                                  }
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
                              ],
                            ),
                    )),
                const Text("Recent Transactions",
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.bold)),
                const SizedBox(
                  height: 10,
                ),
                StreamBuilder(
                    stream:  (selectedStartDate == null || selectedEndDate == null)
                            ? FirebaseFirestore.instance
                                .collection(Collections.transactions)
                                .orderBy("createdAt", descending: true)
                                .snapshots()
                            : FirebaseFirestore.instance
                                .collection(Collections.transactions)
                                .where("createdAt",
                                    isGreaterThanOrEqualTo: selectedStartDate,
                                    isLessThanOrEqualTo: selectedEndDate)
                                .orderBy("createdAt", descending: true)
                                .snapshots(),
                    builder: (context,
                        AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>>
                            snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(
                          child: Text("No Transactions to show"),
                        );
                      }

                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: Text("Loading Transactions"),
                        );
                      }

                      if (snapshot.data!.docs.isEmpty) {
                        return const Center(
                          child: Text("No Transactions to show"),
                        );
                      }

                      return ListView.builder(
                        shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: isAdmin ? snapshot.data!.size : 10,
                          itemBuilder: (context, index) {
                            TransactionModel transaction =
                                TransactionModel.fromMap(
                                    snapshot.data!.docs[index].data());
                            if (((transaction.category == selectedCategory) ||
                                    selectedCategory.toLowerCase() ==
                                        'all categories') &&
                                ((transaction.transactionType ==
                                        selectedPaymentMode) ||
                                    selectedPaymentMode!.toLowerCase() ==
                                        'both payment modes')
                                && (transaction.desc.toLowerCase().contains(searchController.text.toLowerCase()) || transaction.category.toLowerCase().contains(searchController.text.toLowerCase()))
                            ) {
                              // setAmounts(transaction);

                              return TransactionCard(
                                transactionModel: transaction,
                              );
                            }
                            return const SizedBox();
                          });
                    })
              ],
            ),
          ),
        ),
      ),
    );
  }

  void setAmounts(TransactionModel transaction) {
    if (transaction.transactionSign == '+') {
      if (transaction.transactionType == 'cash') {
        amountController.totalAmountCash = transaction.amount + amountController.totalAmountCash;
        amountController.totalAddedCash = transaction.amount + amountController.totalAddedCash;
      } else {
        amountController.totalAmountCard = amountController.totalAmountCard + transaction.amount;
        amountController.totalAddedCard = transaction.amount + amountController.totalAddedCard;
      }
    } else if (transaction.transactionSign == '-') {
      if (transaction.transactionType == 'cash') {
        amountController.totalAmountCash = amountController.totalAmountCash - transaction.amount;
        amountController.totalWithdrawCash = transaction.amount + amountController.totalWithdrawCash;
      } else {
        amountController.totalAmountCard = amountController.totalAmountCard - transaction.amount;
        amountController.totalWithdrawCard = transaction.amount + amountController.totalWithdrawCard;
      }
    }
  }

  Widget buttonsRow() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Expanded(
                child: ElevatedButton(
                    onPressed: () {
                      // if (formKey.currentState!.validate()) {
                      // }

                      amountController.reset();
                      setState(() {});
                    },
                    child: const Text("Apply"))),
            const SizedBox(
              width: 15,
            ),
            Expanded(
              child: ElevatedButton(
                  onPressed: () {
                    selectedEndDate = null;
                    selectedStartDate = null;
                    startTimeController.text = '';
                    endTimeController.text = '';
                    selectedCategory = 'All Categories';
                    selectedPaymentMode = 'Both Payment Modes';
                    setState(() {});
                  },
                  child: const Text("Reset")),
            )
          ],
        ),
        // const SizedBox(height: 10,),
        ///Users and Transaction Button
      ],
    );
  }

  Widget amountContainer(String title, String amount, String totalAdded, String totalWithdrawal) {
    return SizedBox(
      width: double.infinity,
      child: Material(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(title,
                  style: const TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.bold)),
              const SizedBox(
                height: 10,
              ),
              Text(
                amount,
                style: const TextStyle(
                    color: Colors.blue,
                    fontSize: 16,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(
                height: 10,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 8.0, right: 8),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Total Added:"),
                        const SizedBox(
                          width: 10,
                        ),
                        Text(
                          totalAdded,
                          style: const TextStyle(
                              color: Colors.green, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,

                      children: [
                        const Text("Total Withdrawn:"),
                        const SizedBox(
                          width: 10,
                        ),
                        Text(
                          totalWithdrawal,
                          style: const TextStyle(
                              color: Colors.red, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}