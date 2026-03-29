#===============================================================================
# POKEMON SURVIVORS – A Vampire Survivors-style Minigame Mod
# Launch from debug console or event: pbPokemonSurvivors
#===============================================================================

module PokeSurvivors
  ARENA_W       = 2400
  ARENA_H       = 2400
  GAME_DURATION = 300      # 5 minutes
  MAX_MOBS      = 100
  MAX_GEMS      = 80
  MAX_PROJ      = 60
  MAX_POPUPS    = 30
  PLAYER_HP     = 100
  PLAYER_SPEED  = 3.0
  IFRAMES       = 40
  PICKUP_RANGE  = 60
  MAGNET_RANGE  = 120
  ANIM_SPEED    = 8
  MAX_WEAPONS   = 4
  MAX_PASSIVES  = 4

  DIR_DOWN  = 0
  DIR_LEFT  = 1
  DIR_RIGHT = 2
  DIR_UP    = 3

  TIER1 = %w[RATTATA PIDGEY CATERPIE WEEDLE ZUBAT MAGIKARP SENTRET ZIGZAGOON BIDOOF WURMPLE]
  TIER2 = %w[PIKACHU EEVEE GEODUDE MACHOP GASTLY GROWLITHE ODDISH POLIWAG VULPIX MEOWTH]
  TIER3 = %w[GENGAR ALAKAZAM SCYTHER ARCANINE LAPRAS SNORLAX HERACROSS MACHAMP GOLEM STEELIX]
  BOSSES = %w[MEWTWO RAYQUAZA GIRATINA ARCEUS DIALGA]

  TIERS = [
    { names: TIER1, hp: 20,  speed: 1.2, dmg: 5,  xp: 4, scale: 1.0 },
    { names: TIER2, hp: 40,  speed: 1.5, dmg: 8,  xp: 6, scale: 1.0 },
    { names: TIER3, hp: 80,  speed: 1.8, dmg: 12, xp: 8, scale: 1.2 },
  ]
  BOSS_CFG = { hp: 500, speed: 1.0, dmg: 20, xp: 60, scale: 2.0 }

  SPAWN_SCHEDULE = [
    { t: 0,   interval: 180, count: 1, max_tier: 0 },
    { t: 15,  interval: 140, count: 1, max_tier: 0 },
    { t: 30,  interval: 120, count: 2, max_tier: 0 },
    { t: 50,  interval: 100, count: 2, max_tier: 0 },
    { t: 75,  interval: 80,  count: 3, max_tier: 1 },
    { t: 100, interval: 65,  count: 3, max_tier: 1 },
    { t: 130, interval: 55,  count: 4, max_tier: 1 },
    { t: 160, interval: 45,  count: 4, max_tier: 2 },
    { t: 190, interval: 38,  count: 5, max_tier: 2 },
    { t: 220, interval: 30,  count: 6, max_tier: 2 },
    { t: 250, interval: 22,  count: 7, max_tier: 2 },
    { t: 275, interval: 15,  count: 8, max_tier: 2 },
  ]
  BOSS_TIMES = [60, 120, 180, 240, 295]

  ANIM_FIRE    = "Graphics/Animations/015-Fire01"
  ANIM_ICE     = "Graphics/Animations/016-Ice01"
  ANIM_THUNDER = "Graphics/Animations/017-Thunder01"
  ANIM_DARK    = "Graphics/Animations/022-Darkness01"
  ANIM_EXPLODE = "Graphics/Animations/030-Explosion01"
  ANIM_SLASH   = "Graphics/Animations/004-Attack02"

  FONT_TITLE = "Power Red and Green"
  FONT_BODY  = "Power Green Small"

  WEAPONS = {
    slash: {
      name: "Slash", desc: "Melee strike at nearest foe",
      color: [255, 255, 100], type: :melee,
      anim: { sheet: ANIM_SLASH, frames: [[0,0],[1,0],[2,0],[3,0],[4,0],[0,1],[1,1]], sz: 40, spd: 3 },
      levels: [
        { dmg: 8,  cd: 40, range: 80  },
        { dmg: 12, cd: 35, range: 90  },
        { dmg: 16, cd: 30, range: 100 },
        { dmg: 22, cd: 25, range: 110 },
        { dmg: 30, cd: 20, range: 120 },
      ]
    },
    ember: {
      name: "Ember", desc: "Fireball at nearest foe",
      color: [255, 120, 30], type: :projectile,
      anim: { sheet: ANIM_FIRE, frames: [[0,1],[1,1],[2,1]], sz: 24, spd: 6 },
      levels: [
        { dmg: 10, cd: 90,  n: 1, spd: 5,   sz: 14, pierce: 0, range: 300 },
        { dmg: 15, cd: 80,  n: 1, spd: 5.5, sz: 15, pierce: 0, range: 320 },
        { dmg: 20, cd: 70,  n: 2, spd: 6,   sz: 16, pierce: 0, range: 340 },
        { dmg: 28, cd: 60,  n: 2, spd: 6.5, sz: 17, pierce: 1, range: 360 },
        { dmg: 38, cd: 45,  n: 3, spd: 7,   sz: 18, pierce: 1, range: 400 },
      ]
    },
    razor_leaf: {
      name: "Razor Leaf", desc: "Orbiting leaves",
      color: [60, 200, 60], type: :orbit,
      anim: { sheet: ANIM_FIRE, frames: [[3,1],[4,1]], sz: 20, spd: 8 },
      levels: [
        { dmg: 8,  n: 2, radius: 70,  spd: 0.04, sz: 10, hit_cd: 30 },
        { dmg: 12, n: 3, radius: 80,  spd: 0.045,sz: 11, hit_cd: 28 },
        { dmg: 18, n: 4, radius: 90,  spd: 0.05, sz: 12, hit_cd: 25 },
        { dmg: 24, n: 5, radius: 105, spd: 0.055,sz: 13, hit_cd: 22 },
        { dmg: 32, n: 6, radius: 120, spd: 0.06, sz: 14, hit_cd: 18 },
      ]
    },
    thunderbolt: {
      name: "Thunderbolt", desc: "Lightning strikes nearby foes",
      color: [255, 255, 60], type: :strike,
      anim: { sheet: ANIM_THUNDER, frames: [[2,0],[3,0],[4,0],[0,1]], sz: 48, spd: 4 },
      levels: [
        { dmg: 18, cd: 120, n: 1, range: 200 },
        { dmg: 24, cd: 105, n: 2, range: 220 },
        { dmg: 32, cd: 90,  n: 3, range: 250 },
        { dmg: 40, cd: 75,  n: 4, range: 280 },
        { dmg: 55, cd: 60,  n: 5, range: 320 },
      ]
    },
    shadow_ball: {
      name: "Shadow Ball", desc: "Piercing dark orb",
      color: [140, 50, 200], type: :projectile,
      anim: { sheet: ANIM_DARK, frames: [[0,0],[1,0],[2,0]], sz: 28, spd: 6 },
      levels: [
        { dmg: 12, cd: 100, n: 1, spd: 4,   sz: 16, pierce: 3,  range: 350 },
        { dmg: 18, cd: 90,  n: 1, spd: 4.5, sz: 17, pierce: 4,  range: 370 },
        { dmg: 24, cd: 80,  n: 1, spd: 5,   sz: 18, pierce: 6,  range: 400 },
        { dmg: 32, cd: 70,  n: 2, spd: 5.5, sz: 20, pierce: 8,  range: 430 },
        { dmg: 42, cd: 55,  n: 2, spd: 6,   sz: 22, pierce: 99, range: 500 },
      ]
    },
    ice_beam: {
      name: "Ice Beam", desc: "Freezing beam, slows foes",
      color: [100, 200, 255], type: :projectile,
      anim: { sheet: ANIM_ICE, frames: [[0,0],[1,0],[2,0]], sz: 22, spd: 5 },
      levels: [
        { dmg: 8,  cd: 80, n: 1, spd: 6,   sz: 12, pierce: 2, range: 280, slow: 0.4 },
        { dmg: 12, cd: 72, n: 1, spd: 6.5, sz: 13, pierce: 3, range: 300, slow: 0.45 },
        { dmg: 16, cd: 64, n: 2, spd: 7,   sz: 14, pierce: 4, range: 330, slow: 0.5 },
        { dmg: 22, cd: 55, n: 2, spd: 7.5, sz: 15, pierce: 5, range: 360, slow: 0.55 },
        { dmg: 30, cd: 45, n: 3, spd: 8,   sz: 16, pierce: 7, range: 400, slow: 0.6 },
      ]
    },
    earthquake: {
      name: "Earthquake", desc: "AoE ground smash",
      color: [180, 140, 80], type: :aoe,
      anim: { sheet: ANIM_EXPLODE, frames: [[0,0],[1,0],[2,0],[3,0]], sz: 48, spd: 4 },
      levels: [
        { dmg: 15, cd: 180, radius: 120 },
        { dmg: 22, cd: 160, radius: 140 },
        { dmg: 30, cd: 140, radius: 165 },
        { dmg: 40, cd: 120, radius: 190 },
        { dmg: 55, cd: 100, radius: 220 },
      ]
    },
  }

  PASSIVES = {
    quick_feet:    { name: "Quick Feet",    desc: "+Move speed",     lvs: [0.15, 0.30, 0.50] },
    thick_fat:     { name: "Thick Fat",     desc: "+Max HP",         lvs: [25, 55, 90] },
    natural_cure:  { name: "Natural Cure",  desc: "HP regen/sec",    lvs: [0.5, 1.0, 1.8] },
    sniper:        { name: "Sniper",        desc: "+Damage",         lvs: [0.15, 0.30, 0.50] },
    compound_eyes: { name: "Compound Eyes", desc: "+Pickup range",   lvs: [0.40, 0.80, 1.30] },
    iron_barbs:    { name: "Iron Barbs",    desc: "-Damage taken",   lvs: [0.12, 0.24, 0.40] },
  }

  # First 2–3 levels come quickly; then requirements scale up.
  def self.xp_for_level(lv)
    case lv
    when 1 then 4   # level 1 → 2
    when 2 then 5   # level 2 → 3
    when 3 then 8   # level 3 → 4
    else
      # Level 4+: 12, then +4, +5, +6, ... so 12 + (4+5+...+(lv-1))
      n = lv - 4
      12 + n * (4 + (lv - 1)) / 2
    end
  end

  class << self
    attr_accessor :cam_x, :cam_y, :sw, :sh
  end
