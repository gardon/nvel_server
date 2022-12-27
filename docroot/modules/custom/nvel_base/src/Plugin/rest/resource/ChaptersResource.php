<?php

namespace Drupal\nvel_base\Plugin\rest\resource;

use Drupal\Core\Url;
use Drupal\views\Views;
use Psr\Log\LoggerInterface;
use Drupal\node\NodeInterface;
use Drupal\rest\ResourceResponse;
use Drupal\image\Entity\ImageStyle;
use Drupal\rest\Plugin\ResourceBase;
use Drupal\Core\Render\RendererInterface;
use Drupal\Component\Render\PlainTextOutput;
use Drupal\Core\Entity\EntityTypeManagerInterface;
use Drupal\Core\Language\LanguageManagerInterface;

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
   * Renderer Service.
   *
   * @var \Drupal\Core\Render\RendererInterface
   */
  protected $renderer;

  /**
   * Language Service.
   *
   * @var \Drupal\Core\Language\LanguageManagerInterface
   */
  protected $languageManager;

  /**
   * Entity Type Manager.
   *
   * @var \Drupal\Core\Entity\EntityTypeManagerInterface
   */
  protected $entityTypeManager;

  /**
   * {@inheritdoc}
   */
  public function __construct(array $configuration, $plugin_id, $plugin_definition, array $serializer_formats, LoggerInterface $logger, RendererInterface $renderer, LanguageManagerInterface $language_manager, EntityTypeManagerInterface $entity_type_manager) {
    parent::__construct($configuration, $plugin_id, $plugin_definition, $serializer_formats, $logger);
    $this->renderer = $renderer;
    $this->languageManager = $language_manager;
    $this->entityTypeManager = $entity_type_manager;
  }

  /**
   * {@inheritdoc}
   */
  public static function create($container, $configuration, $plugin_id, $plugin_definition) {
    return new static($configuration, $plugin_id, $plugin_definition,
      $container->getParameter('serializer.formats'),
      $container->get('logger.factory')->get('rest'),
      $container->get('renderer'),
      $container->get('language_manager'),
      $container->get('entity_type.manager')
    );
  }

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

    $renderer = $this->renderer;
    $langcode = $this->languageManager->getCurrentLanguage()->getId();
    $nodeStorage = $this->entityTypeManager->getStorage('node');
    $fileStorage = $this->entityTypeManager->getStorage('file');

    $view = Views::getView('chapters_admin');

    $view->execute('master');

    $next_update = 0;
    foreach ($view->result as $row) {
      $id = $row->nid;

      /**
       * @var \Drupal\node\NodeInterface
       */
      $entity = $nodeStorage->load($id);

      $node = $entity->getTranslation($langcode);
      if (!$node->isPublished()) {
        continue;
      }

      $display_options = ['label' => 'hidden'];

      $title = $node->get('title')->view();
      $description = $node->get('field_description')->view($display_options);

      $audios = [];
      foreach ($node->field_bg_music as $item) {
        // @TODO: $item should have a method to get the entity.
        /**
         * @var \Drupal\file\FileInterface
         */
        $file = $fileStorage->load($item->getValue()['target_id']);
        $audios[] = $file->createFileUrl(FALSE);
      }

      $disqus_id = $node->field_disqus_id->value;
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
        'disqus_id' => $disqus_id,
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
              $section['audios'][] = Url::fromUri(file_create_url($file->getFileUri()))->toString();
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
          'uri' => Url::fromUri(file_create_url($image_file->getFileUri()))->toString(),
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
    $image['uri'] = empty($sizes) ? Url::fromUri(file_create_url($image_file->getFileUri()))->toString() : reset($image['derivatives'])['uri'];
    return $image;
  }
}
