<?php

namespace Drupal\nvel_base;

use Drupal\path_alias\AliasManagerInterface;
use Drupal\path_alias\AliasRepositoryInterface;
use Drupal\Core\Entity\EntityTypeManagerInterface;
use Drupal\Component\Transliteration\TransliterationInterface;
use Drupal\Core\Language\LanguageManagerInterface;

class ChapterPath {

  protected $aliasManager;

  protected $entityTypeManager;

  protected $aliasStorage;

  protected $transliteration;

  protected $language;

  public function __construct(
      AliasManagerInterface $aliasManager,
      EntityTypeManagerInterface $entityTypeManager,
      AliasRepositoryInterface $aliasStorage,
      TransliterationInterface $transliteration,
      LanguageManagerInterface $language ) {
    $this->aliasManager = $aliasManager;
    $this->entityTypeManager = $entityTypeManager;
    $this->aliasStorage = $aliasStorage;
    $this->transliteration = $transliteration;
    $this->language = $language;
  }

  public function getChapterPathByNid($nid, $langcode = NULL) {
    $alias = $this->aliasManager->getAliasByPath('/node/' . $nid, $langcode);
    $parts = explode('/', $alias);
    if ($parts[1] != 'chapters') {
      // (re)generate alias for this.
      return $this->createPathByNid($nid);
    }
    elseif (!empty($parts[3])) {
      // update invalid alias.
      return $this->truncateAlias($alias);
    }
    else {
      return implode('/', [$parts[2]]);
    }
  }

  private function createPathByNid($nid) {
    $langcode = $this->language->getCurrentLanguage()->getId();
    $node = $this->entityTypeManager->getStorage('node')->load($nid);

    $title = $node->title->value;
    $number = $node->field_chapter_number->value;

    $alias = strtolower('/chapters/' . $number . '-' . $this->transliteration->transliterate($title, $node->langcode));
    // TODO: Get source from node route?
    // TODO: delete existing ones?
    $this->aliasStorage->save('/node/' . $nid, $alias, $langcode);
    $path = str_replace('/chapters/', '', $alias);
    return $path;
  }

  private function truncateAlias($alias) {
    $parts = explode('/', $alias);
    $new_alias = implode('/', array_slice($parts, 0, 3));

    $alias_record = $this->aliasStorage->load(['alias' => $alias]);
    if ($alias_record) {
      $alias_record['alias'] = $new_alias;
      $this->aliasStorage->save($alias_record['source'], $alias_record['alias'], $alias_record['langcode'], $alias_record['pid']);
      $path = str_replace('/chapters/', '', $new_alias);
      return $path;
    }
    else {
      return FALSE;
    }

  }
}
