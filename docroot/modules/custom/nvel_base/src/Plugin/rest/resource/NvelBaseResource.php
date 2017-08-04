<?php

namespace Drupal\nvel_base\Plugin\rest\resource;

use Drupal\rest\Plugin\ResourceBase;
use Drupal\rest\ResourceResponse;
use Drupal\Core\Config\ConfigFactoryInterface;
//use Symfony\Component\HttpKernel\Exception\BadRequestHttpException;
//use Symfony\Component\HttpKernel\Exception\NotFoundHttpException;

/**
 * Provides a resource for serving basic settings to frontend.
 *
 * @RestResource(
 *   id = "nvel_base",
 *   label = @Translation("Nvel Base Settings"),
 *   uri_paths = {
 *     "canonical" = "/nvel_base"
 *   }
 * )
 */
class NvelBaseResource extends ResourceBase {

  /**
   * Responds to GET requests.
   *
   * Returns a watchdog log entry for the specified ID.
   *
   * @return \Drupal\rest\ResourceResponse
   *   The response containing Nvel basic settings.
   */
  public function get() {
    $config = \Drupal::config('nvel_base.settings');
    $build = new ResourceResponse($config->get('nvel_base'));

    // Add dependency to avoid cache when config changes.
    $build->addCacheableDependency($build, $config);

    return $build;
  }
}
