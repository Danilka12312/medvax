// app/assets/javascripts/auto_update.js

document.addEventListener('DOMContentLoaded', function() {
  const monthSelect = document.getElementById('month-select');
  
  if (monthSelect) {
    monthSelect.addEventListener('change', function() {
      this.form.submit();
    });
  }
});
