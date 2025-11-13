import 'dart:math';

import 'package:flutter/material.dart';
import 'package:test_1/theme/app_colors.dart';

class CalculatorPage extends StatefulWidget {
  const CalculatorPage({super.key});

  @override
  State<CalculatorPage> createState() => _CalculatorPageState();
}

class _CalculatorPageState extends State<CalculatorPage> {
  String _display = '0';
  // full expression string (infix), e.g. "12+32+2^2+sqrt(9)"
  String _exprStr = '';
  bool _inputtingNumber = false;
  bool _shouldClear = false;

  void _num(String n) {
    setState(() {
      if (_shouldClear || _display == '0') {
        _display = n;
        _shouldClear = false;
        if (!_inputtingNumber) _exprStr = '';
      } else {
        _display += n;
      }
      _exprStr += n;
      _inputtingNumber = true;
    });
  }

  void _dot() {
    if (!_display.contains('.'))
      setState(() {
        _display += '.';
        _exprStr += '.';
        _inputtingNumber = true;
      });
  }

  void _replaceTrailingNumber(String newVal) {
    final m = RegExp(r'(\d+\.?\d*)$').firstMatch(_exprStr);
    if (m != null) {
      _exprStr = _exprStr.substring(0, m.start) + newVal;
    } else {
      _exprStr += newVal;
    }
  }

  String _stripZeros(double v) {
    final s = v.toString();
    return s.replaceAll(RegExp(r"\.0+"), '');
  }

  void _clear() {
    setState(() {
      _display = '0';
      _exprStr = '';
      _inputtingNumber = false;
      _shouldClear = false;
    });
  }

  void _setOp(String operator) {
    setState(() {
      if (_display.isNotEmpty) {
        _display = '';
      }
      if (_exprStr.isEmpty && operator == '-') {
        _exprStr = '-';
        _display = '-';
        _inputtingNumber = true;
        return;
      }
      if (_exprStr.isNotEmpty) {
        final last = _exprStr.characters.last;
        if (RegExp(r'[+\-*/^]').hasMatch(last)) {
          _exprStr = _exprStr.substring(0, _exprStr.length - 1) + operator;
        } else {
          _exprStr += operator;
        }
      }
      _shouldClear = false;
      _inputtingNumber = false;
    });
  }

  void _sqrt() {
    setState(() {
      final m = RegExp(r'(\d+\.?\d*)$').firstMatch(_exprStr);
      if (m != null) {
        final numStr = m.group(0)!;
        final before = _exprStr.substring(0, m.start);
        _exprStr = '$before' + 'sqrt($numStr)';
        final val = double.tryParse(numStr) ?? 0.0;
        final res = val >= 0 ? sqrt(val) : double.nan;
        _display = _stripZeros(res);
        _shouldClear = true;
        _inputtingNumber = false;
      } else {
        _exprStr += 'sqrt(';
        _inputtingNumber = false;
      }
    });
  }

  void _eq() {
    try {
      final result = _evaluateExpression(_exprStr);
      setState(() {
        _display = _stripZeros(result);
        _exprStr = '';
        _shouldClear = true;
        _inputtingNumber = false;
      });
    } catch (e) {
      setState(() {
        _display = 'Error';
        _shouldClear = true;
      });
    }
  }

  double _evaluateExpression(String expr) {
    final tokens = <String>[];
    final regex = RegExp(r"sqrt|\d+\.?\d*|[+\-*/^(),]");
    for (final m in regex.allMatches(expr)) tokens.add(m.group(0)!);

    final out = <String>[];
    final ops = <String>[];

    int prec(String op) {
      if (op == '+' || op == '-') return 1;
      if (op == '*' || op == '/') return 2;
      if (op == '^') return 3;
      return 0;
    }
    bool isLeftAssoc(String op) => op != '^';

    for (final t in tokens) {
      if (RegExp(r"^\d").hasMatch(t)) {
        out.add(t);
      } else if (t == 'sqrt') {
        ops.add(t);
      } else if (t == ',') {
        while (ops.isNotEmpty && ops.last != '(') out.add(ops.removeLast());
      } else if (RegExp(r'[+\-*/^]').hasMatch(t)) {
        while (ops.isNotEmpty && RegExp(r'[+\-*/^]').hasMatch(ops.last)) {
          final o2 = ops.last;
          if ((isLeftAssoc(t) && prec(t) <= prec(o2)) || (!isLeftAssoc(t) && prec(t) < prec(o2))) {
            out.add(ops.removeLast());
            continue;
          }
          break;
        }
        ops.add(t);
      } else if (t == '(') {
        ops.add(t);
      } else if (t == ')') {
        while (ops.isNotEmpty && ops.last != '(') out.add(ops.removeLast());
        if (ops.isNotEmpty && ops.last == '(') ops.removeLast();
        if (ops.isNotEmpty && ops.last == 'sqrt') out.add(ops.removeLast());
      }
    }
    while (ops.isNotEmpty) out.add(ops.removeLast());

    final stack = <double>[];
    for (final t in out) {
      if (RegExp(r"^\d").hasMatch(t)) {
        stack.add(double.parse(t));
      } else if (t == 'sqrt') {
        final a = stack.removeLast();
        stack.add(sqrt(a));
      } else if (RegExp(r'[+\-*/^]').hasMatch(t)) {
        final b = stack.removeLast();
        final a = stack.removeLast();
        switch (t) {
          case '+':
            stack.add(a + b);
            break;
          case '-':
            stack.add(a - b);
            break;
          case '*':
            stack.add(a * b);
            break;
          case '/':
            stack.add(a / b);
            break;
          case '^':
            stack.add(pow(a, b).toDouble());
            break;
        }
      }
    }
    return stack.isNotEmpty ? stack.last : 0.0;
  }

