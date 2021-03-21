enum PlugType {
  type2,
  chademo,
  ccs,
  type1,
  none,
}

extension StringPlugTypeExtension on String {
  PlugType get type {
    switch (this) {
      case 'type1':
        return PlugType.type1;
      case 'type2':
      case 'tesla_suc':
        return PlugType.type2;
      case 'chademo':
        return PlugType.chademo;
      case 'ccs':
      case 'tesla_ccs':
        return PlugType.ccs;
    }

    print(this);
    return PlugType.none;
  }

  PlugType get cuType {
    final lowerType = this.toLowerCase();

    if (lowerType.contains("type 1")) {
      return PlugType.type1;
    } else if (lowerType.contains("type 2")) {
      return PlugType.type2;
    } else if (lowerType.contains("chademo")) {
      return PlugType.chademo;
    } else if (lowerType.contains("ccs")) {
      return PlugType.ccs;
    } else if (lowerType.contains("tesla")) {
      return PlugType.ccs;
    } else {
      return PlugType.none;
    }
  }
}

extension PlugTypeExtensionImage on PlugType {
  String get svg => {
        PlugType.type1: 'type1',
        PlugType.type2: 'type2',
        PlugType.chademo: 'chademo',
        PlugType.ccs: 'ccs',
      }[this];

  String get name => {
        PlugType.type1: 'Type 1',
        PlugType.type2: 'Type 2',
        PlugType.chademo: 'CHADEMO',
        PlugType.ccs: 'CCS',
      }[this];
}