end

#─── Bitmap Cache ──────────────────────────────────────────────────────────────
module PokeSurvivors::Cache
  @bitmaps = {}

  def self.load(path)
    return @bitmaps[path] if @bitmaps.key?(path)
    bmp = Bitmap.new(path) rescue nil
    unless bmp
      full = path + ".png"
      bmp = Bitmap.new(full) rescue nil if File.exist?(full)
    end
    unless bmp
      full = path + ".PNG"
      bmp = Bitmap.new(full) rescue nil if File.exist?(full)
    end
    @bitmaps[path] = bmp
    bmp
  end

  def self.follower(name)
    load("Graphics/Characters/Followers/#{name}")
  end

  def self.player_walk
    load("Graphics/Characters/player/base/overworld/default/walk_default")
  end

  def self.player_composed
    return @bitmaps["_player_composed"] if @bitmaps.key?("_player_composed")
    bmp = nil
    if defined?(generateClothedBitmapStatic) && $Trainer
      bmp = generateClothedBitmapStatic($Trainer, "walk") rescue nil
    end
    bmp ||= player_walk
    @bitmaps["_player_composed"] = bmp
    bmp
  end

  def self.anim_frame(sheet_path, col, row, target_sz)
    key = "_af_#{sheet_path}_#{col}_#{row}_#{target_sz}"
    return @bitmaps[key] if @bitmaps.key?(key)
    begin
      sheet = load(sheet_path)
      unless sheet
        @bitmaps[key] = nil
        return nil
      end
      cell_w = sheet.width / 5
      cell_h = [cell_w, sheet.height].min
      rows = (sheet.height.to_f / cell_h).floor
      if row >= rows || col >= 5
        @bitmaps[key] = nil
        return nil
      end
      src = Rect.new(col * cell_w, row * cell_h, cell_w, cell_h)
      bmp = Bitmap.new(target_sz, target_sz)
      bmp.stretch_blt(Rect.new(0, 0, target_sz, target_sz), sheet, src)
      @bitmaps[key] = bmp
      bmp
    rescue
      @bitmaps[key] = nil
      nil
    end
  end

  def self.anim_frames(sheet_path, frames_spec, target_sz)
    frames_spec.map { |col, row| anim_frame(sheet_path, col, row, target_sz) }.compact
  end

  def self.ebdx(name)
    key = "_ebdx_#{name}"
    return @bitmaps[key] if @bitmaps.key?(key)
    bmp = nil
    begin
      bmp = pbBitmap("Graphics/EBDX/Animations/Moves/#{name}") if defined?(pbBitmap)
    rescue
    end
    bmp ||= load("Graphics/EBDX/Animations/Moves/#{name}")
    @bitmaps[key] = bmp
    bmp
  end

  def self.proj_bitmap(weapon_key, sz)
    d = sz * 2
    begin
      case weapon_key
      when :ember
        v = rand(3)
        key = "_proj_ember_#{d}_#{v}"
        return @bitmaps[key] if @bitmaps.key?(key)
        src = ebdx("eb136")
        if src
          bmp = Bitmap.new(d, d)
          bmp.stretch_blt(Rect.new(0, 0, d, d), src, Rect.new(0, 101 * v, 53, 101))
          @bitmaps[key] = bmp
          return bmp
        end
      when :shadow_ball
        key = "_proj_shadow_#{d}"
        return @bitmaps[key] if @bitmaps.key?(key)
        src = ebdx("eb175_1")
        if src
          bmp = Bitmap.new(d, d)
          bmp.stretch_blt(Rect.new(0, 0, d, d), src, Rect.new(0, 0, src.width, src.height))
          @bitmaps[key] = bmp
          return bmp
        end
      when :ice_beam
        key = "_proj_ice_#{d}"
        return @bitmaps[key] if @bitmaps.key?(key)
        src = ebdx("eb250")
        if src
          bmp = Bitmap.new(d, d)
          bmp.stretch_blt(Rect.new(0, 0, d, d), src, Rect.new(0, 0, src.width, src.height))
          @bitmaps[key] = bmp
          return bmp
        end
      end
    rescue
    end
    nil
  end

  def self.ebdx_leaf(target_sz)
    key = "_ebdx_leaf_#{target_sz}"
    return @bitmaps[key] if @bitmaps.key?(key)
    src = ebdx("eb191_2")
    if src
      bmp = Bitmap.new(target_sz, target_sz)
      bmp.stretch_blt(Rect.new(0, 0, target_sz, target_sz), src, Rect.new(0, 0, src.width, src.height))
      @bitmaps[key] = bmp
      return bmp
    end
    @bitmaps[key] = nil
    nil
  end

  def self.ebdx_bolt(idx, target_w, target_h)
    key = "_ebdx_bolt_#{idx}_#{target_w}_#{target_h}"
    return @bitmaps[key] if @bitmaps.key?(key)
    src = ebdx("eb069_2")
    if src
      bolt_w = src.width / 3
      bmp = Bitmap.new(target_w, target_h)
      bmp.stretch_blt(Rect.new(0, 0, target_w, target_h), src, Rect.new(idx * bolt_w, 0, bolt_w, src.height))
      @bitmaps[key] = bmp
      return bmp
    end
    @bitmaps[key] = nil
    nil
  end

  def self.gem_bmp_for_value(val)
    key = val >= 30 ? "_gem_boss" : val >= 9 ? "_gem_large" : val >= 3 ? "_gem_medium" : "_gem_small"
    return @bitmaps[key] if @bitmaps.key?(key)
    bmp = case key
          when "_gem_small"  then PokeSurvivors::Gfx.gem_bmp_small
          when "_gem_medium" then PokeSurvivors::Gfx.gem_bmp_medium
          when "_gem_large"  then PokeSurvivors::Gfx.gem_bmp_large
          else                    PokeSurvivors::Gfx.gem_bmp_boss
          end
    @bitmaps[key] = bmp
    bmp
  end

  def self.placeholder(w, h, r, g, b)
    key = "_ph_#{w}_#{h}_#{r}_#{g}_#{b}"
    return @bitmaps[key] if @bitmaps[key]
    bmp = Bitmap.new(w, h)
    c = Color.new(r, g, b)
    fw = w / 4; fh = h / 4
    4.times { |row| 4.times { |col| bmp.fill_rect(col * fw + 4, row * fh + 4, fw - 8, fh - 8, c) } }
    @bitmaps[key] = bmp
  end

  def self.dispose_all
    @bitmaps.each_value { |b| b.dispose if b && !b.disposed? }
    @bitmaps.clear
  end
end

#─── Procedural Bitmap Helpers ─────────────────────────────────────────────────
module PokeSurvivors::Gfx
  def self.circle(sz, r, g, b)
    d = sz * 2
    bmp = Bitmap.new(d, d)
    c = Color.new(r, g, b)
    (-sz..sz).each do |dy|
      hw = Math.sqrt([sz * sz - dy * dy, 0].max).to_i
      next if hw <= 0
      bmp.fill_rect(sz - hw, sz + dy, hw * 2, 1, c)
    end
    bmp
  end

  def self.glow_orb(sz, r, g, b)
    pad = 4
    d = (sz + pad) * 2
    bmp = Bitmap.new(d, d)
    cx = d / 2; cy = d / 2
    gr = sz + pad - 1
    gc = Color.new([r + 80, 255].min, [g + 80, 255].min, [b + 80, 255].min, 90)
    (-gr..gr).each do |dy|
      hw = Math.sqrt([gr * gr - dy * dy, 0].max).to_i
      next if hw <= 0
      bmp.fill_rect(cx - hw, cy + dy, hw * 2, 1, gc)
    end
    mc = Color.new(r, g, b)
    (-sz..sz).each do |dy|
      hw = Math.sqrt([sz * sz - dy * dy, 0].max).to_i
      next if hw <= 0
      bmp.fill_rect(cx - hw, cy + dy, hw * 2, 1, mc)
    end
    cs = [sz * 2 / 5, 3].max
    bc = Color.new([r + 150, 255].min, [g + 150, 255].min, [b + 150, 255].min)
    (-cs..cs).each do |dy|
      hw = Math.sqrt([cs * cs - dy * dy, 0].max).to_i
      next if hw <= 0
      bmp.fill_rect(cx - hw, cy + dy, hw * 2, 1, bc)
    end
    bmp
  end

  def self.diamond(sz, r, g, b)
    d = sz * 2
    bmp = Bitmap.new(d, d)
    c = Color.new(r, g, b)
    sz.times do |i|
      w = (i + 1) * 2
      bmp.fill_rect(sz - i - 1, i, w, 1, c)
      bmp.fill_rect(sz - i - 1, d - 1 - i, w, 1, c)
    end
    bmp
  end

  def self.gem_bmp
    bmp = Bitmap.new(10, 10)
    bmp.fill_rect(3, 0, 4, 10, Color.new(80, 180, 255))
    bmp.fill_rect(0, 3, 10, 4, Color.new(80, 180, 255))
    bmp.fill_rect(2, 1, 6, 8, Color.new(120, 210, 255))
    bmp.fill_rect(4, 3, 2, 4, Color.new(200, 240, 255))
    bmp
  end

  # Small (1–2 xp): blue, 8px
  def self.gem_bmp_small
    bmp = Bitmap.new(8, 8)
    bmp.fill_rect(2, 0, 4, 8, Color.new(80, 160, 255))
    bmp.fill_rect(0, 2, 8, 4, Color.new(80, 160, 255))
    bmp.fill_rect(2, 2, 4, 4, Color.new(140, 200, 255))
    bmp
  end

  # Medium (3–8 xp): green-cyan, 10px
  def self.gem_bmp_medium
    bmp = Bitmap.new(10, 10)
    bmp.fill_rect(3, 0, 4, 10, Color.new(60, 200, 140))
    bmp.fill_rect(0, 3, 10, 4, Color.new(60, 200, 140))
    bmp.fill_rect(2, 1, 6, 8, Color.new(100, 230, 180))
    bmp.fill_rect(4, 3, 2, 4, Color.new(180, 255, 220))
    bmp
  end

  # Large (9–29 xp): gold, 12px
  def self.gem_bmp_large
    bmp = Bitmap.new(12, 12)
    bmp.fill_rect(4, 0, 4, 12, Color.new(220, 180, 60))
    bmp.fill_rect(0, 4, 12, 4, Color.new(220, 180, 60))
    bmp.fill_rect(3, 2, 6, 8, Color.new(255, 220, 100))
    bmp.fill_rect(5, 4, 2, 4, Color.new(255, 248, 180))
    bmp
  end

  # Boss (30+ xp): purple/red sparkle, 14px
  def self.gem_bmp_boss
    bmp = Bitmap.new(14, 14)
    bmp.fill_rect(4, 0, 6, 14, Color.new(200, 80, 255))
    bmp.fill_rect(0, 4, 14, 6, Color.new(200, 80, 255))
    bmp.fill_rect(3, 2, 8, 10, Color.new(230, 120, 255))
    bmp.fill_rect(5, 4, 4, 6, Color.new(255, 200, 255))
    bmp
  end
