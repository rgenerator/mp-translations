//= require jquery
//= require bootstrap-sprockets
//= require jquery_ujs
//= require turbolinks
//= require jquery.selectunique.js
//= require tinymce
//= require_tree .

var editorHandler = function() {
  $('.editor .btn').click(function(e) {
    e.preventDefault();
    var $editor = $('.editor'), $textareas = $('textarea').not('#source_text');
    if ($editor.hasClass('enabled')) {
      $editor.removeClass('enabled');
      $editor.addClass('disabled');

      $textareas.each(function() {
        tinymce.execCommand('mceRemoveEditor', false, $(this).attr('id'));
      });
    }
    else {
      $editor.removeClass('disabled');
      $editor.addClass('enabled');

      $textareas.each(function() {
        tinymce.execCommand('mceAddEditor', false, $(this).attr('id'));
      });
    }
  });
}

var createTranslationRow = function() {
  return $(  $('#translation-row').text().replace('//<![CDATA[', '').replace('//]]>', '') );
};

var addRow = function() {
  var newRow = createTranslationRow(), rowNumber = $('.translation').size() + 1;

  var selectBox = newRow.find('td select');
  selectBox.attr('name', 'source[translations_attributes]['+ rowNumber +'][language]');
  selectBox.attr('id', 'source_translations_attributes_'+ rowNumber +'_language');

  var textArea = newRow.find('td textarea');
  textArea.attr('name', 'source[translations_attributes]['+ rowNumber +'][text]');
  textArea.attr('id', 'source_translations_attributes_'+ rowNumber + '_text');

  $('#translationFields tbody').append(newRow);

  if ($('.editor').hasClass('enabled')) {
    var id = textArea.attr('id');
    // Must be in the DOM to work
    tinymce.execCommand('mceAddEditor', false, id);
    tinymce.execCommand('mceFocus', false, id);
  }

  $('select[id$=_language]').selectunique('refresh');
};

var rowHandler = function() {
  $('body').on('click', '.translation .remove', function(e) {
    e.preventDefault();

    $(this).parents('.translation').remove();
    $('select[id$=_language]').selectunique('refresh');
  });
}

var ready = function() {
  $('select[id$=_language]').selectunique();
  $('body').on('click', '.add-translation', function(e) {
    e.preventDefault();
    addRow();
  });

  editorHandler();
  rowHandler();
};

$(document).ready(ready);
$(document).on('page:load', ready);
