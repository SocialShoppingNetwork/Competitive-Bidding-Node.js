module.exports = function (grunt) {
  grunt.registerTask("config", "Generate configuration file base on NODE_ENV"
    , function () {
      var filePath = '.tmp/scripts/config.js';
      var config = require('../../config').public;
      var content = 'window.config=' + JSON.stringify(config);
      grunt.file.write(filePath, content);
    });
};

