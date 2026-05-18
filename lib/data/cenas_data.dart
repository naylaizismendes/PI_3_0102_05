import '../models/cena.dart';
import 'h15_cenas.dart';
import 'biblioteca_cenas.dart';
import 'cta_cenas.dart';
import 'lab_a_cenas.dart';
import 'lab_b_cenas.dart';
import 'auditorio_cenas.dart';

class CenasData {
  static final Map<int, Cena> cenas = {
    ...H15Cenas.cenas,
    ...BibliotecaCenas.cenas,
    ...CTACenas.cenas,
    ...LabACenas.cenas,
    ...LabBCenas.cenas,
    ...AuditorioCenas.cenas,
  };

  static Cena? getCena(int id) {
    return cenas[id];
  }
}
