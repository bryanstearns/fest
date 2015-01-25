# encoding: utf-8
module Countries
  def self.code_to_name(code)
    CODE_TO_NAME.fetch(code, "")
  end

  def self.name_to_code(name)
    NAME_TO_CODE.fetch(name, "")
  end

  # Names can't have commas in them
  CODE_TO_NAME = {
    'af' => "Afghanistan",
    'ax' => "Åland Islands",
    'al' => "Albania",
    'dz' => "Algeria",
    'as' => "American Samoa",
    'ad' => "Andorra",
    'ao' => "Angola",
    'ai' => "Anguilla",
    'aq' => "Antarctica",
    'ag' => "Antigua and Barbuda", # And -> and
    'ar' => "Argentina",
    'am' => "Armenia",
    'aw' => "Aruba",
    'au' => "Australia",
    'at' => "Austria",
    'az' => "Azerbaijan",
    'bs' => "Bahamas",
    'bh' => "Bahrain",
    'bd' => "Bangladesh",
    'bb' => "Barbados",
    'by' => "Belarus",
    'be' => "Belgium",
    'bz' => "Belize",
    'bj' => "Benin",
    'bm' => "Bermuda",
    'bt' => "Bhutan",
    'bo' => "Bolivia", # Bolivia, Plurinational State Of",
    'ba' => "Bosnia and Herzegovina", # And -> and
    'bw' => "Botswana",
    'bv' => "Bouvet Island",
    'br' => "Brazil",
    'io' => "British Indian Ocean Territory",
    'bn' => "Brunei Darussalam",
    'bg' => "Bulgaria",
    'bf' => "Burkina Faso",
    'bi' => "Burundi",
    'kh' => "Cambodia",
    'cm' => "Cameroon",
    'ca' => "Canada",
    'cv' => "Cape Verde",
    'ky' => "Cayman Islands",
    'cf' => "Central African Republic",
    'td' => "Chad",
    'cl' => "Chile",
    'cn' => "China",
    'cx' => "Christmas Island",
    'cc' => "Cocos (Keeling) Islands", # "Cocos (keeling) Islands"
    'co' => "Colombia",
    'km' => "Comoros",
    'cg' => "Congo",
    'cd' => "Congo", # "Congo, The Democratic Republic Of The",
    'ck' => "Cook Islands",
    'cr' => "Costa Rica",
    'ci' => "CÔte d'Ivoire", # "CÔte D'ivoire"
    'hr' => "Croatia",
    'cu' => "Cuba",
    'cy' => "Cyprus",
    'cz' => "Czech Republic",
    'dk' => "Denmark",
    'dj' => "Djibouti",
    'dm' => "Dominica",
    'do' => "Dominican Republic",
    'ec' => "Ecuador",
    'eg' => "Egypt",
    'sv' => "El Salvador",
    'gq' => "Equatorial Guinea",
    'er' => "Eritrea",
    'ee' => "Estonia",
    'et' => "Ethiopia",
    'fk' => "Falkland Islands (Malvinas)", # "Falkland Islands (malvinas)"
    'fo' => "Faroe Islands",
    'fj' => "Fiji",
    'fi' => "Finland",
    'fr' => "France",
    'gf' => "French Guiana",
    'pf' => "French Polynesia",
    'tf' => "French Southern Territories",
    'ga' => "Gabon",
    'gm' => "Gambia",
    'ge' => "Georgia",
    'de' => "Germany",
    'gh' => "Ghana",
    'gi' => "Gibraltar",
    'gr' => "Greece",
    'gl' => "Greenland",
    'gd' => "Grenada",
    'gp' => "Guadeloupe",
    'gu' => "Guam",
    'gt' => "Guatemala",
    'gg' => "Guernsey",
    'gn' => "Guinea",
    'gw' => "Guinea-Bissau", # "Guinea-bissau"
    'gy' => "Guyana",
    'ht' => "Haiti",
    'hm' => "Heard Island and McDonald Islands", # "Heard Island And Mcdonald Islands"
    'va' => "Vatican", # "Holy See (vatican City State)"
    'hn' => "Honduras",
    'hk' => "Hong Kong",
    'hu' => "Hungary",
    'is' => "Iceland",
    'in' => "India",
    'id' => "Indonesia",
    'ir' => "Iran", # "Iran, Islamic Republic Of"
    'iq' => "Iraq",
    'ie' => "Ireland",
    'il' => "Israel",
    'it' => "Italy",
    'jm' => "Jamaica",
    'jp' => "Japan",
    'je' => "Jersey",
    'jo' => "Jordan",
    'kz' => "Kazakhstan",
    'ke' => "Kenya",
    'ki' => "Kiribati",
    'kp' => "North Korea", # "Korea, Democratic People's Republic Of"
    'kr' => "South Korea", # "Korea, Republic Of"
    'kw' => "Kuwait",
    'kg' => "Kyrgyzstan",
    'la' => "Lao People's Democratic Republic",
    'lv' => "Latvia",
    'lb' => "Lebanon",
    'ls' => "Lesotho",
    'lr' => "Liberia",
    'ly' => "Libya",
    'li' => "Liechtenstein",
    'lt' => "Lithuania",
    'lu' => "Luxembourg",
    'mo' => "Macao",
    'mk' => "Macedonia", # "Macedonia, The Former Yugoslav Republic Of"
    'mg' => "Madagascar",
    'mw' => "Malawi",
    'my' => "Malaysia",
    'mv' => "Maldives",
    'ml' => "Mali",
    'mt' => "Malta",
    'mh' => "Marshall Islands",
    'mq' => "Martinique",
    'mr' => "Mauritania",
    'mu' => "Mauritius",
    'yt' => "Mayotte",
    'mx' => "Mexico",
    'fm' => "Micronesia", # "Micronesia, Federated States Of"
    'md' => "Moldova", # "Moldova, Republic Of"
    'mc' => "Monaco",
    'mn' => "Mongolia",
    'me' => "Montenegro",
    'ms' => "Montserrat",
    'ma' => "Morocco",
    'mz' => "Mozambique",
    'mm' => "Myanmar",
    'na' => "Namibia",
    'nr' => "Nauru",
    'np' => "Nepal",
    'nl' => "Netherlands",
    'nc' => "New Caledonia",
    'nz' => "New Zealand",
    'ni' => "Nicaragua",
    'ne' => "Niger",
    'ng' => "Nigeria",
    'nu' => "Niue",
    'nf' => "Norfolk Island",
    'mp' => "Northern Mariana Islands",
    'no' => "Norway",
    'om' => "Oman",
    'pk' => "Pakistan",
    'pw' => "Palau",
    'ps' => "Palestine", # "Palestinian Territory", # "Palestinian Territory, Occupied"
    'pa' => "Panama",
    'pg' => "Papua New Guinea",
    'py' => "Paraguay",
    'pe' => "Peru",
    'ph' => "Philippines",
    'pn' => "Pitcairn",
    'pl' => "Poland",
    'pt' => "Portugal",
    'pr' => "Puerto Rico",
    'qa' => "Qatar",
    're' => "Réunion", # "RÉunion"
    'ro' => "Romania",
    'ru' => "Russia", # "Russian Federation"
    'rw' => "Rwanda",
    'bl' => "Saint Barthélemy", # "Saint BarthÉlemy"
    'sh' => "Saint Helena, Ascension and Tristan Da Cunha", # And -> and
    'kn' => "Saint Kitts and Nevis", # And -> and
    'lc' => "Saint Lucia",
    'mf' => "Saint Martin", # "Saint Martin (french Part)"
    'pm' => "Saint Pierre and Miquelon", # And -> and
    'vc' => "Saint Vincent and The Grenadines", # And -> and
    'ws' => "Samoa",
    'sm' => "San Marino",
    'st' => "Sao Tome and Principe", # And -> and
    'sa' => "Saudi Arabia",
    'sn' => "Senegal",
    'rs' => "Serbia",
    'sc' => "Seychelles",
    'sl' => "Sierra Leone",
    'sg' => "Singapore",
    'sk' => "Slovakia",
    'si' => "Slovenia",
    'sb' => "Solomon Islands",
    'so' => "Somalia",
    'za' => "South Africa",
    'gs' => "South Georgia and the South Sandwich Islands", # And The -> and the
    'es' => "Spain",
    'lk' => "Sri Lanka",
    'sd' => "Sudan",
    'sr' => "Suriname",
    'sj' => "Svalbard and Jan Mayen", # And -> and
    'sz' => "Swaziland",
    'se' => "Sweden",
    'ch' => "Switzerland",
    'sy' => "Syrian Arab Republic",
    'tw' => "Taiwan", # "Taiwan, Province Of China"
    'tj' => "Tajikistan",
    'tz' => "Tanzania", # "Tanzania, United Republic Of"
    'th' => "Thailand",
    'tl' => "Timor-leste",
    'tg' => "Togo",
    'tk' => "Tokelau",
    'to' => "Tonga",
    'tt' => "Trinidad and Tobago", # And -> and
    'tn' => "Tunisia",
    'tr' => "Turkey",
    'tm' => "Turkmenistan",
    'tc' => "Turks and Caicos Islands", # And -> and
    'tv' => "Tuvalu",
    'ug' => "Uganda",
    'ua' => "Ukraine",
    'ae' => "United Arab Emirates",
    'gb' => "United Kingdom",
    'us' => "United States",
    # commenting this because I've never seen it and it leads to typos
    # um' => "United States Minor Outlying Islands",
    'uy' => "Uruguay",
    'uz' => "Uzbekistan",
    'vu' => "Vanuatu",
    've' => "Venezuela", # "Venezuela, Bolivarian Republic Of",
    'vn' => "Viet Nam",
    'vg' => "British Virgin Islands", # "Virgin Islands, British"
    'vi' => "U.S. Virgin Islands", # "Virgin Islands, U.S."
    'wf' => "Wallis and Futuna", # And -> and
    'eh' => "Western Sahara",
    'ye' => "Yemen",
    'zm' => "Zambia",
    'zw' => "Zimbabwe"
  }
  NAME_TO_CODE = CODE_TO_NAME.invert

  # The list of country codes, sorted alphabetically by country label
  NAMES = NAME_TO_CODE.keys.sort
  CODES = CODE_TO_NAME.keys.sort_by {|code| CODE_TO_NAME[code] }

  module Helpers
    def flags(countries)
      return nil if countries.blank?
      safe_join(countries.split(' ').map do |country|
        name = Countries.code_to_name(country)
        image_tag("blank.gif", class: "flag-icon flag-icon-#{country}",
                  alt: name, title: name)
      end)
    end
    def country_names(countries)
      return nil if countries.blank?
      countries.split(' ').map {|country| Countries.code_to_name(country) }\
                          .join(", ")
    end
  end
end
