require "test_helper"

module Claude
  module Arsenal
    module Config
      class TestSkillRules < Minitest::Test
        include TestHelpers

        def test_initialize_with_default_path
          rules = SkillRules.new
          assert_equal SkillRules::DEFAULT_CONFIG_PATH, rules.config_path
        end

        def test_initialize_with_custom_path
          custom_path = 'custom/skill-rules.json'
          rules = SkillRules.new(config_path: custom_path)
          assert_equal custom_path, rules.config_path
        end

        def test_add_skill
          rules = SkillRules.new

          rules.add_skill('backend-dev', {
            type: 'domain',
            enforcement: 'suggest',
            priority: 'high',
            promptTriggers: {
              keywords: ['backend', 'API']
            }
          })

          skill = rules.get_skill('backend-dev')
          assert_equal 'domain', skill['type']
          assert_equal 'suggest', skill['enforcement']
          assert_equal 'high', skill['priority']
          assert_equal ['backend', 'API'], skill['promptTriggers']['keywords']
        end

        def test_remove_skill
          rules = SkillRules.new
          rules.add_skill('test-skill', { type: 'domain' })

          assert rules.get_skill('test-skill')

          rules.remove_skill('test-skill')
          assert_nil rules.get_skill('test-skill')
        end

        def test_save_and_reload
          rules = SkillRules.new
          rules.add_skill('test-skill', { type: 'domain', priority: 'high' })
          rules.save

          assert File.exist?(SkillRules::DEFAULT_CONFIG_PATH)

          # Create new instance and verify it loads the saved data
          new_rules = SkillRules.new
          skill = new_rules.get_skill('test-skill')
          assert_equal 'domain', skill['type']
          assert_equal 'high', skill['priority']
        end

        def test_normalize_config_with_symbols
          rules = SkillRules.new
          rules.add_skill('test', {
            type: :domain,
            enforcement: :suggest,
            priority: :high
          })

          skill = rules.get_skill('test')
          assert_equal 'domain', skill['type']
          assert_equal 'suggest', skill['enforcement']
          assert_equal 'high', skill['priority']
        end

        def test_default_enforcement_and_priority
          rules = SkillRules.new
          rules.add_skill('test', { type: 'domain' })

          skill = rules.get_skill('test')
          assert_equal 'suggest', skill['enforcement']
          assert_equal 'medium', skill['priority']
        end

        def test_invalid_json_raises_error
          FileUtils.mkdir_p('.claude/config')
          File.write(SkillRules::DEFAULT_CONFIG_PATH, '{ invalid json }')

          error = assert_raises(Claude::Arsenal::Error) do
            SkillRules.new
          end

          assert_match(/Invalid JSON/, error.message)
        end
      end
    end
  end
end
