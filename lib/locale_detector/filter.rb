module LocaleDetector
  module Filter
    extend ActiveSupport::Concern

    included do
      append_before_filter :set_locale
    end

    protected

    def set_locale
      Rails.logger.info "Setting locale"
      if session[:locale].present?
        # set locale from session
        Rails.logger.info "Session locale present"
        set_locale_if_exists(session[:locale])
      elsif cookies[:locale].present?
        Rails.logger.info "Cookie present"
        set_locale_if_exists(cookies[:locale])
      elsif params[:locale].present?
        Rails.logger.info "Param present"
        find_locale_and_set_cookie(params[:locale])
      else
        # set locale from http header or request host
        possible_locale_name = begin
          request.env['HTTP_ACCEPT_LANGUAGE'].split(/\s*,\s*/).collect do |l|
            l += ';q=1.0' unless l =~ /;q=\d+\.\d+$/
            l.split(';q=')
          end.sort do |x,y|
            raise "Incorrect format" unless x.first =~ /^[a-z\-]+$/i
            y.last.to_f <=> x.last.to_f
          end.first.first.gsub(/-[a-z]+$/i, '').downcase
          find_locale_and_set_cookie(possible_locale_name)
        rescue # rescue (anything) from the malformed (or missing) accept language headers
          I18n.locale = country_to_language(request.host.split('.').last)
        end
      end
      Rails.logger.info "Locale set to #{I18n.locale}"
    end

    def set_locale_if_exists(possible_locale_name)
      Rails.logger.info "Setting locale if exists " + possible_locale_name.to_s
      sym = possible_locale_name.to_sym
      locale = I18n.default_locale

      if I18n.available_locales.include? sym
        locale = sym
      end
      I18n.locale = locale
    end
    def find_locale_and_set_cookie(possible_locale_name)
      set_locale_if_exists(possible_locale_name)
      cookies[:locale] = locale
      Rails.logger.info "Cookie set to " + locale.to_s
    end

    def country_to_language(country_code)

      if MAPPINGS.has_key?(country_code.to_sym)
        MAPPINGS[country_code.to_sym].to_s
      else
        # fall back for all other missing mappings
        I18n.default_locale.to_s
      end

    end

    MAPPINGS = {
        # English
        :au => :en,
        :ca => :en,
        :eu => :en,
        :ie => :en,
        :nz => :en,
        :sg => :en,
        :uk => :en,
        :us => :en,

        # French
        :cd => :fr,
        :cg => :fr,
        :cm => :fr,
        :fr => :fr,
        :mg => :fr,

        # German
        :at => :de,
        :ch => :de,
        :de => :de,
        :li => :de,
        :lu => :de,

        # Portuguese
        :ao => :pt,
        :br => :pt,
        :mz => :pt,
        :pt => :pt,

        # Spanish
        :ar => :"es-CL",
        :cl => :"es-CL",
        :co => :"es-CL",
        :cu => :"es-CL",
        :es => :"es-CL",
        :mx => :"es-CL",

        # All other languages
        :bg => :bg,
        :by => :be,
        :cn => :zh,
        :cz => :cs,
        :dk => :da,
        :ee => :et,
        :fi => :fi,
        :gr => :el,
        :hr => :hr,
        :hu => :hu,
        :il => :he,
        :in => :hi,
        :is => :is,
        :it => :it,
        :jp => :ja,
        :kr => :ko,
        :lt => :lt,
        :lv => :lv,
        :mn => :mn,
        :nl => :nl,
        :no => :no,
        :pl => :pl,
        :ro => :ro,
        :rs => :sr,
        :ru => :ru,
        :se => :sv,
        :si => :sl,
        :sk => :sk,
        :th => :th,
        :tr => :tr,
        :ua => :uk,
        :vn => :vi,
      }
  end
end
