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
      '#default_value' => $config->get('title'),
      '#description' => $this->t('The title of your graphic novel.'),
    );

    $form['description'] = array(
      '#type' => 'textfield',
      '#title' => $this->t('Description'),
      '#default_value' => $config->get('description'),
      '#description' => $this->t('A short description of your graphic novel.'),
    );

    $form['facebook_page'] = array(
      '#type' => 'textfield',
      '#title' => $this->t('Facebook Page'),
      '#field_prefix' => 'www.facebook.com/',
      '#default_value' => $config->get('facebook_page'),
      '#description' => $this->t('Link your Facebook page, typing just the handle/id part of the URL.'),
    );

    $form['instagram_handle'] = array(
      '#type' => 'textfield',
      '#title' => $this->t('Instagram Handle'),
      '#field_prefix' => 'instagram.com/',
      '#default_value' => $config->get('instagram_handle'),
      '#description' => $this->t('Link your Instagram profile, typing just the handle/id part of the URL.'),
    );

    $form['deviantart_profile'] = array(
      '#type' => 'textfield',
      '#title' => $this->t('Deviantart Profile'),
      '#field_suffix' => '.deviantart.com/',
      '#default_value' => $config->get('deviantart_profile'),
      '#description' => $this->t('Link your Deviantart profile, typing just your username.'),
    );

    $form['about'] = array(
      '#type' => 'textarea',
      '#title' => $this->t('About Content'),
      '#default_value' => $config->get('about'),
      '#description' => $this->t('About content. You can use Markdown syntax.')
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
    $config->set('title', $form_state->getValue('title'));
    $config->set('description', $form_state->getValue('description'));
    $config->set('facebook_page', $form_state->getValue('facebook_page'));
    $config->set('instagram_handle', $form_state->getValue('instagram_handle'));
    $config->set('deviantart_profile', $form_state->getValue('deviantart_profile'));
    $config->set('about', $form_state->getValue('about'));
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
