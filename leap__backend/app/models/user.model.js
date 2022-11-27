const sql = require("./db.js");

// constructor
const User = function(user) {
    this.uid = user.uid;
    this.first_name = user.first_name;
    this.last_name = user.last_name;
    this.username = user.username;
    this.email = user.email;
    this.phone = user.phone;
    this.gender = user.gender;
    this.address = user.address;
    this.birthday = user.birthday;
    this.school_id = user.school_id;
    this.role_id = user.role_id;
    this.course = user.course;
    this.year = user.year;
    this.photoURL = user.photoURL;
    this.deleted_at = user.deleted_at;
};

User.create = (newUser, result) => {
  sql.query("INSERT INTO users SET ?", newUser, (err, res) => {
    if (err) {
      console.log("error: ", err);
      result(err, null);
      return;
    }

    console.log("created user: ", { id: res.insertId, ...newUser });
    result(null, { id: res.insertId, ...newUser });
    return;
  });
};

User.findById = (uid, result) => {
  sql.query(`SELECT * FROM users WHERE uid = '${uid}'`, (err, res) => {
    if (err) {
      console.log("error: ", err);
      result(err, null);
      return;
    }

    if (res.length) {
      console.log("found users: ", res[0]);
      result(null, res[0]);
      return;
    }

    // not found Tutorial with the id
    result({ kind: "not_found" }, null);
    return;
  });
};

User.getAll = (result) => {
  let query = "SELECT * FROM users";

  sql.query(query, (err, res) => {
    if (err) {
      console.log("error: ", err);
      result(null, err);
      return;
    }

    console.log("users: ", res);
    result(null, res);
  });
};

User.updateById = (id, user, result) => {
  sql.query(
    `UPDATE users SET 
        first_name = ?, last_name = ?, username = ?, email = ?, phone = ?, gender = ?, address = ?, birthday = ?, school_id = ?, role_id = ?, course = ?, year = ?, photoURL = ?
    WHERE id = ?`,
    [
        user.first_name
        ,user.last_name
        ,user.username
        ,user.email
        ,user.phone
        ,user.gender
        ,user.address
        ,user.birthday
        ,user.school_id
        ,user.role_id
        ,user.course
        ,user.year
        ,user.photoURL
        , id
    ],
    (err, res) => {
      if (err) {
        console.log("error: ", err);
        result(null, err);
        return;
      }

      if (res.affectedRows == 0) {
        // not found Tutorial with the id
        result({ kind: "not_found" }, null);
        return;
      }

      console.log("updated users: ", { id: id, ...tutorial });
      result(null, { id: id, ...tutorial });
    }
  );
};

User.remove = (id, result) => {
  sql.query("DELETE FROM users WHERE id = ?", id, (err, res) => {
    if (err) {
      console.log("error: ", err);
      result(null, err);
      return;
    }

    if (res.affectedRows == 0) {
      // not found Tutorial with the id
      result({ kind: "not_found" }, null);
      return;
    }

    console.log("deleted users with id: ", id);
    result(null, res);
  });
};

module.exports = User;
