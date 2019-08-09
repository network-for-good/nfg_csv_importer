function saveAndExit(link) {
  let form = $('form#onboarding_main_form');
  form.on('submit', e => {
    link.addClass('disabled');
  });
  link.on('click', e => {
    const action = form.attr("action");
    form.attr("action", action + "?exit=true");
    form.submit();
    return false;
  });
}

$(document).ready(function() {
  const link = $('#onboarding_main_form').find('#save_and_exit');
  if (!link.length) { return; }
  saveAndExit(link)
});
