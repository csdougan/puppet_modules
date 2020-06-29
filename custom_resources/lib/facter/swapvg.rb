Facter.add(:swapvg) do
  setcode "lvs|grep swap|awk '{print $2}'" 
end
