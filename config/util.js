"use strict";
module.exports = {
  /*
   Similiar to _.extend(), but do nested merge
   Leave here even grunt has it owns
   */

  _extend: function (target, source) {
    var next, original;
    for (var key in source) {
      original = target[key];
      next = source[key];
      if (original && next && Object.prototype.toString.apply(next) === "[object Object]") {
        module.exports._extend(original, next);
      } else {
        target[key] = next;
      }
    }
    return target;
  },

  _scope: function (config, unstrict) {
    var result = {
      private: {},
      public: {}
  };
    for (var key in config) {
      var isPrivate, isPublic, realKey;
      // without this ini'ion, all vars messup!
      isPrivate = isPublic = realKey = false;

      // Key processing
      var scope = key.substr(0, 1);
      if (scope === '_') {
        isPrivate = true;
        realKey = key.substr(1);
      }
      else if (scope === '$') {
        isPublic = true;
        realKey = key.substr(1);
      }
      else {
        realKey = key;
      }

      // Value processing
      if (Object.prototype.toString.apply(config[key]) === "[object Object]") {
        var tmp = module.exports._scope(config[key], unstrict);
        for (var k in tmp.public){
          result.public[realKey] = tmp.public;
          break;
        }
        result.private[realKey] = tmp.private;
      }
      else {
        if (isPublic || (unstrict && !isPrivate)) {
          result.public[realKey] = config[key];
        }
        result.private[realKey] = config[key];
      }
    }
    return result;
  }
}
