const User = require("../models/user.model.js");

// Create and Save a new Tutorial
exports.create = (req, res) => {
    // Validate request
    if (req.headers['content-type'] === 'application/json;') {
        req.headers['content-type'] = 'application/json';
    }

    console.log(req.headers['content-type'], req.body);
    if (!req.body || req.body == "") {
      return res.status(400).send({
        message: "Content can not be empty!"
      });
    }
    var params = req.body;
    // Create a User
    const user = new User({
        id : params.id,
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