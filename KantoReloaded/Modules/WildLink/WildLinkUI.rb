#==============================================================================
# Kanto Reloaded - Wild Link UI
#==============================================================================

module KantoReloaded
  module WildLink
    module UI
      class << self
        def open
          return false unless graphics_available?
          result = nil
          KantoReloaded::UI::Modal.with_modal do
            result = Scene.new.main
          end
          result
        rescue StandardError => e
          WildLink.log_exception("Wild Link UI failed", e)
          false
        ensure
          KantoReloaded::UI::Modal.drain_input if
            defined?(KantoReloaded::UI::Modal)
        end

        private

        def graphics_available?
          defined?(Graphics) && defined?(Input) && defined?(Viewport) &&
            defined?(BitmapSprite) && defined?(PokemonIconSprite) &&
            defined?(KantoReloaded::ListState)
        end
      end

      class Scene
        SCREEN_W = 512
        SCREEN_H = 384
        HEADER_H = 72
        FOOTER_H = 28
        ROW_H = 25
        LIST_X = 8
        LIST_Y = HEADER_H + 4
        LIST_W = 310
        LIST_H = SCREEN_H - LIST_Y - FOOTER_H - 4
        DETAIL_X = LIST_X + LIST_W + 8
        DETAIL_W = SCREEN_W - DETAIL_X - 8
        VISIBLE_ROWS = (LIST_H - 12) / ROW_H

        BG = Color.new(16, 20, 31)
        PANEL = Color.new(26, 32, 48)
        BORDER = Color.new(56, 79, 126)
        WHITE = Color.new(255, 255, 255)
        GRAY = Color.new(174, 181, 201)
        DIM = Color.new(104, 112, 138)
        BLUE = Color.new(112, 191, 255)
        GREEN = Color.new(102, 224, 158)
        GOLD = Color.new(240, 202, 82)
        RED = Color.new(235, 98, 116)

        def initialize
          @method_index = 0
          @result = false
          @detail_icon_key = nil
        end

        def main
          setup
          loop do
            Graphics.update
            Input.update
            @detail_icon.update if @detail_icon
            result = handle_input
            break if result == :close
            if ((Graphics.frame_count rescue 0) % 4).zero?
              draw_list
            end
          end
          @result
        ensure
          dispose
        end

        private

        def setup
          @viewport = Viewport.new(0, 0, SCREEN_W, SCREEN_H)
          @viewport.z = 999_999
          @background = Sprite.new(@viewport)
          @background.bitmap = Bitmap.new(SCREEN_W, SCREEN_H)
          @background.bitmap.fill_rect(0, 0, SCREEN_W, SCREEN_H, BG)
          @header_sprite = BitmapSprite.new(SCREEN_W, HEADER_H, @viewport)
          @list_sprite = BitmapSprite.new(LIST_W, LIST_H, @viewport)
          @detail_sprite = BitmapSprite.new(DETAIL_W, LIST_H, @viewport)
          @footer_sprite = BitmapSprite.new(SCREEN_W, FOOTER_H, @viewport)
          @list_sprite.x = LIST_X
          @list_sprite.y = LIST_Y
          @detail_sprite.x = DETAIL_X
          @detail_sprite.y = LIST_Y
          @footer_sprite.y = SCREEN_H - FOOTER_H
          @detail_icon = PokemonIconSprite.new(nil, @viewport)
          @detail_icon.z = @viewport.z + 3
          load_methods
          draw_all
        end

        def load_methods(preferred_method = nil, preferred_species = nil)
          old_method = preferred_method || current_method_id
          old_species = preferred_species || current_species_key
          @methods = EncounterPools.available_methods
          if old_method
            found = @methods.index { |method| method[:id] == old_method }
            @method_index = found if found
          end
          @method_index = @method_index.clamp(
            0, [@methods.length - 1, 0].max
          )
          load_entries(old_species)
        end

        def load_entries(preferred_species = nil)
          @entries = current_method ?
            EncounterPools.entries_for(current_method) : []
          @state = KantoReloaded::ListState::State.new(
            @entries, :visible_rows => VISIBLE_ROWS
          )
          if preferred_species
            index = @entries.index do |entry|
              !entry[:signal] &&
                WildLink.species_key(entry[:species]) == preferred_species
            end
            @state.select(index) if index
          end
          @detail_icon_key = nil
        end

        def draw_all
          draw_header
          draw_list
          draw_detail
          draw_footer
        end

        def draw_header
          bitmap = @header_sprite.bitmap
          bitmap.clear
          bitmap.fill_rect(0, 0, SCREEN_W, HEADER_H, BG)
          set_font(bitmap, 16)
          text(bitmap, 8, -1, SCREEN_W - 16, 24, _INTL("WILD LINK"), BLUE, 1, 16)
          if @methods.empty?
            text(
              bitmap, 8, 30, SCREEN_W - 16, 22,
              _INTL("No compatible encounter signals are available here."),
              DIM, 1
            )
          else
            draw_method_tabs(bitmap)
          end
          bitmap.fill_rect(0, HEADER_H - 1, SCREEN_W, 1, BORDER)
        end

        def draw_method_tabs(bitmap)
          width = (SCREEN_W - 16) / @methods.length
          @methods.each_with_index do |method, index|
            x = 8 + index * width
            actual_width = index == @methods.length - 1 ?
              SCREEN_W - 8 - x : width - 2
            if index == @method_index
              fill, border = KantoReloaded::Options.cursor_colors
              KantoReloaded::UI::Draw.rounded_rect(
                bitmap, x, 29, actual_width, 27, 4, fill, border
              )
            end
            color = index == @method_index ? WHITE : GRAY
            text(
              bitmap, x + 2, 29, actual_width - 4, 25,
              method[:label], color, 1
            )
          end
          active = Runtime.target
          return unless active
          label = active[:unknown] ? _INTL("Rare Signal") :
            GameData::Species.get(active[:species]).name
          text(
            bitmap, 8, 51, SCREEN_W - 16, 18,
            _INTL("Active: {1} | Chain {2}", label, WildLink.runtime.chain),
            GREEN, 1, 13
          )
        rescue StandardError
          nil
        end

        def draw_list
          bitmap = @list_sprite.bitmap
          bitmap.clear
          panel(bitmap, LIST_W, LIST_H)
          set_font(bitmap, 15)
          if @state.empty?
            text(
              bitmap, 10, 104, LIST_W - 20, 24,
              _INTL("No Pokemon are available for this method."), DIM, 1
            )
            return
          end
          @state.visible.each_with_index do |entry, local|
            index = @state.scroll + local
            y = 6 + local * ROW_H
            selected = index == @state.index
            cursor(bitmap, y) if selected
            name = EncounterPools.entry_name(entry)
            color = row_color(entry, selected)
            text(bitmap, 14, y - 2, LIST_W - 112, ROW_H, name, color)
            status = row_status(entry)
            text(
              bitmap, LIST_W - 110, y - 2, 94, ROW_H,
              status, status_color(entry), 2
            )
          end
        end

        def draw_detail
          bitmap = @detail_sprite.bitmap
          bitmap.clear
          panel(bitmap, DETAIL_W, LIST_H)
          set_font(bitmap, 15)
          entry = @state.current
          unless entry
            @detail_icon.pokemon = nil
            text(
              bitmap, 8, 104, DETAIL_W - 16, 24,
              _INTL("Select a signal."), DIM, 1
            )
            return
          end
          refresh_detail_icon(entry)
          name = EncounterPools.entry_name(entry)
          text(bitmap, 8, 8, DETAIL_W - 16, 22, name, WHITE, 1)
          if entry[:signal]
            draw_signal_detail(bitmap, entry)
          else
            draw_species_detail(bitmap, entry)
          end
        end

        def draw_signal_detail(bitmap, entry)
          status = entry[:unlocked] ? _INTL("Signal Available") :
            _INTL("Signal Locked")
          color = entry[:unlocked] ? GREEN : RED
          text(bitmap, 8, 34, DETAIL_W - 16, 20, status, color, 1)
          text(
            bitmap, 10, 123, DETAIL_W - 20, 38,
            entry[:unlocked] ?
              _INTL("Search for an undiscovered route-exclusive Pokemon.") :
              _INTL("See every standard Land Pokemon on this map first."),
            GRAY, 1
          )
          draw_level_range(bitmap, entry, 174)
        end

        def draw_species_detail(bitmap, entry)
          seen = WildLink.seen?(entry[:species])
          caught = WildLink.caught?(entry[:species])
          status = caught ? _INTL("Caught") : (seen ? _INTL("Seen") : _INTL("Unseen"))
          color = caught ? GREEN : (seen ? GOLD : DIM)
          text(bitmap, 8, 34, DETAIL_W - 16, 20, status, color, 1)
          level = WildLink.search_level(entry[:species])
          text(
            bitmap, 10, 122, DETAIL_W - 20, 20,
            _INTL("Search Level"), GRAY
          )
          text(
            bitmap, 10, 122, DETAIL_W - 20, 20,
            level.to_s, BLUE, 2
          )
          method_id = current_method ? current_method[:id] : :land
          chain = WildLink.chain_for(entry[:species], method_id)
          text(bitmap, 10, 143, DETAIL_W - 20, 20, _INTL("Chain"), GRAY)
          text(bitmap, 10, 143, DETAIL_W - 20, 20, chain.to_s, GOLD, 2)
          active = active_target_for?(entry)
          if active
            draw_active_details(bitmap, Runtime.target, 164)
          else
            draw_bonus_preview(bitmap, entry, level, chain, 161)
            draw_next_unlock(bitmap, level, 254)
          end
        end

        def draw_bonus_preview(bitmap, entry, level, chain, start_y)
          preview = Bonuses.bonus_preview(level, chain, entry[:species])
          native_min = entry[:min_level].to_i
          native_max = entry[:max_level].to_i
          native_levels = native_min == native_max ?
            native_min.to_s : "#{native_min}-#{native_max}"
          bonus_min, bonus_max = preview[:level_bonus]
          level_bonus = bonus_min == bonus_max ?
            "+#{bonus_min}" : "+#{bonus_min}-#{bonus_max}"
          second_egg = preview[:second_egg_move]
          hidden_label = percentage_or_na(preview[:hidden_ability])
          item_label = percentage_or_na(preview[:held_item])

          text(
            bitmap, 8, start_y, DETAIL_W - 16, 16,
            _INTL("CURRENT BONUSES"), BLUE, 1, 13
          )
          text(
            bitmap, 8, start_y + 16, DETAIL_W - 16, 16,
            _INTL("Levels {1} | Bonus {2}", native_levels, level_bonus),
            GRAY, 1, 12
          )
          text(
            bitmap, 8, start_y + 31, DETAIL_W - 16, 16,
            _INTL("Shiny +{1} Rolls", preview[:shiny_rolls]),
            GREEN, 1, 12
          )
          text(
            bitmap, 8, start_y + 46, DETAIL_W - 16, 16,
            _INTL("IV {1}", preview[:perfect_ivs]), WHITE, 1, 12
          )
          text(
            bitmap, 8, start_y + 61, DETAIL_W - 16, 16,
            _INTL("HA {1} | Item Roll {2}", hidden_label, item_label),
            GOLD, 1, 12
          )
          if preview[:first_egg_move].nil?
            text(
              bitmap, 8, start_y + 76, DETAIL_W - 16, 16,
              _INTL("Egg Moves N/A"), GRAY, 1, 12
            )
          else
            second_egg_label = case second_egg
                               when :locked then _INTL("Locked")
                               when nil then _INTL("N/A")
                               else _INTL("{1}%", second_egg)
                               end
            text(
              bitmap, 8, start_y + 76, DETAIL_W - 16, 16,
              _INTL("Egg 1 {1}% | Egg 2 {2}",
                    preview[:first_egg_move], second_egg_label),
              GRAY, 1, 12
            )
          end
        rescue StandardError
          nil
        end

        def percentage_or_na(value)
          value.nil? ? _INTL("N/A") : _INTL("{1}%", value)
        end

        def draw_level_range(bitmap, entry, y)
          minimum = entry[:min_level].to_i
          maximum = entry[:max_level].to_i
          label = minimum == maximum ? minimum.to_s : "#{minimum}-#{maximum}"
          text(bitmap, 10, y, DETAIL_W - 20, 20, _INTL("Native Levels"), GRAY)
          text(bitmap, 10, y, DETAIL_W - 20, 20, label, WHITE, 2)
        end

        def draw_active_details(bitmap, current, start_y)
          lines = Runtime.target_summary_lines(current)
          lines = [_INTL("Target details unlock as Search Level rises.")] if lines.empty?
          set_font(bitmap, 12)
          wrapped = lines.inject([]) do |rows, line|
            rows.concat(
              KantoReloaded::UI::Draw.wrap_lines(
                bitmap, line.to_s, DETAIL_W - 20
              )
            )
          end
          wrapped.first(8).each_with_index do |line, index|
            text(
              bitmap, 8, start_y + index * 14, DETAIL_W - 16, 16,
              line, index.zero? ? GREEN : GRAY, 1, 12
            )
          end
        end

        def draw_next_unlock(bitmap, level, y)
          threshold, label = next_unlock(level)
          if threshold
            text(
              bitmap, 8, y, DETAIL_W - 16, 20,
              _INTL("Next: {1} at SL {2}", label, threshold),
              DIM, 1, 13
            )
          else
            text(
              bitmap, 8, y, DETAIL_W - 16, 20,
              _INTL("All scan details unlocked."), GREEN, 1, 13
            )
          end
        end

        def draw_footer
          bitmap = @footer_sprite.bitmap
          bitmap.clear
          bitmap.fill_rect(0, 0, SCREEN_W, FOOTER_H, BG)
          bitmap.fill_rect(0, 0, SCREEN_W, 1, BORDER)
          @footer_entries = footer_entries
          KantoReloaded::HintText.draw_footer(
            bitmap, @footer_entries,
            8, 4, SCREEN_W - 16,
            :size => 14, :color => WHITE, :height => FOOTER_H,
            :y_offset => -4, :show_hint => false
          )
        end

        def footer_entries
          entries = [
            KantoReloaded::HintText.confirm("Search"),
            KantoReloaded::HintText.back("Back")
          ]
          entries << KantoReloaded::HintText.action("Cancel Link") if
            cancellable_link?
          entries << KantoReloaded::HintText.other("Method", "L/R")
          entries
        end

        def handle_input
          mouse_result = update_mouse
          if mouse_result == :cancel &&
             KantoReloaded::MouseInput.mouse_triggered?
            return cancel_current_link
          elsif mouse_result == :search &&
             KantoReloaded::MouseInput.mouse_triggered?
            return search_selected
          elsif mouse_result == :method &&
                KantoReloaded::MouseInput.mouse_triggered?
            return :continue
          end
          wheel = KantoReloaded::MouseInput.wheel_delta
          if wheel != 0
            move(wheel < 0 ? 1 : -1)
          elsif Input.repeat?(Input::UP)
            move(-1)
          elsif Input.repeat?(Input::DOWN)
            move(1)
          elsif Input.repeat?(Input::LEFT)
            move(-5)
          elsif Input.repeat?(Input::RIGHT)
            move(5)
          elsif trigger?(:AUX1)
            change_method(-1)
          elsif trigger?(:AUX2)
            change_method(1)
          elsif Input.trigger?(Input::ACTION) && cancellable_link?
            return cancel_current_link
          elsif Input.trigger?(Input::USE)
            return search_selected
          elsif Input.trigger?(Input::BACK)
            pbPlayCloseMenuSE rescue nil
            return :close
          end
          :continue
        end

        def cancellable_link?
          Runtime.active? || Runtime.chain_active?
        end

        def cancel_current_link
          proceed = WildLink.confirm(
            _INTL("Cancel the current Wild Link target and end its chain?"),
            :default => false, :serious => true, :theme => :warning
          )
          unless proceed
            draw_all
            return :continue
          end
          if Runtime.active?
            Runtime.clear_target(:manual_cancel, true)
          else
            WildLink.break_chain
          end
          pbPlayCancelSE rescue nil
          WildLink.toast(:success, _INTL("The current Wild Link was cancelled."))
          load_methods(current_method_id, current_species_key)
          draw_all
          :continue
        end

        def search_selected
          entry = @state.current
          return :continue unless entry && current_method
          unless searchable?(entry)
            pbPlayBuzzerSE rescue nil
            message = entry[:signal] ?
              _INTL("This Rare Signal is still locked.") :
              _INTL("This Pokemon must be seen before it can be searched.")
            WildLink.message(message, :theme => :warning)
            draw_all
            return :continue
          end
          label = EncounterPools.entry_name(entry)
          proceed = WildLink.confirm(
            _INTL("Start a Wild Link search for {1}?", label),
            :default => true
          )
          unless proceed
            draw_all
            return :continue
          end
          if Runtime.start_search(entry, current_method)
            @result = :target_started
            return :close
          end
          load_methods(current_method_id, current_species_key)
          draw_all
          :continue
        end

        def searchable?(entry)
          return !!entry[:unlocked] if entry[:signal]
          WildLink.seen?(entry[:species])
        end

        def move(amount)
          return unless @state.move(amount)
          pbPlayCursorSE rescue nil
          @detail_icon_key = nil
          draw_list
          draw_detail
        end

        def change_method(amount)
          return if @methods.empty?
          @method_index = (@method_index + amount.to_i) % @methods.length
          pbPlayCursorSE rescue nil
          load_entries
          draw_all
        end

        def update_mouse
          position = KantoReloaded::MouseInput.active_position
          return nil unless position
          x, y = position
          return :cancel if cancellable_link? &&
                            footer_entry_at?(x, y, :action)
          if y >= 29 && y < 57 && x >= 8 && x < SCREEN_W - 8 &&
             !@methods.empty?
            width = (SCREEN_W - 16) / @methods.length
            index = ((x - 8) / width).clamp(0, @methods.length - 1)
            if index != @method_index
              @method_index = index
              load_entries
              pbPlayCursorSE rescue nil
              draw_all
            end
            return :method
          end
          return nil unless x >= LIST_X && x < LIST_X + LIST_W
          return nil unless y >= LIST_Y + 6 && y < LIST_Y + LIST_H - 6
          local = (y - LIST_Y - 6) / ROW_H
          index = @state.scroll + local
          return nil if index < 0 || index >= @state.rows.length
          if index != @state.index
            @state.select(index)
            @detail_icon_key = nil
            draw_list
            draw_detail
          end
          :search
        end

        def footer_entry_at?(mouse_x, mouse_y, type)
          local_y = mouse_y - @footer_sprite.y
          return false if local_y < 0 || local_y >= FOOTER_H
          bitmap = @footer_sprite.bitmap
          entries = @footer_entries || footer_entries
          labels = entries.map do |entry|
            KantoReloaded::HintText.format([entry])
          end
          separator = "   "
          separator_width = bitmap.text_size(separator).width
          full_text = labels.join(separator)
          full_width = bitmap.text_size(full_text).width
          footer_width = SCREEN_W - 16
          hidden_hint = KantoReloaded::HintText.other("Hints", "Z")
          hint_text = KantoReloaded::HintText.format([hidden_hint])
          hint_width = [
            bitmap.text_size(hint_text).width + 8, footer_width / 3
          ].min
          center_width = [footer_width - hint_width - 8, 0].max
          cursor_x = 8 + [(center_width - full_width) / 2, 0].max
          entries.each_with_index do |entry, index|
            label_width = bitmap.text_size(labels[index]).width
            if entry[:type] == type.to_sym
              left = cursor_x - separator_width / 2
              right = cursor_x + label_width + separator_width / 2
              return mouse_x >= left && mouse_x < right
            end
            cursor_x += label_width + separator_width
          end
          false
        rescue StandardError
          false
        end

        def refresh_detail_icon(entry)
          species = entry[:species]
          key = [
            WildLink.species_key(species), WildLink.caught?(species),
            entry[:signal]
          ]
          return if @detail_icon_key == key
          @detail_icon_key = key
          pokemon = Pokemon.new(species, 5)
          @detail_icon.pokemon = pokemon
          @detail_icon.x = DETAIL_X + (DETAIL_W - 64) / 2
          @detail_icon.y = LIST_Y + 55
          if entry[:signal] || !WildLink.caught?(species)
            @detail_icon.color = Color.new(0, 0, 0, 255)
          else
            @detail_icon.color = Color.new(0, 0, 0, 0)
          end
        rescue StandardError
          @detail_icon.pokemon = nil if @detail_icon
        end

        def row_color(entry, selected)
          return selected ? WHITE : DIM if entry[:signal] && !entry[:unlocked]
          return selected ? WHITE : GREEN if entry[:rare] && WildLink.seen?(entry[:species])
          selected ? WHITE : GRAY
        end

        def row_status(entry)
          return entry[:unlocked] ? _INTL("Ready") : _INTL("Locked") if entry[:signal]
          return _INTL("Caught") if WildLink.caught?(entry[:species])
          return _INTL("Seen") if WildLink.seen?(entry[:species])
          _INTL("Unknown")
        end

        def status_color(entry)
          return entry[:unlocked] ? GREEN : RED if entry[:signal]
          return GREEN if WildLink.caught?(entry[:species])
          return GOLD if WildLink.seen?(entry[:species])
          DIM
        end

        def active_target_for?(entry)
          current = Runtime.target
          return false unless current && !entry[:signal] && current_method
          current[:method_id] == current_method[:id] &&
            WildLink.species_key(current[:species]) ==
              WildLink.species_key(entry[:species])
        end

        def next_unlock(level)
          [
            [1, _INTL("target level")],
            [5, _INTL("temperament")],
            [10, _INTL("potential")],
            [15, _INTL("held item")],
            [20, _INTL("ability")],
            [25, _INTL("Egg Moves")],
            [50, _INTL("exact signal direction")]
          ].find { |row| level.to_i < row[0] }
        end

        def current_method
          return nil unless @methods && !@methods.empty?
          @methods[@method_index]
        end

        def current_method_id
          method = current_method
          method ? method[:id] : nil
        end

        def current_species_key
          entry = @state && @state.current
          entry && !entry[:signal] ? WildLink.species_key(entry[:species]) : nil
        end

        def panel(bitmap, width, height)
          KantoReloaded::UI::Draw.rounded_rect(
            bitmap, 0, 0, width, height, 5, PANEL, BORDER
          )
        end

        def cursor(bitmap, y)
          fill, border = KantoReloaded::Options.cursor_colors
          KantoReloaded::UI::Draw.rounded_rect(
            bitmap, 7, y + 2, LIST_W - 14, ROW_H - 3, 4, fill, border
          )
        rescue StandardError
          nil
        end

        def set_font(bitmap, size = 15)
          pbSetSmallFont(bitmap) if defined?(pbSetSmallFont)
          bitmap.font.size = size
        end

        def text(bitmap, x, y, width, height, value, color,
                 align = 0, size = 15)
          KantoReloaded::UI::Draw.plain_text(
            bitmap, x, y, width, height, value.to_s, color, align, size
          )
        end

        def trigger?(name)
          KantoReloaded::UI::InputRouter.input_triggered?(name)
        rescue StandardError
          false
        end

        def dispose
          @detail_icon.dispose if @detail_icon && !@detail_icon.disposed?
          [@background, @header_sprite, @list_sprite, @detail_sprite,
           @footer_sprite].each do |sprite|
            next unless sprite
            if sprite.bitmap && !sprite.bitmap.disposed?
              sprite.bitmap.dispose
            end
            sprite.dispose unless sprite.disposed?
          rescue StandardError
            nil
          end
          @viewport.dispose if @viewport && !@viewport.disposed?
          Graphics.update if defined?(Graphics)
        rescue StandardError
          nil
        end
      end
    end

    class SettingsScene < KantoReloaded::SettingsUI::BaseScene
      def scene_title
        "Wild Link"
      end

      def scene_description
        "Configure Wild Link search behavior and permanent progression."
      end

      def pbGetOptions(_inloadscreen = false)
        rows = []
        rows << setting_row(MESSAGES_SETTING)
        rows << setting_row(CONTINUE_SETTING)
        rows << KantoReloaded::Options::TextDisplayOption.new(
          _INTL("Search Level Cap"),
          proc { SEARCH_LEVEL_CAP.to_s },
          _INTL("Search Levels are stored per exact Pokemon species or fusion.")
        )
        rows << KantoReloaded::Options::TextDisplayOption.new(
          _INTL("Shiny Bonus"),
          proc { _INTL("+8 Rolls Maximum") },
          _INTL("Search Level and chain bonuses provide up to eight additional rolls.")
        )
        rows << KantoReloaded::Options::TextDisplayOption.new(
          _INTL("Chain Scope"),
          proc { _INTL("Pokemon / Method / Map") },
          _INTL("Changing the Pokemon, method, or map ends the active chain.")
        )
        rows << KantoReloaded::Options::ActionButton.new(
          _INTL("Reset Search Levels"),
          proc { reset_search_levels },
          _INTL("Erase all permanent Wild Link Search Level progression.")
        )
        rows.compact
      end

      private

      def setting_row(key)
        definition = KantoReloaded::Settings.definition(key)
        return nil unless definition
        KantoReloaded::SettingsUI::RowFactory.build(
          definition, :scene => self, :wild_link => true
        )
      end

      def reset_search_levels
        return unless KantoReloaded::PopupWindow.confirm(
          _INTL("Erase every Wild Link Search Level? This cannot be undone."),
          :default => false, :serious => true, :theme => :warning
        )
        if Runtime.active?
          Runtime.clear_target(:reset, true)
        elsif Runtime.chain_active?
          WildLink.break_chain
        end
        WildLink.reset_search_levels
        sync_window_values
        WildLink.toast(:success, _INTL("Wild Link Search Levels reset."))
      end
    end
  end
end
