<?php

namespace Drupal\nvel_base\Plugin\rest\resource;

use Drupal\rest\Plugin\ResourceBase;
use Drupal\rest\ResourceResponse;
use Drupal\Core\Config\ConfigFactoryInterface;
use Drupal\node\Entity\Node;
use Drupal\paragraphs\Entity\Paragraph;
use Drupal\Component\Render\PlainTextOutput;
use Drupal\views\Views;
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
    $view = Views::getView('chapters_admin');
    $view->execute('master');
    foreach ($view->result as $row) {
      $id = $row->nid;
      $node = Node::load($id);
      $title = $node->get('title')->view();
      $description = $node->get('field_description')->view(array('label' => 'hidden'));
      $chapter = array(
        'nid' => $id,
        'title' => PlainTextOutput::renderFromHtml($renderer->renderRoot($title)),
        'field_description' => nl2br(trim(PlainTextOutput::renderFromHtml($renderer->renderRoot($description)))),
        'content' => $this->getSections($node),
        'index' => (int) $row->draggableviews_structure_weight,
      );
      $chapters[$id] = $chapter;
    }

    $build = new ResourceResponse($chapters);
    $build->addCacheableDependency($build, $view->result);

    return $build;
  }

  private function getSections($node) {
    $paragraphs = $node->get('field_sections');
    $sections = array();
    foreach ($paragraphs as $paragraph) {
      $entity = Paragraph::load($paragraph->target_id);
      $type = $entity->get('type')->first()->getValue()['target_id'];
      $section = array(
        'type' => $type
      );
      switch ($type) {
        case 'full_width_single_panel':
          $image_file = $entity->get('field_panel_image')->referencedEntities()[0];
          $image = $entity->get('field_panel_image')->first()->getValue();
          $section['image'] = $image;
          $section['image']['uri'] = $image_file->url();
          $section['image']['width'] = (int) $section['image']['width'];
          $section['image']['height'] = (int) $section['image']['height'];
          break;
      }
      $sections[] = $section;
    }
    return $sections;
  }
}
