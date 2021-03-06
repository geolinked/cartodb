var cdb = require('cartodb.js');

/**
 *  Create header view
 *
 *  It will manage which content should be displayed
 *  depending create model
 *
 */

module.exports = cdb.core.View.extend({

  events: {
    'click .js-back': '_onClickBack'
  },
  
  initialize: function() {
    this.user = this.options.user;
    this.template = cdb.templates.getTemplate('new_common/views/create/create_header');
    this._initBinds();
  },

  render: function() {
    this.$el.html(
      this.template({
        type: this.model.get('type'),
        option: this.model.get('option')
      })
    );
    return this;
  },

  _initBinds: function() {
    this.model.bind('change:option', this.render, this);
  },

  _onClickBack: function() {
    this.model.set('option', 'templates');
  }

});