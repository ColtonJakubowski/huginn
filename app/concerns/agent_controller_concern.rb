module AgentControllerConcern
  extend ActiveSupport::Concern

  included do
    can_control_other_agents!

    validate :validate_control_action
  end

  def default_options
    {
      'action' => 'run'
    }
  end

  def control_action
    interpolated['action']
  end

  def validate_control_action
    case options['action']
    when 'run'
      control_targets.each { |target|
        if target.cannot_be_scheduled?
          errors.add(:base, "#{target.name} cannot be scheduled")
        end
      }
    when 'configure'
      if !options['configure_options'].is_a?(Hash) || options['configure_options'].empty?
        errors.add(:base,
                   "A non-empty hash must be specified in the 'configure_options' option when using the 'configure' action.")
      end
    when 'enable', 'disable'
    when nil
      errors.add(:base, "action must be specified")
    when /\{[%{]/
      # Liquid template
    else
      errors.add(:base, 'invalid action')
    end
  end

  def control!
    control_targets.each do |target|
      interpolate_with('target' => target) do
        case action = control_action
        when 'run'
          case
          when target.cannot_be_scheduled?
            error "'#{target.name}' cannot run without an incoming event"
          when target.disabled?
            log "Agent run ignored for disabled Agent '#{target.name}'"
          else
            Agent.async_check(target.id)
            log "Agent run queued for '#{target.name}'"
          end
        when 'enable'
          case
          when target.disabled?
            if boolify(interpolated['drop_pending_events'])
              target.drop_pending_events = true
            end
            target.update!(disabled: false)
            log "Agent '#{target.name}' is enabled"
          else
            log "Agent '#{target.name}' is already enabled"
          end
        when 'disable'
          case
          when target.disabled?
            log "Agent '#{target.name}' is alread disabled"
          else
            target.update!(disabled: true)
            log "Agent '#{target.name}' is disabled"
          end
        when 'configure'
          target.update! options: target.options.deep_merge(interpolated['configure_options'])
          log "Agent '#{target.name}' is configured with #{interpolated['configure_options'].inspect}"
        when ''
          log 'No action is performed.'
        else
          error "Unsupported action '#{action}' ignored for '#{target.name}'"
        end
      rescue StandardError => e
        error "Failed to #{action} '#{target.name}': #{e.message}"
      end
    end
  end
end
