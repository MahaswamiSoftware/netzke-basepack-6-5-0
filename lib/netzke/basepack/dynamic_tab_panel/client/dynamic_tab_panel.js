{
  tabCounter: 0,

  netzkeTabComponentDelivered: function(c, config) {
    var tab,
        i,
        activeTab = this.getActiveTab(),
        cmp = Ext.create(Ext.apply(c, {closable: true}));

    if (config.newTab || activeTab == null) {
      tab = this.add(cmp);
    } else {
      tab = this.getActiveTab();
      i = this.items.indexOf(tab);
      this.remove(tab);
      tab = this.insert(i, cmp);
    }

    if(config.tabIcon){
      tab.setIcon(config.tabIcon);
    }

    if(config.tabTitle){
      tab.setTitle(config.tabTitle);
    }

    this.setActiveTab(tab);
  },

  netzkeLoadComponentByClass: function(klass, options) {
    this.netzkeLoadComponent('child', Ext.apply(options, {
      configOnly: true,
      itemId: "tab_" + this.tabCounter++,
      serverConfig: Ext.apply(options.serverConfig || {}, { class_name: klass }),
      callback: this.netzkeTabComponentDelivered
    }));
  }
}