end

#─── Player ────────────────────────────────────────────────────────────────────
class PokeSurvivors::Player
  attr_accessor :x, :y, :hp, :max_hp, :level, :xp, :xp_needed
  attr_accessor :weapons, :passives, :kills, :iframes
  attr_reader :sprite, :fw, :fh, :alive

  def initialize(vp)
    @x = PokeSurvivors::ARENA_W / 2.0
    @y = PokeSurvivors::ARENA_H / 2.0
    @max_hp = PokeSurvivors::PLAYER_HP.to_f
    @hp = @max_hp
    @level = 1; @xp = 0
    @xp_needed = PokeSurvivors.xp_for_level(1)
    @weapons  = { slash: 0 }
    @passives = {}
    @kills = 0; @iframes = 0; @alive = true
    @dir = 0; @frame = 0; @anim_ct = 0

    bmp = PokeSurvivors::Cache.player_composed
    bmp ||= PokeSurvivors::Cache.placeholder(128, 128, 220, 180, 120)
    @sprite = Sprite.new(vp)
    @sprite.bitmap = bmp
    @fw = bmp.width / 4; @fh = bmp.height / 4
    @sprite.src_rect.set(0, 0, @fw, @fh)
    @sprite.ox = @fw / 2; @sprite.oy = @fh / 2
    @sprite.z = 100
  end

  def pv(key)
    return nil unless @passives[key]
    PokeSurvivors::PASSIVES[key][:lvs][@passives[key]]
  end

  def eff_speed;   PokeSurvivors::PLAYER_SPEED * (1.0 + (pv(:quick_feet) || 0)); end
  def dmg_mult;    1.0 + (pv(:sniper) || 0); end
  def dmg_reduce;  pv(:iron_barbs) || 0; end
  def pickup_r;    PokeSurvivors::PICKUP_RANGE  * (1.0 + (pv(:compound_eyes) || 0)); end
  def magnet_r;    PokeSurvivors::MAGNET_RANGE  * (1.0 + (pv(:compound_eyes) || 0)); end
  def regen_frame; (pv(:natural_cure) || 0) / 60.0; end

  def update
    dx = 0; dy = 0
    dx -= 1 if Input.press?(Input::LEFT)
    dx += 1 if Input.press?(Input::RIGHT)
    dy -= 1 if Input.press?(Input::UP)
    dy += 1 if Input.press?(Input::DOWN)
    moving = (dx != 0 || dy != 0)

    if moving
      if dx != 0 && dy != 0
        len = Math.sqrt(2); dx /= len; dy /= len
      end
      spd = eff_speed
      @x = (@x + dx * spd).clamp(20, PokeSurvivors::ARENA_W - 20)
      @y = (@y + dy * spd).clamp(20, PokeSurvivors::ARENA_H - 20)
      @dir = (dx.abs > dy.abs) ? (dx > 0 ? 2 : 1) : (dy > 0 ? 0 : 3)
      @anim_ct += 1
      if @anim_ct >= PokeSurvivors::ANIM_SPEED
        @anim_ct = 0; @frame = (@frame + 1) % 4
      end
    else
      @frame = 0; @anim_ct = 0
    end

    @hp = [@hp + regen_frame, @max_hp].min
    @iframes -= 1 if @iframes > 0

    @sprite.src_rect.set(@frame * @fw, @dir * @fh, @fw, @fh)
    @sprite.x = @x - PokeSurvivors.cam_x
    @sprite.y = @y - PokeSurvivors.cam_y
    @sprite.z  = @y.to_i
    @sprite.opacity = (@iframes > 0 && @iframes % 4 < 2) ? 100 : 255
  end

  def take_damage(amount)
    return if @iframes > 0
    actual = amount * (1.0 - dmg_reduce)
    @hp -= actual
    @iframes = PokeSurvivors::IFRAMES
    if @hp <= 0
      @hp = 0; @alive = false
    end
  end

  def add_xp(amount)
    @xp += amount
    leveled = false
    while @xp >= @xp_needed
      @xp -= @xp_needed
      @level += 1
      @xp_needed = PokeSurvivors.xp_for_level(@level)
      leveled = true
    end
    leveled
  end

  def dispose; @sprite.dispose if @sprite && !@sprite.disposed?; end
end

#─── Mob ───────────────────────────────────────────────────────────────────────
class PokeSurvivors::Mob
  attr_accessor :x, :y, :hp, :max_hp, :alive, :species, :xp_val, :damage, :is_boss
  attr_reader :sprite

  def initialize(vp)
    @vp = vp; @sprite = Sprite.new(vp)
    @alive = false; @sprite.visible = false
    @x = 0; @y = 0; @hp = 0; @max_hp = 0
    @speed = 0; @damage = 0; @xp_val = 0
    @species = ""; @is_boss = false
    @dir = 0; @frame = 0; @anim_ct = 0
    @fw = 32; @fh = 32; @hit_flash = 0
    @slow_timer = 0; @slow_factor = 0.0
  end

  def spawn(species, cfg, sx, sy, boss = false)
    @species = species; @is_boss = boss
    bmp = PokeSurvivors::Cache.follower(species)
    bmp ||= PokeSurvivors::Cache.placeholder(128, 128, 180, 60, 60)
    @sprite.bitmap = bmp
    @fw = bmp.width / 4; @fh = bmp.height / 4
    @sprite.src_rect.set(0, 0, @fw, @fh)
    @sprite.ox = @fw / 2; @sprite.oy = @fh / 2
    sc = cfg[:scale] || 1.0
    @sprite.zoom_x = sc; @sprite.zoom_y = sc
    @sprite.visible = true; @alive = true
    @x = sx; @y = sy
    @hp = cfg[:hp].to_f; @max_hp = @hp
    @speed = cfg[:speed]; @damage = cfg[:dmg]; @xp_val = cfg[:xp]
    @dir = 0; @frame = 0; @anim_ct = 0
    @hit_flash = 0; @slow_timer = 0; @slow_factor = 0.0
  end

  def update(px, py)
    return unless @alive
    dx = px - @x; dy = py - @y
    dist = Math.sqrt(dx * dx + dy * dy)
    if dist > 1
      dx /= dist; dy /= dist
      spd = @speed
      spd *= (1.0 - @slow_factor) if @slow_timer > 0
      @x += dx * spd; @y += dy * spd
      @dir = (dx.abs > dy.abs) ? (dx > 0 ? 2 : 1) : (dy > 0 ? 0 : 3)
      @anim_ct += 1
      if @anim_ct >= PokeSurvivors::ANIM_SPEED
        @anim_ct = 0; @frame = (@frame + 1) % 4
      end
    end
    @slow_timer -= 1 if @slow_timer > 0
    @hit_flash  -= 1 if @hit_flash > 0
    @sprite.src_rect.set(@frame * @fw, @dir * @fh, @fw, @fh)
    sx = @x - PokeSurvivors.cam_x; sy = @y - PokeSurvivors.cam_y
    @sprite.x = sx; @sprite.y = sy; @sprite.z = @y.to_i
    @sprite.color.set(@hit_flash > 0 ? 255 : 0, @hit_flash > 0 ? 255 : 0, @hit_flash > 0 ? 255 : 0, @hit_flash > 0 ? 160 : 0)
    margin = 100
    @sprite.visible = sx > -margin && sx < PokeSurvivors.sw + margin &&
                      sy > -margin && sy < PokeSurvivors.sh + margin
  end

  def take_damage(amount, slow_f = nil)
    return 0 unless @alive
    @hp -= amount; @hit_flash = 6
    if slow_f
      @slow_timer = 90; @slow_factor = slow_f
    end
    if @hp <= 0
      @alive = false; @sprite.visible = false
      return @xp_val
    end
    0
  end

  def col_r
    r = [(@fw * (@sprite.zoom_x || 1.0)) / 2.5, (@fh * (@sprite.zoom_y || 1.0)) / 2.5].min
    r.to_i
  end

  def deactivate; @alive = false; @sprite.visible = false; end
  def dispose; @sprite.dispose if @sprite && !@sprite.disposed?; end
end

