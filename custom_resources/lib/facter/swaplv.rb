Facter.add(:swaplv) do
  setcode "lvs|grep swap|awk '{print $1}'" 
end

