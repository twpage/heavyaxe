// Generated by CoffeeScript 1.7.1
(function() {
  var __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

  window.Brew.Interaction.Wand = {
    use: function(user, wand) {
      var new_id, _ref, _ref1;
      Brew.msg("You zap the " + (Brew.Catalog.getItemName(wand)) + "...");
      if (_ref = !wand.itemType, __indexOf.call(Brew.ItemType.list_of.wand, _ref) >= 0) {
        console.error("unexpected wand item", flask);
        return false;
      }
      new_id = Brew.Catalog.identify(wand);
      Brew.Menu.popup.context = "target";
      Brew.Menu.popup.target_context = "wand";
      Brew.Menu.popup.item = wand;
      Brew.Menu.popup.target_def = {
        range: (_ref1 = wand.range) != null ? _ref1 : 10,
        blockedByTerrain: wand.blockedByTerrain,
        blockedByOtherTargets: wand.blockedByOtherTargets,
        blockedByAnyTarget: wand.blockedByAnyTarget,
        requiresTarget: wand.requiresTarget
      };
      Brew.Targeting.showTargeting();
      return true;
    },
    zap: function(wand, target_xy) {
      var bolt, final_xy, line, old_xy;
      if (wand.itemType === Brew.ItemType.type_of.wand.missile.id) {
        bolt = Brew.featureFactory("PROJ_MAGICMISSILE");
        bolt.damage = 2;
        line = Brew.utils.getLineBetweenPoints(Brew.gamePlayer().coordinates, target_xy);
        line = line.slice(1, +(line.length - 1) + 1 || 9e9);
        Brew.Game.addAnimation(new Brew.ProjectileEffect(Brew.gamePlayer(), bolt, line));
        Brew.Game.endPlayerTurn();
      } else if (wand.itemType === Brew.ItemType.type_of.wand.blink.id) {
        old_xy = Brew.gamePlayer().coordinates;
        Brew.Game.addAnimation(new Brew.FlashEffect(old_xy, Brew.colors.light_blue));
        Brew.Game.addAnimation(new Brew.FlashEffect(target_xy, Brew.colors.light_blue));
        Brew.gameLevel().removeMonsterAt(old_xy);
        Brew.gameLevel().setMonsterAt(target_xy, Brew.gamePlayer());
        Brew.Display.drawMapAt(old_xy);
        Brew.Display.drawMapAt(target_xy);
        Brew.Game.endPlayerTurn();
      } else if (wand.itemType === Brew.ItemType.type_of.wand.charge.id) {
        bolt = Brew.featureFactory("PROJ_CHARGE");
        bolt.damage = 1;
        line = Brew.utils.getLineBetweenPoints(Brew.gamePlayer().coordinates, target_xy);
        line = line.slice(1, +(line.length - 1) + 1 || 9e9);
        Brew.Game.addAnimation(new Brew.ProjectileEffect(Brew.gamePlayer(), bolt, line));
        old_xy = Brew.gamePlayer().coordinates;
        final_xy = line[line.length - 2];
        Brew.gameLevel().removeMonsterAt(old_xy);
        Brew.gameLevel().setMonsterAt(final_xy, Brew.gamePlayer());
        Brew.Display.drawMapAt(old_xy);
        Brew.Display.drawMapAt(final_xy);
        Brew.Game.endPlayerTurn();
      } else if (wand.itemType === Brew.ItemType.type_of.wand.shock.id) {
        bolt = Brew.featureFactory("PROJ_SPARK");
        bolt.damage = 1;
        line = Brew.utils.getLineBetweenPoints(Brew.gamePlayer().coordinates, target_xy);
        line = line.slice(1, +(line.length - 1) + 1 || 9e9);
        Brew.Game.addAnimation(new Brew.ProjectileEffect(Brew.gamePlayer(), bolt, line));
        Brew.Game.endPlayerTurn();
      } else {
        console.error("got a bad wand zapping");
      }
      return true;
    }
  };

}).call(this);

//# sourceMappingURL=wand.map
