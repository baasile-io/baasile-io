'use strict';

const serviceModel = require('../../models/v1/Service.model.js'),
  routeModel = require('../../models/v1/Route.model.js'),
  fs = require('fs'),
  markdown = require("node-markdown").Markdown;

module.exports = DocumentationsController;

function DocumentationsController(options) {
  options = options || {};
  const logger = options.logger;
  const ServiceModel = new serviceModel(options);
  const RouteModel = new routeModel(options);

  this.index = function(req, res, next) {
    res.render('pages/doc', {
      layout: 'layouts/home',
      page: 'pages/doc',
      query: {},
      data: req.data,
      flash: res._flash
    });
  };

  this.getPage = function(req, res, next) {
    const pageId = req.params.pageId;

    fs.readFile("./public/documentation/dashboard-" + pageId + ".md", function (err, data) {
      if (err)
        return next({code: 404});

      res.render('pages/documentation/get_page', {
        layout: 'layouts/home',
        page: 'pages/documentation/get_page',
        data: req.data,
        flash: res._flash,
        pageContent: markdown(data.toString())
      });
    });
  };
}
