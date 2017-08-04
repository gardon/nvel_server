<?php

namespace Drupal\nvel_base\Form;

use Drupal\Core\Form\ConfigFormBase;
use Drupal\Core\Form\FormStateInterface;
use Drupal\Core\Config\ConfigFactoryInterface;
use Drupal\rest\RestResourceConfigInterface;

/**
 * Nvel basic settings form.
 */
class NvelSettingsForm extends ConfigFormBase {

  /**
   * {@inheritdoc}
   */
  public function getFormId() {
    return "nvel_base_settings";
  }

  /**
   * {@inheritdoc}
   */
  public function buildForm(array $form, FormStateInterface $form_state) {
    // Form constructor.
    $form = parent::buildForm($form, $form_state);
    // Default settings.
    $config = $this->config('nvel_base.settings');

    $form['title'] = array(
      '#type' => 'textfield',
      '#title' => $this->t('Title'),
      '#default_value' => $config->get('nvel_base.title'),
      '#description' => $this->t('The title of your graphic novel.'),
    );

    $form['description'] = array(
      '#type' => 'textfield',
      '#title' => $this->t('Description'),
      '#default_value' => $config->get('nvel_base.description'),
      '#description' => $this->t('A short description of your graphic novel.'),
    );

    return $form;
  }

  /**
   * {@inheritdoc}
   */
  public function validateForm(array &$form, FormStateInterface $form_state) {

  }

  /**
   * {@inheritdoc}
   */
  public function submitForm(array &$form, FormStateInterface $form_state) {
    $config = $this->config('nvel_base.settings');
    $config->set('nvel_base.title', $form_state->getValue('title'));
    $config->set('nvel_base.description', $form_state->getValue('description'));
    $config->save();
    return parent::submitForm($form, $form_state);

  }

  /**
   * {@inheritdoc}
   */
  public function getEditableConfigNames() {
    return [
      'nvel_base.settings'
    ];
  }
}
