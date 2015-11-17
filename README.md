##openSUSE Leap 42.1 liveCD 定制版

----------------------------------------
官方没有为 Leap 提供 liveCD ,大家可以以此为模版自己制作。默认的模版已经包括了完整的中文翻译（包括繁体），可以直接使用 KIWI 工具制作。模版已经默认将安装源替换为了国内较快的中科大镜像。

###模版
livecd-gnome:GNOME 桌面环境的模版。附加 gnome-builder IDE 开发工具、VLC 播放器、Gstreamer 解码器、Rhythmbox 音频播放器、Adobe Flash Player 插件、支付宝控件、openshot 视频处理软件。

livecd-kde:GNOME 桌面环境的模版。附加 qt-creator IDE 开发工具、kdevelop IDE 开发工具、VLC 播放器、Gstreamer 解码器、Adobe Flash Player 插件、支付宝控件、openshot 视频处理软件。

livecd-mate:GNOME 桌面环境的模版。附加 VLC 播放器、Gstreamer 解码器、Rhythmbox 音频播放器、Adobe Flash Player 插件、支付宝控件、openshot 视频处理软件。

###制作方法
sudo zypper in kiwi kiwi-desc-isoboot kiwi-desc-oemboot kiwi-desc-netboot
su
export 'KIWI_IGNORE_OLD_MOUNTS=yes'
kiwi --createhash livecd-gnome      #如果没有修改模版可以跳过这一步
kiwi --build livecd-gnome -d gnome

构建完成后会在 gnome 目录下生成一个 ISO 镜像。
