const fs = require("fs");

module.exports = function loggerMigrations(data) {
  fs.appendFile(
    `logs/migrations-${Date.now()}.txt`,
    JSON.stringify(data),
    function (err) {
      if (err) throw err;
    },
  );
};
