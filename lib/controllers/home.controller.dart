import 'package:mobx/mobx.dart';

import 'package:contact_app/models/contact.model.dart';
import 'package:contact_app/repositories/contact.repository.dart';
part 'home.controller.g.dart';

class HomeController = _HomeController with _$HomeController;

abstract class _HomeController with Store {
  @observable
  bool showSearch = false;

  @observable
  ObservableList<ContactModel> contacts = new ObservableList<ContactModel>();

  @action
  toggleSearch() {
    showSearch = !showSearch;
  }

  @action
  search(String term) async {
    final repository = new ContactRepository();
    contacts = new ObservableList<ContactModel>();

    var data = await repository.search(term);
    contacts.addAll(data);
  }
}
