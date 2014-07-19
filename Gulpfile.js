var gulp = require('gulp'),
    glob = require('glob'),
    args = require('yargs').argv,
    $ = require('gulp-load-plugins')();

var isProduction = args.type === 'production';

gulp.task('css', function() {
    gulp.src('src/css/style.less')
        .pipe($.less())
        .pipe($.autoprefixer('last 3 versions'))
        .pipe($.if(isProduction, $.uncss({html: glob.sync('src/*.html')})))
        .pipe($.if(isProduction, $.minifyCss()))
        .pipe(gulp.dest('./dist/css'));
});
gulp.task('js', function () {
    gulp.src([
        'src/js/*.js',
        'bower_components/zeroclipboard/dist/ZeroClipboard.js'
    ]).pipe($.if(isProduction, $.uglify()))
      .pipe(gulp.dest('./dist/js'));

    gulp.src('bower_components/zeroclipboard/dist/ZeroClipboard.swf').pipe(gulp.dest('dist/js'));

    gulp.src('src/js/*.coffee')
        .pipe($.coffee())
        .pipe($.if(isProduction, $.uglify()))
        .pipe(gulp.dest('./dist/js'));
});
gulp.task('html', function() {
    gulp.src('src/*.html')
        .pipe($.renderful())
        .pipe($.if(isProduction, $.htmlmin({collapseWhitespace: true})))
        .pipe(gulp.dest('./dist'));
});
gulp.task('images', function() {
    gulp.src('src/img/*')
        .pipe($.if(isProduction, $.imagemin({
            progressive: true
        })))
        .pipe(gulp.dest('./dist/img'));
});
gulp.task('misc', function () {
    gulp.src('src/**/*.woff').pipe(gulp.dest('./dist'));
});

gulp.task('default', ['html', 'js', 'css', 'images', 'misc']);
