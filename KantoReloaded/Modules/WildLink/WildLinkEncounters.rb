#==============================================================================
# Kanto Reloaded - Wild Link Encounter Pools and Bonuses
#==============================================================================

module KantoReloaded
  module WildLink
    module EncounterPools
      ROD_TYPES = [
        [:OldRod, :OLDROD],
        [:GoodRod, :GOODROD],
        [:SuperRod, :SUPERROD]
      ].freeze

      class << self
        def available_methods
          rows = []
          rows << method_row(:land, encounter_types_for(:land)) if land_available?
          rows << method_row(:cave, encounter_types_for(:cave)) if cave_available?
          rows << method_row(:surf, encounter_types_for(:water)) if surf_available?
          fishing = available_rod_types
          rows << method_row(:fishing, fishing) unless fishing.empty?
          headbutt = [:HeadbuttLow, :HeadbuttHigh].select { |id| has_type?(id) }
          rows << method_row(:headbutt, headbutt) if !headbutt.empty? && nearby_event?(/headbutttree/i)
          rock = rock_smash_encounter_types
          rows << method_row(:rock_smash, rock) if !rock.empty? && nearby_event?(/smashrock/i)
          rows
        rescue StandardError => e
          WildLink.log_exception("Wild Link method scan failed", e)
          []
        end

        def entries_for(method)
          return [] unless method
          records = encounter_records(Array(method[:encounter_types]))
          entries = merge_records(records)
          add_discovered_fusions(entries, method[:id])
          add_rare_signal(entries, method) if method[:id] == :land
          entries.sort_by do |entry|
            status = entry[:signal] ? 3 : (WildLink.seen?(entry[:species]) ? 0 : 2)
            [status, entry_name(entry).downcase]
          end
        rescue StandardError => e
          WildLink.log_exception("Wild Link encounter roster failed", e)
          []
        end

        def entry_name(entry)
          return _INTL("Rare Signal") if entry[:signal]
          return _INTL("Unknown Pokemon") unless WildLink.seen?(entry[:species])
          GameData::Species.get(entry[:species]).name
        rescue StandardError
          _INTL("Unknown Pokemon")
        end

        def choose_target(entry)
          return nil unless entry
          if entry[:signal]
            candidate = weighted_rare_record(Array(entry[:rare_records]))
            return nil unless candidate
            species = mapped_species(candidate[2])
            level = random_level(candidate[3], candidate[4] || candidate[3])
            return {
              :species => species,
              :level => level,
              :unknown => !WildLink.seen?(species),
              :rare_signal => true
            }
          end
          record = weighted_record(Array(entry[:records]))
          return nil unless record
          {
            :species => entry[:species],
            :level => random_level(record[2], record[3]),
            :unknown => !WildLink.seen?(entry[:species]),
            :rare_signal => !!entry[:rare]
          }
        rescue StandardError => e
          WildLink.log_exception("Wild Link target choice failed", e)
          nil
        end

        def find_entry(method_id, species)
          method = available_methods.find { |row| row[:id] == method_id.to_sym }
          return nil unless method
          entries_for(method).find do |entry|
            !entry[:signal] && WildLink.species_key(entry[:species]) ==
              WildLink.species_key(species)
          end
        end

        def standard_seen_for_method?(entries)
          standards = entries.reject do |entry|
            entry[:signal] || entry[:rare] || entry[:discovered_fusion]
          end
          !standards.empty? && standards.all? { |entry| WildLink.seen?(entry[:species]) }
        end

        def nearby_named_events(pattern, maximum_distance = nil)
          return [] unless $game_map && $game_player
          $game_map.events.values.select do |event|
            next false unless event && event.name.to_s.match?(pattern)
            next false if event.respond_to?(:erased) && event.erased
            next true unless maximum_distance
            distance = (event.x - $game_player.x).abs + (event.y - $game_player.y).abs
            distance <= maximum_distance
          end
        rescue StandardError
          []
        end

        private

        def method_row(id, encounter_types)
          {
            :id => id,
            :label => WildLink.method_label(id),
            :encounter_types => encounter_types
          }
        end

        def land_available?
          encounter_types_for(:land).any? && !$PokemonGlobal.surfing
        rescue StandardError
          false
        end

        def cave_available?
          encounter_types_for(:cave).any? && !$PokemonGlobal.surfing
        rescue StandardError
          false
        end

        def surf_available?
          encounter_types_for(:water).any? && !!$PokemonGlobal.surfing
        rescue StandardError
          false
        end

        def encounter_types_for(kind)
          return [] unless $PokemonEncounters
          rows = []
          GameData::EncounterType.each do |encounter_type|
            next unless encounter_type.type == kind
            next if encounter_type.id == :BugContest
            rows << encounter_type.id if has_type?(encounter_type.id)
          end
          rows
        rescue StandardError
          []
        end

        def available_rod_types
          ROD_TYPES.each_with_object([]) do |pair, rows|
            encounter_type, item = pair
            next unless has_type?(encounter_type)
            next unless bag_has?(item)
            rows << encounter_type
          end
        end

        def rock_smash_encounter_types
          has_type?(:RockSmash) ? [:RockSmash] : []
        rescue StandardError
          []
        end

        def bag_has?(item)
          return false unless $PokemonBag
          return $PokemonBag.pbHasItem?(item) if $PokemonBag.respond_to?(:pbHasItem?)
          $PokemonBag.pbQuantity(item).to_i > 0
        rescue StandardError
          false
        end

        def has_type?(encounter_type)
          $PokemonEncounters &&
            $PokemonEncounters.has_encounter_type?(encounter_type)
        rescue StandardError
          false
        end

        def nearby_event?(pattern)
          !nearby_named_events(pattern).empty?
        end

        def encounter_records(encounter_types)
          records = []
          encounter_types.each do |encounter_type|
            table = $PokemonEncounters.listPossibleEncounters(encounter_type)
            Array(table).each do |record|
              next unless record.is_a?(Array) && record.length >= 4
              species = mapped_species(record[1])
              next unless species && GameData::Species.exists?(species)
              records << [
                record[0].to_i, species, record[2].to_i, record[3].to_i,
                encounter_type
              ]
            end
          end
          records
        end

        def merge_records(records)
          merged = {}
          records.each do |record|
            key = WildLink.species_key(record[1])
            merged[key] ||= {
              :species => record[1],
              :weight => 0,
              :min_level => record[2],
              :max_level => record[3],
              :records => []
            }
            entry = merged[key]
            entry[:weight] += record[0].to_i
            entry[:min_level] = [entry[:min_level], record[2]].min
            entry[:max_level] = [entry[:max_level], record[3]].max
            entry[:records] << [record[0], record[1], record[2], record[3], record[4]]
          end
          merged.values
        end

        def add_discovered_fusions(entries, method_id)
          WildLink.discovered_fusions(method_id).each do |record|
            species = record[:species]
            next if entries.any? do |entry|
              WildLink.species_key(entry[:species]) ==
                WildLink.species_key(species)
            end
            minimum = record[:min_level].to_i
            maximum = record[:max_level].to_i
            entries << {
              :species => species,
              :weight => 1,
              :min_level => minimum,
              :max_level => maximum,
              :records => [
                [1, species, minimum, maximum, :DiscoveredFusion]
              ],
              :discovered_fusion => true
            }
          end
          entries
        end

        def add_rare_signal(entries, method)
          rare = rare_records
          return entries if rare.empty?
          rare.each do |record|
            species = mapped_species(record[2])
            next unless WildLink.seen?(species)
            existing = entries.find do |entry|
              WildLink.species_key(entry[:species]) == WildLink.species_key(species)
            end
            if existing
              existing[:rare] = true
              next
            end
            entries << {
              :species => species,
              :weight => record[1].to_i,
              :min_level => record[3].to_i,
              :max_level => (record[4] || record[3]).to_i,
              :records => [[record[1], species, record[3], record[4] || record[3], :RareSignal]],
              :rare => true
            }
          end
          unseen = rare.reject { |record| WildLink.seen?(mapped_species(record[2])) }
          return entries if unseen.empty?
          entries << {
            :species => mapped_species(unseen[0][2]),
            :signal => true,
            :unlocked => standard_seen_for_method?(entries),
            :rare_records => unseen,
            :min_level => unseen.map { |record| record[3].to_i }.min,
            :max_level => unseen.map { |record| (record[4] || record[3]).to_i }.max
          }
          entries
        end

        def rare_records
          return [] unless defined?(Settings::POKE_RADAR_ENCOUNTERS)
          Array(Settings::POKE_RADAR_ENCOUNTERS).select do |record|
            record.is_a?(Array) && record[0].to_i == WildLink.current_map_id &&
              GameData::Species.exists?(record[2])
          end
        rescue StandardError
          []
        end

        def mapped_species(species)
          id = GameData::Species.get(species).id
          return id unless global_mapping_enabled?
          receiver = Object.new
          mapped = receiver.__send__(:getRandomizedTo, id)
          mapped ? GameData::Species.get(mapped).id : id
        rescue StandardError
          id || species
        end

        def global_mapping_enabled?
          return false unless $game_switches
          return false unless Object.const_defined?(:SWITCH_RANDOM_WILD)
          return false unless $game_switches[Object.const_get(:SWITCH_RANDOM_WILD)]
          if Object.const_defined?(:SWITCH_RANDOM_WILD_AREA)
            return false if $game_switches[Object.const_get(:SWITCH_RANDOM_WILD_AREA)]
          end
          Object.private_method_defined?(:getRandomizedTo) ||
            Object.method_defined?(:getRandomizedTo)
        rescue StandardError
          false
        end

        def weighted_record(records)
          rows = records.compact
          return nil if rows.empty?
          total = rows.inject(0) { |sum, row| sum + [row[0].to_i, 1].max }
          roll = rand(total)
          rows.each do |row|
            roll -= [row[0].to_i, 1].max
            return row if roll < 0
          end
          rows[-1]
        end

        def weighted_rare_record(records)
          rows = records.compact
          return nil if rows.empty?
          total = rows.inject(0) { |sum, row| sum + [row[1].to_i, 1].max }
          roll = rand(total)
          rows.each do |row|
            roll -= [row[1].to_i, 1].max
            return row if roll < 0
          end
          rows[-1]
        end

        def random_level(minimum, maximum)
          low = [minimum.to_i, 1].max
          high = [maximum.to_i, low].max
          rand(low..high)
        end
      end
    end

    module Bonuses
      STATS = [:HP, :ATTACK, :DEFENSE, :SPECIAL_ATTACK,
               :SPECIAL_DEFENSE, :SPEED].freeze

      class << self
        def build(entry, method_id)
          choice = EncounterPools.choose_target(entry)
          return nil unless choice
          species = choice[:species]
          search_level = WildLink.search_level(species)
          chain = WildLink.chain_for(species, method_id)
          level = boosted_level(choice[:level], search_level)
          pokemon = global_call(:pbGenerateWildPokemon, species, level)
          return nil unless pokemon
          temperament = temperament_for(species)
          apply_shiny_rolls(pokemon, search_level, chain)
          apply_perfect_ivs(pokemon, search_level, chain)
          apply_hidden_ability(pokemon, search_level, chain)
          egg_moves = apply_egg_moves(pokemon, search_level, chain)
          apply_held_item(pokemon, search_level, chain)
          pokemon.calc_stats if pokemon.respond_to?(:calc_stats)
          pokemon.instance_variable_set(:@wild_link_egg_moves, egg_moves)
          pokemon.instance_variable_set(:@wild_link_temperament, temperament)
          choice.merge(
            :pokemon => pokemon,
            :level => pokemon.level,
            :search_level => search_level,
            :chain => chain,
            :temperament => temperament,
            :egg_moves => egg_moves
          )
        rescue StandardError => e
          WildLink.log_exception("Wild Link Pokemon generation failed", e)
          nil
        end

        def temperament_for(species)
          data = GameData::Species.get(species)
          stats = data.base_stats
          attack = [stats[:ATTACK].to_i, stats[:SPECIAL_ATTACK].to_i].max
          defense = [stats[:DEFENSE].to_i, stats[:SPECIAL_DEFENSE].to_i].max
          speed = stats[:SPEED].to_i
          choices = [:calm, :curious]
          choices.concat([:aggressive, :territorial]) if attack >= defense
          choices.concat([:territorial, :calm]) if defense > attack
          choices.concat([:skittish, :elusive]) if speed >= 80
          choices[data.id_number.to_i % choices.length]
        rescue StandardError
          :calm
        end

        def temperament_label(value)
          value.to_s.split("_").map { |part| part.capitalize }.join(" ")
        end

        def perfect_iv_count(pokemon)
          STATS.count { |stat| pokemon.iv[stat].to_i >= 31 }
        rescue StandardError
          0
        end

        def bonus_preview(search_level, chain, species = nil)
          level = search_level.to_i
          chain_value = chain.to_i
          level_range = level_bonus_range(level)
          availability = bonus_availability(species)
          {
            :shiny_rolls => [
              search_shiny_rolls(level) + chain_shiny_rolls(chain_value), 8
            ].min,
            :level_bonus => [level_range.begin, level_range.end],
            :perfect_ivs => perfect_iv_preview_label(level, chain_value),
            :hidden_ability => if availability[:hidden_ability]
                                 [
                                   hidden_ability_base(level) +
                                     hidden_ability_chain(chain_value),
                                   50
                                 ].min
                               end,
            :first_egg_move => if availability[:egg_move_count] >= 1
                                 [
                                   first_egg_base(level) +
                                     first_egg_chain(chain_value),
                                   90
                                 ].min
                               end,
            :second_egg_move => second_egg_move_preview(
              level, chain_value, availability[:egg_move_count]
            ),
            :held_item => if availability[:held_item]
                            [
                              item_base(level) + item_chain(chain_value), 60
                            ].min
                          end
          }
        end

        private

        def bonus_availability(species)
          return {
            :hidden_ability => true,
            :egg_move_count => 2,
            :held_item => true
          } if species.nil?
          data = GameData::Species.get(species)
          items = [
            data.wild_item_common,
            data.wild_item_uncommon,
            data.wild_item_rare
          ].compact.uniq
          {
            :hidden_ability => !Array(data.hidden_abilities).compact.empty?,
            :egg_move_count => Array(data.egg_moves).compact.uniq.length,
            :held_item => !items.empty?
          }
        rescue StandardError
          {
            :hidden_ability => false,
            :egg_move_count => 0,
            :held_item => false
          }
        end

        def second_egg_move_preview(search_level, chain, egg_move_count)
          return nil if egg_move_count.to_i < 2
          return :locked unless search_level.to_i >= 100 || chain.to_i >= 50
          [
            second_egg_base(search_level) + second_egg_chain(chain), 65
          ].min
        end

        def boosted_level(level, search_level)
          range = level_bonus_range(search_level)
          maximum = if defined?(GameData::GrowthRate) &&
                       GameData::GrowthRate.respond_to?(:max_level)
                      GameData::GrowthRate.max_level
                    else
                      100
                    end
          [level.to_i + rand(range), maximum.to_i].min
        rescue StandardError
          level.to_i
        end

        def level_bonus_range(search_level)
          case search_level.to_i
          when 0..9 then 0..0
          when 10..24 then 0..1
          when 25..49 then 0..2
          when 50..99 then 1..2
          when 100..199 then 1..3
          when 200..499 then 2..4
          else 3..5
          end
        end

        def perfect_iv_preview_label(search_level, chain)
          minimum = case search_level.to_i
                    when 0..49 then 0
                    when 50..199 then 1
                    else 2
                    end
          minimum = [minimum, 4].max if chain.to_i >= 150
          minimum = [minimum, 3].max if chain.to_i.between?(100, 149)
          minimum = [minimum, 2].max if chain.to_i.between?(50, 99)
          chances = []
          if search_level.to_i.between?(25, 49) && minimum < 1
            chances << "15%"
          elsif search_level.to_i.between?(100, 199) && minimum < 2
            chances << "20%"
          elsif search_level.to_i >= 500 && minimum < 3
            chances << "20%"
          end
          if chain.to_i.between?(30, 49) && minimum < 4
            chances << "50%"
          end
          label = _INTL("{1} min", minimum)
          label += " | +#{chances.join('/+')}" unless chances.empty?
          label
        end

        def apply_shiny_rolls(pokemon, search_level, chain)
          return if pokemon.shiny?
          rolls = search_shiny_rolls(search_level) + chain_shiny_rolls(chain)
          rolls = [rolls, 8].min
          rolls.times do
            pokemon.personalID = rand(2**16) | (rand(2**16) << 16)
            pokemon.shiny = nil
            break if pokemon.shiny?
          end
        end

        def search_shiny_rolls(level)
          case level.to_i
          when 0..24 then 0
          when 25..99 then 1
          when 100..199 then 2
          when 200..499 then 3
          else 4
          end
        end

        def chain_shiny_rolls(chain)
          case chain.to_i
          when 0..9 then 0
          when 10..19 then 1
          when 20..49 then 2
          when 50..149 then 3
          else 4
          end
        end

        def apply_perfect_ivs(pokemon, search_level, chain)
          target = search_iv_target(search_level)
          if chain.to_i.between?(30, 49) && rand(100) < 50
            target += 1
          elsif chain.to_i >= 150
            target = [target, 4].max
          elsif chain.to_i >= 100
            target = [target, 3].max
          elsif chain.to_i >= 50
            target = [target, 2].max
          end
          target = [target, 4].min
          available = STATS.reject { |stat| pokemon.iv[stat].to_i >= 31 }
          while perfect_iv_count(pokemon) < target && !available.empty?
            stat = available.delete_at(rand(available.length))
            pokemon.iv[stat] = 31
          end
        end

        def search_iv_target(level)
          case level.to_i
          when 0..24 then 0
          when 25..49 then rand(100) < 15 ? 1 : 0
          when 50..99 then 1
          when 100..199 then 1 + (rand(100) < 20 ? 1 : 0)
          when 200..499 then 2
          else 2 + (rand(100) < 20 ? 1 : 0)
          end
        end

        def apply_hidden_ability(pokemon, search_level, chain)
          hidden = Array(pokemon.species_data.hidden_abilities).compact
          return if hidden.empty?
          chance = [hidden_ability_base(search_level) +
                    hidden_ability_chain(chain), 50].min
          return unless rand(100) < chance
          if defined?(KantoReloaded::DoubleAbilities) &&
             KantoReloaded::DoubleAbilities.respond_to?(:eligible_pokemon?) &&
             KantoReloaded::DoubleAbilities.eligible_pokemon?(pokemon)
            choices = KantoReloaded::DoubleAbilities.hidden_slot_choices(
              pokemon, 1
            ).compact.uniq
            return if choices.empty?
            selected = choices[rand(choices.length)]
            return unless KantoReloaded::DoubleAbilities.assign_slot!(
              pokemon, 1, selected
            )
            return KantoReloaded::DoubleAbilities.primary_id(pokemon)
          end
          index = rand(hidden.length)
          pokemon.ability_index = index + 2
          pokemon.ability = nil
          pokemon.ability_id
        end

        def hidden_ability_base(level)
          case level.to_i
          when 0..9 then 0
          when 10..24 then 2
          when 25..49 then 5
          when 50..99 then 8
          when 100..199 then 12
          when 200..499 then 18
          else 25
          end
        end

        def hidden_ability_chain(chain)
          case chain.to_i
          when 0..9 then 0
          when 10..19 then 5
          when 20..49 then 10
          when 50..99 then 15
          when 100..149 then 20
          else 25
          end
        end

        def apply_egg_moves(pokemon, search_level, chain)
          pool = Array(pokemon.species_data.egg_moves).compact.uniq
          return [] if pool.empty?
          learned = []
          first_chance = [first_egg_base(search_level) +
                          first_egg_chain(chain), 90].min
          return learned unless rand(100) < first_chance
          learned << pool.delete_at(rand(pool.length))
          second_unlocked = search_level.to_i >= 100 || chain.to_i >= 50
          if second_unlocked && !pool.empty?
            second_chance = [second_egg_base(search_level) +
                             second_egg_chain(chain), 65].min
            learned << pool.delete_at(rand(pool.length)) if rand(100) < second_chance
          end
          learned.each { |move| pokemon.learn_move(move) }
          pokemon.record_first_moves if pokemon.respond_to?(:record_first_moves)
          learned
        end

        def first_egg_base(level)
          case level.to_i
          when 0..9 then 0
          when 10..24 then 10
          when 25..49 then 20
          when 50..99 then 30
          when 100..199 then 40
          when 200..499 then 55
          else 70
          end
        end

        def first_egg_chain(chain)
          case chain.to_i
          when 0..9 then 0
          when 10..19 then 5
          when 20..49 then 10
          when 50..99 then 15
          when 100..149 then 20
          else 25
          end
        end

        def second_egg_base(level)
          case level.to_i
          when 0..99 then 0
          when 100..199 then 10
          when 200..499 then 20
          else 30
          end
        end

        def second_egg_chain(chain)
          case chain.to_i
          when 0..49 then 0
          when 50..99 then 15
          when 100..149 then 25
          else 35
          end
        end

        def apply_held_item(pokemon, search_level, chain)
          chance = [item_base(search_level) + item_chain(chain), 60].min
          return unless rand(100) < chance
          items = Array(pokemon.wildHoldItems)
          candidates = item_candidates(items, search_level, chain)
          return if candidates.empty?
          chosen = candidates[rand(candidates.length)]
          current_rank = item_rank(pokemon.item_id, items)
          chosen_rank = item_rank(chosen, items)
          pokemon.item = chosen if !pokemon.item_id || chosen_rank > current_rank
        end

        def item_candidates(items, search_level, chain)
          common, uncommon, rare = items
          score = [search_level.to_i / 10 + chain.to_i, 200].min
          rare_weight = [5 + score / 5, 40].min
          uncommon_weight = [25 + score / 4, 55].min
          rows = []
          rows.concat(Array.new(rare_weight, rare)) if rare
          rows.concat(Array.new(uncommon_weight, uncommon)) if uncommon
          rows.concat(Array.new([100 - rare_weight - uncommon_weight, 10].max, common)) if common
          rows.compact
        end

        def item_rank(item, items)
          return -1 unless item
          return 2 if item == items[2]
          return 1 if item == items[1]
          0
        end

        def item_base(level)
          case level.to_i
          when 0..9 then 0
          when 10..24 then 5
          when 25..49 then 10
          when 50..99 then 15
          when 100..199 then 20
          when 200..499 then 25
          else 30
          end
        end

        def item_chain(chain)
          case chain.to_i
          when 0..9 then 0
          when 10..19 then 5
          when 20..49 then 10
          when 50..99 then 15
          when 100..149 then 20
          else 30
          end
        end

        def global_call(name, *args)
          Object.new.__send__(name, *args)
        end
      end
    end
  end
end
