-- Monitor configuration
-- Laptop display
hl.monitor({
    output   = "desc:BOE 0x0D41",
    mode     = "preferred",
    -- position = "960x2160",
    position = "auto",
    scale    = 1,
})

-- Home monitor
hl.monitor({
    output   = "HDMI-A-1",
    mode     = "2560x1440@144",
    position = "auto-right",
    scale    = 1,
})

-- Office DELL monitor
hl.monitor({
    output   = "desc:Dell Inc. DELL S3221QS 2VKS6N3",
    mode     = "3840x2160@60",
    position = "0x0",
    scale    = 1,
})

-- Office Lenovo monitor
hl.monitor({
    output    = "desc:Lenovo Group Limited L24i-30 UPB4PTW9",
    mode      = "1920x1080@74.97",
    position  = "3840x0",
    scale     = 1,
    transform = 3,
})
