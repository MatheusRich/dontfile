// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, or any plugin's
// vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file. JavaScript code in this file should be added after the last require_* statement.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery3
//= require rails-ujs
//= require turbolinks
//= require_tree .
//= require_tree .
//= require activestorage

function getPagePath() {
  const container = $("#container");
  const pagePath = "/" + container.attr("data-path");

  return pagePath;
}

// This function saves all text modifications
function saveText(pageText) {
  $.ajax({
    url: getPagePath(),
    type: "PATCH",
    data: {
      page: {
        content: pageText
      }
    },
    success: function (resp) {}
  })
}

function displayErrorMessage() {
  alert("File is too big. Max size is 100mb.");
  $('#file').val('');
}

function updateProgressBar() {
  var newXhr = $.ajaxSettings.xhr();
  if(newXhr.upload) {
    newXhr.upload.addEventListener('progress', function (e) {
      if (e.lengthComputable) {
        $('#file-upload-progress').attr({
          value: e.loaded,
          max: e.total
        });
      }
    }, false);
  }
  return newXhr;
}

// This function saves all file uploads
function saveFile() {
  const MAX_SIZE = 100 * 1000 * 1000; // Max size: 100mb
  const file = $('#file').prop('files')[0];

  if(file.size <= MAX_SIZE) {
    const form = new FormData();
    form.append('page[file]', file);
    const progressBar = $('#file-upload-progress');
    $.ajax({
      async: true,
      url: getPagePath(),
      type: 'PATCH',
      processData: false,
      cache: false,
      contentType: false,
      data: form,
      beforeSend: () => progressBar.addClass('active'),
      xhr: updateProgressBar,
      success: (resp) => location.reload(),
      error: displayErrorMessage,
      complete: () => progressBar.removeClass('active')
    });
  } else {
    displayErrorMessage();
  }
}

function goToPage() {
  let pagePath = $('#input').val();

  if(pagePath.length > 0) {
    window.location.href = pagePath;
  }
}

function updateText(){
  $.ajax({
    url: getPagePath() + '.json',
    type: "GET",
    success: (resp) => {
      let textArea = $('#text');
      textArea.val(resp.content);
    }
  });
}

$(() => {
  let textArea = $('#text');
  let timeout = null;

  textArea.keyup(() => {
    clearTimeout(timeout);
    timeout = setTimeout(() => {
      saveText(textArea.val());
    }, 800);
  });
  
  setInterval(() => {
    updateText();
  }, 10000);
});
