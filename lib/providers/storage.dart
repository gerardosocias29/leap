import 'package:localstorage/localstorage.dart';

class StorageProvider {

  userStorage() {
    final LocalStorage storage = LocalStorage('userStorage');
    return storage;
  }

  commonDataStorage() {
    final LocalStorage storage = LocalStorage('common_data');
    return storage;
  }

  storageAddItem(LocalStorage storage, item, value){
    storage.setItem(item, value);
  }

  storageGetItem(LocalStorage storage, item){
    return storage.getItem(item);
  }

  storageRemoveItem(LocalStorage storage, item){
    storage.deleteItem(item);
  }
}