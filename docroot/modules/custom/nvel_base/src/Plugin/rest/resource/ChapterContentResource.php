<?php

namespace Drupal\nvel_base\Plugin\rest\resource;

use Drupal\rest\Plugin\ResourceBase;
use Drupal\rest\ResourceResponse;
use Drupal\Core\Config\ConfigFactoryInterface;
use Drupal\node\Entity\Node;
use Drupal\paragraphs\Entity\Paragraph;
use Drupal\Component\Render\PlainTextOutput;
//use Symfony\Component\HttpKernel\Exception\BadRequestHttpException;
//use Symfony\Component\HttpKernel\Exception\NotFoundHttpException;

/**
 * Provides a resource for serving chapters.
 *
 * @RestResource(
 *   id = "nvel_base_chapter_content",
 *   label = @Translation("Nvel Chapter Content"),
 *   uri_paths = {
 *     "canonical" = "/chapters/{id}"
 *   }
 * )
 */
class ChapterContentResource extends ResourceBase {

  /**
   * Responds to GET requests.
   *
   * Returns a structured list of chapters.
   *
   * @return \Drupal\rest\ResourceResponse
   *   The response containing the chapters.
   */
  public function get($id = NULL) {
    if (!$id) {
      throw new BadRequestHttpException(t('No ID was provided'));
    }

    $config = \Drupal::config('nvel_base.settings');

    $renderer = \Drupal::service('renderer');
    $node = Node::load($id);

    if (!$node) {
      throw new BadRequestHttpException(t('Invalid ID was provided'));
    }

    $title = $node->get('title')->view();
    $description = $node->get('field_description')->view(array('label' => 'hidden'));
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
          break;
      }
      $sections[] = $section;
    }
    $chapter = array(
      'nid' => $id,
      'title' => PlainTextOutput::renderFromHtml($renderer->renderRoot($title)),
      'field_description' => nl2br(trim(PlainTextOutput::renderFromHtml($renderer->renderRoot($description)))),
      'content' => $sections,
      );

    $build = new ResourceResponse($chapter);
    $build->addCacheableDependency($build, $node);

    return $build;
  }
}
