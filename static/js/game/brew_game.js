// Generated by CoffeeScript 1.7.1
(function() {
  var __hasProp = {}.hasOwnProperty;

  window.Brew.GameObject = (function() {
    function GameObject(display_info) {
      this.levels = {};
      this.pathmaps = {};
      this.my_level = null;
      this.my_player = null;
      this.ai = null;
      this.dummy_fov = null;
      this.animations = [];
      this.scheduler = new ROT.Scheduler.Speed();
      Brew.Display.init(display_info);
      this.item_catalog = {};
      this.turn = 0;
      this.debugDropdownMenu();
    }

    GameObject.prototype.keypress = function(e) {
      return this.ui.keypress(e);
    };

    GameObject.prototype.start = function(player_name, hero_type) {
      var given_seed, id;
      given_seed = getParameterByName("seed");
      console.log(given_seed);
      if (given_seed != null) {
        this.seed = Number(given_seed);
        console.log(given_seed);
      } else {
        this.seed = Math.floor(ROT.RNG.getUniform() * 999999999);
      }
      console.log(this.seed);
      ROT.RNG.setSeed(this.seed);
      this.my_player = this.createPlayer(hero_type);
      this.my_player.name = player_name;
      this.ai = new Brew.MonsterAI(this);
      Brew.Catalog.randomizeItemCatalog();
      id = this.createLevel(0);
      this.setCurrentLevel(id);
      $("#id_div_seed").html("<p><span style='color: grey'><a href='/index.html?seed=" + this.seed + "'>[ Replay or Copy this Seed " + this.seed + " ]</a></span></p>");
      return true;
    };

    GameObject.prototype.restart = function() {
      var id, _ref;
      this.seed = Math.floor(ROT.RNG.getUniform() * 999999999);
      ROT.RNG.setSeed(this.seed);
      this.my_player = this.createPlayer((_ref = this.my_player.hero_type) != null ? _ref : null);
      this.my_player.name = player_name;
      this.ai = new Brew.MonsterAI(this);
      Brew.Catalog.randomizeItemCatalog();
      id = this.createLevel(0);
      this.setCurrentLevel(id);
      $("#id_div_seed").html("<p><span style='color: grey'><a href='/index.html?seed=" + this.seed + "'>[ Replay or Copy this Seed " + this.seed + " ]</a></span></p>");
      return true;
    };

    GameObject.prototype.createPlayer = function() {
      var heavy_axe, i, player, random_scroll, starting_scrolls, _i, _ref;
      player = Brew.monsterFactory("PLAYER");
      player.createStat(Brew.stat.health, 3);
      player.createStat(Brew.stat.stamina, 6);
      player.createStat(Brew.stat.doom, Brew.config.initial_doom_level);
      player.setFlag(Brew.flags.see_all.id);
      heavy_axe = Brew.itemFactory("WPN_AXE");
      player.inventory.addItem(heavy_axe, "0");
      player.inventory.equipItem(heavy_axe, Brew.equip_slot.melee);
      player.inventory.addItem(Brew.itemFactory("SCROLL_RECALL"));
      starting_scrolls = ["SCROLL_SHATTER", "SCROLL_RECALL", "SCROLL_RECALL", "SCROLL_TELEPORT"];
      for (i = _i = 1, _ref = Brew.config.starting_scrolls; 1 <= _ref ? _i <= _ref : _i >= _ref; i = 1 <= _ref ? ++_i : --_i) {
        random_scroll = starting_scrolls.random();
        player.inventory.addItem(Brew.itemFactory(random_scroll));
      }
      return player;
    };

    GameObject.prototype.refreshScheduler = function() {
      var mob, _i, _len, _ref, _results;
      this.scheduler.clear();
      _ref = this.my_level.getMonsters();
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        mob = _ref[_i];
        _results.push(this.scheduler.add(mob, true));
      }
      return _results;
    };

    GameObject.prototype.updatePathMapsFor = function(monster, calc_from) {
      if (calc_from == null) {
        calc_from = false;
      }
      monster.pathmaps[Brew.paths.to_player] = Brew.PathMap.createMapToPlayer(this.my_level, this.my_player.coordinates, monster, 10);
      if (calc_from) {
        return monster.pathmaps[Brew.paths.from_player] = Brew.PathMap.createMapFromPlayer(this.my_level, this.my_player.coordinates, monster, monster.pathmaps[Brew.paths.to_player], 10);
      }
    };

    GameObject.prototype.setCurrentLevel = function(level_id, arrive_xy) {
      this.my_level = this.levels[level_id];
      this.my_level.setMonsterAt((arrive_xy != null ? arrive_xy : this.my_level.start_xy), this.my_player);
      this.my_level.updateLightMap();
      this.refreshScheduler();
      this.updatePathMapsEndOfPlayerTurn();
      this.my_player.getStat(Brew.stat.stamina).reset();
      this.my_player.getStat(Brew.stat.doom).setTo(0);
      Brew.Sounds.play("new_level");
      this.updateAllFov();
      Brew.Display.centerViewOnPlayer();
      Brew.Display.drawDisplayAll();
      return Brew.Display.drawHudAll();
    };

    GameObject.prototype.updateAllFov = function() {
      var monster, _i, _len, _ref;
      _ref = this.my_level.getMonsters();
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        monster = _ref[_i];
        if (monster.objtype === "monster") {
          monster.updateFov(this.my_level);
        }
      }
      this.updateCombinedEnemyFov();
      return true;
    };

    GameObject.prototype.updateCombinedEnemyFov = function() {
      var dummy, in_fov, key, mob, _i, _len, _ref, _ref1;
      dummy = Brew.monsterFactory("DUMMY");
      dummy.clearFov();
      _ref = this.my_level.getMonsters();
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        mob = _ref[_i];
        if (Brew.utils.compareThing(mob, this.my_player)) {
          continue;
        }
        _ref1 = mob.fov;
        for (key in _ref1) {
          if (!__hasProp.call(_ref1, key)) continue;
          in_fov = _ref1[key];
          dummy.fov[key] = true;
        }
      }
      return this.dummy_fov = dummy;
    };

    GameObject.prototype.changeLevels = function(portal) {
      var next_id, next_level;
      if (portal.to_level_id === -1) {
        next_id = this.createLevel(this.my_level.depth + 1);
        next_level = this.levels[next_id];
        this.my_level.setLinkedPortalAt(this.my_level.exit_xy, next_id, next_level.start_xy);
        return this.setCurrentLevel(next_id, next_level.start_xy);
      } else {
        return this.setCurrentLevel(portal.to_level_id, portal.level_xy);
      }
    };

    GameObject.prototype.createLevel = function(depth) {
      var level;
      level = Brew.LevelGenerator.createLevel(depth, Brew.panels.game.width, Brew.panels.game.height, {});
      this.levels[level.id] = level;
      return level.id;
    };

    GameObject.prototype.canApply = function(item, applier) {
      if (applier == null) {
        applier = this.my_player;
      }
      return applier.inventory.hasItem(item) && Brew.group[item.group].canApply;
    };

    GameObject.prototype.canEquip = function(item, equipee) {
      return false;
    };

    GameObject.prototype.canRemove = function(item, equipee) {
      return false;
    };

    GameObject.prototype.canDrop = function(item, dropper) {
      if (dropper == null) {
        dropper = this.my_player;
      }
      return dropper.inventory.hasItem(item);
    };

    GameObject.prototype.canMove = function(monster, terrain) {
      if (terrain.blocks_walking) {
        if ((terrain.can_open != null) && terrain.can_open) {
          return true;
        } else {
          if (monster.hasFlag(Brew.flags.is_flying.id) && !terrain.blocks_flying) {
            return true;
          } else {
            return false;
          }
        }
      } else {
        return true;
      }
    };

    GameObject.prototype.msg = function(text) {
      var message_xy;
      message_xy = this.my_player.coordinates;
      return Brew.Display.showFloatingTextAbove(message_xy, text);
    };

    GameObject.prototype.msgFrom = function(monster, text) {
      if (this.my_player.hasKnowledgeOf(monster)) {
        return this.msg(text);
      }
    };

    GameObject.prototype.doPlayerMoveTowards = function(destination_xy) {
      var knows_path, next_xy, offset_xy, path;
      knows_path = this.my_player.canView(destination_xy) || (this.my_player.getMemoryAt(this.my_level.id, destination_xy) != null);
      offset_xy = null;
      if (knows_path) {
        path = this.findPath_AStar(this.my_player, this.my_player.coordinates, destination_xy);
        if (path != null) {
          next_xy = path[1];
          offset_xy = next_xy.subtract(this.my_player.coordinates).asUnit();
        }
      }
      if (offset_xy == null) {
        offset_xy = destination_xy.subtract(this.my_player.coordinates).asUnit();
      }
      return this.movePlayer(offset_xy);
    };

    GameObject.prototype.movePlayer = function(offset_xy) {
      var monster, new_xy, t;
      new_xy = this.my_player.coordinates.add(offset_xy);
      monster = this.my_level.getMonsterAt(new_xy);
      t = this.my_level.getTerrainAt(new_xy);
      if (!this.my_level.checkValid(new_xy)) {
        return Brew.Sounds.play("bump");
      } else if (monster != null) {
        return this.doPlayerBumpMonster(monster);
      } else if (t.blocks_walking && !(this.my_player.hasFlag(Brew.flags.is_flying.id) && !t.blocks_flying)) {
        if (t.can_apply != null) {
          return this.doPlayerApplyTerrain(t, true);
        } else {
          return Brew.Sounds.play("bump");
        }
      } else {
        Brew.Display.updateTerrainFooter(this.my_player.coordinates, new_xy);
        this.moveThing(this.my_player, new_xy);
        Brew.Axe.onPlayerMove();
        return this.endPlayerTurn();
      }
    };

    GameObject.prototype.getApplicableTerrain = function(thing) {
      var apply_list, neighbors, t, xy, _i, _len;
      neighbors = thing.coordinates.getSurrounding();
      apply_list = [];
      for (_i = 0, _len = neighbors.length; _i < _len; _i++) {
        xy = neighbors[_i];
        t = this.my_level.getTerrainAt(xy);
        if ((t != null) && (t != null ? t.can_apply : void 0) === true) {
          apply_list.push([xy.subtract(thing.coordinates), t]);
        }
      }
      return apply_list;
    };

    GameObject.prototype.applyTerrain = function(terrain, applier, bump) {
      if (Brew.utils.isTerrain(terrain, "DOOR_CLOSED")) {
        this.my_level.setTerrainAt(terrain.coordinates, Brew.terrainFactory("DOOR_OPEN"));
        return true;
      } else if (Brew.utils.isTerrain(terrain, "DOOR_OPEN")) {
        this.my_level.setTerrainAt(terrain.coordinates, Brew.terrainFactory("DOOR_CLOSED"));
        return true;
      }
      this.msg("You aren't sure how to apply that " + terrain.name);
      return false;
    };

    GameObject.prototype.moveThing = function(thing, new_xy, swap_override) {
      var existing_monster, old_xy, t;
      if (swap_override == null) {
        swap_override = false;
      }
      t = this.my_level.getTerrainAt(new_xy);
      if (Brew.utils.isTerrain(t, "DOOR_CLOSED")) {
        this.applyTerrain(t, thing, true);
        return false;
      }
      existing_monster = this.my_level.getMonsterAt(new_xy);
      if ((existing_monster != null) && swap_override) {
        old_xy = thing.coordinates;
        this.my_level.setMonsterAt(new_xy, thing);
        this.my_level.setMonsterAt(old_xy, existing_monster);
      } else if ((existing_monster != null) && !swap_override) {
        console.error("attempting to move monster to location with existing monster");
        return false;
      } else {
        old_xy = thing.coordinates;
        this.my_level.removeMonsterAt(old_xy);
        this.my_level.setMonsterAt(new_xy, thing);
      }
      Brew.Display.drawMapAt(old_xy);
      Brew.Display.drawMapAt(new_xy);
      return true;
    };

    GameObject.prototype.doPlayerAction = function() {
      var item, portal;
      item = this.my_level.getItemAt(this.my_player.coordinates);
      portal = this.my_level.getPortalAt(this.my_player.coordinates);
      if (item != null) {
        if (item.group === Brew.group.info.id) {
          Brew.Menu.popup.context = "info";
          Brew.Menu.popup.item = item;
          return Brew.Menu.showInfoScreen();
        } else {
          return this.doPlayerPickup(item);
        }
      } else if (portal != null) {
        return this.changeLevels(portal);
      } else {
        return this.doPlayerRest();
      }
    };

    GameObject.prototype.doPlayerRest = function() {
      var last_attacked, recharge, _ref;
      recharge = 1;
      last_attacked = (_ref = this.my_player.last_attacked) != null ? _ref : 0;
      if ((this.turn - last_attacked) > Brew.config.wait_to_heal && (!this.my_player.hasFlag(Brew.flags.poisoned.id))) {
        this.my_player.getStat(Brew.stat.stamina).addTo(recharge);
        Brew.Display.drawHudAll();
      }
      return this.endPlayerTurn();
    };

    GameObject.prototype.doPlayerThrow = function(item, target_xy) {
      var traverse_lst;
      if (item.equip != null) {
        this.my_player.inventory.unequipItem(item);
        Brew.Display.drawHudAll();
      }
      this.my_player.inventory.removeItemByKey(item.inv_key);
      traverse_lst = Brew.utils.getLineBetweenPoints(Brew.gamePlayer().coordinates, target_xy);
      this.addAnimation(new Brew.ThrownEffect(this.my_player, item, traverse_lst));
      return this.endPlayerTurn();
    };

    GameObject.prototype.doPlayerPickup = function(item, end_turn) {
      var inv_key;
      if (end_turn == null) {
        end_turn = true;
      }
      inv_key = this.my_player.inventory.addItem(item);
      if (!inv_key) {
        return this.msg("Inventory full");
      } else {
        this.my_level.removeItemAt(this.my_player.coordinates);
        this.msg("Picked up");
        if (end_turn) {
          return this.endPlayerTurn();
        }
      }
    };

    GameObject.prototype.doPlayerDrop = function(item) {
      var item_at;
      if (!item) {
        return false;
      }
      item_at = this.my_level.getItemAt(this.my_player.coordinates);
      if (item_at != null) {
        this.msg("Something here already");
        return false;
      }
      if (item.equip != null) {
        this.doPlayerRemove(item);
      }
      this.my_player.inventory.removeItemByKey(item.inv_key);
      this.my_level.setItemAt(this.my_player.coordinates, item);
      this.msg("Dropped");
      return true;
    };

    GameObject.prototype.doPlayerEquip = function(item) {
      var existing, slot;
      if (!item) {
        return false;
      }
      slot = Brew.group[item.group].equip_slot;
      if (slot == null) {
        this.msg("??");
        return false;
      }
      existing = this.my_player.inventory.getEquipped(slot);
      if (existing != null) {
        this.doPlayerRemove(existing);
      }
      this.my_player.inventory.equipItem(item, slot);
      this.msg("You are " + Brew.group[item.group].equip_verb + " " + Brew.Catalog.getItemName(item) + " (" + item.inv_key_lower + ")");
      Brew.Display.drawHudAll();
      return true;
    };

    GameObject.prototype.doPlayerRemove = function(item) {
      if (!item) {
        return false;
      }
      if (!this.canRemove(item)) {
        if (!this.canEquip(item)) {

        } else {
          this.msg("That's not equipped.");
        }
        return false;
      }
      this.my_player.inventory.unequipItem(item);
      this.msg("You've stopped " + Brew.group[item.group].equip_verb + " " + Brew.Catalog.getItemName(item) + " (" + item.inv_key_lower + ")");
      Brew.Display.drawHudAll();
      return true;
    };

    GameObject.prototype.doPlayerApply = function(item, inv_key) {
      if (!item) {
        return false;
      }
      if (!this.canApply(item)) {
        this.msg("Can't apply that");
        return false;
      }
      this.applyItem(this.my_player, item);
      return true;
    };

    GameObject.prototype.doPlayerApplyTerrain = function(terrain, bump) {
      var success;
      success = this.applyTerrain(terrain, this.my_player, bump);
      if (success) {
        return this.endPlayerTurn();
      }
    };

    GameObject.prototype.applyItem = function(applier, item) {
      if (item.group === Brew.group.scroll.id) {
        return Brew.Interaction.Scroll.use(this.my_player, item);
      } else {
        throw "error - non-appliable item";
      }
    };

    GameObject.prototype.doPlayerBumpMonster = function(bumpee) {
      if (bumpee.objtype === "monster") {
        this.meleeAttack(this.my_player, bumpee);
      } else if (bumpee.objtype === "agent") {
        Brew.Actor.handleBump(this, this.my_player, bumpee);
      } else {
        throw "a horrible error happened when bumping a monster";
      }
      return this.endPlayerTurn();
    };

    GameObject.prototype.canAttack = function(attacker, target_mob) {
      var attack_range, xy;
      attack_range = attacker.getAttackRange();
      if (attack_range === 0) {
        return false;
      } else if (attack_range === 1) {
        return ((function() {
          var _i, _len, _ref, _results;
          _ref = attacker.coordinates.getAdjacent();
          _results = [];
          for (_i = 0, _len = _ref.length; _i < _len; _i++) {
            xy = _ref[_i];
            if (xy.compare(target_mob.coordinates)) {
              _results.push(xy);
            }
          }
          return _results;
        })()).length > 0;
      } else if (attack_range === 1.5) {
        return ((function() {
          var _i, _len, _ref, _results;
          _ref = attacker.coordinates.getSurrounding();
          _results = [];
          for (_i = 0, _len = _ref.length; _i < _len; _i++) {
            xy = _ref[_i];
            if (xy.compare(target_mob.coordinates)) {
              _results.push(xy);
            }
          }
          return _results;
        })()).length > 0;
      } else {
        return Brew.Targeting.checkSimpleRangedAttack(attacker, target_mob)[0];
      }
    };

    GameObject.prototype.meleeAttack = function(attacker, defender) {
      return Brew.Combat.attack(attacker, defender, true);
    };

    GameObject.prototype.doMonsterAttack = function(monster, defender) {
      var is_melee, laserbeam, neighbors, start_xy, target_xy, traverse_lst;
      neighbors = defender.coordinates.getSurrounding();
      is_melee = neighbors.some(function(xy) {
        return monster.coordinates.compare(xy);
      });
      if (!is_melee) {
        start_xy = monster.coordinates;
        target_xy = defender.coordinates;
        traverse_lst = Brew.utils.getLineBetweenPoints(start_xy, target_xy);
        traverse_lst = traverse_lst.slice(1, +(traverse_lst.length - 1) + 1 || 9e9);
        laserbeam = Brew.featureFactory("PROJ_MONSTERBOLT", {
          code: Brew.utils.getLaserProjectileCode(start_xy, target_xy),
          damage: monster.damage
        });
        return this.addAnimation(new Brew.ProjectileEffect(monster, laserbeam, traverse_lst));
      } else {
        return Brew.Combat.attack(monster, defender, is_melee);
      }
    };

    GameObject.prototype.gameOver = function(killer, victim_player, is_melee, overkill_damage) {
      console.log("you died!");
      return Brew.Menu.showDied();
    };

    GameObject.prototype.doVictory = function() {
      console.log("you won!");
      return Brew.Menu.showVictory();
    };

    GameObject.prototype.endPlayerTurn = function() {
      var amount, carrying_axe, weapon;
      this.turn += 1;
      weapon = this.my_player.inventory.getEquipped(Brew.equip_slot.melee);
      carrying_axe = weapon != null;
      if (carrying_axe) {
        amount = 2;
      } else {
        amount = 1;
      }
      Brew.Axe.increaseLevelOfDoom(amount);
      this.updatePathMapsEndOfPlayerTurn();
      return this.nextTurn();
    };

    GameObject.prototype.updatePathMapsEndOfPlayerTurn = function() {
      return this.pathmaps[Brew.paths.to_player] = Brew.PathMap.createGenericMapToPlayer(this.my_level, this.my_player.coordinates, 10);
    };

    GameObject.prototype.runAnimationsOnly = function() {
      return this.nextTurn(true);
    };

    GameObject.prototype.animationTurn = function(animation, dont_end_player_turn) {
      if (dont_end_player_turn == null) {
        dont_end_player_turn = false;
      }
      animation.runTurn();
      if (!animation.active) {
        this.removeAnimation(animation);
      }
      this.finishEndPlayerTurn({
        update_all: animation.over_saturate,
        over_saturate: animation.over_saturate
      });
      setTimeout((function(_this) {
        return function() {
          return _this.nextTurn(dont_end_player_turn);
        };
      })(this), animation.animation_speed);
    };

    GameObject.prototype.nextTurn = function(dont_end_player_turn) {
      var first_animation, monster, next_actor, _ref;
      if (dont_end_player_turn == null) {
        dont_end_player_turn = false;
      }
      if (this.hasAnimations()) {
        first_animation = this.animations[0];
        this.animationTurn(first_animation, dont_end_player_turn);
        return;
      }
      if (dont_end_player_turn) {
        return;
      }
      next_actor = this.scheduler.next();
      if ((_ref = Brew.Input.getInputHandler()) === "died" || _ref === "victory") {
        return;
      }
      if (next_actor.group === "player") {
        this.checkFlagCounters(next_actor);
        this.finishEndPlayerTurn({
          update_all: true,
          over_saturate: false
        });
        return;
      }
      if (next_actor.objtype === "monster") {
        monster = next_actor;
        if (monster.is_dead != null) {
          console.error("trying to run a turn on a dead monster, should be removed from scheduler");
          debugger;
        }
        monster.updateFov(this.my_level);
        this.checkFlagCounters(next_actor);
        this.ai.doMonsterTurn(monster);
        this.finishEndPlayerTurn();
        this.nextTurn();
      }
    };

    GameObject.prototype.finishEndPlayerTurn = function(options) {
      var lights, overSaturate, updateAll, _ref, _ref1;
      if (options == null) {
        options = {};
      }
      updateAll = (_ref = options.update_all) != null ? _ref : false;
      overSaturate = (_ref1 = options.over_saturate) != null ? _ref1 : false;
      if (updateAll) {
        lights = this.my_level.updateLightMap();
        Brew.Display.drawMapAtList(lights);
        this.updateAllFov();
        Brew.Display.centerViewOnPlayer();
        Brew.Display.drawDisplayAll({
          over_saturate: overSaturate
        });
        return Brew.Display.drawOnScreenInfo();
      }
    };

    GameObject.prototype.findPath_AStar = function(thing, start_xy, end_xy) {
      return this.find_AStar(thing, start_xy, end_xy, false);
    };

    GameObject.prototype.findMove_AStar = function(thing, start_xy, end_xy) {
      return this.find_AStar(thing, start_xy, end_xy, true);
    };

    GameObject.prototype.find_AStar = function(thing, start_xy, end_xy, returnNextMoveOnly) {
      var astar, next_xy, passable_fn, path, update_fn;
      passable_fn = (function(_this) {
        return function(x, y) {
          var dist, m, t, xy;
          xy = new Coordinate(x, y);
          t = _this.my_level.getTerrainAt(xy);
          if (t != null) {
            if (!_this.canMove(thing, t)) {
              return false;
            } else {
              m = _this.my_level.getMonsterAt(xy);
              if (m != null) {
                if (thing.group === "player") {
                  return true;
                } else if (thing.id === m.id) {
                  return true;
                } else {
                  dist = Brew.utils.dist2d_xy(start_xy.x, start_xy.y, x, y);
                  if (dist === 1) {
                    return false;
                  } else {
                    return true;
                  }
                }
              } else {
                return true;
              }
            }
          } else {
            return false;
          }
        };
      })(this);
      path = [];
      update_fn = function(x, y) {
        return path.push(new Coordinate(x, y));
      };
      astar = new ROT.Path.AStar(end_xy.x, end_xy.y, passable_fn, {
        topology: 4
      });
      astar.compute(start_xy.x, start_xy.y, update_fn);
      next_xy = path[1];
      if (returnNextMoveOnly) {
        return next_xy != null ? next_xy : null;
      } else {
        return path;
      }
    };

    GameObject.prototype.execMonsterTurnResult = function(monster, result) {
      if (result.action === "sleep") {

      } else if (result.action === "move") {
        return this.moveThing(monster, result.xy);
      } else if (result.action === "wait") {

      } else if (result.action === "attack") {
        return this.doMonsterAttack(monster, result.target);
      } else if (result.action === "stand") {

      } else if (result.action === "special") {

      } else {
        throw "unexpected AI result";
      }
    };

    GameObject.prototype.addAnimation = function(new_animation) {
      return this.animations.push(new_animation);
    };

    GameObject.prototype.removeAnimation = function(my_animation) {
      var a;
      this.animations = (function() {
        var _i, _len, _ref, _results;
        _ref = this.animations;
        _results = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          a = _ref[_i];
          if (a.id !== my_animation.id) {
            _results.push(a);
          }
        }
        return _results;
      }).call(this);
      return true;
    };

    GameObject.prototype.hasAnimations = function() {
      return this.animations.length > 0;
    };

    GameObject.prototype.doTargetingAt = function(target_context, item_or_power, target_xy) {
      if (target_context === "throw") {
        this.doPlayerThrow(item_or_power, target_xy);
        return true;
      } else if (target_context === "wand") {
        Brew.Interaction.Wand.zap(item_or_power, target_xy);
      } else {
        console.error("unknown targeting context " + target_context);
        return false;
      }
      return false;
    };

    GameObject.prototype.setFlagWithCounter = function(thing, flag, effect_turns) {
      thing.setFlagCounter(flag, effect_turns, this.turn + effect_turns);
      return true;
    };

    GameObject.prototype.checkFlagCounters = function(thing) {
      var end_turn, flag, _i, _len, _ref;
      _ref = thing.getFlagCounters();
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        flag = _ref[_i];
        end_turn = thing.getFlagCount(flag);
        if (end_turn <= this.turn) {
          thing.removeFlagCounter(flag);
          if (Brew.utils.compareThing(thing, this.my_player)) {
            this.msg("No longer " + flag);
            Brew.Display.drawHudAll();
          } else {
            this.msgFrom(thing, "" + thing.name + " is no longer " + flag);
          }
        } else {
          if (flag === Brew.flags.on_fire.id) {
            if (Brew.utils.compareThing(thing, this.my_player)) {
              this.my_player.getStat(Brew.stat.stamina).deduct(1);
              this.my_player.last_attacked = this.turn;
              Brew.Display.drawHudAll();
            } else {
              thing.getStat(Brew.stat.health).deduct(1);
              if (thing.getStat(Brew.stat.health).isZero()) {
                this.killMonster(this.my_player, thing, false, 0);
              }
            }
          }
        }
      }
      return true;
    };

    GameObject.prototype.debugClick = function(map_xy) {
      var debug_id, def_id, monster, objtype, _ref;
      debug_id = $("#id_select_debug").val();
      _ref = debug_id.split("-"), objtype = _ref[0], def_id = _ref[1];
      if (objtype === "MONSTER") {
        monster = Brew.monsterFactory(def_id);
        this.my_level.setMonsterAt(map_xy, monster);
        Brew.Display.drawMapAt(map_xy);
        return this.scheduler.add(monster, true);
      }
    };

    GameObject.prototype.debugDropdownMenu = function() {
      var def_id, monster_def, _ref, _results;
      _ref = Brew.monster_def;
      _results = [];
      for (def_id in _ref) {
        if (!__hasProp.call(_ref, def_id)) continue;
        monster_def = _ref[def_id];
        if (def_id === "PLAYER") {
          continue;
        }
        _results.push($("#id_select_debug").append("<option value=\"MONSTER-" + def_id + "\">" + def_id + "</option>"));
      }
      return _results;
    };

    return GameObject;

  })();

}).call(this);

//# sourceMappingURL=brew_game.map
