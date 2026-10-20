
// <link rel="stylesheet" type="text/css" href="/home/css/bgMusicPlayer.css" />
// <script type="text/javascript" src="/home/js/webMiscTools.js"></script>
            
const fs = require('node:fs');
const path = require('path');

function walkDir(root, prefix) {
    var output = [];
    const dirs = fs.readdirSync(root, { recursive: false }).map(function (file) {
        return {
            name: file,
            realpath: path.resolve(root, file),
            path: path.join(prefix, file)
        };
    });
    for (const file of dirs) {
        const isDir = fs.statSync(file.realpath).isDirectory();
        if (isDir) {
            const subList = walkDir(path.join(root, file.name), path.join(prefix, file.name));
            output = output.concat(subList);
        } else {
            output.push(file.path);
        }
    }
    return output;
}

var jsFiles = undefined // walkDir('./source/js', '/home/js')
var cssFiles = undefined // walkDir('./source/css', '/home/css')

function addCss($, filename) {
    $('<link>').attr('rel', 'stylesheet').attr('type', 'text/css').attr('href', filename).appendTo('body');
}

function addJs($, filename) {
    $('<script>').attr('type', 'text/javascript').attr('src', filename).appendTo('body');
}

const cheerio = require('cheerio');
hexo.extend.filter.register('after_render:html', function (html) {
    if (!jsFiles) {
        jsFiles = walkDir('./source/js', '/home/js');
    }
    if (!cssFiles) {
        cssFiles = walkDir('./source/css', '/home/css');
    }
    const $ = cheerio.load(html);
    for (const file of cssFiles) {
        addCss($, file);
    }

    for (const file of jsFiles) {
        addJs($, file);
    }
    return $.html();
});