#─── Projectile ────────────────────────────────────────────────────────────────
class PokeSurvivors::Projectile
  attr_accessor :alive, :dmg, :slow

  def initialize(vp)
    @sprite = Sprite.new(vp); @alive = false
    @sprite.visible = false
    @x = 0; @y = 0; @vx = 0; @vy = 0
    @dmg = 0; @pierce = 0; @slow = nil; @life = 0
    @sz = 0; @hit_ids = []
    @bmps = {}
  end

  def fire(x, y, vx, vy, dmg, pierce, life, rgb, sz, slow = nil, weapon_key = nil)
    @x = x; @y = y; @vx = vx; @vy = vy
    @dmg = dmg; @pierce = pierce; @life = life; @slow = slow
    @sz = sz; @hit_ids = []

    bmp = PokeSurvivors::Cache.proj_bitmap(weapon_key, sz) if weapon_key
    if bmp
      @sprite.bitmap = bmp
      @sprite.ox = bmp.width / 2; @sprite.oy = bmp.height / 2
    else
      key = "orb_#{rgb.join(',')}_#{sz}"
      @bmps[key] ||= PokeSurvivors::Gfx.glow_orb(sz, *rgb)
      @sprite.bitmap = @bmps[key]
      @sprite.ox = sz + 4; @sprite.oy = sz + 4
    end
    @sprite.opacity = 255
    @sprite.visible = true
    @alive = true
  end

  def update
    return unless @alive
    @x += @vx; @y += @vy; @life -= 1
    if @life <= 0
      deactivate; return
    end
    @sprite.x = @x - PokeSurvivors.cam_x
    @sprite.y = @y - PokeSurvivors.cam_y
    @sprite.z = 200; @sprite.visible = true
  end

  def hit_mob?(mob)
    return false if @hit_ids.include?(mob.object_id)
    dx = @x - mob.x; dy = @y - mob.y
    dist = Math.sqrt(dx * dx + dy * dy)
    if dist < mob.col_r + @sz
      @hit_ids << mob.object_id
      @pierce -= 1
      deactivate if @pierce < 0
      return true
    end
    false
  end

  def deactivate; @alive = false; @sprite.visible = false; end
  def dispose
    @sprite.dispose if @sprite && !@sprite.disposed?
    @bmps.each_value { |b| b.dispose if b && !b.disposed? }
  end
end

#─── XP Gem ────────────────────────────────────────────────────────────────────
class PokeSurvivors::Gem
  attr_accessor :x, :y, :alive, :value

  def initialize(vp)
    @sprite = Sprite.new(vp); @alive = false
    @sprite.visible = false
    @x = 0; @y = 0; @value = 0; @bob = rand(100)
  end

  def spawn(x, y, val)
    @x = x; @y = y; @value = val; @alive = true
    bmp = PokeSurvivors::Cache.gem_bmp_for_value(val)
    @sprite.bitmap = bmp
    @sprite.ox = bmp.width / 2; @sprite.oy = bmp.height / 2
    @sprite.visible = true; @bob = rand(100)
  end

  def update(fc)
    return unless @alive
    bob = Math.sin((fc + @bob) * 0.08) * 3
    @sprite.x = @x - PokeSurvivors.cam_x
    @sprite.y = @y - PokeSurvivors.cam_y + bob
    @sprite.z = 50
  end

  def move_toward(tx, ty, spd)
    dx = tx - @x; dy = ty - @y
    d = Math.sqrt(dx * dx + dy * dy)
    if d > 1
      @x += (dx / d) * spd; @y += (dy / d) * spd
    end
  end

  def deactivate; @alive = false; @sprite.visible = false; end
  def dispose; @sprite.dispose if @sprite && !@sprite.disposed?; end
end

#─── Damage Popup ──────────────────────────────────────────────────────────────
class PokeSurvivors::Popup
  attr_accessor :alive

  def initialize(vp)
    @sprite = Sprite.new(vp)
    @bmp = Bitmap.new(80, 24)
    @bmp.font.name = PokeSurvivors::FONT_BODY rescue nil
    @bmp.font.size = 18; @bmp.font.bold = true
    @sprite.bitmap = @bmp; @sprite.ox = 40; @sprite.oy = 12
    @alive = false; @sprite.visible = false
    @x = 0; @y = 0; @life = 0
  end

  def show(x, y, val, color = nil)
    color ||= Color.new(255, 255, 255)
    @bmp.clear
    @bmp.font.color = Color.new(0, 0, 0)
    @bmp.draw_text(1, 1, 80, 24, val.to_i.to_s, 1)
    @bmp.font.color = color
    @bmp.draw_text(0, 0, 80, 24, val.to_i.to_s, 1)
    @x = x; @y = y; @life = 40; @alive = true
    @sprite.visible = true; @sprite.opacity = 255
  end

  def update
    return unless @alive
    @life -= 1; @y -= 1.2
    @sprite.x = @x - PokeSurvivors.cam_x
    @sprite.y = @y - PokeSurvivors.cam_y
    @sprite.z = 500
    @sprite.opacity = (@life * 255 / 40.0).to_i.clamp(0, 255)
    if @life <= 0; @alive = false; @sprite.visible = false; end
  end

  def dispose
    @sprite.dispose if @sprite && !@sprite.disposed?
    @bmp.dispose if @bmp && !@bmp.disposed?
  end
end

