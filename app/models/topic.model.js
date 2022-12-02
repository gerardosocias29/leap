const sql = require("./db.js");

// constructor
const Topic = function(topic) {
    this.lesson_id = topic.chapter_name;
    this.topic_details = topic.topic_details;
    this.topic_title = topic.topic_title;
};

Topic.create = (newTopic, result) => {
  sql.query("INSERT INTO topics SET ?", newTopic, (err, res) => {
    if (err) {
      console.log("error: ", err);
      result(err, null);
      return;
    }

    console.log("created topic: ", { id: res.insertId, ...newTopic });
    result(null, { id: res.insertId, ...newTopic });
    return;
  });
};

Topic.findById = (id, result) => {
  sql.query(`SELECT * FROM topics WHERE id = '${id}'`, (err, res) => {
    if (err) {
      console.log("error: ", err);
      result(err, null);
      return;
    }

    if (res.length) {
      console.log("found topic: ", res[0]);
      result(null, res[0]);
      return;
    }

    // not found Tutorial with the id
    result({ kind: "not_found" }, null);
    return;
  });
};

Topic.getAll = (result) => {
  let query = "SELECT * FROM topics";

  sql.query(query, (err, res) => {
    if (err) {
      console.log("error: ", err);
      result(null, err);
      return;
    }

    console.log("topics: ", res);
    result(null, res);
  });
};

Topic.updateById = (id, topic, result) => {
  sql.query(
    `UPDATE topics SET 
        lesson_id = ?, topic_details = ?, topic_title = ?
    WHERE id = ?`,
    [
        topic.lesson_id
        ,topic.topic_details
        ,topic.topic_title
        ,id
    ],
    (err, res) => {
      if (err) {
        console.log("error: ", err);
        result(null, err);
        return;
      }

      if (res.affectedRows == 0) {
        // not found Topic with the id
        result({ kind: "not_found" }, null);
        return;
      }

      console.log("updated topic: ", { id: id, ...tutorial });
      result(null, { id: id, ...tutorial });
    }
  );
};

Topic.remove = (id, result) => {
  sql.query("DELETE FROM topics WHERE id = ?", id, (err, res) => {
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

    console.log("deleted topic with id: ", id);
    result(null, res);
  });
};

module.exports = Topic;
