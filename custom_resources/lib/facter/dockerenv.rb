Facter.add(:dockerenv) do
  setcode do
    if File.exist? '/.dockeenv'
      true
    end
  end
end

