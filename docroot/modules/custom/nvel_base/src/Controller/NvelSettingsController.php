<?php

namespace Drupal\nvel_base\Controller;

use Drupal\Core\Controller\ControllerBase;
use Symfony\Component\HttpFoundation\Request;

class NvelSettingsController extends ControllerBase {
  /**
   * This will return the output of the foobar page.
   **/
  public function NvelSettingsPage() {
    return array(
      '#markup' => t('This is the demo foobar page.'),
    );
  }
}
