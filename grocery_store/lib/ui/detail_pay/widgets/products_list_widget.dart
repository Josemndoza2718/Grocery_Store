import 'package:flutter/material.dart';
import 'package:grocery_store/core/resource/colors.dart';
import 'package:intl/intl.dart';

class PaymentInPartsWidget extends StatelessWidget {
  final int itemCount;
  final double price;
  PaymentInPartsWidget({
    super.key,
    required this.itemCount,
    required this.price,
  });

  int number = 1;
  DateTime hoy = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.transparent,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Container(
        height: 250, //530,
        width: double.infinity,
        color: AppColors.transparent,
        child: ListView.separated(
          //physics: const NeverScrollableScrollPhysics(),
          itemCount: itemCount,
          separatorBuilder: (context, index) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  width: 16,
                  color: AppColors.transparent,
                  child: Column(
                    spacing: 4,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        height: 8,
                        width: 2,
                        color: AppColors.darkgreen,
                      ),
                      Container(
                        height: 8,
                        width: 2,
                        color: AppColors.darkgreen,
                      ),
                      Container(
                        height: 8,
                        width: 2,
                        color: AppColors.darkgreen,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          itemBuilder: (context, index) => Container(
            color: AppColors.transparent,
            child: Row(
              spacing: 8,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  height: 30,
                  width: 30,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: AppColors.darkgreen,
                  ),
                  child: Center(
                    child: Text(
                      "${number++}",
                      style: const TextStyle(
                        color: AppColors.white,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
                Text(
                  DateFormat('dd/MM/yyyy')
                      .format(hoy.add(Duration(days: 15 * index))),
                  style: const TextStyle(
                    color: AppColors.black,
                    fontSize: 14,
                  ),
                ),
                const Spacer(),
                Text("${price / itemCount}\$",
                    style: const TextStyle(
                      color: AppColors.black,
                      fontSize: 14,
                    )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
