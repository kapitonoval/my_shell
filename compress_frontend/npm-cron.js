var cron = require('node-cron');
var gulp = require('gulp');
var uglify = require('gulp-uglify');
var pump = require('pump');
var rename = require('gulp-rename');
var cssmin = require('gulp-cssmin');


gulp.task('compress_js', function (cb) {

  pump([
      gulp.src([
        'scripts/**/*.js'
      ]),
      uglify(),
      gulp.dest('scripts/')
    ],
    cb
  );

});

gulp.task('compress_css', function () {
  gulp.src('css/**/*.css')
    .pipe(cssmin())
    .pipe(gulp.dest('css'));
});


cron.schedule('1,16,31,46 * * * *', function () {
  // пережимаем compress
  gulp.start('compress_js');
  gulp.start('compress_css');
  console.log('start npm-cron script is successful');
});
