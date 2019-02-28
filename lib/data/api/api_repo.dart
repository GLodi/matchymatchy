import 'net_utils.dart';

import 'package:squazzle/data/models/models.dart';

abstract class ApiRepo {

}

class ApiRepoImpl implements ApiRepo {
  final NetUtils _net;

  ApiRepoImpl(this._net);
}