angular.module "ngLocale", [], ["$provide", ($provide) ->
  PLURAL_CATEGORY =
    ZERO: "zero"
    ONE: "one"
    TWO: "two"
    FEW: "few"
    MANY: "many"
    OTHER: "other"
  localeObject =
    DATETIME_FORMATS:
      MONTH: [
        "tammikuuta"
        "helmikuuta"
        "maaliskuuta"
        "huhtikuuta"
        "toukokuuta"
        "kesäkuuta"
        "heinäkuuta"
        "elokuuta"
        "syyskuuta"
        "lokakuuta"
        "marraskuuta"
        "joulukuuta"]
      SHORTMONTH: [
        "tammikuuta"
        "helmikuuta"
        "maaliskuuta"
        "huhtikuuta"
        "toukokuuta"
        "kesäkuuta"
        "heinäkuuta"
        "elokuuta"
        "syyskuuta"
        "lokakuuta"
        "marraskuuta"
        "joulukuuta"
      ]
      DAY: [
        "sunnuntaina"
        "maanantaina"
        "tiistaina"
        "keskiviikkona"
        "torstaina"
        "perjantaina"
        "lauantaina"
      ]
      SHORTDAY: [
        "su"
        "ma"
        "ti"
        "ke"
        "to"
        "pe"
        "la"
      ]
      AMPMS: [
        "ap."
        "ip."
      ]
      medium: "d.M.yyyy H.mm.ss"
      short: "d.M.yyyy H.mm"
      fullDate: "cccc d. MMMM y"
      longDate: "d. MMMM y"
      mediumDate: "d.M.yyyy"
      shortDate: "d.M.yyyy"
      mediumTime: "H.mm.ss"
      shortTime: "H.mm"

    NUMBER_FORMATS:
      DECIMAL_SEP: ","
      GROUP_SEP: " "
      PATTERNS: [
        minInt: 1
        minFrac: 0
        macFrac: 0
        posPre: ""
        posSuf: ""
        negPre: "-"
        negSuf: ""
        gSize: 3
        lgSize: 3
        maxFrac: 3
      ,
        minInt: 1
        minFrac: 2
        macFrac: 0
        posPre: ""
        posSuf: " ¤"
        negPre: "-"
        negSuf: " ¤"
        gSize: 3
        lgSize: 3
        maxFrac: 2
      ]
      CURRENCY_SYM: "€"

    pluralCat: (n) ->
      return PLURAL_CATEGORY.ONE  if n is 1
      PLURAL_CATEGORY.OTHER

    id: "fi"
  $provide.value "$locale", localeObject

]
