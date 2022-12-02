const sql = require("./db.js");

const Migration = function(queries) {
    this.queries = queries;
};

Migration.migrate = (migration, result) => {
    var resul = [];
    migration.queries.forEach((query, index) => {
        sql.query(query, (err, res) => {
            if (err) {
              console.log("error: ", err);
              resul.push(res);
              return;
            }
            resul.push(res); 
        });
    });
    result(null, resul);
    
};
  
module.exports = Migration;
