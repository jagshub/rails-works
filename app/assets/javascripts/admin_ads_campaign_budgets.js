/* eslint-disable */
(function($) {
  $(document).ready(function() {
    const $kind = $('#ads_budget_kind');
    const $amount = $('#ads_budget_amount');
    const $unitPrice = $('#ads_budget_unit_price');
    const $impressions = $('#ads_budget_impressions');
    const $startTime = $('#ads_budget_start_time');
    const $numberOfDays = $('#ads_budget_number_of_days');
    const $endTime = $('#ads_budget_end_time');

    $kind.on('change', function(e) {
      const isCPM = e.target.value === 'cpm';
      $unitPrice.prop('disabled', !isCPM);
      $impressions.prop('disabled', !isCPM);
    });

    $amount.on('keyup', function(e) {
      $amount.val(formatNumber(e.target.value, '$'));

      if ($kind.val() !== 'cpm') return;

      const amount = unFormatNumber(e.target.value);
      const unitPrice = unFormatNumber($unitPrice.val());
      const impressions = unFormatNumber($impressions.val());

      if (amount === 0) return;

      if (unitPrice > 0) {
        $impressions.val(formatNumber(Math.ceil((amount * 1000) / unitPrice)));
      } else if (impressions > 0) {
        $unitPrice.val(formatNumber((amount * 1000) / impressions, '$'));
      }
    });

    $unitPrice.on('keyup', function(e) {
      $unitPrice.val(formatNumber(e.target.value, '$'));

      const amount = unFormatNumber($amount.val());
      const unitPrice = unFormatNumber(e.target.value);

      if (amount === 0 || unitPrice === 0) return;

      $impressions.val(formatNumber(Math.ceil((amount * 1000) / unitPrice)));
    });

    $impressions.on('keyup', function(e) {
      $impressions.val(formatNumber(e.target.value));

      const amount = unFormatNumber($amount.val());
      const impressions = unFormatNumber(e.target.value);

      if (amount === 0 || impressions === 0) return;

      $unitPrice.val(formatNumber((amount * 1000) / impressions, '$'));
    });

    $startTime.on('change', function(e) {
      const startTime = new Date(e.target.value);
      startTime.setDate(startTime.getDate() + parseInt($numberOfDays.val()));
      if (isNaN(startTime.getTime())) return;

      $endTime.val(dateToDateSelectorValue(startTime));
    });

    $numberOfDays.on('keyup', function(e) {
      const startTime = new Date($startTime.val());
      startTime.setDate(startTime.getDate() + parseInt(e.target.value));
      if (isNaN(startTime.getTime())) return;

      $endTime.val(dateToDateSelectorValue(startTime));
    });

    $endTime.on('change', function(e) {
      const startTime = new Date($startTime.val());
      const endTime = new Date(e.target.value);
      const diff = endTime.getTime() - startTime.getTime();

      $numberOfDays.val(diff / (1000 * 3600 * 24));
    });
  });
})(jQuery);

// NOTE(DZ): Soln from https://stackoverflow.com/a/23966200/2130243
// This worked better than most libraries (e.g. accounting.js)
function formatNumber(num, sign = '') {
  if (num === '') return;

  var str = num.toString().replace('$', ''),
    parts = false,
    output = [],
    i = 1,
    formatted = null;
  if (str.indexOf('.') > 0) {
    parts = str.split('.');
    str = parts[0];
  }
  str = str.split('').reverse();
  for (var j = 0, len = str.length; j < len; j++) {
    if (str[j] != ',') {
      output.push(str[j]);
      if (i % 3 == 0 && j < len - 1) {
        output.push(',');
      }
      i++;
    }
  }
  formatted = output.reverse().join('');
  return sign + formatted + (parts ? '.' + parts[1].substr(0, 2) : '');
}

function unFormatNumber(str) {
  const numStr = str.replace(/[\$,]/g, '');

  return isNaN(numStr) || numStr === '' ? 0 : parseFloat(numStr);
}

function dateToDateSelectorValue(date) {
  return new Date(date.getTime() - date.getTimezoneOffset() * 60000)
    .toISOString()
    .slice(0, 23);
}
