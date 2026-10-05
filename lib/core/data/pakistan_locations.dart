class PakistanLocationData {
  static const Map<String, List<String>> provinceCityMap = {
    'Punjab': [
      'Lahore', 'Faisalabad', 'Rawalpindi', 'Multan', 'Gujranwala',
      'Sialkot', 'Bahawalpur', 'Sargodha', 'Sheikhupura', 'Jhang',
      'Rahim Yar Khan', 'Kasur', 'Gujrat', 'Sahiwal', 'Okara',
      'Vehari', 'Chiniot', 'Kamoke', 'Hafizabad', 'Kot Adu'
    ],
    'Sindh': [
      'Karachi', 'Hyderabad', 'Sukkur', 'Larkana', 'Nawabshah',
      'Mirpur Khas', 'Jacobabad', 'Shikarpur', 'Khairpur', 'Dadu',
      'Tando Adam', 'Tando Allahyar', 'Umerkot', 'Thatta', 'Badin'
    ],
    'Khyber Pakhtunkhwa': [
      'Peshawar', 'Mardan', 'Mingora', 'Kohat', 'Abbottabad',
      'Dera Ismail Khan', 'Nowshera', 'Charsadda', 'Swabi', 'Mansehra',
      'Bannu', 'Timargara', 'Parachinar', 'Hangu', 'Karak'
    ],
    'Balochistan': [
      'Quetta', 'Khuzdar', 'Turbat', 'Chaman', 'Hub',
      'Sibi', 'Zhob', 'Gwadar', 'Dera Murad Jamali', 'Dera Allah Yar',
      'Usta Muhammad', 'Loralai', 'Pasni', 'Kharan', 'Mastung'
    ],
    'Islamabad Capital Territory': [
      'Islamabad'
    ],
    'Gilgit-Baltistan': [
      'Gilgit', 'Skardu', 'Chilas', 'Gahkuch', 'Aliabad',
      'Shigar', 'Khaplu', 'Juglot', 'Astore', 'Danyor'
    ],
    'Azad Jammu & Kashmir': [
      'Muzaffarabad', 'Mirpur', 'Rawalakot', 'Kotli', 'Bhimber',
      'Bagh', 'Sudhanoti', 'Hattian', 'Haveli', 'Neelum'
    ]
  };

  static List<String> get provinces => provinceCityMap.keys.toList();

  static List<String> getCitiesForProvince(String? province) {
    if (province == null || !provinceCityMap.containsKey(province)) {
      return [];
    }
    return provinceCityMap[province]!;
  }
}
