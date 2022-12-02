const Lesson = require("../models/lesson.model.js");

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
    // Create a Lesson
    const chapter = new Lesson({
        chapter_name : params.uid,
        chapter_details : params.first_name,
        chapter_type : params.last_name,
    });
  
    // Save Lesson in the database
    Lesson.create(chapter, (err, data) => {
        if (err)
            return res.status(500).send({
            message:
                err.message || "Some error occurred while creating the Lesson."
            });
        else return res.send(data);
    });
};

exports.findAll = (req, res) => {
    Lesson.getAll((err, data) => {
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
  Lesson.findById(req.params.id, (err, data) => {
    if (err) {
      if (err.kind === "not_found") {
        res.status(404).send({
          message: `Not found Lesson with id ${req.params.id}`,
          status: false
        });
      } else {
        res.status(500).send({
          message: "Error retrieving Lesson with id " + req.params.id,
          status: false
        });
      }
    } else res.send(data);
  });
};

// Update a Lesson identified by the id in the request
exports.update = (req, res) => {
    // Validate Request
    if (!req.body) {
      res.status(400).send({
        message: "Content can not be empty!"
      });
    }
  
    Lesson.updateById(
      req.params.id,
      new Lesson(req.body),
      (err, data) => {
        if (err) {
            if (err.kind === "not_found") {
                return res.status(404).send({
                message: `Not found Lesson with id ${req.params.id}.`
                });
            } else {
                return res.status(500).send({
                message: "Error updating Lesson with id " + req.params.id
                });
            }
        } else return res.send(data);
      }
    );
  };