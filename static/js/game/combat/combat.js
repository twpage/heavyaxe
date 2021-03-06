// Generated by CoffeeScript 1.7.1
(function() {
  Brew.Combat = {
    attack: function(attacker, defender, is_melee, options) {
      var attacker_is_player, combat_msg, damage, damage_color, defender_is_player, equipped_wpn, flash_color, is_dead, overkill, _ref;
      if (options == null) {
        options = {};
      }
      defender.last_attacked = Brew.Game.turn;
      attacker_is_player = attacker.group === "player";
      if (defender == null) {
        debugger;
      }
      defender_is_player = defender.group === "player";
      combat_msg = "";
      if (attacker_is_player) {
        combat_msg += "You ";
        combat_msg += is_melee ? "punch " : "fire at ";
        combat_msg += "the " + defender.name;
      } else {
        combat_msg += "The " + attacker.name + " ";
        combat_msg += is_melee ? "attacks " : "shoots at ";
        combat_msg += defender_is_player ? "you" : "the " + defender.name;
      }
      if (defender.hasFlag(Brew.flags.is_shielded.id)) {
        flash_color = Brew.colors.green;
        damage = 0;
        defender.removeFlag(Brew.flags.is_shielded.id);
      } else {
        flash_color = Brew.colors.red;
        if (attacker_is_player && (options.remote != null)) {
          damage = options.remote.damage;
          if (options.recall_damage != null) {
            damage = options.recall_damage;
          }
          defender.getStat(Brew.stat.health).deductOverflow(damage);
        } else if (attacker_is_player) {
          equipped_wpn = (_ref = attacker.inventory) != null ? _ref.getEquipped(Brew.equip_slot.melee) : void 0;
          if (equipped_wpn != null) {
            damage = Math.max(attacker.getStat(Brew.stat.stamina).getCurrent(), equipped_wpn.damage);
          } else {
            damage = attacker.getAttackDamage(is_melee);
          }
          overkill = defender.getStat(Brew.stat.health).deductOverflow(damage);
          if (overkill > 0) {
            attacker.getStat(Brew.stat.stamina).addTo(overkill);
          }
        } else {
          damage = attacker.getAttackDamage(is_melee);
          defender.getStat(Brew.stat.health).deductOverflow(damage);
        }
      }
      damage_color = defender_is_player ? Brew.colors.red : Brew.colors.light_blue;
      Brew.Game.addAnimation(new Brew.FlashEffect(defender.coordinates, damage_color));
      Brew.Display.showFloatingTextAbove(defender.coordinates, "" + damage, damage_color);
      is_dead = defender.getStat(Brew.stat.health).isZero();
      Brew.Display.drawHudAll();
      defender_is_player = defender.group === "player";
      if (is_dead && defender_is_player) {
        Brew.Game.gameOver(attacker, defender, is_melee, overkill);
      } else if (is_dead) {
        Brew.Combat.killMonster(attacker, defender, is_melee, overkill);
      }
      return true;
    },
    killMonster: function(attacker, victim, is_melee, overkill_damage) {
      var dead_xy, explode_xy, lights;
      dead_xy = clone(victim.coordinates);
      victim.is_dead = true;
      if (victim.light_source != null) {
        console.log("victim was a light source");
        lights = Brew.gameLevel().updateLightMap();
        Brew.Display.drawMapAtList(lights);
      }
      Brew.gameLevel().removeMonsterAt(victim.coordinates);
      Brew.Game.scheduler.remove(victim);
      Brew.Display.drawMapAt(dead_xy);
      Brew.Axe.updateOnKill(victim, is_melee, overkill_damage);
      if (victim.hasFlag(Brew.flags.explodes_on_death.id)) {
        explode_xy = clone(victim.coordinates);
        Brew.Axe.explodeOnDeath(victim, explode_xy);
      }
      if (victim.hasFlag(Brew.flags.respawns_on_death.id)) {
        Brew.Axe.respawnOnDeath(victim);
      }
      if (victim.def_id === "BOSS_MONSTER") {
        return Brew.Game.doVictory();
      }
    }
  };

}).call(this);

//# sourceMappingURL=combat.map