#─── Main Scene ────────────────────────────────────────────────────────────────
class PokeSurvivors::Scene
  def main
    old_fps = Graphics.frame_rate
    Graphics.frame_rate = 60
    init_all
    loop do
      Graphics.update; Input.update
      update
      break if @done
    end
    dispose_all
    Graphics.frame_rate = old_fps
  end

  #─────────────────────────── Init ────────────────────────────────────────────
  def init_all
    sw = Graphics.width; sh = Graphics.height
    PokeSurvivors.sw = sw; PokeSurvivors.sh = sh
    PokeSurvivors.cam_x = 0; PokeSurvivors.cam_y = 0

    @bg_vp      = Viewport.new(0, 0, sw, sh); @bg_vp.z = 100000
    @game_vp    = Viewport.new(0, 0, sw, sh); @game_vp.z = 100001
    @hud_vp     = Viewport.new(0, 0, sw, sh); @hud_vp.z = 100002
    @overlay_vp = Viewport.new(0, 0, sw, sh); @overlay_vp.z = 100003

    init_background(sw, sh)

    @player = PokeSurvivors::Player.new(@game_vp)

    @mobs   = Array.new(PokeSurvivors::MAX_MOBS)   { PokeSurvivors::Mob.new(@game_vp) }
    @projs  = Array.new(PokeSurvivors::MAX_PROJ)    { PokeSurvivors::Projectile.new(@game_vp) }
    @gems   = Array.new(PokeSurvivors::MAX_GEMS)    { PokeSurvivors::Gem.new(@game_vp) }
    @popups = Array.new(PokeSurvivors::MAX_POPUPS)   { PokeSurvivors::Popup.new(@game_vp) }

    @orbit_sprites = Array.new(8) do
      s = Sprite.new(@game_vp); s.visible = false; s.z = 150; s
    end
    @orbit_bmp = PokeSurvivors::Cache.ebdx_leaf(28) || PokeSurvivors::Gfx.diamond(14, 60, 200, 60)
    @orbit_anim_frames = nil
    @orbit_sprites.each do |s|
      s.bitmap = @orbit_bmp
      s.ox = @orbit_bmp.width / 2; s.oy = @orbit_bmp.height / 2
    end
    @orbit_anim_idx = 0; @orbit_anim_ct = 0
    @orbit_angle = 0.0
    @orbit_hit_cd = {}

    bolt_w = 20; bolt_h = 80
    @thunder_frames = []
    3.times { |i| f = PokeSurvivors::Cache.ebdx_bolt(i, bolt_w, bolt_h); @thunder_frames << f if f }
    if @thunder_frames.empty?
      thunder_anim = PokeSurvivors::WEAPONS[:thunderbolt][:anim]
      @thunder_frames = PokeSurvivors::Cache.anim_frames(thunder_anim[:sheet], thunder_anim[:frames], thunder_anim[:sz])
    end
    @thunder_sprites = Array.new(5) do
      s = Sprite.new(@game_vp); s.visible = false; s.z = 250; s
    end
    if @thunder_frames && !@thunder_frames.empty?
      @thunder_sprites.each do |s|
        s.bitmap = @thunder_frames[0]
        s.ox = @thunder_frames[0].width / 2; s.oy = @thunder_frames[0].height / 2
      end
    end
    @thunder_timers = Array.new(5, 0)

    quake_anim = PokeSurvivors::WEAPONS[:earthquake][:anim]
    @quake_frames = PokeSurvivors::Cache.anim_frames(quake_anim[:sheet], quake_anim[:frames], quake_anim[:sz])
    @quake_sprite = Sprite.new(@game_vp)
    @quake_sprite.visible = false; @quake_sprite.z = 90
    if @quake_frames && !@quake_frames.empty?
      @quake_sprite.bitmap = @quake_frames[0]
      @quake_sprite.ox = @quake_frames[0].width / 2; @quake_sprite.oy = @quake_frames[0].height / 2
    end
    @quake_timer = 0

    slash_anim = PokeSurvivors::WEAPONS[:slash][:anim]
    @slash_frames = PokeSurvivors::Cache.anim_frames(slash_anim[:sheet], slash_anim[:frames], slash_anim[:sz]) rescue nil
    @slash_sprites = Array.new(3) do
      s = Sprite.new(@game_vp); s.visible = false; s.z = 250; s
    end
    if @slash_frames && !@slash_frames.empty?
      @slash_sprites.each { |s| s.bitmap = @slash_frames[0]; s.ox = @slash_frames[0].width / 2; s.oy = @slash_frames[0].height / 2 }
    end
    @slash_timers = Array.new(3, 0)
    @slash_targets = Array.new(3, nil)

    @hud_bmp = Bitmap.new(sw, sh)
    @hud_spr = Sprite.new(@hud_vp); @hud_spr.bitmap = @hud_bmp

    @overlay_bmp = Bitmap.new(sw, sh)
    @overlay_spr = Sprite.new(@overlay_vp); @overlay_spr.bitmap = @overlay_bmp

    @weapon_cds = {}
    @frame_count = 0; @spawn_timer = 0; @boss_idx = 0
    @shake_timer = 0; @shake_amt = 0
    @pending_level_up = false; @level_choices = []; @choice_idx = 0
    @current_boss = nil; @done = false
    @state = :title

    draw_title
  end

  def init_background(sw, sh)
    tile = Bitmap.new(64, 64)
    tile.fill_rect(0, 0, 64, 64, Color.new(34, 85, 40))
    30.times { tile.fill_rect(rand(64), rand(64), 2, 2, Color.new(44, 105, 52)) }
    15.times { tile.fill_rect(rand(64), rand(64), 2, 2, Color.new(28, 70, 34)) }
    bw = sw + 128; bh = sh + 128
    @bg_bmp = Bitmap.new(bw, bh)
    tx = (bw / 64) + 1; ty = (bh / 64) + 1
    tx.times { |ix| ty.times { |iy| @bg_bmp.blt(ix * 64, iy * 64, tile, Rect.new(0, 0, 64, 64)) } }
    tile.dispose
    @bg_spr = Sprite.new(@bg_vp); @bg_spr.bitmap = @bg_bmp; @bg_spr.z = 0
  end

  #─────────────────────────── Main Loop ───────────────────────────────────────
  def update
    case @state
    when :title    then update_title
    when :playing  then update_playing
    when :level_up then update_level_up
    when :paused   then update_paused
    when :game_over then update_end_screen
    when :victory   then update_end_screen
    end
    update_shake
  end

  #─────────────────────────── Title Screen ────────────────────────────────────
  def set_font(bmp, size, color, bold = false, name = nil)
    bmp.font.name = name || PokeSurvivors::FONT_TITLE
    bmp.font.size = size; bmp.font.bold = bold
    bmp.font.color = color
  end

  def draw_title
    sw = PokeSurvivors.sw; sh = PokeSurvivors.sh
    @overlay_bmp.clear

    @overlay_bmp.fill_rect(0, 0, sw, sh, Color.new(12, 10, 28))
    stripe_c = Color.new(25, 20, 50)
    8.times { |i| @overlay_bmp.fill_rect(0, i * (sh / 8), sw, 2, stripe_c) }

    accent = Color.new(60, 40, 90)
    @overlay_bmp.fill_rect(0, sh / 2 - 130, sw, 4, accent)
    @overlay_bmp.fill_rect(0, sh / 2 + 175, sw, 4, accent)

    begin
      deco_names = %w[PIKACHU GENGAR EEVEE MEWTWO CHARIZARD RAYQUAZA]
      deco_names.each_with_index do |name, i|
        bmp = PokeSurvivors::Cache.follower(name)
        next unless bmp
        fw = bmp.width / 4; fh = bmp.height / 4
        dx = (i < 3) ? 20 + i * 40 : sw - 140 + (i - 3) * 40
        dy = sh / 2 - 110 + (i.even? ? -10 : 10)
        @overlay_bmp.blt(dx, dy, bmp, Rect.new(0, 0, fw, fh), 80)
      end
    rescue; end

    set_font(@overlay_bmp, 40, Color.new(255, 220, 60), true)
    @overlay_bmp.draw_text(2, sh / 2 - 98, sw, 48, "POKEMON SURVIVORS", 1)
    set_font(@overlay_bmp, 40, Color.new(200, 160, 20), true)
    @overlay_bmp.draw_text(0, sh / 2 - 100, sw, 48, "POKEMON SURVIVORS", 1)

    set_font(@overlay_bmp, 20, Color.new(180, 180, 210), false, PokeSurvivors::FONT_BODY)
    @overlay_bmp.draw_text(0, sh / 2 - 44, sw, 26, "A Vampire Survivors-style Minigame", 1)

    set_font(@overlay_bmp, 18, Color.new(140, 140, 170), false, PokeSurvivors::FONT_BODY)
    @overlay_bmp.draw_text(0, sh / 2 + 10, sw, 24, "Arrow Keys to Move - Auto-Attack Enemies", 1)
    @overlay_bmp.draw_text(0, sh / 2 + 36, sw, 24, "Collect XP - Level Up - Choose Power-Ups", 1)
    @overlay_bmp.draw_text(0, sh / 2 + 62, sw, 24, "Survive 5 Minutes to Win!", 1)

    set_font(@overlay_bmp, 26, Color.new(100, 255, 100), true)
    @overlay_bmp.draw_text(0, sh / 2 + 110, sw, 32, "Z / Enter - Start", 1)
    set_font(@overlay_bmp, 18, Color.new(200, 100, 100), false, PokeSurvivors::FONT_BODY)
    @overlay_bmp.draw_text(0, sh / 2 + 148, sw, 24, "X / Esc - Quit", 1)
    @overlay_spr.visible = true
  end

  def update_title
    if Input.trigger?(Input::C)
      @overlay_bmp.clear; @overlay_spr.visible = false
      @state = :playing; @frame_count = 0
    elsif Input.trigger?(Input::B)
      @done = true
    end
  end

  #─────────────────────────── Playing ─────────────────────────────────────────
  def update_playing
    @frame_count += 1
    elapsed = @frame_count / 60.0

    if elapsed >= PokeSurvivors::GAME_DURATION
      @state = :victory; draw_end_screen(true); return
    end
    unless @player.alive
      @state = :game_over; draw_end_screen(false); return
    end

    @player.update
    update_camera
    update_background
    update_spawning(elapsed)

    @mobs.each { |m| m.update(@player.x, @player.y) if m.alive }
    update_weapons
    @projs.each { |p| p.update if p.alive }
    update_proj_collisions
    update_mob_player_collisions
    update_gems_logic
    @popups.each { |p| p.update if p.alive }
    update_vfx
    draw_hud(elapsed)

    if @pending_level_up
      @pending_level_up = false
      start_level_up
    end

    if Input.trigger?(Input::B)
      @state = :paused; draw_pause
    end
  end

  def update_camera
    sw = PokeSurvivors.sw; sh = PokeSurvivors.sh
    PokeSurvivors.cam_x = (@player.x - sw / 2.0).clamp(0, [PokeSurvivors::ARENA_W - sw, 0].max)
    PokeSurvivors.cam_y = (@player.y - sh / 2.0).clamp(0, [PokeSurvivors::ARENA_H - sh, 0].max)
  end

  def update_background
    @bg_spr.x = -(PokeSurvivors.cam_x.to_i % 64)
    @bg_spr.y = -(PokeSurvivors.cam_y.to_i % 64)
  end

  def update_shake
    if @shake_timer > 0
      @shake_timer -= 1
      @game_vp.ox = rand(@shake_amt * 2 + 1) - @shake_amt
      @game_vp.oy = rand(@shake_amt * 2 + 1) - @shake_amt
    else
      @game_vp.ox = 0; @game_vp.oy = 0
    end
  end

  def shake(amt, dur); @shake_amt = amt; @shake_timer = dur; end

  #─────────────────────────── Spawning ────────────────────────────────────────
  def update_spawning(elapsed)
    sched = PokeSurvivors::SPAWN_SCHEDULE.select { |s| elapsed >= s[:t] }.last
    return unless sched

    @spawn_timer -= 1
    if @spawn_timer <= 0
      @spawn_timer = sched[:interval]
      sched[:count].times { spawn_one_mob(sched[:max_tier]) }
    end

    if @boss_idx < PokeSurvivors::BOSS_TIMES.size && elapsed >= PokeSurvivors::BOSS_TIMES[@boss_idx]
      spawn_boss; @boss_idx += 1
    end
  end

  def spawn_one_mob(max_tier)
    slot = @mobs.find { |m| !m.alive }
    return unless slot
    tier_idx = rand(max_tier + 1)
    tier = PokeSurvivors::TIERS[tier_idx]
    species = tier[:names].sample
    sx, sy = spawn_pos
    slot.spawn(species, tier, sx, sy)
  end

  def spawn_boss
    slot = @mobs.find { |m| !m.alive }
    return unless slot
    species = PokeSurvivors::BOSSES[@boss_idx % PokeSurvivors::BOSSES.size]
    sx, sy = spawn_pos
    slot.spawn(species, PokeSurvivors::BOSS_CFG, sx, sy, true)
    @current_boss = slot
    shake(6, 30)
  end

  def spawn_pos
    sw = PokeSurvivors.sw; sh = PokeSurvivors.sh
    margin = 80
    side = rand(4)
    case side
    when 0; sx = PokeSurvivors.cam_x + rand(sw); sy = PokeSurvivors.cam_y - margin
    when 1; sx = PokeSurvivors.cam_x + rand(sw); sy = PokeSurvivors.cam_y + sh + margin
    when 2; sx = PokeSurvivors.cam_x - margin;   sy = PokeSurvivors.cam_y + rand(sh)
    when 3; sx = PokeSurvivors.cam_x + sw + margin; sy = PokeSurvivors.cam_y + rand(sh)
    end
    [sx.clamp(0, PokeSurvivors::ARENA_W), sy.clamp(0, PokeSurvivors::ARENA_H)]
  end

  #─────────────────────────── Weapons ─────────────────────────────────────────
  def update_weapons
    @player.weapons.each do |key, lv|
      data = PokeSurvivors::WEAPONS[key]
      stats = data[:levels][lv]
      @weapon_cds[key] ||= 0
      @weapon_cds[key] -= 1 if @weapon_cds[key] > 0

      case data[:type]
      when :melee      then fire_melee(key, data, stats)
      when :projectile then fire_projectile(key, data, stats)
      when :orbit      then update_orbit(key, data, stats)
      when :strike     then fire_strike(key, data, stats)
      when :aoe        then fire_aoe(key, data, stats)
      end
    end
    hide_unused_orbits
  end

  def fire_melee(key, data, stats)
    return if @weapon_cds[key] && @weapon_cds[key] > 0
    targets = nearest_mobs(@player.x, @player.y, stats[:range], 1)
    return if targets.empty?
    @weapon_cds[key] = stats[:cd]
    mob = targets[0]
    dmg = (stats[:dmg] * @player.dmg_mult).to_i
    xp = mob.take_damage(dmg)
    show_popup(mob.x, mob.y - 20, dmg, Color.new(*data[:color]))
    slot = @slash_timers.index { |t| t <= 0 }
    if slot && @slash_frames && !@slash_frames.empty?
      @slash_sprites[slot].x = mob.x - PokeSurvivors.cam_x
      @slash_sprites[slot].y = mob.y - PokeSurvivors.cam_y
      @slash_sprites[slot].visible = true
      @slash_sprites[slot].opacity = 255
      @slash_sprites[slot].bitmap = @slash_frames[0]
      @slash_sprites[slot].angle = rand(360)
      @slash_timers[slot] = @slash_frames.size * 3
      @slash_targets[slot] = [mob.x, mob.y]
    end
    if xp > 0
      @player.kills += 1
      spawn_gem(mob.x, mob.y, xp)
      @current_boss = nil if mob.is_boss
    end
  end

  def fire_projectile(key, data, stats)
    return if @weapon_cds[key] > 0
    targets = nearest_mobs(@player.x, @player.y, stats[:range], stats[:n])
    return if targets.empty?
    @weapon_cds[key] = stats[:cd]
    targets.each do |mob|
      proj = @projs.find { |p| !p.alive }
      next unless proj
      dx = mob.x - @player.x; dy = mob.y - @player.y
      d = Math.sqrt(dx * dx + dy * dy)
      next if d < 1
      vx = (dx / d) * stats[:spd]; vy = (dy / d) * stats[:spd]
      life = (stats[:range] / stats[:spd]).to_i
      dmg = (stats[:dmg] * @player.dmg_mult).to_i
      proj.fire(@player.x, @player.y, vx, vy, dmg, stats[:pierce], life, data[:color], stats[:sz], stats[:slow], key)
    end
  end

  def update_orbit(_key, data, stats)
    @orbit_angle += stats[:spd]
    @orbit_hit_cd.delete_if { |_, v| v <= 0 }
    @orbit_hit_cd.each_key { |k| @orbit_hit_cd[k] -= 1 }

    if @orbit_anim_frames && @orbit_anim_frames.size > 1
      @orbit_anim_ct += 1
      if @orbit_anim_ct >= 8
        @orbit_anim_ct = 0
        @orbit_anim_idx = (@orbit_anim_idx + 1) % @orbit_anim_frames.size
        bmp = @orbit_anim_frames[@orbit_anim_idx]
        stats[:n].times { |i| @orbit_sprites[i].bitmap = bmp }
      end
    end

    stats[:n].times do |i|
      angle = @orbit_angle + (2 * Math::PI * i / stats[:n])
      ox = @player.x + Math.cos(angle) * stats[:radius]
      oy = @player.y + Math.sin(angle) * stats[:radius]
      s = @orbit_sprites[i]
      s.x = ox - PokeSurvivors.cam_x; s.y = oy - PokeSurvivors.cam_y
      s.visible = true

      @mobs.each do |mob|
        next unless mob.alive
        next if @orbit_hit_cd[mob.object_id]
        dx = ox - mob.x; dy = oy - mob.y
        if dx * dx + dy * dy < (mob.col_r + stats[:sz]) ** 2
          dmg = (stats[:dmg] * @player.dmg_mult).to_i
          xp = mob.take_damage(dmg)
          @orbit_hit_cd[mob.object_id] = stats[:hit_cd]
          show_popup(mob.x, mob.y - 20, dmg, Color.new(*data[:color]))
          if xp > 0
            @player.kills += 1
            spawn_gem(mob.x, mob.y, xp)
            @current_boss = nil if mob.is_boss
          end
        end
      end
    end
  end

  def hide_unused_orbits
    has_orbit = @player.weapons.key?(:razor_leaf)
    count = has_orbit ? PokeSurvivors::WEAPONS[:razor_leaf][:levels][@player.weapons[:razor_leaf]][:n] : 0
    @orbit_sprites.each_with_index { |s, i| s.visible = false if i >= count }
  end

  def update_vfx
    @slash_timers.each_with_index do |t, i|
      next if t <= 0
      @slash_timers[i] -= 1
      ss = @slash_sprites[i]
      if @slash_timers[i] <= 0
        ss.visible = false
      elsif @slash_frames && !@slash_frames.empty?
        max_t = @slash_frames.size * 3
        progress = 1.0 - (@slash_timers[i].to_f / max_t)
        fi = (progress * @slash_frames.size).to_i.clamp(0, @slash_frames.size - 1)
        ss.bitmap = @slash_frames[fi]
        ss.opacity = (@slash_timers[i] * 255 / max_t).to_i.clamp(80, 255)
        if @slash_targets[i]
          ss.x = @slash_targets[i][0] - PokeSurvivors.cam_x
          ss.y = @slash_targets[i][1] - PokeSurvivors.cam_y
        end
      end
    end

    @thunder_timers.each_with_index do |t, i|
      next if t <= 0
      @thunder_timers[i] -= 1
      ts = @thunder_sprites[i]
      if @thunder_timers[i] <= 0
        ts.visible = false
      else
        ts.opacity = (@thunder_timers[i] * 255 / 15.0).to_i.clamp(0, 255)
        if @thunder_frames && @thunder_timers[i] % 4 == 0
          ts.bitmap = @thunder_frames[rand(@thunder_frames.size)]
        end
      end
    end

    if @quake_timer > 0
      @quake_timer -= 1
      progress = 1.0 - (@quake_timer / 20.0)
      scale = 1.0 + progress * 3.0
      @quake_sprite.zoom_x = scale; @quake_sprite.zoom_y = scale
      @quake_sprite.opacity = (@quake_timer * 255 / 20.0).to_i.clamp(0, 255)
      @quake_sprite.x = @player.x - PokeSurvivors.cam_x
      @quake_sprite.y = @player.y - PokeSurvivors.cam_y
      if @quake_frames && @quake_frames.size > 1
        fi = ((progress * @quake_frames.size).to_i).clamp(0, @quake_frames.size - 1)
        @quake_sprite.bitmap = @quake_frames[fi]
      end
      @quake_sprite.visible = false if @quake_timer <= 0
    end
  end

  def fire_strike(key, data, stats)
    return if @weapon_cds[key] > 0
    targets = nearest_mobs(@player.x, @player.y, stats[:range], stats[:n])
    return if targets.empty?
    @weapon_cds[key] = stats[:cd]
    targets.each_with_index do |mob, i|
      dmg = (stats[:dmg] * @player.dmg_mult).to_i
      xp = mob.take_damage(dmg)
      show_popup(mob.x, mob.y - 20, dmg, Color.new(*data[:color]))
      if @thunder_frames && i < @thunder_sprites.size
        ts = @thunder_sprites[i]
        ts.x = mob.x - PokeSurvivors.cam_x
        ts.y = mob.y - PokeSurvivors.cam_y
        ts.visible = true
        ts.bitmap = @thunder_frames[rand(@thunder_frames.size)]
        @thunder_timers[i] = 15
      end
      if xp > 0
        @player.kills += 1
        spawn_gem(mob.x, mob.y, xp)
        @current_boss = nil if mob.is_boss
      end
    end
  end

  def fire_aoe(key, data, stats)
    return if @weapon_cds[key] > 0
    found = false
    @mobs.each do |mob|
      next unless mob.alive
      dx = mob.x - @player.x; dy = mob.y - @player.y
      if dx * dx + dy * dy < stats[:radius] ** 2
        dmg = (stats[:dmg] * @player.dmg_mult).to_i
        xp = mob.take_damage(dmg)
        show_popup(mob.x, mob.y - 20, dmg, Color.new(*data[:color]))
        found = true
        if xp > 0
          @player.kills += 1
          spawn_gem(mob.x, mob.y, xp)
          @current_boss = nil if mob.is_boss
        end
      end
    end
    if found
      @weapon_cds[key] = stats[:cd]
      @game_vp.color.set(180, 140, 80, 60)
      shake(4, 10)
      if @quake_frames && !@quake_frames.empty?
        @quake_sprite.bitmap = @quake_frames[0]
        @quake_sprite.x = @player.x - PokeSurvivors.cam_x
        @quake_sprite.y = @player.y - PokeSurvivors.cam_y
        @quake_sprite.zoom_x = 1.0; @quake_sprite.zoom_y = 1.0
        @quake_sprite.opacity = 255
        @quake_sprite.visible = true
        @quake_timer = 20
      end
    end
  end

  #─────────────────────────── Collisions ──────────────────────────────────────
  def update_proj_collisions
    @projs.each do |proj|
      next unless proj.alive
      @mobs.each do |mob|
        next unless mob.alive
        if proj.hit_mob?(mob)
          xp = mob.take_damage(proj.dmg, proj.slow)
          show_popup(mob.x, mob.y - 20, proj.dmg)
          if xp > 0
            @player.kills += 1
            spawn_gem(mob.x, mob.y, xp)
            @current_boss = nil if mob.is_boss
          end
          break unless proj.alive
        end
      end
    end
  end

  def update_mob_player_collisions
    @mobs.each do |mob|
      next unless mob.alive
      dx = mob.x - @player.x; dy = mob.y - @player.y
      dist = Math.sqrt(dx * dx + dy * dy)
      if dist < mob.col_r + 16
        @player.take_damage(mob.damage)
        if @player.iframes == PokeSurvivors::IFRAMES
          shake(3, 8)
          show_popup(@player.x, @player.y - 30, mob.damage, Color.new(255, 60, 60))
        end
      end
    end
  end

  #─────────────────────────── Gems ────────────────────────────────────────────
  def update_gems_logic
    pr = @player.pickup_r; mr = @player.magnet_r
    @gems.each do |gem|
      next unless gem.alive
      dx = @player.x - gem.x; dy = @player.y - gem.y
      dist = Math.sqrt(dx * dx + dy * dy)
      if dist < pr
        if @player.add_xp(gem.value)
          @pending_level_up = true
        end
        gem.deactivate; next
      elsif dist < mr
        gem.move_toward(@player.x, @player.y, 6)
      end
      gem.update(@frame_count)
    end
  end

  def spawn_gem(x, y, val)
    slot = @gems.find { |g| !g.alive }
    return unless slot
    slot.spawn(x + rand(11) - 5, y + rand(11) - 5, val)
  end

  def show_popup(x, y, val, color = nil)
    slot = @popups.find { |p| !p.alive }
    slot.show(x, y, val, color) if slot
  end

  #─────────────────────────── Helpers ─────────────────────────────────────────
  def nearest_mobs(x, y, range, count)
    cands = []
    r2 = range * range
    @mobs.each do |m|
      next unless m.alive
      dx = m.x - x; dy = m.y - y
      d2 = dx * dx + dy * dy
      cands << [m, d2] if d2 <= r2
    end
    cands.sort_by! { |c| c[1] }
    cands.first(count).map { |c| c[0] }
  end

  #─────────────────────────── HUD ─────────────────────────────────────────────
  def draw_hud(elapsed)
    sw = PokeSurvivors.sw; sh = PokeSurvivors.sh
    @hud_bmp.clear
    @hud_bmp.font.name = PokeSurvivors::FONT_BODY rescue nil

    remaining = [(PokeSurvivors::GAME_DURATION - elapsed).ceil, 0].max
    mins = remaining / 60; secs = remaining % 60
    @hud_bmp.font.size = 22; @hud_bmp.font.bold = true
    @hud_bmp.font.color = Color.new(255, 255, 255)
    @hud_bmp.draw_text(0, 6, sw, 26, sprintf("%d:%02d", mins, secs), 1)

    @hud_bmp.font.size = 16; @hud_bmp.font.bold = false
    @hud_bmp.draw_text(sw - 140, 6, 130, 20, "Kills: #{@player.kills}", 2)
    @hud_bmp.draw_text(10, 6, 130, 20, "Lv. #{@player.level}", 0)

    bar_w = [sw / 3, 200].min; bar_h = 14
    bx = (sw - bar_w) / 2; by = sh - 38
    hp_pct = (@player.hp / @player.max_hp.to_f).clamp(0, 1)
    @hud_bmp.fill_rect(bx - 1, by - 1, bar_w + 2, bar_h + 2, Color.new(0, 0, 0))
    @hud_bmp.fill_rect(bx, by, bar_w, bar_h, Color.new(60, 20, 20))
    @hud_bmp.fill_rect(bx, by, (bar_w * hp_pct).to_i, bar_h, Color.new(40, 200, 60))
    @hud_bmp.font.size = 12
    @hud_bmp.font.color = Color.new(255, 255, 255)
    @hud_bmp.draw_text(bx, by, bar_w, bar_h, "#{@player.hp.to_i} / #{@player.max_hp.to_i}", 1)

    xp_h = 8; xy = sh - 18
    xp_pct = @player.xp_needed > 0 ? (@player.xp.to_f / @player.xp_needed).clamp(0, 1) : 0
    @hud_bmp.fill_rect(bx - 1, xy - 1, bar_w + 2, xp_h + 2, Color.new(0, 0, 0))
    @hud_bmp.fill_rect(bx, xy, bar_w, xp_h, Color.new(20, 20, 60))
    @hud_bmp.fill_rect(bx, xy, (bar_w * xp_pct).to_i, xp_h, Color.new(80, 140, 255))

    wpn_y = 30
    @player.weapons.each do |key, lv|
      wdata = PokeSurvivors::WEAPONS[key]
      @hud_bmp.font.size = 13; @hud_bmp.font.color = Color.new(*wdata[:color])
      @hud_bmp.draw_text(10, wpn_y, 200, 16, "#{wdata[:name]} Lv#{lv + 1}", 0)
      wpn_y += 16
    end
    @player.passives.each do |key, lv|
      pdata = PokeSurvivors::PASSIVES[key]
      @hud_bmp.font.size = 13; @hud_bmp.font.color = Color.new(180, 220, 180)
      @hud_bmp.draw_text(10, wpn_y, 200, 16, "#{pdata[:name]} Lv#{lv + 1}", 0)
      wpn_y += 16
    end

    if @current_boss && @current_boss.alive
      boss_w = [sw / 2, 300].min; boss_h = 12
      bbx = (sw - boss_w) / 2; bby = 34
      boss_pct = (@current_boss.hp / @current_boss.max_hp.to_f).clamp(0, 1)
      @hud_bmp.fill_rect(bbx - 1, bby - 1, boss_w + 2, boss_h + 2, Color.new(0, 0, 0))
      @hud_bmp.fill_rect(bbx, bby, boss_w, boss_h, Color.new(60, 20, 20))
      @hud_bmp.fill_rect(bbx, bby, (boss_w * boss_pct).to_i, boss_h, Color.new(220, 50, 50))
      @hud_bmp.font.size = 12; @hud_bmp.font.color = Color.new(255, 200, 200)
      @hud_bmp.draw_text(bbx, bby - 16, boss_w, 16, @current_boss.species, 1)
    end

    aoe_alpha = @game_vp.color.alpha rescue 0
    if aoe_alpha > 0
      new_a = [aoe_alpha - 8, 0].max
      @game_vp.color.set(@game_vp.color.red, @game_vp.color.green, @game_vp.color.blue, new_a)
    end
  end

  #─────────────────────────── Level Up ────────────────────────────────────────
  def start_level_up
    @state = :level_up
    @level_choices = generate_choices
    @choice_idx = 0
    draw_level_up
  end

  def generate_choices
    pool = []
    PokeSurvivors::WEAPONS.each do |key, data|
      if @player.weapons.key?(key)
        lv = @player.weapons[key]
        if lv < data[:levels].size - 1
          pool << { type: :weapon_up, key: key, name: data[:name], desc: data[:desc],
                    from: lv + 1, to: lv + 2, color: data[:color] }
        end
      elsif @player.weapons.size < PokeSurvivors::MAX_WEAPONS
        pool << { type: :weapon_new, key: key, name: data[:name], desc: data[:desc],
                  from: 0, to: 1, color: data[:color] }
      end
    end
    PokeSurvivors::PASSIVES.each do |key, data|
      if @player.passives.key?(key)
        lv = @player.passives[key]
        if lv < data[:lvs].size - 1
          pool << { type: :passive_up, key: key, name: data[:name], desc: data[:desc],
                    from: lv + 1, to: lv + 2, color: [180, 220, 180] }
        end
      elsif @player.passives.size < PokeSurvivors::MAX_PASSIVES
        pool << { type: :passive_new, key: key, name: data[:name], desc: data[:desc],
                  from: 0, to: 1, color: [180, 220, 180] }
      end
    end

    if pool.size < 3
      pool << { type: :heal, key: nil, name: "Full Heal", desc: "Restore all HP",
                from: 0, to: 0, color: [100, 255, 100] }
    end

    pool.shuffle.first(3)
  end

  def draw_level_up
    sw = PokeSurvivors.sw; sh = PokeSurvivors.sh
    @overlay_bmp.clear
    @overlay_bmp.fill_rect(0, 0, sw, sh, Color.new(0, 0, 0, 185))

    bar_c = Color.new(255, 220, 60, 100)
    @overlay_bmp.fill_rect(0, sh / 2 - 150, sw, 3, bar_c)
    @overlay_bmp.fill_rect(0, sh / 2 + 145, sw, 3, bar_c)

    set_font(@overlay_bmp, 36, Color.new(0, 0, 0), true)
    @overlay_bmp.draw_text(2, sh / 2 - 138, sw, 42, "LEVEL UP!", 1)
    set_font(@overlay_bmp, 36, Color.new(255, 220, 60), true)
    @overlay_bmp.draw_text(0, sh / 2 - 140, sw, 42, "LEVEL UP!", 1)

    set_font(@overlay_bmp, 15, Color.new(190, 190, 215), false, PokeSurvivors::FONT_BODY)
    @overlay_bmp.draw_text(0, sh / 2 - 96, sw, 20, "Choose an upgrade:", 1)

    card_w = [sw / 3.5, 180].min.to_i; card_h = 145; gap = 16
    total_w = card_w * @level_choices.size + gap * (@level_choices.size - 1)
    start_x = (sw - total_w) / 2; cy = sh / 2 - 62

    @level_choices.each_with_index do |ch, i|
      cx = start_x + i * (card_w + gap)
      sel = (i == @choice_idx)

      @overlay_bmp.fill_rect(cx + 4, cy + 4, card_w, card_h, Color.new(0, 0, 0, 100))

      bc = sel ? Color.new(255, 220, 60) : Color.new(60, 55, 80)
      bw = sel ? 3 : 2
      @overlay_bmp.fill_rect(cx - bw, cy - bw, card_w + bw * 2, card_h + bw * 2, bc)

      top_c = sel ? Color.new(55, 45, 85) : Color.new(32, 28, 52)
      bot_c = sel ? Color.new(38, 32, 65) : Color.new(22, 20, 40)
      @overlay_bmp.fill_rect(cx, cy, card_w, card_h / 2, top_c)
      @overlay_bmp.fill_rect(cx, cy + card_h / 2, card_w, card_h / 2, bot_c)

      accent_c = Color.new(*ch[:color])
      @overlay_bmp.fill_rect(cx, cy, card_w, 4, accent_c)

      is_new = ch[:type].to_s.include?("new")
      is_heal = (ch[:type] == :heal)
      badge_c = is_new ? Color.new(50, 170, 50) : is_heal ? Color.new(50, 180, 90) : Color.new(70, 70, 110)
      badge_t = is_new ? "NEW" : is_heal ? "HEAL" : "UP"
      bw2 = 50
      @overlay_bmp.fill_rect(cx + (card_w - bw2) / 2, cy + 14, bw2, 18, badge_c)
      set_font(@overlay_bmp, 11, Color.new(255, 255, 255), true, PokeSurvivors::FONT_BODY)
      @overlay_bmp.draw_text(cx + (card_w - bw2) / 2, cy + 14, bw2, 18, badge_t, 1)

      set_font(@overlay_bmp, 18, Color.new(*ch[:color]), true)
      @overlay_bmp.draw_text(cx + 6, cy + 42, card_w - 12, 24, ch[:name], 1)

      set_font(@overlay_bmp, 13, Color.new(180, 178, 210), false, PokeSurvivors::FONT_BODY)
      @overlay_bmp.draw_text(cx + 6, cy + 70, card_w - 12, 18, ch[:desc], 1)

      sep_c = Color.new(80, 75, 110, 120)
      @overlay_bmp.fill_rect(cx + 10, cy + 94, card_w - 20, 1, sep_c)

      if is_heal
        set_font(@overlay_bmp, 14, Color.new(100, 255, 100), false, PokeSurvivors::FONT_BODY)
        @overlay_bmp.draw_text(cx + 6, cy + 104, card_w - 12, 20, "Restore all HP", 1)
      else
        label = is_new ? "Unlock!" : "Lv#{ch[:from]} -> Lv#{ch[:to]}"
        lc = is_new ? Color.new(100, 255, 100) : Color.new(200, 200, 220)
        set_font(@overlay_bmp, 14, lc, is_new, PokeSurvivors::FONT_BODY)
        @overlay_bmp.draw_text(cx + 6, cy + 104, card_w - 12, 20, label, 1)
      end

      if sel
        ptr_y = cy + card_h + 6
        ptr_c = Color.new(255, 220, 60)
        ptr_cx = cx + card_w / 2
        6.times do |j|
          w = (6 - j) * 2
          @overlay_bmp.fill_rect(ptr_cx - w / 2, ptr_y + j, w, 1, ptr_c)
        end
      end
    end

    set_font(@overlay_bmp, 15, Color.new(140, 140, 170), false, PokeSurvivors::FONT_BODY)
    @overlay_bmp.draw_text(0, sh / 2 + 118, sw, 22, "< > Choose  |  Z Confirm", 1)
    @overlay_spr.visible = true
  end

  def update_level_up
    moved = false
    if Input.trigger?(Input::LEFT)
      @choice_idx = (@choice_idx - 1) % @level_choices.size; moved = true
    elsif Input.trigger?(Input::RIGHT)
      @choice_idx = (@choice_idx + 1) % @level_choices.size; moved = true
    end
    draw_level_up if moved

    if Input.trigger?(Input::C)
      ch = @level_choices[@choice_idx]
      apply_choice(ch)
      @overlay_bmp.clear; @overlay_spr.visible = false
      @state = :playing
    end
  end

  def apply_choice(ch)
    case ch[:type]
    when :weapon_new
      @player.weapons[ch[:key]] = 0
    when :weapon_up
      @player.weapons[ch[:key]] += 1
    when :passive_new
      @player.passives[ch[:key]] = 0
      apply_passive_immediate(ch[:key], 0)
    when :passive_up
      @player.passives[ch[:key]] += 1
      apply_passive_immediate(ch[:key], @player.passives[ch[:key]])
    when :heal
      @player.hp = @player.max_hp
    end
  end

  def apply_passive_immediate(key, _lv)
    if key == :thick_fat
      total_bonus = PokeSurvivors::PASSIVES[:thick_fat][:lvs][@player.passives[:thick_fat]]
      @player.max_hp = PokeSurvivors::PLAYER_HP + total_bonus
      @player.hp = [@player.hp + 25, @player.max_hp].min
    end
  end

  #─────────────────────────── Pause ───────────────────────────────────────────
  def draw_pause
    sw = PokeSurvivors.sw; sh = PokeSurvivors.sh
    @overlay_bmp.clear
    @overlay_bmp.fill_rect(0, 0, sw, sh, Color.new(0, 0, 0, 180))

    bar_c = Color.new(100, 100, 140, 80)
    @overlay_bmp.fill_rect(0, sh / 2 - 55, sw, 3, bar_c)
    @overlay_bmp.fill_rect(0, sh / 2 + 50, sw, 3, bar_c)

    set_font(@overlay_bmp, 32, Color.new(0, 0, 0), true)
    @overlay_bmp.draw_text(2, sh / 2 - 38, sw, 38, "PAUSED", 1)
    set_font(@overlay_bmp, 32, Color.new(255, 255, 255), true)
    @overlay_bmp.draw_text(0, sh / 2 - 40, sw, 38, "PAUSED", 1)

    set_font(@overlay_bmp, 17, Color.new(180, 180, 210), false, PokeSurvivors::FONT_BODY)
    @overlay_bmp.draw_text(0, sh / 2 + 10, sw, 24, "Z to Resume  |  X to Quit", 1)
    @overlay_spr.visible = true
  end

  def update_paused
    if Input.trigger?(Input::C)
      @overlay_bmp.clear; @overlay_spr.visible = false; @state = :playing
    elsif Input.trigger?(Input::B)
      @done = true
    end
  end

  #─────────────────────────── Game Over / Victory ─────────────────────────────
  def draw_end_screen(victory)
    sw = PokeSurvivors.sw; sh = PokeSurvivors.sh
    elapsed = @frame_count / 60.0
    mins = (elapsed / 60).to_i; secs = (elapsed % 60).to_i

    @overlay_bmp.clear
    @overlay_bmp.fill_rect(0, 0, sw, sh, Color.new(0, 0, 0, 185))

    bar_c = victory ? Color.new(255, 220, 60, 80) : Color.new(255, 60, 60, 80)
    @overlay_bmp.fill_rect(0, sh / 2 - 110, sw, 3, bar_c)
    @overlay_bmp.fill_rect(0, sh / 2 + 110, sw, 3, bar_c)

    title_c = victory ? Color.new(255, 220, 60) : Color.new(255, 60, 60)
    title = victory ? "VICTORY!" : "GAME OVER"
    set_font(@overlay_bmp, 36, Color.new(0, 0, 0), true)
    @overlay_bmp.draw_text(2, sh / 2 - 98, sw, 42, title, 1)
    set_font(@overlay_bmp, 36, title_c, true)
    @overlay_bmp.draw_text(0, sh / 2 - 100, sw, 42, title, 1)

    set_font(@overlay_bmp, 18, Color.new(200, 200, 220), false, PokeSurvivors::FONT_BODY)
    @overlay_bmp.draw_text(0, sh / 2 - 40, sw, 24, sprintf("Time: %d:%02d", mins, secs), 1)
    @overlay_bmp.draw_text(0, sh / 2 - 12, sw, 24, "Kills: #{@player.kills}", 1)
    @overlay_bmp.draw_text(0, sh / 2 + 16, sw, 24, "Level: #{@player.level}", 1)

    set_font(@overlay_bmp, 14, Color.new(140, 140, 170), false, PokeSurvivors::FONT_BODY)
    wpn_y = sh / 2 + 48
    @player.weapons.each do |key, lv|
      wdata = PokeSurvivors::WEAPONS[key]
      set_font(@overlay_bmp, 13, Color.new(*wdata[:color]), false, PokeSurvivors::FONT_BODY)
      @overlay_bmp.draw_text(0, wpn_y, sw, 18, "#{wdata[:name]} Lv#{lv + 1}", 1)
      wpn_y += 16
    end

    set_font(@overlay_bmp, 18, Color.new(100, 255, 100), true, PokeSurvivors::FONT_BODY)
    @overlay_bmp.draw_text(0, sh / 2 + 88, sw, 26, "Z - Play Again  |  X - Quit", 1)
    @overlay_spr.visible = true
  end

  def update_end_screen
    if Input.trigger?(Input::C)
      dispose_all; init_all
      @overlay_bmp.clear; @overlay_spr.visible = false
      @state = :playing; @frame_count = 0
    elsif Input.trigger?(Input::B)
      @done = true
    end
  end

  #─────────────────────────── Dispose ─────────────────────────────────────────
  def dispose_all
    @player.dispose if @player
    @mobs.each   { |m| m.dispose } if @mobs
    @projs.each  { |p| p.dispose } if @projs
    @gems.each   { |g| g.dispose } if @gems
    @popups.each { |p| p.dispose } if @popups
    @orbit_sprites.each { |s| s.dispose if s && !s.disposed? } if @orbit_sprites
    @orbit_bmp.dispose if @orbit_bmp && !@orbit_bmp.disposed? && !@orbit_anim_frames
    @slash_sprites.each { |s| s.dispose if s && !s.disposed? } if @slash_sprites
    @thunder_sprites.each { |s| s.dispose if s && !s.disposed? } if @thunder_sprites
    @quake_sprite.dispose if @quake_sprite && !@quake_sprite.disposed?
    @bg_bmp.dispose  if @bg_bmp  && !@bg_bmp.disposed?
    @bg_spr.dispose  if @bg_spr  && !@bg_spr.disposed?
    @hud_bmp.dispose if @hud_bmp && !@hud_bmp.disposed?
    @hud_spr.dispose if @hud_spr && !@hud_spr.disposed?
    @overlay_bmp.dispose if @overlay_bmp && !@overlay_bmp.disposed?
    @overlay_spr.dispose if @overlay_spr && !@overlay_spr.disposed?
    @bg_vp.dispose      if @bg_vp      && !@bg_vp.disposed?
    @game_vp.dispose    if @game_vp    && !@game_vp.disposed?
    @hud_vp.dispose     if @hud_vp     && !@hud_vp.disposed?
    @overlay_vp.dispose if @overlay_vp && !@overlay_vp.disposed?
    PokeSurvivors::Cache.dispose_all
  end
end

#─── Entry Point ───────────────────────────────────────────────────────────────
def pbPokemonSurvivors
  PokeSurvivors::Scene.new.main
end

#─── Pause Menu Hook ───────────────────────────────────────────────────────────
if defined?(PokemonPauseMenu_Scene)
  class ::PokemonPauseMenu_Scene
    alias pokemon_survivors_mod_pbShowCommands pbShowCommands unless method_defined?(:pokemon_survivors_mod_pbShowCommands)

    def pbShowCommands(commands)
      display = commands.dup
      surv_label = _INTL("Poke Survivors")
      insert_at = display.length - 1
      insert_at = [insert_at, 0].max
      display.insert(insert_at, surv_label)
      ret = pokemon_survivors_mod_pbShowCommands(display)
      if ret == insert_at
        pbPlayDecisionSE
        pbFadeOutIn do
          pbPokemonSurvivors
        end
        return -1
      end
      if ret > insert_at && ret >= 0
        ret -= 1
      end
      return ret
    end
  end
end
