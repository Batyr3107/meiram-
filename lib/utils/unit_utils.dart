String getRussianUnit(String unit, double quantity) {
  final int q = quantity.floor();
  switch (unit.toUpperCase()) {
    case 'KG':
      if (q % 10 == 1 && q % 100 != 11) return 'килограмм';
      if (q % 10 >= 2 && q % 10 <= 4 && (q % 100 < 10 || q % 100 >= 20)) return 'килограмма';
      return 'килограммов';

    case 'LITER':
      if (q % 10 == 1 && q % 100 != 11) return 'литр';
      if (q % 10 >= 2 && q % 10 <= 4 && (q % 100 < 10 || q % 100 >= 20)) return 'литра';
      return 'литров';

    case 'PIECE':
      if (q % 10 == 1 && q % 100 != 11) return 'штука';
      if (q % 10 >= 2 && q % 10 <= 4 && (q % 100 < 10 || q % 100 >= 20)) return 'штуки';
      return 'штук';

    case 'PACK':
      if (q % 10 == 1 && q % 100 != 11) return 'упаковка';
      if (q % 10 >= 2 && q % 10 <= 4 && (q % 100 < 10 || q % 100 >= 20)) return 'упаковки';
      return 'упаковок';

    case 'BOX':
      if (q % 10 == 1 && q % 100 != 11) return 'коробка';
      if (q % 10 >= 2 && q % 10 <= 4 && (q % 100 < 10 || q % 100 >= 20)) return 'коробки';
      return 'коробок';

    default:
      return unit.toLowerCase();
  }
}

String getRussianProductWord(int count) {
  if (count % 10 == 1 && count % 100 != 11) return 'товар';
  if (count % 10 >= 2 && count % 10 <= 4 && (count % 100 < 10 || count % 100 >= 20)) return 'товара';
  return 'товаров';
}