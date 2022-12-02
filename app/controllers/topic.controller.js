const Topic = require("../models/topic.model.js");

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
    // Create a Topic
    const chapter = new Topic({
        lesson_id : params.lesson_id,
        topic_details : params.topic_details,
        topic_title : params.topic_title,
    });
  
    // Save Topic in the database
    Topic.create(chapter, (err, data) => {
        if (err)
            return res.status(500).send({
            message:
                err.message || "Some error occurred while creating the Topic."
            });
        else return res.send(data);
    });
};

exports.findAll = (req, res) => {
    Topic.getAll((err, data) => {
        if (err)
            return res.status(500).send({
            message:
                err.message || "Some error occurred while retrieving topic."
            });
        else return res.send(data);
    });
};

exports.findOne = (req, res) => {
  console.log(req);
  Topic.findById(req.params.id, (err, data) => {
    if (err) {
      if (err.kind === "not_found") {
        res.status(404).send({
          message: `Not found Topic with id ${req.params.id}`,
          status: false
        });
      } else {
        res.status(500).send({
          message: "Error retrieving Topic with id " + req.params.id,
          status: false
        });
      }
    } else res.send(data);
  });
};

// Update a Topic identified by the id in the request
exports.update = (req, res) => {
    // Validate Request
    if (!req.body) {
      res.status(400).send({
        message: "Content can not be empty!"
      });
    }
  
    Topic.updateById(
      req.params.id,
      new Topic(req.body),
      (err, data) => {
        if (err) {
            if (err.kind === "not_found") {
                return res.status(404).send({
                message: `Not found Topic with id ${req.params.id}.`
                });
            } else {
                return res.status(500).send({
                message: "Error updating Topic with id " + req.params.id
                });
            }
        } else return res.send(data);
      }
    );
  };