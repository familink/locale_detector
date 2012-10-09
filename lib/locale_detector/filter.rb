module LocaleDetector
  module Filter
    extend ActiveSupport::Concern

    included do
      append_before_filter :set_locale
    end

    protected

    def set_locale
      if session[:locale].present?
        # set locale from session
        I18n.locale = session[:locale]
      elsif params[:locale]
        Rails.logger.info "No locale on session"
        string_locale = params[:locale]
        sym_locale = params[:locale].parameterize.to_sym
        Rails.logger.info "Logger on params #{{string_locale}} (#{{sym_locale}})"
        Rails.logger.info "Looking for locale in #{{I18n.available_locales}}"
        if I18n.available_locales.include? string_locale
          Rails.logger.info "String locale detected"
          I18n.locale = string_locale
        elsif I18n.available_locales.include? sym_locale
          Rails.logger.info "Symbol locale detected"
          I18n.locale = sym_locale
        else
          Rails.logger.info "Not detected"
          I18n.locale = I18n.default_locale
        end
        #session[:locale] = locale
      else
        # set locale from http header or request host
        I18n.locale = begin
          request.env['HTTP_ACCEPT_LANGUAGE'].split(/\s*,\s*/).collect do |l|
            l += ';q=1.0' unless l =~ /;q=\d+\.\d+$/
            l.split(';q=')
          end.sort do |x,y|
            raise "Incorrect format" unless x.first =~ /^[a-z\-]+$/i
            y.last.to_f <=> x.last.to_f
          end.first.first.gsub(/-[a-z]+$/i, '').downcase
        rescue # rescue (anything) from the malformed (or missing) accept language headers
          country_to_language(request.host.split('.').last)
        end
      end
      Rails.logger.info "Locale set to #{I18n.locale}"
      Rails.logger.info I18n.available_locales
    end

    # a somewhat incomplete list of toplevel domain suffix to language code mappings
    def country_to_language(country_code)

      # sources:
      # http://en.wikipedia.org/wiki/List_of_Internet_top-level_domains
      # http://www.w3.org/WAI/ER/IG/ert/iso639.htm
      # http://msdn.microsoft.com/en-us/library/ms693062%28v=vs.85%29.aspx

      # country_code => language_code
      

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
        :ar => :es,
        :cl => :es,
        :co => :es,
        :cu => :es,
        :es => :es,
        :mx => :es,

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
