-- johann + wrms (lite)
--
-- version 0.1 @andrew
--
-- required: 
-- johann + wrms installed
-- midi keyboard

--external libs

tab = require 'tabutil'
cs = require 'controlspec'
mu = require 'musicutil'
pattern_time = require 'pattern_time'

--johann stuff

engine.name = "Johann"

params:add_separator('johann')

params:add{
    id = 'level', type = 'control',
    controlspec = cs.def{ min = 0, max = 15, default = 9 },
    action = function(v) engine.level(v) end,
}
params:add{
    id = 'rate', type = 'control',
    controlspec = cs.def{ 
        min = -2, max = 2, default = -0.12, quantum = 1/100/4,
    },
    action = function(v) engine.rate(2^v) end,
}

m = midi.connect()
m.event = function(data)
    local msg = midi.to_msg(data)
    if msg.type == "note_on" then
        
        -- args: midival, dynamic, variation, release
        engine.noteOn(msg.note-12, math.ceil((msg.vel/127)*7), 1, 0)
    elseif msg.type == "note_off" then
    end
end

--git submodule libs

nest = include 'lib/nest/core'
Key, Enc = include 'lib/nest/norns'
Text = include 'lib/nest/text'
Grid = include 'lib/nest/grid'

multipattern = include 'lib/nest/util/pattern-tools/multipattern'
of = include 'lib/nest/util/of'
to = include 'lib/nest/util/to'
PatternRecorder = include 'lib/nest/examples/grid/pattern_recorder'

cartographer, Slice = include 'lib/cartographer/cartographer'
crowify = include 'lib/crowify/lib/crowify' .new(0.01)

--script lib files

wrms = include 'wrms/lib/globals'      --saving, loading, values, etc
sc, reg = include 'wrms/lib/softcut'   --softcut utilities
wrms_gfx = include 'wrms/lib/graphics' --graphics & animations
include 'wrms/lib/params'              --create params
Wrms = include 'wrms/lib/ui'           --nest v2 UI components

pattern, mpat = {}, {}
for i = 1,5 do
    pattern[i] = pattern_time.new() 
    mpat[i] = multipattern.new(pattern[i])
end


--set up nest v2 UI

local App = {}

local _app = { norns = Wrms.lite() }
nest.connect_enc(_app.norns)
nest.connect_key(_app.norns)
nest.connect_screen(_app.norns, 24)

--init/cleanup

function init()
    -- send the engine a folder of samples, naming format is the same as mx.samples
    engine.loadfolder(_path.audio .. 'johann/classic')

    wrms.setup()

    params:read()

    wrms.load()

    params:bang()
end

function cleanup() 
    wrms.save()
    params:write()
end
