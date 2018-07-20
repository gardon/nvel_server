<?php

namespace Drupal\nvel_base\Plugin\rest\resource;

use Drupal\rest\Plugin\ResourceBase;
use Drupal\rest\ResourceResponse;
use Drupal\Core\Config\ConfigFactoryInterface;
use Drupal\node\Entity\Node;
use Drupal\paragraphs\Entity\Paragraph;
use Drupal\Component\Render\PlainTextOutput;
use Drupal\views\Views;
use Drupal\image\Entity\ImageStyle;
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
      $image_file = $node->get('field_thumbnail')->referencedEntities()[0];
      $image = $node->get('field_thumbnail')->first()->getValue();
      $image = $this->buildImage($image, $image_file, array('thumbnail' => '100w', 'medium' => '200w', '_original' => '300w'), 100, 100);
      $featured_image_file = $node->get('field_featured_image')->referencedEntities()[0];
      $featured_image = $node->get('field_featured_image')->first()->getValue();
      $featured_image = $this->buildImage($featured_image, $featured_image_file, array('featured' => '460w', '_original' => '920w'), 460, 300);
      $pub_date = $node->get('field_original_publication_date')->view(array('label' => 'hidden', 'type' => 'datetime_custom', 'settings' => array('date_format' => 'c')));
      $authors = array();
      foreach ($node->get('field_authors') as $author) {
        $view = $author->view();
        $authors[] = PlainTextOutput::renderFromHtml($renderer->renderRoot($view));
      }
      $index = $node->get('field_chapter_number')->view(array('label' => 'hidden'));
      $chapter = array(
        'nid' => $id,
        'title' => PlainTextOutput::renderFromHtml($renderer->renderRoot($title)),
        'field_description' => trim(PlainTextOutput::renderFromHtml($renderer->renderRoot($description))),
        'index' => (int) trim(PlainTextOutput::renderFromHtml($renderer->renderRoot($index))),
        'thumbnail' => $image,
        'authors' => $authors,
        'publication_date' => trim(PlainTextOutput::renderFromHtml($renderer->renderRoot($pub_date))),
        'featured_image' => $featured_image,
      );
      $chapter['content'] = $this->getSections($node, $chapter);
      $chapters[$id] = $chapter;
    }

    $build = new ResourceResponse($chapters);
    $cacheableMetadata = $build->getCacheableMetadata();
    $cacheableMetadata->addCacheTags(array('node_list'));

    // TODO: add cache for multilingual

    return $build;
  }

  private function getSections($node, $chapter) {
    $renderer = \Drupal::service('renderer');
    $paragraphs = $node->get('field_sections');
    $sections = array();
    $id = 1;
    foreach ($paragraphs as $paragraph) {
      $entity = Paragraph::load($paragraph->target_id);
      $type = $entity->get('type')->first()->getValue()['target_id'];
      $section = array(
        'type' => $type,
        'chapter' => $chapter['nid'],
        'id' => $id,
      );
      switch ($type) {
        case 'full_width_single_panel':
        case 'single_panel':
          $image_file = $entity->get('field_panel_image')->referencedEntities()[0];
          $image = $entity->get('field_panel_image')->first()->getValue();
          $section['image'] = $this->buildImage($image, $image_file);
          break;
        case 'title_panel':
          $image_file = $entity->get('field_title_image')->referencedEntities();
          if (!empty($image_file)) {
            $image = $entity->get('field_title_image')->first()->getValue();
            $section['image'] = $this->buildImage($image, $image_file[0]);
          }
          $extra = $entity->get('field_extra_text')->view(array('label' => 'hidden'));
          $extra_text = trim(PlainTextOutput::renderFromHtml($renderer->renderRoot($extra)));
          $features = $entity->get('field_title_panel_features')->getValue();
          $section['features'] = array(
            'title' => '',
            'author' => '',
            'copyright' => '',
            'extra' => '',
          );
          foreach ($features as $feature) {
            if (isset($section['features'][$feature['value']])) {
              switch ($feature['value']) {
                case 'extra':
                  $section['features']['extra'] = $extra_text;
                  break;
                case 'author':
                  $section['features']['author'] = $chapter['authors'][0];
                  break;
                case 'title':
                  $section['features']['title'] = '#' . $chapter['index'] . ': ' . $chapter['title'];
                  break;
                case 'copyright':
                  $section['features']['copyright'] = '© Todos os direitos reservados';
                  break;
                default:
                  $section['features'][$feature['value']] = '';
              }
            }
          }
          break;
      }
      $sections[] = $section;
      $id++;
    }
    return $sections;
  }

  private function buildImage($image, $image_file, array $sizes = [], $width = NULL, $height = NULL) {
    $image['width'] = empty($width) ? (int) $image['width'] : $width;
    $image['height'] = empty($height) ? (int) $image['height'] : $height;

    foreach ($sizes as $style => $size) {
      if ($style == '_original') {
        $image['derivatives'][] = array(
          'uri' => $image_file->url(),
          'size' => $size,
        );
      }
      else {
        $style_object = ImageStyle::load($style);
        $image['derivatives'][] = array(
          'uri' => $style_object->buildUrl($image_file->getFileUri()),
          'size' => $size,
        );
      }
    }
    $image['uri'] = empty($sizes) ? $image_file->url() : reset($image['derivatives'])['uri'];
    return $image;
  }
}
