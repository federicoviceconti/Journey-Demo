import 'package:flutter/material.dart';
import 'package:journey_demo/common/text/bold_text.dart';
import 'package:journey_demo/common/widget/underline_widget.dart';
import 'package:journey_demo/common/widget/base_widget.dart';
import 'package:journey_demo/common/widget/border_button.dart';
import 'package:journey_demo/notifier/create_ev_notifier.dart';
import 'package:provider/provider.dart';

class CreateYourEvWidget extends StatefulWidget {
  @override
  _CreateYourEvWidgetState createState() => _CreateYourEvWidgetState();
}

class _CreateYourEvWidgetState extends State<CreateYourEvWidget> {

  @override
  Widget build(BuildContext context) {
    return BaseWidget(
      safeArea: true,
      child: _buildBody(),
      loadingBundle: Provider.of<CreateEvNotifier>(context).loadingBundle,
    );
  }

  _buildBody() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: [
          _buildForm(),
          _buildButton(),
        ],
      ),
    );
  }

  _buildForm() {
    return Consumer<CreateEvNotifier>(builder: (_, notifier, __) {
      return Expanded(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 16),
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Icon(
                  Icons.arrow_back_ios,
                  color: Colors.deepOrangeAccent,
                ),
              ),
              SizedBox(height: 16),
              BoldText(
                "Create your EV",
                fontSize: 32,
                color: Colors.deepOrange,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: notifier.nameController,
                decoration: InputDecoration(
                  hintText: "Input your ev name...",
                  labelText: "Name",
                ),
                onChanged: (value) => notifier.onFieldChange(),
              ),
              SizedBox(height: 16),
              UnderlineWidget(
                controller: notifier.selectEvController,
                title: "Select your EV *",
                onTap: () => notifier.goToSelectEv(),
              )
            ],
          ),
        ),
      );
    });
  }

  _buildButton() {
    return Consumer<CreateEvNotifier>(
      builder: (_, notifier, ___) {
        return Column(
          children: [
            BorderButton(
              onTap: () => notifier.onNextTap(),
              width: double.infinity,
              enable: notifier.isEnableButton,
              child: BoldText(
                "Continue",
                align: TextAlign.center,
              ),
            ),
            SizedBox(height: 16),
          ],
        );
      },
    );
  }
}
