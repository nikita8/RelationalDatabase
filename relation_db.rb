class RelationDB
  attr_reader :attributes, :fds, :keys

  def initialize(attributes, fds)
    @attributes = attributes.split('')
    @fds = filter_and_transform(fds)
    @keys = compute_keys
  end

  def closure(seed)
    seed_closure = seed.strip.split('') - ['-', '>', ' ']
    valid_fds = fds
    found_fds = []
    while true
      found_all_closure = true
      valid_fds.each do |fd|
        lhs, rhs = fd.split('->')
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
    if third_nf
      "3NF"
    elsif bcnf
      "BCNF"
    elsif second_nf
      "2NF"
    elsif first_nf
      "1NF"
    end
  end

  private
  def filter_and_transform(fds)
    new_fd = fds
    fds.each do |fd|
      lhs, rhs = fd.split('->')
      if lhs.nil? || rhs.nil?
        new_fd = new_fd - [fd]
        return
      end
      if rhs.length > 1 
        new_fd = new_fd - [fd]
        new_fd = new_fd + transform_to_non_trivial_fd(lhs, rhs)
      elsif check_trivial_or_invalid(lhs, rhs)
        new_fd = new_fd - [fd]
      end
    end
    new_fd
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
    rhs.split('').map do |new_rhs|
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
    (key_attributes - attribute.split('')).each do |attr|
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

  def bcnf
  end

  def first_nf
  end

  def second_nf
  end

  def third_nf
    bcnf(fd) && 
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

  def rhs_key_attributes
    @rhs_key_attributes ||= keys.map do |key|
      key_attrs = key.split('')
      rhs_attributes.select{|attr| !(key_attrs - attr.split('')).empty? }
    end.flatten
  end

  def compute_normal_form
    bcnf_voilating_fds = keys.map do |key|
      key_attrs = key.split('')
      lhs_attributes.select{|attr| !(key_attrs - attr.split('')).empty? }
    end.flatten

    if bcnf_voilating_fds.empty?
      return "3NF" if rhs_key_attributes.present?
      "BCNF"
    elsif rhs_key_attributes.present?
    end
  end
end
