const config = require("/config/settings.js");
const fs = require("fs");
const bcrypt = require("bcryptjs");

// Sane and required defaults for the add-on
config.debugUseColors = false;
config.flowFile = "flows.json";
config.nodesDir = "/config/nodes";
config.userDir = "/config/";

// Set Node-RedPort
config.uiPort = process.env.NODERED_PORT || 1880;

//Set path for HTTP_Nodes to be served from avoiding lua auth
config.httpNodeRoot = "/endpoint";

// Disable SSL, since the add-on handles that
config.https = null;

module.exports = config;
