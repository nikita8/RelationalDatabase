class Relation
  attr_reader :attributes, :fds, :keys, :normal_form, :lhs_attributes, :rhs_attributes

  def initialize(attributes, fds)
    @attributes = attributes.chars
    @fds = filter_and_transform(fds).uniq
    @keys = compute_keys
    @normal_form = compute_normal_form
  end

  def closure(seed, computing_fds=fds)
    seed_closure = seed.strip.chars - ['-', '>', ' ']
    # return unless (seed_closure - attributes).empty?
    valid_fds = computing_fds
    found_fds = []
    found_all_closure = false
    while !found_all_closure
      found_all_closure = true
      valid_fds.each do |fd|
        lhs, rhs = fd.split('->').map(&:strip)
        if(lhs.chars - seed_closure).empty?
          seed_closure += rhs.chars
          found_fds << fd
          found_all_closure = false
        end
      end
      valid_fds = valid_fds - found_fds
      break if found_all_closure
    end
    seed_closure.uniq
  end

  private
  def filter_and_transform(fds)
    filtered_fds = []
    @lhs_attributes = []
    @rhs_attributes = []
    fds.each do |fd|
      fd = fd.strip 
      lhs, rhs = fd.split('->')
      lhs = lhs&.strip
      rhs = rhs&.strip
      next if discard_fd?(lhs, rhs)
      if rhs.length > 1 
        filtered_fds = filtered_fds + transform_trivial_fd(lhs, rhs)
      else
        filtered_fds = filtered_fds + [fd]
        update_lhs_rhs_attr(lhs, rhs)
      end
    end
    filtered_fds - superfluous_fds(filtered_fds)
  end

  def update_lhs_rhs_attr(lhs, rhs)
    @lhs_attributes << lhs
    @rhs_attributes << rhs
  end

  def discard_fd?(lhs, rhs)
    return true if lhs.nil? || rhs.nil?
    unless rhs.length > 1
      return trivial_or_invalid_fd?(lhs, rhs)
    end 
    return false
  end

  def superfluous_fds(filtered_fds)
    discarded_fds = []
    filtered_fds.each do |fd|
      lhs, rhs = fd.split('->').map(&:strip)
      if lhs.size > 1
        remainging_fds = filtered_fds - [fd] - discarded_fds
        fd_closure = closure(lhs, remainging_fds)
        if ([rhs] - fd_closure).empty?
          discarded_fds << fd
        end
      end
    end
    discarded_fds
  end

  def trivial_or_invalid_fd?(lhs, rhs)
    invalid = !((lhs + rhs).chars - attributes).empty?
    trivial = lhs.include?(rhs)
    if ( trivial || invalid)
      return true
    else
      return false
    end
  end

  def transform_trivial_fd(lhs, rhs)
    rhs.strip.chars.map do |non_trivial_rhs|
      unless trivial_or_invalid_fd?(lhs, non_trivial_rhs)
        update_lhs_rhs_attr(lhs, non_trivial_rhs)
        [lhs, non_trivial_rhs].join('->')
      end
    end.compact
  end

  def compute_keys
    partial_key = (attributes - rhs_attributes).join
    return [partial_key] if key?(partial_key)
    keys_seed.map do |attribute|
      key(attribute + partial_key)
    end.compact
  end

  def key(attribute)
    return attribute if key?(attribute)
    (keys_seed - attribute.chars).each do |attr|
      key(attribute + attr)
    end
    return
  end

  def key?(attribute)
    (attributes - closure(attribute)).empty?
  end

  def attr_in_rhs_only
    rhs_attributes - lhs_attributes.map(&:chars).flatten.uniq
  end

  def partial_key_fds
    keys.map do |key|
      key_attrs = key.chars
      lhs_attributes.select{|attr| !(key_attrs - attr.chars).empty? }
    end
  end

  def keys_seed
    @keys_seed ||= attributes - attr_in_rhs_only
  end

  def bcnf_voilating_fds?
    lhs_attributes.each do |attr| 
      keys.each do |key|
        key_attrs = key.chars
        if !(key_attrs - attr.chars).empty?
          return true
        end
      end
    end
    return false
  end

  def one_nf?
    fds.each do |fd| 
      lhs, rhs = fd.split('->').map(&:strip)
      keys.each do |key|
        next if lhs.chars == key.chars
        if (lhs.chars - key.chars).empty? && !key.include?(rhs)
          return true
        end
      end
    end
    return false
  end

  def all_rhs_key_attributes?
    rhs_attributes.each do |attr|
      key_attribute = keys.any? do |key|
        key.include?(attr)
      end
      return false unless key_attribute
    end
    return true
  end

  def any_rhs_key_attributes?
    rhs_attributes.each do |attr|
      key_attribute = keys.any? do |key|
        key.include?(attr)
      end
      return true if key_attribute
    end
    return false
  end

  def compute_normal_form
    return 'BCNF' if fds.empty?
    if all_rhs_key_attributes?
      "3NF"
    elsif !bcnf_voilating_fds?
      if any_rhs_key_attributes?
        return "3NF"
      end
      "BCNF" 
    elsif one_nf?
      "1NF"
    else
      "2NF"
    end
  end
end
