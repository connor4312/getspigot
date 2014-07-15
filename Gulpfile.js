var gulp = require('gulp'),
    glob = require('glob'),
    g_if = require('gulp-if'),
    prefix = require('gulp-autoprefixer'),
    args = require('yargs').argv,
    $ = require('gulp-load-plugins')();

var isProduction = args.type === 'production';

gulp.task('css', function() {
    gulp.src('src/css/style.less')
        .pipe($.less())
        .pipe(prefix('last 3 versions'))
        .pipe(g_if(isProduction, $.uncss({html: glob.sync('src/*.html')})))
        .pipe(g_if(isProduction, $.minifyCss()))
        .pipe(gulp.dest('./dist/css'));
});
gulp.task('js', function () {
    gulp.src('src/js/*.js')
        .pipe(g_if(isProduction, $.uglify()))
        .pipe(gulp.dest('./dist/js'));

    gulp.src('src/js/*.coffee')
        .pipe($.coffee())
        .pipe(g_if(isProduction, $.uglify()))
        .pipe(gulp.dest('./dist/js'));
});
gulp.task('html', function() {
    gulp.src('src/*.html')
        .pipe(g_if(isProduction, $.htmlmin({collapseWhitespace: true})))
        .pipe(gulp.dest('./dist'));
});
gulp.task('images', function() {
    gulp.src('src/img/*')
        .pipe(g_if(isProduction, $.imagemin({
            progressive: true
        })))
        .pipe(gulp.dest('./dist/img'));
});
gulp.task('misc', function () {
    gulp.src('src/**/*.woff').pipe(gulp.dest('./dist'));
});

gulp.task('default', ['html', 'js', 'css', 'images', 'misc']);