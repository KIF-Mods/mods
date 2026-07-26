#==============================================================================
# Kanto Reloaded - Wild Link Data
#==============================================================================

module KantoReloaded
  module WildLink
    MODULE_ID = :wild_link
    STATE_KEY = :state
    SETTINGS_ACTION = :wild_link_settings
    MESSAGES_SETTING = :"wild_link.messages"
    CONTINUE_SETTING = :"wild_link.continue_search"

    CONTINUE_PROMPT = 0
    CONTINUE_AUTOMATIC = 1
    CONTINUE_OFF = 2
    SEARCH_LEVEL_CAP = 999

    METHOD_LABELS = {
      :land => "Land",
      :cave => "Cave",
      :surf => "Surf",
      :fishing => "Fishing",
      :headbutt => "Headbutt",
      :rock_smash => "Rock Smash"
    }.freeze

    class RuntimeState
      attr_accessor :target
      attr_accessor :chain
      attr_accessor :chain_key
      attr_accessor :pending_continue
      attr_accessor :stable_map_updates

      def initialize
        @target = nil
        @chain = 0
        @chain_key = nil
        @pending_continue = nil
        @stable_map_updates = 0
      end

      def reset
        @target = nil
        @chain = 0
        @chain_key = nil
        @pending_continue = nil
        @stable_map_updates = 0
      end
    end

    class << self
      def runtime
        @runtime ||= RuntimeState.new
      end

      def state
        stored = KantoReloaded::SaveData.get(
          MODULE_ID, STATE_KEY, {}, section: :modules
        )
        stored = {} unless stored.is_a?(Hash)
        stored["version"] = 2
        stored["search_levels"] = {} unless stored["search_levels"].is_a?(Hash)
        unless stored["discovered_fusions"].is_a?(Hash)
          stored["discovered_fusions"] = {}
        end
        stored
      rescue StandardError
        @fallback_state ||= {
          "version" => 2,
          "search_levels" => {},
          "discovered_fusions" => {}
        }
      end

      def save_state(value)
        @fallback_state = value
        KantoReloaded::SaveData.set(
          MODULE_ID, STATE_KEY, value, section: :modules
        )
        true
      rescue StandardError => e
        log_exception("Wild Link state save failed", e)
        false
      end

      def species_key(species)
        GameData::Species.get(species).id.to_s
      rescue StandardError
        species.to_s
      end

      def search_level(species)
        state["search_levels"][species_key(species)].to_i.clamp(
          0, SEARCH_LEVEL_CAP
        )
      rescue StandardError
        0
      end

      def increment_search_level(species, amount)
        data = state
        key = species_key(species)
        value = (data["search_levels"][key].to_i + amount.to_i).clamp(
          0, SEARCH_LEVEL_CAP
        )
        data["search_levels"][key] = value
        save_state(data)
        value
      end

      def reset_search_levels
        data = state
        data["search_levels"] = {}
        save_state(data)
      end

      def record_discovered_fusion(species, method_id, level,
                                   map_id = current_map_id)
        return false unless method_id && map_id.to_i > 0
        species_data = GameData::Species.get(species)
        return false unless species_data.respond_to?(:is_fusion) &&
                            species_data.is_fusion
        data = state
        bucket_key = discovered_fusion_bucket_key(method_id, map_id)
        buckets = data["discovered_fusions"]
        buckets[bucket_key] = {} unless buckets[bucket_key].is_a?(Hash)
        key = species_key(species_data.id)
        observed = [level.to_i, 1].max
        record = buckets[bucket_key][key]
        record = {} unless record.is_a?(Hash)
        minimum = record["min_level"].to_i
        maximum = record["max_level"].to_i
        record["min_level"] = minimum > 0 ? [minimum, observed].min : observed
        record["max_level"] = maximum > 0 ? [maximum, observed].max : observed
        buckets[bucket_key][key] = record
        save_state(data)
      rescue StandardError => e
        log_exception("Wild Link fusion discovery save failed", e)
        false
      end

      def discovered_fusions(method_id, map_id = current_map_id)
        bucket_key = discovered_fusion_bucket_key(method_id, map_id)
        bucket = state["discovered_fusions"][bucket_key]
        return [] unless bucket.is_a?(Hash)
        rows = []
        bucket.each do |species, record|
          begin
            species_data = GameData::Species.get(species)
            next unless species_data.respond_to?(:is_fusion) &&
                        species_data.is_fusion
            details = record.is_a?(Hash) ? record : {}
            minimum = [details["min_level"].to_i, 1].max
            maximum = [details["max_level"].to_i, minimum].max
            rows << {
              :species => species_data.id,
              :min_level => minimum,
              :max_level => maximum
            }
          rescue StandardError
            next
          end
        end
        rows
      rescue StandardError
        []
      end

      def discovered_fusion_bucket_key(method_id, map_id = current_map_id)
        [map_id.to_i, method_id.to_s].join("|")
      end

      def chain_key(species, method_id, map_id = current_map_id)
        [species_key(species), method_id.to_s, map_id.to_i].join("|")
      end

      def begin_chain(species, method_id, map_id = current_map_id)
        key = chain_key(species, method_id, map_id)
        if runtime.chain_key != key
          runtime.chain = 0
          runtime.chain_key = key
        end
        runtime.chain
      end

      def advance_chain(species, method_id, map_id = current_map_id)
        begin_chain(species, method_id, map_id)
        runtime.chain = runtime.chain.to_i + 1
      end

      def break_chain
        runtime.chain = 0
        runtime.chain_key = nil
        runtime.pending_continue = nil
        runtime.stable_map_updates = 0
        true
      end

      def chain_for(species, method_id, map_id = current_map_id)
        return 0 unless runtime.chain_key == chain_key(species, method_id, map_id)
        runtime.chain.to_i
      end

      def continue_mode
        KantoReloaded::Settings.get(
          CONTINUE_SETTING, CONTINUE_PROMPT
        ).to_i
      rescue StandardError
        CONTINUE_PROMPT
      end

      def messages_enabled?
        KantoReloaded::Settings.get(MESSAGES_SETTING, 1).to_i == 1
      rescue StandardError
        true
      end

      def message(text, options = {})
        return false unless messages_enabled?
        KantoReloaded::PopupWindow.message(text, options)
      end

      def confirm(text, options = {})
        return true unless messages_enabled?
        KantoReloaded::PopupWindow.confirm(text, options)
      end

      def toast(theme, text)
        return false unless messages_enabled?
        return false unless defined?(KantoReloaded::Toast)
        KantoReloaded::Toast.__send__(theme, text)
      rescue StandardError
        false
      end

      def seen?(species)
        pokedex = player_pokedex
        pokedex ? !!pokedex.seen?(species) : false
      rescue StandardError
        false
      end

      def caught?(species)
        pokedex = player_pokedex
        pokedex ? !!pokedex.owned?(species) : false
      rescue StandardError
        false
      end

      def method_label(method_id)
        _INTL(METHOD_LABELS[method_id.to_sym] || method_id.to_s)
      rescue StandardError
        method_id.to_s
      end

      def current_map_id
        $game_map ? $game_map.map_id.to_i : 0
      rescue StandardError
        0
      end

      def player_pokedex
        return nil unless $Trainer
        return $Trainer.pokedex if $Trainer.respond_to?(:pokedex)
        $Trainer
      end

      def log_exception(message, error)
        KantoReloaded::Log.exception(
          message, error, channel: :wild_link
        ) if defined?(KantoReloaded::Log)
      rescue StandardError
        nil
      end
    end
  end
end
