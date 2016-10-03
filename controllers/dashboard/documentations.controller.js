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
    res.render('pages/documentation/index', {
      layout: 'layouts/home',
      page: 'pages/documentation/index',
      query: {},
      data: req.data,
      flash: res._flash
    });
  };

  this.getPage = function(req, res, next) {
    const pageId = req.params.pageId;
    const folderId = req.params.folderId;

    function render(data) {
      res.render('pages/documentation/get_page', {
        layout: 'layouts/home',
        page: 'pages/documentation/' + folderId + "/" + pageId,
        data: req.data,
        flash: res._flash,
        pageContent: data
      });
    }

    fs.readFile("./public/documentation/" + folderId + "/" + pageId + ".md", function (err, data) {
      if (err) {
        return fs.readFile("./public/documentation/" + folderId + "/" + pageId + ".html", function (err, data) {
          if (err)
            return next({code: 404});
          render(data);
        });
      }
      render(markdown(data.toString()));
    });
  };
}
