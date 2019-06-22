// Generated by CoffeeScript 1.7.1
(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  window.Brew.Effect = (function(_super) {
    __extends(Effect, _super);

    function Effect(effect_type) {
      Effect.__super__.constructor.call(this, "effect");
      this.effectType = effect_type;
      this.turn = 0;
      this.active = true;
      this.over_saturate = false;
      this.animation_speed = Brew.config.animation_speed;
    }

    Effect.prototype.runTurn = function() {
      this.cleanup();
      this.turn += 1;
      return this.update();
    };

    Effect.prototype.getSpeed = function() {
      return 10000;
    };

    return Effect;

  })(Brew.Thing);

  window.Brew.FlashEffect = (function(_super) {
    __extends(FlashEffect, _super);

    function FlashEffect(flash_xy, flash_color) {
      this.flash_xy = flash_xy;
      this.flash_color = flash_color;
      FlashEffect.__super__.constructor.call(this, "effect_flash");
      this.lastOverhead = null;
    }

    FlashEffect.prototype.cleanup = function() {
      if (this.turn === 1) {
        if (this.lastOverhead != null) {
          Brew.gameLevel().setOverheadAt(this.flash_xy, this.lastOverhead);
        } else {
          Brew.gameLevel().removeOverheadAt(this.flash_xy);
        }
        return Brew.Display.drawMapAt(this.flash_xy);
      }
    };

    FlashEffect.prototype.update = function() {
      var flash, overhead;
      if (this.turn === 1) {
        overhead = Brew.gameLevel().getOverheadAt(this.flash_xy);
        if (overhead != null) {
          this.lastOverhead = overhead;
        }
        flash = Brew.featureFactory("TILE_FLASH", {
          color: this.flash_color
        });
        Brew.gameLevel().setOverheadAt(this.flash_xy, flash);
        return Brew.Display.drawMapAt(this.flash_xy);
      } else {
        return this.active = false;
      }
    };

    return FlashEffect;

  })(Brew.Effect);

  window.Brew.ProjectileEffect = (function(_super) {
    __extends(ProjectileEffect, _super);

    function ProjectileEffect(original_attacker, projectile_feature, full_path_lst) {
      var _ref;
      this.original_attacker = original_attacker;
      this.projectile_feature = projectile_feature;
      this.full_path_lst = full_path_lst;
      ProjectileEffect.__super__.constructor.call(this, "effect_projectile");
      this.lastOverhead = null;
      if (((_ref = this.projectile_feature) != null ? _ref.light_source : void 0) != null) {
        this.over_saturate = true;
      }
    }

    ProjectileEffect.prototype.cleanup = function() {
      var idx, last_xy;
      if (this.turn === 0) {
        return;
      }
      idx = this.turn - 1;
      if (idx >= this.full_path_lst.length) {
        console.log("tried to clean up bad index " + idx);
        return;
      }
      last_xy = this.full_path_lst[idx];
      if (this.lastOverhead != null) {
        Brew.gameLevel().setOverheadAt(last_xy, this.lastOverhead);
      } else {
        Brew.gameLevel().removeOverheadAt(last_xy);
      }
      Brew.Display.drawMapAt(last_xy);
      return this.lastOverhead = null;
    };

    ProjectileEffect.prototype.update = function() {
      var idx, next_xy, overhead, target;
      idx = this.turn - 1;
      if (idx === this.full_path_lst.length) {
        console.log("error, index too high on pathing animation");
        this.active = false;
        return;
      }
      next_xy = this.full_path_lst[idx];
      if (idx === this.full_path_lst.length - 1) {
        this.active = false;
        target = Brew.gameLevel().getMonsterAt(next_xy);
        if (target != null) {
          Brew.Combat.attack(this.original_attacker, target, false, {
            remote: this.projectile_feature
          });
          return console.log("attacking target at " + next_xy);
        }
      } else {
        overhead = Brew.gameLevel().getOverheadAt(next_xy);
        if (overhead != null) {
          this.lastOverhead = overhead;
        }
        Brew.gameLevel().setOverheadAt(next_xy, this.projectile_feature);
        return Brew.Display.drawMapAt(next_xy, {
          over_saturate: this.over_saturate
        });
      }
    };

    return ProjectileEffect;

  })(Brew.Effect);

  window.Brew.ThrownEffect = (function(_super) {
    __extends(ThrownEffect, _super);

    function ThrownEffect(thrower, projectile_item, full_path_lst) {
      this.thrower = thrower;
      this.projectile_item = projectile_item;
      this.full_path_lst = full_path_lst;
      ThrownEffect.__super__.constructor.call(this, "effect_thrown");
      this.lastOverhead = null;
    }

    ThrownEffect.prototype.cleanup = function() {
      var idx, last_xy;
      if (this.turn === 0) {
        return;
      }
      idx = this.turn - 1;
      if (idx >= this.full_path_lst.length) {
        console.log("tried to clean up bad index " + idx);
        return;
      }
      last_xy = this.full_path_lst[idx];
      if (this.lastOverhead != null) {
        Brew.gameLevel().setOverheadAt(last_xy, this.lastOverhead);
      } else {
        Brew.gameLevel().removeOverheadAt(last_xy);
      }
      Brew.Display.drawMapAt(last_xy);
      return this.lastOverhead = null;
    };

    ThrownEffect.prototype.update = function() {
      var idx, next_xy, overhead;
      idx = this.turn - 1;
      if (idx === this.full_path_lst.length) {
        console.log("error, index too high on pathing animation");
        this.active = false;
        return;
      }
      next_xy = this.full_path_lst[idx];
      if (idx === this.full_path_lst.length - 1) {
        this.active = false;
        Brew.gameLevel().setItemAt(next_xy, this.projectile_item);
        return Brew.Display.drawMapAt(next_xy);
      } else {
        overhead = Brew.gameLevel().getOverheadAt(next_xy);
        if (overhead != null) {
          this.lastOverhead = overhead;
        }
        Brew.gameLevel().setOverheadAt(next_xy, this.projectile_item);
        return Brew.Display.drawMapAt(next_xy);
      }
    };

    return ThrownEffect;

  })(Brew.Effect);

  window.Brew.RecallEffect = (function(_super) {
    __extends(RecallEffect, _super);

    function RecallEffect() {
      return RecallEffect.__super__.constructor.apply(this, arguments);
    }

    RecallEffect.prototype.update = function() {
      var idx, m, next_xy, overhead;
      idx = this.turn - 1;
      if (idx === this.full_path_lst.length) {
        console.log("error, index too high on pathing animation");
        this.active = false;
        return;
      }
      next_xy = this.full_path_lst[idx];
      if (idx === this.full_path_lst.length - 1) {
        this.active = false;
        Brew.Display.drawMapAt(next_xy);
        return Brew.Axe.finishRecallAxe(this.projectile_item);
      } else {
        overhead = Brew.gameLevel().getOverheadAt(next_xy);
        if (overhead != null) {
          this.lastOverhead = overhead;
        }
        m = Brew.gameLevel().getMonsterAt(next_xy);
        if ((m != null) && !Brew.utils.compareThing(this.thrower, m)) {
          this.recallSmash(m, next_xy);
        }
        Brew.gameLevel().setOverheadAt(next_xy, this.projectile_item);
        return Brew.Display.drawMapAt(next_xy);
      }
    };

    RecallEffect.prototype.recallSmash = function(target, target_xy) {
      var path_damage;
      path_damage = Math.min(Brew.config.max_recall_damage, this.full_path_lst.length);
      return Brew.Combat.attack(this.thrower, target, true, {
        remote: this.projectile_item,
        recall_damage: path_damage
      });
    };

    return RecallEffect;

  })(Brew.ThrownEffect);

  window.Brew.ShapeEffect = (function(_super) {
    __extends(ShapeEffect, _super);

    function ShapeEffect(center_xy, max_radius, shape_color) {
      this.center_xy = center_xy;
      this.max_radius = max_radius;
      this.shape_color = shape_color;
      ShapeEffect.__super__.constructor.call(this, "effect_shape");
      this.overhead_cache = {};
      this.over_saturate = false;
      this.animation_speed = 50;
    }

    ShapeEffect.prototype.cleanup = function() {
      var cached_overhead, xy, _i, _len, _ref, _results;
      if (this.turn === 0) {
        return;
      }
      _ref = this.getPoints();
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        xy = _ref[_i];
        cached_overhead = this.overhead_cache[xy.toKey()];
        if (cached_overhead != null) {
          Brew.gameLevel().setOverheadAt(xy, cached_overhead);
        } else {
          Brew.gameLevel().removeOverheadAt(xy);
        }
        _results.push(Brew.Display.drawMapAt(xy));
      }
      return _results;
    };

    ShapeEffect.prototype.update = function() {
      var existing_overhead, flash, xy, _i, _len, _ref, _results;
      if (this.turn > this.max_radius) {
        this.active = false;
        return;
      }
      _ref = this.getPoints();
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        xy = _ref[_i];
        existing_overhead = Brew.gameLevel().getOverheadAt(xy);
        if ((existing_overhead != null) && Brew.utils.compareDef(existing_overhead, "TILE_FLASH")) {
          continue;
        } else {
          this.overhead_cache[xy.toKey()] = existing_overhead;
          flash = Brew.featureFactory("TILE_FLASH", {
            color: this.shape_color
          });
          Brew.gameLevel().setOverheadAt(xy, flash);
          _results.push(Brew.Display.drawMapAt(xy));
        }
      }
      return _results;
    };

    return ShapeEffect;

  })(Brew.Effect);

  window.Brew.CircleEffect = (function(_super) {
    __extends(CircleEffect, _super);

    function CircleEffect() {
      return CircleEffect.__super__.constructor.apply(this, arguments);
    }

    CircleEffect.prototype.getPoints = function() {
      var circle_lst, points_lst, xy, _i, _len;
      circle_lst = Brew.utils.getCirclePoints(this.center_xy, this.turn);
      points_lst = [];
      for (_i = 0, _len = circle_lst.length; _i < _len; _i++) {
        xy = circle_lst[_i];
        if (!Brew.gameLevel().checkValid(xy)) {
          continue;
        }
        points_lst.push(xy);
      }
      return points_lst;
    };

    return CircleEffect;

  })(Brew.ShapeEffect);

  window.Brew.SquareEffect = (function(_super) {
    __extends(SquareEffect, _super);

    function SquareEffect() {
      return SquareEffect.__super__.constructor.apply(this, arguments);
    }

    SquareEffect.prototype.getPoints = function() {
      var corner_xy, length, points_lst, rectangle, xy, _i, _len, _ref;
      corner_xy = this.center_xy.subtract(new Coordinate(this.turn, this.turn));
      length = (this.turn * 2) + 1;
      rectangle = new Brew.Rectangle(corner_xy.x, corner_xy.y, length, length);
      points_lst = [];
      _ref = rectangle.getWalls();
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        xy = _ref[_i];
        if (!Brew.gameLevel().checkValid(xy)) {
          continue;
        }
        points_lst.push(xy);
      }
      return points_lst;
    };

    return SquareEffect;

  })(Brew.ShapeEffect);

  window.Brew.TauntEffect = (function(_super) {
    __extends(TauntEffect, _super);

    function TauntEffect() {
      return TauntEffect.__super__.constructor.apply(this, arguments);
    }

    TauntEffect.prototype.update = function() {
      var existing_overhead, flash, xy, _i, _len, _ref, _results;
      if (this.turn > this.max_radius) {
        this.active = false;
        return;
      }
      _ref = this.getPoints();
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        xy = _ref[_i];
        existing_overhead = Brew.gameLevel().getOverheadAt(xy);
        if ((existing_overhead != null) && Brew.utils.compareDef(existing_overhead, "TILE_FLASH")) {
          continue;
        } else {
          this.overhead_cache[xy.toKey()] = existing_overhead;
          flash = Brew.featureFactory("TILE_FLASH", {
            color: this.shape_color
          });
          Brew.Axe.tauntMonsterAt(xy);
          Brew.gameLevel().setOverheadAt(xy, flash);
          _results.push(Brew.Display.drawMapAt(xy));
        }
      }
      return _results;
    };

    return TauntEffect;

  })(Brew.SquareEffect);

  window.Brew.ShinyEffect = (function(_super) {
    __extends(ShinyEffect, _super);

    function ShinyEffect(target_xy, shine_color) {
      this.target_xy = target_xy;
      this.shine_color = shine_color;
      ShinyEffect.__super__.constructor.call(this, "effect_shiny");
      this.over_saturate = true;
      this.overhead_cache = null;
      this.animation_speed = 100;
    }

    ShinyEffect.prototype.cleanup = function() {
      if (this.turn === 1) {
        Brew.gameLevel().removeOverheadAt(this.target_xy);
        if (this.overhead_cache != null) {
          return Brew.gameLevel().setOverheadAt(this.target, this.overhead_cache);
        }
      }
    };

    ShinyEffect.prototype.update = function() {
      var existing_overhead, flash, m;
      if (this.turn === 1) {
        existing_overhead = Brew.gameLevel().getOverheadAt(this.target_xy);
        if (existing_overhead != null) {
          this.overhead_cache = existing_overhead;
        }
        flash = Brew.featureFactory("TILE_FLASH", {
          color: this.shine_color,
          light_source: this.shine_color
        });
        m = Brew.gameLevel().getMonsterAt(this.target_xy);
        if (m != null) {
          flash.code = m.code;
        }
        return Brew.gameLevel().setOverheadAt(this.target_xy, flash);
      } else {
        return this.active = false;
      }
    };

    return ShinyEffect;

  })(Brew.Effect);

}).call(this);

//# sourceMappingURL=effect.map