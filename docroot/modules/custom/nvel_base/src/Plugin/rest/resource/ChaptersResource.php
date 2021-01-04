<?php

namespace Drupal\nvel_base\Plugin\rest\resource;

use Drupal\rest\Plugin\ResourceBase;
use Drupal\rest\ResourceResponse;
use Drupal\Component\Render\PlainTextOutput;
use Drupal\views\Views;
use Drupal\image\Entity\ImageStyle;

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

    $chapters = [];

    // TODO: inject
    $renderer = \Drupal::service('renderer');
    $language = \Drupal::service('language_manager');
    $langcode = $language->getCurrentLanguage()->getId();

    $view = Views::getView('chapters_admin');

    $view->execute('master');

    $next_update = 0;
    foreach ($view->result as $row) {
      $id = $row->nid;
      //TODO: inject this.
      $entity = \Drupal::entityTypeManager()->getStorage('node')->load($id);
      $node = $entity->getTranslation($langcode);
      if (!$node->isPublished()) {
        continue;
      }
      $title = $node->get('title')->view();
      //var_dump($node->get('title')->value);
      $description = $node->get('field_description')->view(array('label' => 'hidden'));
      $audios = [];
      foreach ($node->field_bg_music as $item) {
        $file = \Drupal::entityTypeManager()->getStorage('file')->load($item->getValue()['target_id']);
        $audios[] = $file->url();
      }
      $image_file = $node->get('field_thumbnail')->referencedEntities()[0];
      $image = $node->get('field_thumbnail')->first()->getValue();
      $image = $this->buildImage($image, $image_file, array('thumbnail' => '100w', 'medium' => '200w', '_original' => '300w'), 100, 100);
      $featured_image_file = $node->get('field_featured_image')->referencedEntities()[0];
      $featured_image = $node->get('field_featured_image')->first()->getValue();
      $featured_image = $this->buildImage($featured_image, $featured_image_file, array('featured' => '460w', '_original' => '920w'), 460, 300);
      $pub_date = $node->get('field_original_publication_date')->view(array('label' => 'hidden', 'type' => 'datetime_custom', 'settings' => array('date_format' => 'c')));
      $pub_date_unix = $node->get('field_original_publication_date')->view(array('label' => 'hidden', 'type' => 'datetime_custom', 'settings' => array('date_format' => 'U')));
      $authors = array();
      // TODO: inject
      $path = \Drupal::service('nvel.chapter_path')->getChapterPathByNid($id);
      $language_paths = [];
      foreach (array_keys($node->getTranslationLanguages()) as $translation_langcode) {
        $language_paths[$translation_langcode] = \Drupal::service('nvel.chapter_path')->getChapterPathByNid($id, $translation_langcode);
      }
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
        'publication_date_unix' => (int) trim(PlainTextOutput::renderFromHtml($renderer->renderRoot($pub_date_unix))),
        'featured_image' => $featured_image,
        'path' => $path,
        'audios' => $audios,
        'language_paths' => $language_paths,
      );
      $chapter['content'] = $this->getSections($node, $chapter, $langcode);
      $chapter['updated_date'] = $this->getUpdatedDate($chapter);
      $chapters[$path] = $chapter;
      $next_update = $next_update ? min($next_update, $this->getNextUpdated($chapter)) : $this->getNextUpdated($chapter);
    }

    $build = new ResourceResponse($chapters);
    $cacheableMetadata = $build->getCacheableMetadata();
    $cacheableMetadata->addCacheTags(['node_list']);
    if ($next_update) {
      $current_time = \Drupal::time()->getRequestTime();
      if ($next_update > $current_time) {
        $cacheableMetadata->setCacheMaxAge($next_update - $current_time);
      }
    }

    // TODO: add cache for multilingual? Seems not necessary.

    return $build;
  }

  private function getSections($node, $chapter, $langcode) {
    //TODO: inject this.
    $renderer = \Drupal::service('renderer');
    $paragraphs = $node->get('field_sections');
    $sections = array();
    $id = 1;
    $has_preview = FALSE;
    foreach ($paragraphs as $paragraph) {
      //TODO: inject this.
      $entity_base = \Drupal::entityTypeManager()->getStorage('paragraph')->load($paragraph->target_id);
      if (!$entity_base->hasTranslation($langcode)) {
        continue;
      }
      $entity = $entity_base->getTranslation($langcode);
      $type = $entity->get('type')->first()->getValue()['target_id'];
      $pub_date_unix = $entity->get('field_scheduled')->first() ? $entity->get('field_scheduled')->first()->getValue()['value'] : \Drupal::time()->getRequestTime();;
      $preview = $pub_date_unix > \Drupal::time()->getRequestTime();

      // Only provide the first preview.
      if ($preview) {
        if (!$has_preview) {
          $has_preview = TRUE;
        }
        else {
          continue;
        }
      }

      // Fill in common values.
      $section = [
        'type' => $type,
        'chapter' => $chapter['path'],
        'id' => $id,
        'publication_date_unix' => (int) $pub_date_unix,
        'preview' => $preview,
      ];
      switch ($type) {
        case 'full_width_single_panel':
        case 'single_panel':
        case 'folded_image':
          $image_file = $entity->get('field_panel_image')->referencedEntities()[0];
          $image = $entity->get('field_panel_image')->first()->getValue();
          $sizes = $preview ? ['blur' => $image['width']] : [];
          $section['image'] = $this->buildImage($image, $image_file, $sizes);
          break;

        case 'text':
          if ($preview) {
            $text = '';
          }
          else {
            $text = $entity->get('field_text')->view(['label' => 'hidden']);
            $text_content = trim(PlainTextOutput::renderFromHtml($renderer->renderRoot($text)));
            $section['text'] = $text_content;
          }
          break;

        case 'title_panel':
          $image_file = $entity->get('field_title_image')->referencedEntities();
          if (!empty($image_file)) {
            $image = $entity->get('field_title_image')->first()->getValue();
            $section['image'] = $this->buildImage($image, $image_file[0]);
          }
          $extra = $entity->get('field_extra_text')->view(['label' => 'hidden']);
          $extra_text = trim(PlainTextOutput::renderFromHtml($renderer->renderRoot($extra)));
          $features = $entity->get('field_title_panel_features')->getValue();

          $section['features'] = [
            'title' => '',
            'author' => '',
            'copyright' => '',
            'extra' => '',
          ];

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
                  $section['features']['copyright'] = $this->t('© All rights reserved');
                  break;

                default:
                  $section['features'][$feature['value']] = '';
              }
            }
          }
          break;

        case 'audio':
          $section['audios'] = [];
          if (!$preview) {
            foreach ($entity->field_music as $item) {
              $file = \Drupal::entityTypeManager()->getStorage('file')->load($item->getValue()['target_id']);
              $section['audios'][] = $file->url();
            }
          }
          $crossfade = $entity->get('field_crossfade')->first()->getValue()['value'];
          $section['crossfade'] = (int) $crossfade;
          break;

      }
      $sections[] = $section;
      $id++;
    }
    return $sections;
  }

  /**
   * Returns updated date from latest updated section, excluding previews.
   */
  private function getUpdatedDate($chapter) {
    $date_unix = $chapter['publication_date_unix'];
    foreach ($chapter['content'] as $section) {
      if (!$section['preview']) {
        $date_unix = max($date_unix, $section['publication_date_unix']);
      }
    }
    return $date_unix;
  }

  /**
   * Returns the date of the next update if scheduled, useful for cache age.
   */
  private function getNextUpdated($chapter) {
    $time = 0;
    foreach ($chapter['content'] as $section) {
      if ($section['preview']) {
        if ($time) {
          $time = min($time, $section['publication_date_unix']);
        }
        else {
          $time = $section['publication_date_unix'];
        }
      }
    }
    return $time;
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
