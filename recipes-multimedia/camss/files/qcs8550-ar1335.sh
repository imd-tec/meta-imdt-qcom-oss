#!/bin/sh
# Set up every AR1335: csiphyN -> csidI -> vfeI_rdi0, I counting up from 0
MEDIA=/dev/media0

# Drop stale links, or a camera that probed late finds its CSID taken (EBUSY)
media-ctl -d $MEDIA -r 2>/dev/null

TOPO=$(media-ctl -d $MEDIA -p 2>/dev/null)

# One "<phy number> <link flags> <sensor>" line per AR1335, in CSI PHY order
SENSORS=$(echo "$TOPO" | awk '
    /^- entity [0-9]+: ar1335 / { s = $4 " " $5; next }
    /^- entity/ { s = "" }
    s != "" && /-> "msm_csiphy[0-9]+":0/ {
        match($0, /msm_csiphy[0-9]+/)
        n = substr($0, RSTART + 10, RLENGTH - 10)
        f = ($0 ~ /ENABLED/) ? "on" : "off"
        print n, f, s
        s = ""
    }' | sort -n)

FOUND=$(echo "$TOPO" | grep -c '^- entity [0-9]*: ar1335 ')
if [ "$FOUND" = 0 ]; then
    echo "No AR1335 found on $MEDIA"
    exit 0
fi

# CAMSS links no sensor while any applied camera overlay has none fitted
if [ -z "$SENSORS" ]; then
    echo "$FOUND AR1335 found but none linked to a CSI PHY:" \
        "is a camera overlay applied for an empty connector?"
    exit 1
fi

NCSID=$(echo "$TOPO" | grep -c '^- entity [0-9]*: msm_csid[0-9]* ')

RC=0
I=0
while read -r N LINK SENSOR; do
    if [ "$I" -ge "$NCSID" ]; then
        echo "Skipping $SENSOR on CSI$N: all $NCSID CSIDs are in use"
        RC=1
        continue
    fi

    PHY=msm_csiphy$N
    CSID=msm_csid$I
    RDI=msm_vfe${I}_rdi0

    # Ask for the full 13 MP mode, then use what the sensor accepted
    media-ctl -d $MEDIA --set-v4l2 "\"$SENSOR\":0[fmt:SGRBG10_1X10/4208x3120]" || RC=1
    FMT=$(media-ctl -d $MEDIA --get-v4l2 "\"$SENSOR\":0" | sed -n 's/.*fmt:\([^ ]*\).*/\1/p')
    SIZE=${FMT#*/}
    case ${FMT%/*} in
        SRGGB10_1X10) PIX=pRAA ;;
        SGRBG10_1X10) PIX=pgAA ;;
        SGBRG10_1X10) PIX=pGAA ;;
        SBGGR10_1X10) PIX=pBAA ;;
        *) echo "Skipping $SENSOR on CSI$N: unsupported format '$FMT'"; RC=1; I=$((I + 1)); continue ;;
    esac

    if [ "$LINK" = off ]; then
        media-ctl -d $MEDIA -l "\"$SENSOR\":0->\"$PHY\":0[1]" || RC=1
    fi
    media-ctl -d $MEDIA -l "\"$PHY\":1->\"$CSID\":0[1],\"$CSID\":1->\"$RDI\":0[1]" || RC=1

    for PAD in "\"$PHY\":0" "\"$PHY\":1" "\"$CSID\":0" "\"$CSID\":1" "\"$RDI\":0" "\"$RDI\":1"; do
        media-ctl -d $MEDIA --set-v4l2 "$PAD[fmt:$FMT]" || RC=1
    done

    VIDEO_DEV=$(media-ctl -d $MEDIA -e msm_vfe${I}_video0)
    v4l2-ctl -d "$VIDEO_DEV" \
        --set-fmt-video=width=${SIZE%x*},height=${SIZE#*x},pixelformat=$PIX || RC=1

    echo "Pipeline created for $SENSOR on CSI$N ($CSID): $VIDEO_DEV"
    I=$((I + 1))
done <<EOF
$SENSORS
EOF

exit $RC
