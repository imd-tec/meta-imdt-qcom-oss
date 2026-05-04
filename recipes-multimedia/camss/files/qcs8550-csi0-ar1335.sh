#!/bin/sh
media-ctl -d /dev/media0 -l "'ar1335 1-0036':0->'msm_csiphy0':0[1]"
media-ctl -d /dev/media0 -l '"msm_csiphy0":1->"msm_csid0":0[1],"msm_csid0":1->"msm_vfe0_rdi0":0[1]'

media-ctl -d /dev/media0 --set-v4l2 '"ar1335 1-0036":0[fmt:SGRBG10_1X10/4208x3120]'
media-ctl -d /dev/media0 --set-v4l2 '"msm_csiphy0":0[fmt:SGRBG10_1X10/4208x3120]'
media-ctl -d /dev/media0 --set-v4l2 '"msm_csiphy0":1[fmt:SGRBG10_1X10/4208x3120]'
media-ctl -d /dev/media0 --set-v4l2 '"msm_csid0":0[fmt:SGRBG10_1X10/4208x3120]'
media-ctl -d /dev/media0 --set-v4l2 '"msm_csid0":1[fmt:SGRBG10_1X10/4208x3120]'
media-ctl -d /dev/media0 --set-v4l2 '"msm_vfe0_rdi0":0[fmt:SGRBG10_1X10/4208x3120]'
media-ctl -d /dev/media0 --set-v4l2 '"msm_vfe0_rdi0":1[fmt:SGRBG10_1X10/4208x3120]'

echo "Pipeline created for CSI0"
# Sometimes the video device can come up as /dev/video0
# and othertimes it will come up as /dev/video2 so instead of hardcoding it,
# This awk pattern will find the name of the video device
VIDEO_DEV=$(media-ctl -d /dev/media0 -p 2>/dev/null | awk '
    /^- entity/      { is_video = 0; dev = "" }
    /type Node subtype V4L/ { is_video = 1 }
    /device node name \/dev\/video/ { dev = $NF }
    /<- "msm_vfe0_rdi0":1/ && is_video && dev != "" { print dev; exit }
')
DEVICE=${VIDEO_DEV#/dev/video}
echo "Video device: $VIDEO_DEV"

v4l2-ctl -d /dev/video${DEVICE} \
  --set-fmt-video=width=4208,height=3120,pixelformat=pgAA

echo "Video device: $VIDEO_DEV"
