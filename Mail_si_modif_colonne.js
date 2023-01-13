// Modifiez la colonne cible en remplaçant "A" par la lettre de la colonne souhaitée
var columnToWatch = "A";

// Modifiez l'adresse e-mail de destination
var email = "arthur.bignon@autohero.com";

function sendEmails() {
  var sheet = SpreadsheetApp.getActiveSheet();
  var range = sheet.getRange(columnToWatch + "1:" + columnToWatch + sheet.getLastRow());
  var data = range.getValues();
  var message = "Les valeurs de la colonne " + columnToWatch + " ont été modifiées.";
  
  // Envoi de l'email
  var subject = "Modification de la colonne " + columnToWatch;
  MailApp.sendEmail(email, subject, message);
}
