// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or any plugin's vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require bootstrap-sprockets
//= require jquery_ujs
//= require turbolinks
//= require_tree .
//= require jquery.selectunique.js
//= require tinymce
String.prototype.replaceAll = function(search, replacement) {
    var target = this;
    return target.replace(new RegExp(search, 'g'), replacement);
};

var checkMceEnabled = function(){
    var mceEnabledFlag = false;
    $('#translationFields tr:last textarea.tinymce').each(function(input){
      mceEnabledFlag = true;
      tinymce.execCommand("mceRemoveEditor", false, $(this).attr('id'));
    })
   return mceEnabledFlag;
}

var removeEditor = function(){
  $('.main').on('click','.removeEditor', function(){
    $('textarea').each(function(idx){
       tinymce.execCommand("mceRemoveEditor", false, $(this).attr('id'));
     });
  });
}

var addEditor = function(){
  $('.main').on('click','.enableEditor', function(){
    $('textarea').each(function(idx){
          tinymce.execCommand("mceAddEditor", false, $(this).attr('id'));
     });
  });
}

var addRow = function(){
    var lastRow = $("#translationFields tbody tr:last").clone();
    var tinymceDiv = lastRow.find('.mce-tinymce').remove();
    var lastTranslationCount =  lastRow.data('translation-number');
    lastTranslationCount += 1;

    lastRow.attr('data-translation-number', lastTranslationCount);
    var selectBox = lastRow.find('td select');
    selectBox.attr('name', 'source[translations_attributes]['+ (lastTranslationCount+1)+'][language]');
    selectBox.attr('id', 'source_translations_attributes_'+ (lastTranslationCount+1)+'_language');

    var textArea = lastRow.find('td textarea').val('');
    textArea.attr('name', 'source[translations_attributes]['+ (lastTranslationCount+1)+'][text]');
    textArea.attr('id', 'source_translations_attributes_'+ (lastTranslationCount+1)+'_text');
    textArea.show();

    $("#translationFields tbody").append(lastRow);
    if (tinymceDiv[0] != null)
      {
        tinymce.execCommand("mceAddEditor", false, textArea.attr('id'));
      }
    $('.languageSelect').selectunique('refresh');
}

var removeRow = function(){
  $('#translationFields').on('click', '.remove', function(){
    // TODO Need to add Confirm/Canel button and conditions here.
    var confirmation = confirm('Are you sure you want to delete this translation?');
    if (confirmation == true) {
      $.ajax({
        // TODO The targeting here needs to be fixed.
        url: '/translations/' + $(this).parent().parent().prev('input').val(),
        type: 'DELETE',
        success: function(response) {
          // TODO Add success action here.
          alert('Success!!!');
        }
      });
      //alert($(this).parent().parent().prev('input').val());
      $(this).parent().parent().remove();
      $('.languageSelect').selectunique('refresh');
    }
  });
}
var ready = function(){

  $('.languageSelect').selectunique();
  numberTranslations = 0;
  $('.addMore').click(function(){
    mceEnabled = checkMceEnabled();
    addRow();
  });

  removeRow();
  addEditor();
  removeEditor();
};

$(document).ready(ready);
$(document).on('page:load', ready);
