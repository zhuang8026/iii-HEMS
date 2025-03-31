platform :ios, '12.0'  # 建議升級最低 iOS 版本

target 'Energy-Active' do
  use_frameworks! :linkage => :static  # 避免與某些 Pods 不兼容的問題
  use_modular_headers! # ✅ 加入這行

  pod 'Starscream', '4.0.4'
  # Pods for Energy-Active
  pod 'Socket.IO-Client-Swift', '16.0.1'
	
  # 明確指定 CocoaMQTT 版本
  pod 'CocoaMQTT', '2.1.6'

  target 'Energy-ActiveTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'Energy-ActiveUITests' do
    # Pods for testing
  end
end
