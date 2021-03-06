module OmfRc::Util::Sysfs
  include OmfRc::ResourceProxyDSL

  request :devices do |resource|
    devices = []
    # Support net devices for now
    category = "net"

    Dir.glob("/sys/class/net/eth*").each do |v|
      File.exist?("#{v}/uevent") && File.open("#{v}/uevent") do |f|
        subcategory = f.read.match(/DEVTYPE=(.+)/) && $1
        proxy = "net"
        File.exist?("#{v}/device/uevent") && File.open("#{v}/device/uevent") do |f|
          driver = f.read.match(/DRIVER=(.+)/) && $1
          device = { name: File.basename(v), driver: driver, category: category }
          device[:subcategory] = subcategory if subcategory
          device[:proxy] = proxy if OmfRc::ResourceFactory.proxy_list.include?(proxy.to_sym)
          File.exist?("#{v}/operstate") && File.open("#{v}/operstate") do |fo|
            device[:op_state] = (fo.read || '').chomp
          end
          # Let's see if the interface is already up 
          # NOTE: THIS MAY NOT BE ROBUST
          s = `ifconfig #{File.basename(v)}`
          unless s.empty?
            if m = s.match(/inet addr:\s*([0-9.]+)/)
              device[:ip4] = m[1]
            end 
            if m = s.match(/inet6 addr:\s*([0-9a-f.:\/]+)/)
              device[:ip6] = m[1]
            end 
          end
          devices << device
        end
      end
    end

    Dir.glob("/sys/class/ieee80211/*").each do |v|
      subcategory = "wlan"
      proxy = "wlan"
      File.exist?("#{v}/device/uevent") && File.open("#{v}/device/uevent") do |f|
        driver = f.read.match(/DRIVER=(.+)/) && $1
        device = { name: File.basename(v), driver: driver, category: category, subcategory: subcategory }
        device[:proxy] = proxy if OmfRc::ResourceFactory.proxy_list.include?(proxy.to_sym)
        devices << device
      end
    end
    devices
  end

  request :wlan_devices do |resource|
    resource.request_devices.find_all { |v| v[:proxy] == 'wlan' }
  end
end

