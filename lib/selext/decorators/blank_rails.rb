# limited version of selext_blank ... use with rails (active_support)
# to just add the not_blank? method.

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
  # def blank?
  #   respond_to?(:empty?) ? empty? : !self
  # end

  # # An object is present if it's not <tt>blank?</tt>.
  # def present?
  #   !blank?
  # end

  def not_blank?
    !blank?
  end

end

