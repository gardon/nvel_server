<?php

require "vendor/autoload.php";
use MatthiasMullie\Minify;

$source = "app/main.js";
$minifier = new Minify\JS($source);
$minifier->gzip("app/main.js.gz");

$sourcePath = 'app/css/nvel.css';
$minifier = new Minify\CSS($sourcePath);
$minifier->gzip("app/css/nvel.css.gz");

$sourcePath = 'app/css/skeleton.css';
$minifier = new Minify\CSS($sourcePath);
$minifier->gzip("app/css/skeleton.css.gz");

// we can even add another file, they'll then be
// // joined in 1 output file
// $sourcePath2 = '/path/to/second/source/css/file.css';
// $minifier->add($sourcePath2);
//
// // or we can just add plain CSS
// $css = 'body { color: #000000; }';
// $minifier->add($css);
//
// // save minified file to disk
// $minifiedPath = '/path/to/minified/css/file.css';
// $minifier->minify($minifiedPath);
//
// // or just output the content
// echo $minifier->minify();
