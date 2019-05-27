class Object
  # An object is blank if it's false, empty, or a whitespace string.
  # For example, "", "   ", +nil+, [], and {} are all blank.
  #
  # This simplifies:
  #
  #   if address.nil? || address.empty?
  #
  # ...to:
  #
  #   if address.blank?
  def blank?
    respond_to?(:empty?) ? empty? : !self
  end

  # An object is present if it's not <tt>blank?</tt>.
  def present?
    !blank?
  end

  def not_blank?
    !blank?
  end

  # Returns object if it's <tt>present?</tt> otherwise returns +nil+.
  # <tt>object.presence</tt> is equivalent to <tt>object.present? ? object : nil</tt>.
  #
  # This is handy for any representation of objects where blank is the same
  # as not present at all. For example, this simplifies a common check for
  # HTTP POST/query parameters:
  #
  #   state   = params[:state]   if params[:state].present?
  #   country = params[:country] if params[:country].present?
  #   region  = state || country || 'US'
  #
  # ...becomes:
  #
  #   region = params[:state].presence || params[:country].presence || 'US'
  def presence
    self if present?
  end
end

class NilClass
  # +nil+ is blank:
  #
  #   nil.blank? # => true
  #
  def blank?
    true
  end
end

class FalseClass
  # +false+ is blank:
  #
  #   false.blank? # => true
  #
  def blank?
    true
  end
end

class TrueClass
  # +true+ is not blank:
  #
  #   true.blank? # => false
  #
  def blank?
    false
  end
end

class Array
  # An array is blank if it's empty:
  #
  #   [].blank?      # => true
  #   [1,2,3].blank? # => false
  #
  alias_method :blank?, :empty?
end

class Hash
  # A hash is blank if it's empty:
  #
  #   {}.blank?                # => true
  #   {:key => 'value'}.blank? # => false
  #
  alias_method :blank?, :empty?
end

class String
  #NON_WHITESPACE_REGEXP = %r![^\s#{[0x3000].pack("U")}]! unless defined?(NON_WHITESPACE_REGEXP)

  # 0x3000: fullwidth whitespace

  # A string is blank if it's empty or contains whitespaces only:
  #
  #   "".blank?                 # => true
  #   "   ".blank?              # => true
  #   "　".blank?               # => true
  #   " something here ".blank? # => false
  #

    if defined?(Encoding) && "".respond_to?(:encode)
      def encoding_aware?
        true
      end
    else
      def encoding_aware?
        false
      end
    end

  # lifted from active_support/inflectors so we don't have to bring the whole lib into selext

  def blank?
    # 1.8 does not takes [:space:] properly
    if encoding_aware?
      self !~ /[^[:space:]]/
      end
  end

  # lifted from active_support/inflectors so we don't have to bring the whole lib into selext

  def underscore
    camel_cased_word = self
    acronym_regex = //
    word = camel_cased_word.to_s.dup
    word.gsub!(/::/, '/')
    word.gsub!(/(?:([A-Za-z\d])|^)(#{acronym_regex})(?=\b|[^a-z])/) { "#{$1}#{$1 && '_'}#{$2.downcase}" }
    word.gsub!(/([A-Z\d]+)([A-Z][a-z])/,'\1_\2')
    word.gsub!(/([a-z\d])([A-Z])/,'\1_\2')
    word.tr!("-", "_")
    word.downcase!
    # remove trailing underscore if present
    word.chomp!("_")
    word
  end

  # lifted from active_support/inflectors so we don't have to bring the whole lib into selext

  def camelize
    term = self
    uppercase_first_letter = true
    acronym_regex = //
    acronyms = []
    string = term.to_s

    if uppercase_first_letter
      string = string.sub(/^[a-z\d]*/) { $&.capitalize }
    else
      string = string.sub(/^(?:#{acronym_regex}(?=\b|[A-Z_])|\w)/) { $&.downcase }
    end

    string.gsub(/(?:_|(\/))([a-z\d]*)/i) { "#{$1}#{$2.capitalize}" }.gsub('/', '::')
    end
  
end

class Numeric #:nodoc:
  # No number is blank:
  #
  #   1.blank? # => false
  #   0.blank? # => false
  #
  def blank?
    false
  end
end

