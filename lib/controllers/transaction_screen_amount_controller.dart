import 'package:get/get.dart';

class TransactionScreenAmountController {
  double totalAmountCash = 0.0;
  double totalAmountCard = 0.0;
  double totalAddedCash = 0.0;
  double totalWithdrawCash = 0.0;
  double totalAddedCard = 0.0;
  double totalWithdrawCard = 0.0;

  reset(){
    totalAmountCash = 0.0;
    totalAmountCard = 0.0;
    totalAddedCash = 0.0;
    totalWithdrawCash = 0.0;
    totalAddedCard = 0.0;
    totalWithdrawCard = 0.0;
  }

}