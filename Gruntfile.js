'use strict';
var lrSnippet = require('grunt-contrib-livereload/lib/utils').livereloadSnippet;
var mountFolder = function (connect, dir) {
  return connect.static(require('path').resolve(dir));
};

module.exports = function (grunt) {
  // load all grunt tasks
  require('matchdep').filterDev('grunt-*').concat(['gruntacular']).forEach(grunt.loadNpmTasks);

  grunt.loadTasks('task/config');
  grunt.initConfig({
    yeoman: {
      app: 'app',
      dist: 'dist'
    },
    s3: {
      options: {
        key: 'AKIAJCAXW2LKY2RXOFAA',
        secret: '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',
        bucket: 'exhibia-test',
        access: 'public-read'
      },
      upload: [
        {
          //debug: true,
          key: 'AKIAJCAXW2LKY2RXOFAA',
          secret: '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',
          bucket: 'exhibia-test',
          access: 'public-read',
          src: '<%= yeoman.dist %>/*',
          dest: '/'
        },
        {
          //debug: true,
          key: 'AKIAJCAXW2LKY2RXOFAA',
          secret: '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',
          bucket: 'exhibia-test',
          access: 'public-read',
          src: '<%= yeoman.dist %>/image/*',
          dest: '/image/'
        }
      ]
    },
    server: 'server',
    watch: {
      coffee: {
        files: ['<%= yeoman.app %>/scripts/**/*.coffee'],
        tasks: ['coffee:dist']
      },
      coffeeTest: {
        files: ['test/**/*.coffee'],
        tasks: ['coffee:test']
      },
      compass: {
        files: ['<%= yeoman.app %>/styles/*.{scss,sass}'],
        tasks: ['compass']
      },
      livereload: {
        files: [
          '<%= yeoman.app %>/**/*.html',
          '{.tmp,<%= yeoman.app %>}/styles/*.css',
          '{.tmp,<%= yeoman.app %>}/scripts/**/*.js',
          '<%= yeoman.app %>/image/*.{png,jpg,jpeg}'
        ],
        tasks: ['livereload']
      }
    },
    connect: {
      livereload: {
        options: {
          port: 9000,
          middleware: function (connect) {
            return [
              lrSnippet,
              mountFolder(connect, '.tmp'),
              mountFolder(connect, 'app')
            ];
          }
        }
      },
      test: {
        options: {
          port: 9000,
          middleware: function (connect) {
            return [
              mountFolder(connect, '.tmp'),
              mountFolder(connect, 'test')
            ];
          }
        }
      }
    },
    open: {
      server: {
        url: 'http://localhost:<%= connect.livereload.options.port %>'
      }
    },
    clean: {
      dist: ['.tmp', '<%= yeoman.dist %>/*'],
      server: '.tmp'
    },
    jshint: {
      options: {
        jshintrc: '.jshintrc'
      },
      all: [
        'Gruntfile.js',
        '<%= yeoman.app %>/scripts/**/*.js'
      ]
    },
    coffeelint: {
      options: {
        coffeelintrc: '.coffeelintrc'
      },
      all: [
        '<%= yeoman.app %>/scripts/**/*.coffee',
        '<%= server %>/**/*.coffee'
      ]
    },
    testacular: {
      unit: {
        configFile: 'testacular.conf.js',
        singleRun: true
      }
    },
    jasmine_node: {
      // match all files, not only *.spec.coffee
      matchall: true,
      // only read coffee script file
      extensions: 'coffee',
      // test root dir
      projectRoot: 'server/test',
      requirejs: false,
      forceExit: false,
      jUnit: {
        report: false,
        savePath: './build/reports/jasmine/',
        useDotNotation: true,
        consolidate: true
      }
    },
    coffee: {
      options: {
        bare: true
      },
      dist: {
        expand: true, // Enable dynamic expansion.
        cwd: '<%= yeoman.app %>/scripts', // Src matches are relative to this path.
        src: '**/*.coffee', // Actual pattern(s) to match.
        dest: '.tmp/scripts', // Destination path prefix.
        ext: '.js'                        // Dest filepaths will have this extension.
      },
      test: {
        expand: true,
        cwd: 'test',
        src: '**/*.coffee',
        dest: '.tmp/test',
        ext: '.js'                        // Dest filepaths will have this extension.
      }
    },
    compass: {
      options: {
        basePath: '<%= yeoman.app %>',
        sassDir: 'styles',
        cssDir: '../.tmp',
        imagesDir: 'image',
        javascriptsDir: 'scripts',
        fontsDir: 'styles/fonts',
        importPath: 'app/components',
        relativeAssets: false
      },
      dist: {
        options: {
          cssDir: '../dist'
        }
      },
      server: {
        options: {
          debugInfo: true
        }
      }
    },
    concat: {
      dist: {
      }
    },
    useminPrepare: {
      html: '<%= yeoman.app %>/index.html',
      options: {
        dest: '<%= yeoman.dist %>'
      }
    },
    usemin: {
      html: ['<%= yeoman.dist %>/*.html'],
      css: ['<%= yeoman.dist %>/*.css'],
      options: {
        dirs: ['<%= yeoman.dist %>']
      }
    },
    imagemin: {
      dist: {
        files: [
          {
            expand: true,
            cwd: '<%= yeoman.app %>/images',
            src: '*.{png,jpg,jpeg}',
            dest: '<%= yeoman.dist %>/images'
          }
        ]
      }
    },
    cssmin: {
      dist: {
        files: {
          '<%= yeoman.dist %>/main.css': '<%= yeoman.dist %>/main.css'
        }
      }
    },
    htmlmin: {
      options: {
        removeComments: true,
        removeCommentsFromCDATA: true,
        removeCDATASectionsFromCDATA: true,
        // https://github.com/yeoman/grunt-usemin/issues/44
        collapseWhitespace: true,
        collapseBooleanAttributes: true,
        //removeAttributeQuotes: false,
        removeRedundantAttributes: true,
        useShortDoctype: true,
        removeEmptyAttributes: true
        //removeOptionalTags: false
      },
      view: {
        files: [
          {
            expand: true,
            cwd: '<%= yeoman.app %>/views',
            src: '**/*.html',
            dest: '.tmp/views'
          }
        ]
      },
      dist: {
        files: [
          {
            src: '<%= yeoman.dist %>/index.html',
            dest: '<%= yeoman.dist %>/index.html'
          }
        ]
      }
    },
    cdnify: {
      dist: {
        html: ['<%= yeoman.dist %>/*.html']
      }
    },
    config: {
      files: [
        {
          expand: true,
          cwd: 'config',
          dest: '.tmp/config',
          src: [
            '*.cson'
          ]
        }
      ]
    },
    ngtemplates: {
      exhibiaApp: {
        options: { base: '.tmp' },
        src: [ '.tmp/**/*.html' ],
        dest: '.tmp/scripts/templates.js'
      }
    },
    copy: {
      // @todo angular-ui template bug
      view: {
        files: [
          {
            expand: true,
            dot: false,
            cwd: '<%= yeoman.app %>',
            dest: '.tmp/',
            src: [
              'template/alert/alert.html',
              'template/accordion/accordion.html',
              'template/accordion/accordion-group.html',
              'template/dialog/message.html'
            ]
          }
        ]
      },
      dist: {
        files: [
          {
            expand: true,
            dot: false,
            cwd: '<%= yeoman.app %>',
            dest: '<%= yeoman.dist %>',
            src: [
              '*.{ico,txt,html}',
              'image/*'
            ]
          }
        ]
      }
    }
  });

  grunt.renameTask('regarde', 'watch');
  // remove when mincss task is renamed
  grunt.renameTask('mincss', 'cssmin');

  grunt.registerTask('server', [
    'clean:server',
    'coffee:dist',
    'compass:server',
    'livereload-start',
    'config',
    'connect:livereload',
    'open',
    'watch'
  ]);

  grunt.registerTask('lint', [
    'jshint',
    'coffeelint'
  ]);

  grunt.registerTask('test', [
    'clean:server',
    'lint',
    'coffee',
    'compass',
    'config',
    'connect:test',
    'testacular'
  ]);

  grunt.registerTask('build', [
    'clean:dist',
    'test',
    'compass:dist',
    'useminPrepare',
    //'imagemin',
    'cssmin',
    'htmlmin:view',
    // @todo angular-ui template bug
    'copy:view',
    'ngtemplates',
    'concat',
    'copy:dist',
    'cdnify',
    'uglify',
    'usemin',
    'htmlmin:dist'
  ]);

  grunt.registerTask('default', ['build']);
};
