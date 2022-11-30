/* eslint-disable */

//= require chartkick
//= require highcharts

(function ($) {
  let $document = $(document);

  $(document).ready(function () {
      // NOTE(DZ): Set datepicker default format into activerecord acceptable format
      $.datepicker.setDefaults({dateFormat: 'yy-mm-dd'});

      // NOTE(DZ): Activating best_in_place
      // https://github.com/activeadmin/activeadmin/wiki/How-to-Add-In-Page-Editing-Using-Gem-best_in_place
      $('.best_in_place').best_in_place();
      $('.best_in_place').bind('ajax:success', function () {
          if ($(this).data('reload') === true) location.reload();
      });

      if($('#change_log_entry_state').val() == 'published') {
          $('#change_log_entry_has_discussion_input').show();
      } else {
          $('#change_log_entry_has_discussion_input').hide();
      }

      $('#change_log_entry_state').change(function () {
          if ($('#change_log_entry_state').val() == 'published' && $('#change_log_entry_has_discussion:checked').val() == 1) {
              $('#change_log_entry_has_discussion_input').show();
              $("#change_log_entry_author_id_input").show();
          } else if ($('#change_log_entry_state').val() == 'published') {
              $('#change_log_entry_has_discussion_input').show();
              $("#change_log_entry_author_id_input").hide();
          } else {
              $('#change_log_entry_has_discussion_input').hide();
          }
      });

      if ($('#change_log_entry_has_discussion:checked').val() == 1) {
          $("#change_log_entry_author_id_input").show();
          $('#change_log_entry_has_discussion_input').show();
      } else if ($('#change_log_entry_state').val() == 'published') {
          $('#change_log_entry_has_discussion_input').show();
          $("#change_log_entry_author_id_input").hide();
      } else {
          $("#change_log_entry_author_id_input").hide();
          $('#change_log_entry_has_discussion_input').hide();
      }

      $('#change_log_entry_has_discussion').click(function () {
          if ($('#change_log_entry_has_discussion:checked').val() == 1) {
              $("#change_log_entry_author_id_input").show()
          } else {
              $("#change_log_entry_author_id_input").hide()
          }
      });

      $('#js-single-input-prompt').click(function () {
      const $this = $(this);
      const postPath = $this.data('path');
      const formInputName = $this.data('name');
      const promptText = $this.data('prompt') || 'Enter input';
      const inputValue = prompt(promptText);

      // Note(Rahul): inputvalue is null when prompt is cancelled so we don't execute further
      if (inputValue === null) {
        return;
      }

      const buttonText = $(this).text();
      $this.append('...');

      const formData = {};
      formData[formInputName] = inputValue;

      $.ajax({
        url: postPath,
        type: 'PUT',
        data: formData,
        cache: false,
        success: function () {
          if (!alert('Success!')) {
            window.location.reload();
            $this.text(buttonText);
          }
        },
        error: function (response) {
          alert(response.statusText);
          $this.text(buttonText);
        },
      });
    });
  });

  $document.delegate('[data-upload] input[type="file"]', 'change', function () {
    let $element = $(this);
    $element.attr('disabled', true);

    let formData = new FormData();
    formData.append('file', this.files[0]);

    $.ajax({
      url: '/admin/upload/create',
      type: 'POST',
      data: formData,
      cache: false,
      contentType: false,
      processData: false,
      complete: function () {
        $element.val('');
        $element.attr('disabled', false);
      },
      success: function (data) {
        let $conainer = $element.closest('[data-upload]');
        $conainer
          .find('[data-upload-preview]')
          .html(
            '<a href="' +
              data.preview_url +
              '" target="_blank"><img src="' +
              data.preview_url +
              '" /></a>',
          );
        $conainer.find('[data-upload-clear]').show();
        $conainer.find('input[type="hidden"]').val(data.uuid).trigger('change');
      },
      error: function (response) {
        window.alert(response.statusText);
      },
    });

    return false;
  });

  $document.delegate('[data-upload] [data-upload-clear]', 'click', function (
    e,
  ) {
    e.preventDefault();

    let $element = $(this);
    $element.hide();

    let $conainer = $element.closest('[data-upload]');
    $conainer.find('[data-upload-preview]').html('');
    $conainer.find('input[type="hidden"]').val('');
    $conainer.find('input[type="hidden"]').trigger('change');
  });

  let timeout = null;
  let xhr = null;
  $document.delegate('#edit_newsletter', 'change keyup', function () {
    let _this = this;

    clearTimeout(timeout);
    timeout = setTimeout(function () {
      timeout = null;

      let $form = $(_this).closest('form');
      let iframe = $form.find('iframe[data-newsletter-preview]')[0];

      if (xhr) {
        xhr.abort();
      }

      xhr = $.ajax({
        url: '/admin/newsletters/preview_section',
        type: 'POST',
        data: $form.serialize(),
        success: function (data) {
          iframe.contentDocument.body.innerHTML = data;
          xhr = null;
        },
      });
    }, 300);
  });

  $(function () {
    function renderInput(options, value, object, disabled = '') {
      const name = options.name;
      const type = options.type || 'text';
      const index = options.index;

      return (
        '<input type="' +
        type +
        '" data-index="' +
        index +
        '" data-name="' +
        name +
        '" name="newsletter[' +
        object +
        '][' +
        index +
        '][' +
        name +
        ']" value="' +
        value +
        '" ' +
        disabled +
        '>'
      );
    }

    $('#admin-newsletter-posts').each(function () {
      let $container = $(this);
      let posts = $container.data('posts') || [];

      let $tbody = $container.find('tbody');
      function render(posts) {
        $tbody.html(
          $.map(posts, function (post, i) {
            return [
              '<tr>',
              '<td class="col">',
              '<a href="' + post.url + '" target="_blank">visit</a>',
              '</td>' + '<td class="col">',
              renderInput(
                { type: 'hidden', name: 'makers', index: i },
                post.makers,
                'posts',
              ),
              renderInput(
                { type: 'hidden', name: 'id', index: i },
                post.id,
                'posts',
              ),
              renderInput({ name: 'name', index: i }, post.name, 'posts'),
              '</td>',
              '<td class="col">',
              renderInput({ name: 'tagline', index: i }, post.tagline, 'posts'),
              '</td>',
              '<td class="col">',
              '<a href="#" data-remove="' + i + '">remove</a>',
              '</td>',
              '</tr>',
            ].join('');
          }).join(''),
        );

        $('input:first').trigger('change');
      }

      $container.delegate('[data-remove]', 'click', function (e) {
        e.preventDefault();

        posts.splice(parseInt($(this).data('remove'), 10), 1);

        render(posts);
      });

      $container.delegate('[data-add]', 'click', function (e) {
        e.preventDefault();

        const value = $container.find('option:selected').data('value');

        if (
          posts.filter(function (post) {
            return post.id === value.id;
          }).length > 0
        ) {
          return;
        }

        posts.push(value);

        render(posts);
      });

      $container.delegate('input', 'change', function () {
        const $input = $(this);
        const index = $input.data('index');
        const name = $input.data('name');

        posts[index][name] = $input.val();
      });

      render(posts);
    });
  });
})(jQuery);
