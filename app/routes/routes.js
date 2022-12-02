module.exports = app => {
  const migrations = require("../controllers/migration.controller.js");

  const users = require("../controllers/user.controller.js");
  const chapters = require("../controllers/chapter.controller.js");
  const lessons = require("../controllers/lesson.controller.js");
  const topics = require("../controllers/topic.controller.js");

  var router = require("express").Router();

  // router.post("/", tutorials.create);
  // router.get("/", tutorials.findAll);
  // router.put("/:id", tutorials.update);
  // router.delete("/:id", tutorials.delete);
  router.get("/migrations/run/migrate", migrations.migrate);

  router.get("/users/all", users.findAll);
  router.get("/users/:uid", users.findOne);
  router.post("/users/create", users.create);
  router.put("/users/update/:id", users.update);

  router.get("/chapters/all", chapters.findAll);
  router.get("/chapters/:id", chapters.findOne);
  router.post("/chapters/create", chapters.create);
  router.put("/chapters/update/:id", chapters.update);

  router.get("/lessons/all", lessons.findAll);
  router.get("/lessons/:id", lessons.findOne);
  router.post("/lessons/create", lessons.create);
  router.put("/lessons/update/:id", lessons.update);

  router.get("/topics/all", topics.findAll);
  router.get("/topics/:id", topics.findOne);
  router.post("/topics/create", topics.create);
  router.put("/topics/update/:id", topics.update);

  app.use('/api', router);
};
