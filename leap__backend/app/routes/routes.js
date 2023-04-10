module.exports = app => {
  const users = require("../controllers/user.controller.js");

  var router = require("express").Router();

  // router.post("/", tutorials.create);
  // router.get("/", tutorials.findAll);
  // router.put("/:id", tutorials.update);
  // router.delete("/:id", tutorials.delete);

  router.get("/users/all", users.findAll);
  router.get("/users/:uid", users.findOne);
  router.post("/users/create", users.create);
  router.put("/users/update/:id", users.create);

  app.use('/api', router);
};
