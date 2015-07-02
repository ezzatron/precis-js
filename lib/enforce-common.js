// Generated by CoffeeScript 1.9.3
(function() {
  var DirectionalityValidator, PrecisEnforcer, WidthMapper, fs, precis, ref;

  fs = require('fs');

  precis = require('./prepare');

  ref = precis.unicode, DirectionalityValidator = ref.DirectionalityValidator, WidthMapper = ref.WidthMapper;

  PrecisEnforcer = precis.PrecisEnforcer;

  module.exports = function(normalizer) {
    var directionalityValidator, enforcer, widthMapper, widthMappingData;
    widthMappingData = JSON.parse(fs.readFileSync(__dirname + '/../data/width-mapping.json'));
    widthMapper = new WidthMapper(widthMappingData);
    directionalityValidator = new DirectionalityValidator(precis.propertyReader);
    enforcer = new PrecisEnforcer(precis.preparer, precis.propertyReader, widthMapper, normalizer, directionalityValidator);
    precis.enforce = enforcer.enforce.bind(enforcer);
    precis.enforcer = enforcer;
    return precis;
  };

}).call(this);