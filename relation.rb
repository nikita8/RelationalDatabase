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
    filtered_fds = filtered_fds - superfluous_fds(filtered_fds)
    update_lhs_attr(filtered_fds)
    filtered_fds
  end

  def update_lhs_rhs_attr(lhs, rhs)
    @lhs_attributes << lhs
    @rhs_attributes << rhs
  end

  def update_lhs_attr(filtered_fds)
    @lhs_attributes = filtered_fds.map { |fd| lhs, _ = fd.split('->'); lhs}
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
      next if discarded_fds.include?(fd)
      lhs, rhs = fd.split('->').map(&:strip)
      remainging_fds = filtered_fds - [fd] - discarded_fds
      fd_closure = closure(lhs, remainging_fds)
      if ([rhs] - fd_closure).empty?
        if lhs.size > 1
          discarded_fds << fd
        else
          weaker_fds = lhs_attributes.select{ |attr| attr.include?(lhs) && attr != lhs }
          discarded_fds << fd if  weaker_fds.empty?
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

  def keys_seed
    @keys_seed ||= attributes - attr_in_rhs_only
  end

  def bcnf?
    return true if fds.empty?
    lhs_attributes.all? do |attr|
      keys.any? do |key|
        key_attrs = key.chars
        (key_attrs - attr.chars).empty?
      end
    end
  end

  def one_nf?
    fds.any? do |fd| 
      lhs, rhs = fd.split('->').map(&:strip)
      key_attribute = keys.any? { |key| key.include?(rhs) }
      keys.any? do |key|
        key_attrs = key.chars
        partial_key = lhs.chars != key_attrs && !(lhs.chars & key_attrs).empty?
        partial_key && !key_attribute
      end
    end
  end

  def all_rhs_key_attributes?
    rhs_attributes.all? do |attr|
      keys.any? { |key| key.include?(attr) }
    end
  end

  def compute_normal_form
    if bcnf?
      "BCNF" 
    elsif all_rhs_key_attributes?
      "3NF"
    elsif one_nf?
      "1NF"
    else
      "2NF"
    end
  end
end
