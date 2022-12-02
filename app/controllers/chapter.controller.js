const Chapter = require("../models/chapter.model.js");

// Create and Save a new Tutorial
exports.create = (req, res) => {
    // Validate request
    if (req.headers['content-type'] === 'application/json;') {
        req.headers['content-type'] = 'application/json';
    }

    if (!req.body || req.body == "") {
      return res.status(400).send({
        message: "Content can not be empty!"
      });
    }
    var params = req.body;
    // Create a Chapter
    const chapter = new Chapter({
        chapter_name : params.uid,
        chapter_details : params.first_name,
        chapter_type : params.last_name,
    });
  
    // Save Chapter in the database
    Chapter.create(chapter, (err, data) => {
        if (err)
            return res.status(500).send({
            message:
                err.message || "Some error occurred while creating the Chapter."
            });
        else return res.send(data);
    });
};

exports.findAll = (req, res) => {
    Chapter.getAll((err, data) => {
        if (err)
            return res.status(500).send({
            message:
                err.message || "Some error occurred while retrieving chapter."
            });
        else return res.send(data);
    });
};

exports.findOne = (req, res) => {
  console.log(req);
  Chapter.findById(req.params.id, (err, data) => {
    if (err) {
      if (err.kind === "not_found") {
        res.status(404).send({
          message: `Not found Chapter with id ${req.params.id}`,
          status: false
        });
      } else {
        res.status(500).send({
          message: "Error retrieving Chapter with id " + req.params.id,
          status: false
        });
      }
    } else res.send(data);
  });
};

// Update a Chapter identified by the id in the request
exports.update = (req, res) => {
    // Validate Request
    if (!req.body) {
      res.status(400).send({
        message: "Content can not be empty!"
      });
    }
  
    Chapter.updateById(
      req.params.id,
      new Chapter(req.body),
      (err, data) => {
        if (err) {
            if (err.kind === "not_found") {
                return res.status(404).send({
                message: `Not found Chapter with id ${req.params.id}.`
                });
            } else {
                return res.status(500).send({
                message: "Error updating Chapter with id " + req.params.id
                });
            }
        } else return res.send(data);
      }
    );
  };