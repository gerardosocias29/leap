const User = require("../models/user.model.js");

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
    // Create a User
    const user = new User({
        uid : params.uid,
        first_name : params.first_name,
        last_name : params.last_name,
        username : params.username,
        email : params.email,
        phone : params.phone,
        gender : params.gender,
        address : params.address,
        birthday : params.birthday,
        school_id : params.school_id,
        role_id : params.role_id,
        course : params.course,
        year : params.year,
        photoURL : params.photoURL,
    });
  
    // Save User in the database
    User.create(user, (err, data) => {
        if (err)
            return res.status(500).send({
            message:
                err.message || "Some error occurred while creating the User."
            });
        else return res.send(data);
    });
};

exports.findAll = (req, res) => {
    User.getAll((err, data) => {
        if (err)
            return res.status(500).send({
            message:
                err.message || "Some error occurred while retrieving tutorials."
            });
        else return res.send(data);
    });
};

exports.findOne = (req, res) => {
  console.log(req);
  User.findById(req.params.uid, (err, data) => {
    if (err) {
      if (err.kind === "not_found") {
        res.status(404).send({
          message: `Not found User with uid ${req.params.uid}`,
          status: false
        });
      } else {
        res.status(500).send({
          message: "Error retrieving Tutorial with id " + req.params.uid,
          status: false
        });
      }
    } else res.send(data);
  });
};

// Update a User identified by the id in the request
exports.update = (req, res) => {
    // Validate Request
    if (!req.body) {
      res.status(400).send({
        message: "Content can not be empty!"
      });
    }
  
    User.updateById(
      req.params.id,
      new User(req.body),
      (err, data) => {
        if (err) {
            if (err.kind === "not_found") {
                return res.status(404).send({
                message: `Not found User with id ${req.params.id}.`
                });
            } else {
                return res.status(500).send({
                message: "Error updating User with id " + req.params.id
                });
            }
        } else return res.send(data);
      }
    );
  };