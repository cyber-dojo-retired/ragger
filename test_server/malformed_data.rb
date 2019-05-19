
module MalformedData

  def malformed_image_names
    hex = '9'*32
    [
      nil,
      '<none>',        # [docker images] gives this
      '',              # nothing!
      '_',             # cannot start with separator
      'name_',         # cannot end with separator
      ';;;',           # illegal char
      'ALPHA/name',    # no uppercase
      'gcc/Assert',    # no uppercase
      'alpha/name_',   # cannot end in separator
      'alpha/_name',   # cannot begin with separator
      'gcc:.',         # tag can't start with .
      'gcc:-',         # tag can't start with -
      'gcc:{}',        # bad tag
      "gcc:#{'x'*129}",# tag too long
      '-/gcc/assert:23',    # - is illegal hostname
      '-x/gcc/assert:23',   # -x is illegal hostname
      'x-/gcc/assert:23',   # x- is illegal hostname
      '/gcc/assert',        # remote-name can't start with /
      'gcc_assert@sha256:1234567890123456789012345678901',  # >=32 hex-digits
      "gcc_assert!sha256-2:#{hex}",  # need @ to start digest
      "gcc_assert@256:#{hex}",       # algorithm must start with letter
      "gcc_assert@sha256-2:#{hex}",  # alg-component must start with letter
      "gcc_assert@sha256#{hex}",     # need : to start hex-digits
    ]
  end

  # - - - - - - - - - - - - - - - - -

  def malformed_ids
    [
      nil,          # not String
      Object.new,   # not String
      [],           # not String
      '',           # not 6 chars
      '12345',      # not 6 chars
      '1234567',    # not 6 chars
    ]
  end

end
