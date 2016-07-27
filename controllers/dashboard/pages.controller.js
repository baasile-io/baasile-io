'use strict';

const request = require('request'),
  _ = require('lodash'),
  routeModel = require('../../models/v1/Route.model.js'),
  pageModel = require('../../models/v1/Page.model.js'),
  flashHelper = require('../../helpers/flash.helper.js');

module.exports = PagesController;

function PagesController(options) {
  options = options || {};
  const logger = options.logger;
  const RouteModel = new routeModel(options);
  const PageModel = new pageModel(options);
  const FlashHelper = new flashHelper(options);

  this.index = function(req, res) {
    PageModel.io.find({
      service: req.data.service._id
    }, function(err, pages) {
      if (err)
        res.status(500).end();
      return res.render('pages/dashboard/pages/index', {
        page: 'pages/dashboard/pages/index',
        data: req.data,
        csrfToken: req.csrfToken(),
        pages: pages,
        flash: res._flash
      });
    });
  };

  this.new = function(req, res) {
    return res.render('pages/dashboard/pages/new', {
      page: 'pages/dashboard/pages/new',
      data: req.data,
      csrfToken: req.csrfToken(),
      query: {
        page: {
          relationType: PageModel.getRelationTypes()[0].key
        }
      },
      pageTypes: PageModel.getPageTypes(),
      relationTypes: PageModel.getRelationTypes(),
      flash: res._flash
    });
  };

  this.create = function(req, res) {
    const pageName = _.trim(req.body.page_name);
    const pageNormalized = PageModel.getNormalizedName(req.body.page_name_normalized);
    const pageData = {
      name: pageName,
      nameNormalized: pageNormalized,
      description: _.trim(req.body.page_description),
      pageId: PageModel.generateId(),
      type: req.body.page_type,
      relationType: req.body.page_relation_type,
      service: req.data.service,
      clientId: req.data.service.clientId,
      createdAt: new Date(),
      creator: {_id: req.data.user._id}
    };

    PageModel.io.create(pageData, function(err, page) {
      if (err) {
        let errors;
        errors = [err];
        return res.render('pages/dashboard/pages/new', {
          page: 'pages/dashboard/pages/new',
          csrfToken: req.csrfToken(),
          data: req.data,
          query: {
            page: {
              name: pageName,
              nameNormalized: pageNormalized,
              description: pageData.description,
              type: pageData.type,
              relationType: pageData.relationType
            }
          },
          pageTypes: PageModel.getPageTypes(),
          relationTypes: PageModel.getRelationTypes(),
          flash: {
            errors: errors
          }
        });
      }
      logger.info('page created: ' + page.name);
      return res.redirect('/dashboard/services/' + req.data.service.nameNormalized + '/pages');
    });
  };

  this.getPageData = function(req, res, next) {
    PageModel.io.findOne({
      service: req.data.service,
      nameNormalized: req.params.pageName
    }, function(err, page) {
      if (err)
        return next({code: 500});
      if (!page)
        return next({code: 404});
      req.data = req.data || {};
      req.data.page = page;
      return next();
    });
  };
};
