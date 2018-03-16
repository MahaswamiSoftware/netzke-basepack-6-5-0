Ext.ns("Netzke.mixins.Basepack");
Ext.ns("Ext.ux.grid");

Ext.util.Format.mask = function(v){
  return "********";
};

Ext.define('Ext.ux.form.TriCheckbox', {
  extend: 'Ext.form.field.ComboBox',
  alias: 'widget.tricheckbox',
  store: [[true, "Yes"], [false, "No"]],
  forceSelection: true
});

// Fix race condition with Ext JS 5.1.0 (while testing)
// The error was: "Ext.EventObject is undefined"
// Looks like Ext.EventObject is a legacy artifact in Ext JS 5, as it can be found only twice in the whole code base,
// so, it probably gets removed in one of the next releases.
Ext.override(Ext.view.BoundList, {
  onHide: function() {
    var inputEl = this.pickerField.inputEl.dom;
    if (Ext.Element.getActiveElement() !== inputEl) {
      inputEl.focus();
    }
    this.callParent(arguments);
  },
});

// Fix 2-digit precision in the numeric filter
Ext.define('Ext.grid.filters.filter.Number', {
  override: 'Ext.grid.filters.filter.Number',
  getItemDefaults: function() {
    return Ext.apply(this.itemDefaults, { decimalPrecision: 10 });
  }
});

// position: absolute;
// left: 35%;
// top: 10px;
// width: 300px;
// z-index: 20000;


// border-radius: 8px;
// -moz-border-radius: 8px;
// background: #F6F6F6;
// border: 2px solid #ccc;
// margin-top: 2px;
// padding: 10px 15px;
// color: #555;
//
//
// #msg-div .msg {
//     border-radius: 8px;
//     -moz-border-radius: 8px;
//     background: #F6F6F6;
//     border: 2px solid #ccc;
//     margin-top: 2px;
//     padding: 10px 15px;
//     color: #555;
// }
//
// #msg-div .msg p {
//     margin: 0;
// }
