class RelationDB
  attr_reader :attributes, :fds, :keys

  def initialize(attributes, fds)
    @attributes = attributes.split('')
    @fds = filter_and_transform(fds)
    @keys = compute_keys
  end

  def closure(seed, computing_fds=fds)
    seed_closure = seed.strip.split('') - ['-', '>', ' ']
    valid_fds = computing_fds
    found_fds = []
    while true
      found_all_closure = true
      valid_fds.each do |fd|
        lhs, rhs = fd.split('->').map(&:strip)
        if(lhs.split('') - seed_closure).empty?
          seed_closure += rhs.split('')
          found_fds << fd
          found_all_closure = false
        end
      end
      valid_fds = valid_fds - found_fds
      break if found_all_closure
    end
    seed_closure.uniq
  end

  def compute_keys
    partial_key = (attributes - rhs_attributes).join('')
    return [partial_key] if key?(partial_key)
    keys_seed.map do |attribute|
      key(attribute + partial_key)
    end.compact
  end

  def normal_form
    compute_normal_form
  end

  private
  def filter_and_transform(fds)
    parsed_fds = fds
    fds.each do |fd|
      lhs, rhs = fd.split('->')
      if lhs.nil? || rhs.nil?
        parsed_fds = parsed_fds - [fd]
        next
      end
      lhs = lhs.strip
      rhs = rhs.strip
      if rhs.length > 1 
        parsed_fds = parsed_fds - [fd]
        parsed_fds = parsed_fds + transform_to_non_trivial_fd(lhs, rhs)
      elsif check_trivial_or_invalid(lhs, rhs)
        parsed_fds = parsed_fds - [fd]
      end
    end
    parsed_fds - superfluous_fds(parsed_fds)
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

  def check_trivial_or_invalid(lhs, rhs)
    invalid = !((lhs + rhs).split('') - attributes).empty?
    trivial = lhs.include?(rhs)
    if ( trivial || invalid)
      return true
    else
      return false
    end
  end

  def transform_to_non_trivial_fd(lhs, rhs)
    rhs.strip.split('').map do |new_rhs|
      unless check_trivial_or_invalid(lhs, new_rhs)
        [lhs, new_rhs].join('->')
      end
    end.compact
  end

  def rhs_attributes 
    @rhs_attributes ||= fds.map do |fd|
      _, rhs = fd.split('->')
      rhs
    end
  end

  def lhs_attributes 
    @lhs_attributes ||= fds.map do |fd|
      lhs, _ = fd.split('->')
      lhs
    end
  end

  def key(attribute)
    return attribute if key?(attribute)
    (keys_seed - attribute.split('')).each do |attr|
      key(attribute + attr)
    end
    return
  end

  def key?(attribute)
    (attributes - closure(attribute)).empty?
  end

  def key_in_rhs_only
    lhs_attributes - rhs_attributes
  end

  def partial_key_fds
    keys.map do |key|
      key_attrs = key.split('')
      lhs_attributes.select{|attr| !(key_attrs - attr.split('')).empty? }
    end
  end

  def keys_seed
    @keys_seed ||= attributes - key_in_rhs_only
  end

  def bcnf_voilating_fds
    keys.map do |key|
      key_attrs = key.split('')
      lhs_attributes.select{|attr| !(attr.split('') & key_attrs).empty? }
    end.flatten
  end

  def rhs_key_attributes
    @rhs_key_attributes ||= keys.map do |key|
      key_attrs = key.split('')
      rhs_attributes.select{|attr| !(attr.split('') & key_attrs).empty? }
    end.flatten
  end

  def compute_normal_form
    if bcnf_voilating_fds.empty?
      return "3NF" unless rhs_key_attributes.empty?
      return "BCNF"
    elsif !rhs_key_attributes.empty?
      return "1NF"
    else
      return "2NF"
    end
  end
end
