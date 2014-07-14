var gulp = require('gulp'),
    glob = require('glob'),
    $ = require('gulp-load-plugins')();


gulp.task('dist-css', function() {
    gulp.src('src/css/style.less')
        .pipe($.less())
        .pipe($.uncss({html: glob.sync('src/*.html')}))
        .pipe($.minifyCss())
        .pipe(gulp.dest('./dist/css'));
});
gulp.task('dist-js', function () {
    gulp.src('src/js/*.js')
        .pipe($.uglify())
        .pipe(gulp.dest('./dist/js'));
});
gulp.task('dist-html', function() {
    gulp.src('src/*.html')
        .pipe($.htmlmin({collapseWhitespace: true}))
        .pipe(gulp.dest('./dist'));
});
gulp.task('dist-images', function() {
    gulp.src('src/img/*')
        .pipe($.imagemin({
            progressive: true
        }))
        .pipe(gulp.dest('./dist/img'));
});


gulp.task('dev-html', function() {
    gulp.src('src/*.html').pipe(gulp.dest('./dist'));
});
gulp.task('dev-js', function () {
    gulp.src('src/js/*.js').pipe(gulp.dest('./dist/js'));
});
gulp.task('dev-css', function() {
    gulp.src('src/css/style.less')
        .pipe($.less())
        .pipe(gulp.dest('./dist/css'));
});
gulp.task('dev-images', function() {
    gulp.src('src/img/*')
        .pipe(gulp.dest('./dist/img'));
});


gulp.task('default', ['dev-html', 'dev-js', 'dev-css', 'dev-images']);
gulp.task('dist', ['dist-html', 'dist-js', 'dist-css', 'dist-images']);