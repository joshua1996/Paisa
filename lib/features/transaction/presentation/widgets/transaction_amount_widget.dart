import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_simple_calculator/flutter_simple_calculator.dart';
import 'package:go_router/go_router.dart';

import 'package:paisa/core/common.dart';
import 'package:paisa/features/transaction/presentation/bloc/transaction_bloc.dart';
import 'package:paisa/core/widgets/paisa_widget.dart';

class TransactionAmountWidget extends StatefulWidget {
  const TransactionAmountWidget({
    super.key,
    required this.controller,
  });

  final TextEditingController controller;

  @override
  State<TransactionAmountWidget> createState() =>
      _TransactionAmountWidgetState();
}

class _TransactionAmountWidgetState extends State<TransactionAmountWidget> {
  FocusNode focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    print('object');
    // focusNode.addListener(() {
    //   if (focusNode.hasFocus) {
    //     // showCalculator(context, widget.controller, focusNode);
    //     print('object');
    //   }
    // });
    // WidgetsBinding.instance.addPostFrameCallback((_) async {
    //   showCalculator(context, widget.controller, focusNode);
    // });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: PaisaTextFormField(
        controller: widget.controller,
        focusNode: focusNode,
        autofocus: true,
        hintText: context.loc.amount,
        keyboardType: TextInputType.none,
        maxLength: 13,
        maxLines: 1,
        counterText: '',
        inputFormatters: <TextInputFormatter>[
          FilteringTextInputFormatter.allow(RegExp(r"[0-9.]")),
          TextInputFormatter.withFunction((oldValue, newValue) {
            try {
              final text = newValue.text;
              if (text.isNotEmpty) double.parse(text);
              return newValue;
            } catch (_) {}
            return oldValue;
          }),
        ],
        onChanged: (value) {
          double? amount = double.tryParse(value);
          BlocProvider.of<TransactionBloc>(context).transactionAmount = amount;
        },
        validator: (value) {
          if (value!.isNotEmpty) {
            return null;
          } else {
            return context.loc.validAmount;
          }
        },
        onTap: () {
          showCalculator(context, widget.controller, focusNode);
        },
      ),
    );
  }
}

Future<void> showCalculator(BuildContext context,
    TextEditingController controller, FocusNode focusNode) async {
  var calc = SimpleCalculator(
    value: controller.text == '' ? 0 : double.parse(controller.text),
    hideExpression: false,
    hideSurroundingBorder: true,
    autofocus: true,
    onChanged: (key, value, expression) {
      if (kDebugMode) {
        print('$key\t$value\t$expression');
      }
      if (key == '=') {
        double? amount = double.tryParse(value?.toString() ?? '0');
        BlocProvider.of<TransactionBloc>(context).transactionAmount = amount;
        controller.text = value.toString();
        context.pop();
      }
    },
    // onTappedDisplay: (value, details) {
    //   if (kDebugMode) {
    //     print('$value\t${details.globalPosition}');
    //   }
    // },
  );
  showModalBottomSheet(
    isScrollControlled: true,
    context: context,
    builder: (BuildContext context) {
      return SizedBox(
          height: MediaQuery.of(context).size.height * 0.40, child: calc);
    },
  );
  // if (context.mounted) {
  //   FocusScope.of(context).requestFocus(FocusNode());
  // }
}
