const fs = require("fs");
const path = require("path");
;
module.exports = function loggerMigrations(data) {
  fs.appendFile(
    path.join('./', 'logs', `migrations-${Date.now()}.txt`),
    JSON.stringify(data),
    function (err) {
      if (err) throw err;
    },
  );
};
