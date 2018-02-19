<?php

require_once "static_config.php";
$config = static_config();

$path = explode('/', $_GET['q']);
switch ($path[0]) {
  case 'index':
  case 'about':
    $url = $config['backend_url'];
    break;
  case 'chapters':
    if (count($path) == 1) {
      $url = $config['backend_url'];
      break;
    }
    elseif (count($path) == 2 && is_numeric($path[1])) {
      $url = $config['backend_url'] . '/node/' . $path[1];
      break;
    }
    // Intentionally fallback to default fom here
  default:
    header("HTTP/1.0 404 Not Found", true, 404);
    die();
}

redirect($url);

function redirect($url) {
  readfile($url);
  die();
}
