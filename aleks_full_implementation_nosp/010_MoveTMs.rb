#===============================================================================
# NPT Move TMs — Auto-register TM items for all NPT moves
# File: 990_NPT/010_MoveTMs.rb
#
# Runs after 004_Moves.rb has loaded all NPT moves.
# Creates a TM item for each NPT move (id_number 6001-6187).
# TM items get id_number 9500+ and use the engine's machine_{TYPE}.png sprites.
# Pocket 4 = "TMs & HMs", field_use 3 = is_TM? true.
#===============================================================================

if defined?(GameData) && defined?(GameData::Item) && defined?(GameData::Move)
  class GameData::Item
    class << self
      alias npt_move_tms_original_load load unless method_defined?(:npt_move_tms_original_load)
      def load
        npt_move_tms_original_load

        registered = 0
        GameData::Move.each do |move|
          next unless move.id_number.between?(6001, 6999)
          tm_sym       = "TM_#{move.id}".to_sym
          tm_id_number = 9500 + (move.id_number - 6001)
          next if self::DATA.has_key?(tm_sym)

          register({
            id:          tm_sym,
            id_number:   tm_id_number,
            name:        "TM #{move.name}",
            name_plural: "TM #{move.name}",
            pocket:      4,
            price:       0,
            field_use:   3,    # is_TM? => true
            battle_use:  0,
            type:        0,
            move:        move.id,
            description: "Teaches #{move.name} to a compatible Pokémon.",
          })
          registered += 1
        end
      end
    end
  end
end
