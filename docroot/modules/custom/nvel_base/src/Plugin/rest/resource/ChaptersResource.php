<?php

namespace Drupal\nvel_base\Plugin\rest\resource;

use Drupal\rest\Plugin\ResourceBase;
use Drupal\rest\ResourceResponse;
use Drupal\Core\Config\ConfigFactoryInterface;
use Drupal\node\Entity\Node;
//use Symfony\Component\HttpKernel\Exception\BadRequestHttpException;
//use Symfony\Component\HttpKernel\Exception\NotFoundHttpException;

/**
 * Provides a resource for serving chapters.
 *
 * @RestResource(
 *   id = "nvel_base_chapters",
 *   label = @Translation("Nvel Chapters"),
 *   uri_paths = {
 *     "canonical" = "/chapters"
 *   }
 * )
 */
class ChaptersResource extends ResourceBase {

  /**
   * Responds to GET requests.
   *
   * Returns a structured list of chapters.
   *
   * @return \Drupal\rest\ResourceResponse
   *   The response containing the chapters.
   */
  public function get() {
    $config = \Drupal::config('nvel_base.settings');

    $query = \Drupal::entityQuery('node');
    $query->condition('status', 1);
    $query->condition('type', 'chapter');
    $entity_ids = $query->execute();

    $chapters = $nodes = array();
    $renderer = \Drupal::service('renderer');
    foreach ($entity_ids as $id) {
      $node = Node::load($id);
      $title = $node->get('title')->view();
      $description = $node->get('field_description')->view();
      $chapter = array(
        'nid' => $id,
        'title' => $renderer->renderRoot($title),
        'field_description' => $renderer->renderRoot($description),
      );
      $chapters[$id] = $chapter;
    }

    $build = new ResourceResponse($chapters);
    foreach ($nodes as $node) {
      $build->addCacheableDependency($node);
    }

    return $build;
  }
}
