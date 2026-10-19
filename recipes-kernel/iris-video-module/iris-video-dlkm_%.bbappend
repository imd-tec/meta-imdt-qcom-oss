# imdt-8550-sbc: blacklist the downstream iris_vpu and load qcom-iris, as on
# shikra. The downstream driver never binds with the mainline DT, and with no
# video driver loaded the cDSP never answers glink, so /dev/fastrpc-cdsp is
# never created and the HTP cannot be used.
ALTERNATIVE_PRIORITY_${PN}-bl-vidc:imdt-8550-sbc = "150"

# The priority is not in the packaging signature, so a cached package keeps
# the old priority. Bump PR so the change is repackaged.
PR:append:imdt-8550-sbc = ".imdt1"
