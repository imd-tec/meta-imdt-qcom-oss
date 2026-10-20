#!/bin/sh
# Set up the carrier CSI2 AR1335 pipeline: csiphy1 -> csid0 -> vfe0_rdi0
MEDIA=/dev/media0
FMT=SGRBG10_1X10/4208x3120

# The CCI bus number depends on which CCI controllers are enabled
SENSOR=$(media-ctl -d $MEDIA -p 2>/dev/null | sed -n 's/^- entity [0-9]*: \(ar1335 [0-9]*-0036\) .*/\1/p' | head -n 1)
if [ -z "$SENSOR" ]; then
    echo "No AR1335 found on $MEDIA"
    exit 0
fi

media-ctl -d $MEDIA -l '"msm_csiphy1":1->"msm_csid0":0[1],"msm_csid0":1->"msm_vfe0_rdi0":0[1]'

media-ctl -d $MEDIA --set-v4l2 "\"$SENSOR\":0[fmt:$FMT]"
media-ctl -d $MEDIA --set-v4l2 "\"msm_csiphy1\":0[fmt:$FMT]"
media-ctl -d $MEDIA --set-v4l2 "\"msm_csid0\":0[fmt:$FMT]"
media-ctl -d $MEDIA --set-v4l2 "\"msm_vfe0_rdi0\":0[fmt:$FMT]"

echo "Pipeline created for CSI2 ($SENSOR)"

VIDEO_DEV=$(media-ctl -d $MEDIA -e msm_vfe0_video0)
echo "Video device: $VIDEO_DEV"

v4l2-ctl -d "$VIDEO_DEV" --set-fmt-video=width=4208,height=3120,pixelformat=pgAA