  String _formatExprForShow() {
    // insert spaces around operators and functions for readability
    var s = _exprStr.replaceAllMapped(RegExp(r'([+\-*/^()])'), (m) => ' ${m[0]} ');
    s = s.replaceAll('  ', ' ');
    return s.trim();
  }

  void _backspace() {
    setState(() {
      if (_exprStr.isEmpty) {
        _display = '0';
        _inputtingNumber = false;
        return;
      }
      _exprStr = _exprStr.substring(0, _exprStr.length - 1);
      final m = RegExp(r'(\d+\.?\d*)$').firstMatch(_exprStr);
      if (m != null) {
        _display = m.group(0)!;
        _inputtingNumber = true;
      } else if (_exprStr.isEmpty) {
        _display = '0';
        _inputtingNumber = false;
      } else {
        _display = '0';
        _inputtingNumber = false;
      }
    });
  }

  void _toggleSignTrailingNumber() {
    setState(() {
      final m = RegExp(r'(-?)(\d+\.?\d*)$').firstMatch(_exprStr);
      if (m != null) {
        final sign = m.group(1)!;
        final num = m.group(2)!;
        final before = _exprStr.substring(0, m.start);
        if (sign == '-') {
          _exprStr = before + num;
          _display = num;
        } else {
          _exprStr = before + '-' + num;
          _display = '-' + num;
        }
        _inputtingNumber = true;
      } else if (_exprStr.isEmpty) {
        _exprStr = '-';
        _display = '-';
        _inputtingNumber = true;
      }
    });
  }

  Widget _button(String label, {Color? color, void Function()? onTap}) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(6.0),
        child: ElevatedButton(
          onPressed: onTap,
          style: ElevatedButton.styleFrom(
            backgroundColor: color ?? Theme.of(context).colorScheme.surface,
            foregroundColor: color != null ? Colors.white : null,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            padding: const EdgeInsets.symmetric(vertical: 18),
          ),
          child: Text(label, style: const TextStyle(fontSize: 20)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
           // Combined Card: expression (small) on top, main display below
           Card(
             elevation: 2,
             clipBehavior: Clip.hardEdge,
             child: Container(
               width: double.infinity,
               padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
               child: Column(
                 crossAxisAlignment: CrossAxisAlignment.stretch,
                 children: [
                   // expression area (keeps shape when empty)
                   Container(
                     constraints: const BoxConstraints(minHeight: 44, minWidth: 120),
                     padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                     alignment: Alignment.centerRight,
                     child: AnimatedSwitcher(
                       duration: const Duration(milliseconds: 300),
                       transitionBuilder: (child, animation) {
                         final fade = CurvedAnimation(parent: animation, curve: Curves.easeInOutCubic);
                         return FadeTransition(
                           opacity: fade,
                           child: SlideTransition(
                             position: Tween<Offset>(begin: const Offset(0, -0.15), end: Offset.zero).animate(fade),
                             child: child,
                           ),
                         );
                       },
                       child: _exprStr.isNotEmpty
                           ? Text(
                               _formatExprForShow(),
                               key: ValueKey(_exprStr),
                               style: Theme.of(context).textTheme.bodySmall,
                             )
                           : const SizedBox(key: ValueKey('empty_expr'), width: 1, height: 1),
                     ),
                   ),
                   const SizedBox(height: 6),
                   // main display
                   Container(
                     padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 8),
                     child: Text(_display, textAlign: TextAlign.right, style: const TextStyle(fontSize: 36)),
                   ),
                 ],
               ),
             ),
           ),
          // backspace aligned to the right under the display
          Row(
            children: [
              const Expanded(child: SizedBox()),
              IconButton(onPressed: _backspace, icon: const Icon(Icons.backspace)),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: Column(
              children: [
                // extra function row: sqrt and power
                Row(children: [
                  _button('√', color: AppColors.primary, onTap: _sqrt),
                  _button('^', color: AppColors.primary, onTap: () => _setOp('^')),
                  _button('%', onTap: () {
                    // percent of current display
                    setState(() {
                      final v = double.tryParse(_display) ?? 0.0;
                      _display = (v / 100).toString().replaceAll(RegExp(r"\.0+"), '');
                      _replaceTrailingNumber(_display);
                    });
                  }),
                  _button('C', color: Colors.grey, onTap: _clear),
                ]),
                Row(children: [
                  _button('7', onTap: () => _num('7')),
                  _button('8', onTap: () => _num('8')),
                  _button('9', onTap: () => _num('9')),
                  _button('/', color: AppColors.primary, onTap: () => _setOp('/')),
                ]),
                Row(children: [
                  _button('4', onTap: () => _num('4')),
                  _button('5', onTap: () => _num('5')),
                  _button('6', onTap: () => _num('6')),
                  _button('*', color: AppColors.primary, onTap: () => _setOp('*')),
                ]),
                Row(children: [
                  _button('1', onTap: () => _num('1')),
                  _button('2', onTap: () => _num('2')),
                  _button('3', onTap: () => _num('3')),
                  _button('-', color: AppColors.primary, onTap: () => _setOp('-')),
                ]),
                Row(children: [
                  _button('0', onTap: () => _num('0')),
                  _button('.', onTap: _dot),
                  _button('±', onTap: () {
                    _toggleSignTrailingNumber();
                  }),
                  _button('+', color: AppColors.primary, onTap: () => _setOp('+')),
                ]),
                Row(children: [
                  _button('=', color: AppColors.success, onTap: _eq),
                ]),
              ],
            ),
          )
        ],
      ),
    );
  }
}
